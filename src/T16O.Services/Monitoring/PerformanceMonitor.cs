using System.Collections.Concurrent;
using System.Diagnostics;
using InfluxDB.Client;
using InfluxDB.Client.Api.Domain;
using InfluxDB.Client.Writes;
using Microsoft.Extensions.Logging;
using T16O.Models.Metrics;

namespace T16O.Services.Monitoring;

public class PerformanceMonitorOptions
{
    public string Url { get; set; } = "http://localhost:8086";
    public string Token { get; set; } = "t16o-metrics-token";
    public string Org { get; set; } = "t16o";
    public string Bucket { get; set; } = "metrics";
    public int FlushIntervalMs { get; set; } = 5000;
    public int BatchSize { get; set; } = 100;
    public bool Enabled { get; set; } = true;
}

public class PerformanceMonitor : IDisposable
{
    private readonly PerformanceMonitorOptions _options;
    private readonly ILogger<PerformanceMonitor>? _logger;
    private readonly InfluxDBClient? _client;
    private readonly WriteApiAsync? _writeApi;
    private readonly ConcurrentQueue<PointData> _buffer;
    private readonly Timer? _flushTimer;
    private readonly string _host;
    private bool _disposed;

    public PerformanceMonitor(PerformanceMonitorOptions options, ILogger<PerformanceMonitor>? logger = null)
    {
        _options = options;
        _logger = logger;
        _buffer = new ConcurrentQueue<PointData>();
        _host = Environment.MachineName;

        if (!_options.Enabled)
        {
            _logger?.LogInformation("PerformanceMonitor disabled");
            return;
        }

        try
        {
            _client = new InfluxDBClient(_options.Url, _options.Token);
            _writeApi = _client.GetWriteApiAsync();
            _flushTimer = new Timer(FlushBuffer, null, _options.FlushIntervalMs, _options.FlushIntervalMs);
            _logger?.LogInformation("PerformanceMonitor initialized: {Url}", _options.Url);
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to initialize PerformanceMonitor");
        }
    }

    #region Worker Metrics

    public IDisposable TrackWorker(string workerName, string queueName)
    {
        return new WorkerTracker(this, workerName, queueName);
    }

    public void RecordWorkerMetric(WorkerMetric metric)
    {
        if (!_options.Enabled) return;

        var point = PointData.Measurement("worker_metrics")
            .Tag("worker_name", metric.WorkerName)
            .Tag("queue_name", metric.QueueName)
            .Tag("status", metric.Status)
            .Tag("host", _host)
            .Field("messages_processed", metric.MessagesProcessed)
            .Field("processing_time_ms", metric.ProcessingTimeMs)
            .Field("queue_depth", metric.QueueDepth)
            .Field("error_count", metric.ErrorCount)
            .Field("retry_count", metric.RetryCount)
            .Timestamp(DateTime.UtcNow, WritePrecision.Ms);

        EnqueuePoint(point);
    }

    #endregion

    #region Stage Metrics

    public IDisposable TrackStage(string workerName, string stageName)
    {
        return new StageTracker(this, workerName, stageName);
    }

    public void RecordStageMetric(StageMetric metric)
    {
        if (!_options.Enabled) return;

        var point = PointData.Measurement("stage_metrics")
            .Tag("worker_name", metric.WorkerName)
            .Tag("stage_name", metric.StageName)
            .Tag("status", metric.Status)
            .Tag("host", _host)
            .Field("duration_ms", metric.DurationMs)
            .Field("items_processed", metric.ItemsProcessed)
            .Field("bytes_processed", metric.BytesProcessed)
            .Timestamp(DateTime.UtcNow, WritePrecision.Ms);

        EnqueuePoint(point);
    }

    #endregion

    #region RPC Metrics

    public IDisposable TrackRpc(string endpoint, string method)
    {
        return new RpcTracker(this, endpoint, method);
    }

    public void RecordRpcMetric(RpcMetric metric)
    {
        if (!_options.Enabled) return;

        var point = PointData.Measurement("rpc_metrics")
            .Tag("endpoint", metric.Endpoint)
            .Tag("method", metric.Method)
            .Tag("status", metric.Status)
            .Tag("host", _host)
            .Field("duration_ms", metric.DurationMs)
            .Field("response_size_bytes", metric.ResponseSizeBytes)
            .Field("rate_limited", metric.RateLimited)
            .Timestamp(DateTime.UtcNow, WritePrecision.Ms);

        EnqueuePoint(point);
    }

    #endregion

    #region DB Metrics

    public IDisposable TrackDb(string operation, string tableName)
    {
        return new DbTracker(this, operation, tableName);
    }

    public void RecordDbMetric(DbMetric metric)
    {
        if (!_options.Enabled) return;

        var point = PointData.Measurement("db_metrics")
            .Tag("operation", metric.Operation)
            .Tag("table_name", metric.TableName)
            .Tag("status", metric.Status)
            .Tag("host", _host)
            .Field("duration_ms", metric.DurationMs)
            .Field("rows_affected", metric.RowsAffected)
            .Timestamp(DateTime.UtcNow, WritePrecision.Ms);

        EnqueuePoint(point);
    }

    #endregion

    #region System Metrics

    public void RecordSystemMetric(SystemMetric metric)
    {
        if (!_options.Enabled) return;

        var point = PointData.Measurement("system_metrics")
            .Tag("component", metric.Component)
            .Tag("host", _host)
            .Field("active_connections", metric.ActiveConnections)
            .Field("memory_mb", metric.MemoryMb)
            .Field("cpu_percent", metric.CpuPercent)
            .Field("thread_count", metric.ThreadCount)
            .Timestamp(DateTime.UtcNow, WritePrecision.Ms);

        EnqueuePoint(point);
    }

    #endregion

    #region Config Snapshot

    public void RecordConfigSnapshot(string configType, string configKey, string configValue, string eventType = "startup")
    {
        if (!_options.Enabled) return;

        var point = PointData.Measurement("config_snapshot")
            .Tag("config_type", configType)
            .Tag("config_key", configKey)
            .Tag("event", eventType)
            .Tag("host", _host)
            .Field("config_value", configValue)
            .Timestamp(DateTime.UtcNow, WritePrecision.Ms);

        EnqueuePoint(point);
    }

    public void RecordConfigSnapshot(Dictionary<string, Dictionary<string, string>> config, string eventType = "startup")
    {
        foreach (var section in config)
        {
            foreach (var kvp in section.Value)
            {
                RecordConfigSnapshot(section.Key, kvp.Key, kvp.Value, eventType);
            }
        }
    }

    #endregion

    #region Buffer Management

    private void EnqueuePoint(PointData point)
    {
        _buffer.Enqueue(point);

        if (_buffer.Count >= _options.BatchSize)
        {
            _ = FlushAsync();
        }
    }

    private void FlushBuffer(object? state)
    {
        _ = FlushAsync();
    }

    public async Task FlushAsync()
    {
        if (!_options.Enabled || _writeApi == null || _buffer.IsEmpty) return;

        var points = new List<PointData>();
        while (_buffer.TryDequeue(out var point) && points.Count < _options.BatchSize * 2)
        {
            points.Add(point);
        }

        if (points.Count == 0) return;

        try
        {
            await _writeApi.WritePointsAsync(points, _options.Bucket, _options.Org);
            _logger?.LogDebug("Flushed {Count} metrics to InfluxDB", points.Count);
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to flush metrics to InfluxDB");
            // Re-enqueue failed points (up to batch size to prevent infinite growth)
            foreach (var point in points.Take(_options.BatchSize))
            {
                _buffer.Enqueue(point);
            }
        }
    }

    #endregion

    #region Trackers

    private class WorkerTracker : IDisposable
    {
        private readonly PerformanceMonitor _monitor;
        private readonly string _workerName;
        private readonly string _queueName;
        private readonly Stopwatch _stopwatch;
        private string _status = "success";
        private long _messagesProcessed;
        private long _errorCount;

        public WorkerTracker(PerformanceMonitor monitor, string workerName, string queueName)
        {
            _monitor = monitor;
            _workerName = workerName;
            _queueName = queueName;
            _stopwatch = Stopwatch.StartNew();
        }

        public void SetStatus(string status) => _status = status;
        public void IncrementMessages(long count = 1) => Interlocked.Add(ref _messagesProcessed, count);
        public void IncrementErrors(long count = 1) => Interlocked.Add(ref _errorCount, count);

        public void Dispose()
        {
            _stopwatch.Stop();
            _monitor.RecordWorkerMetric(new WorkerMetric
            {
                WorkerName = _workerName,
                QueueName = _queueName,
                Status = _status,
                MessagesProcessed = _messagesProcessed,
                ProcessingTimeMs = _stopwatch.Elapsed.TotalMilliseconds,
                ErrorCount = _errorCount
            });
        }
    }

    private class StageTracker : IDisposable
    {
        private readonly PerformanceMonitor _monitor;
        private readonly string _workerName;
        private readonly string _stageName;
        private readonly Stopwatch _stopwatch;
        private string _status = "success";
        private long _itemsProcessed;
        private long _bytesProcessed;

        public StageTracker(PerformanceMonitor monitor, string workerName, string stageName)
        {
            _monitor = monitor;
            _workerName = workerName;
            _stageName = stageName;
            _stopwatch = Stopwatch.StartNew();
        }

        public void SetStatus(string status) => _status = status;
        public void SetItemsProcessed(long count) => _itemsProcessed = count;
        public void SetBytesProcessed(long bytes) => _bytesProcessed = bytes;

        public void Dispose()
        {
            _stopwatch.Stop();
            _monitor.RecordStageMetric(new StageMetric
            {
                WorkerName = _workerName,
                StageName = _stageName,
                Status = _status,
                DurationMs = _stopwatch.Elapsed.TotalMilliseconds,
                ItemsProcessed = _itemsProcessed,
                BytesProcessed = _bytesProcessed
            });
        }
    }

    private class RpcTracker : IDisposable
    {
        private readonly PerformanceMonitor _monitor;
        private readonly string _endpoint;
        private readonly string _method;
        private readonly Stopwatch _stopwatch;
        private string _status = "success";
        private long _responseSize;
        private bool _rateLimited;

        public RpcTracker(PerformanceMonitor monitor, string endpoint, string method)
        {
            _monitor = monitor;
            _endpoint = endpoint;
            _method = method;
            _stopwatch = Stopwatch.StartNew();
        }

        public void SetStatus(string status) => _status = status;
        public void SetResponseSize(long bytes) => _responseSize = bytes;
        public void SetRateLimited(bool limited) => _rateLimited = limited;

        public void Dispose()
        {
            _stopwatch.Stop();
            _monitor.RecordRpcMetric(new RpcMetric
            {
                Endpoint = _endpoint,
                Method = _method,
                Status = _status,
                DurationMs = _stopwatch.Elapsed.TotalMilliseconds,
                ResponseSizeBytes = _responseSize,
                RateLimited = _rateLimited
            });
        }
    }

    private class DbTracker : IDisposable
    {
        private readonly PerformanceMonitor _monitor;
        private readonly string _operation;
        private readonly string _tableName;
        private readonly Stopwatch _stopwatch;
        private string _status = "success";
        private long _rowsAffected;

        public DbTracker(PerformanceMonitor monitor, string operation, string tableName)
        {
            _monitor = monitor;
            _operation = operation;
            _tableName = tableName;
            _stopwatch = Stopwatch.StartNew();
        }

        public void SetStatus(string status) => _status = status;
        public void SetRowsAffected(long rows) => _rowsAffected = rows;

        public void Dispose()
        {
            _stopwatch.Stop();
            _monitor.RecordDbMetric(new DbMetric
            {
                Operation = _operation,
                TableName = _tableName,
                Status = _status,
                DurationMs = _stopwatch.Elapsed.TotalMilliseconds,
                RowsAffected = _rowsAffected
            });
        }
    }

    #endregion

    public void Dispose()
    {
        if (_disposed) return;
        _disposed = true;

        _flushTimer?.Dispose();
        FlushAsync().GetAwaiter().GetResult();
        _client?.Dispose();
    }
}
