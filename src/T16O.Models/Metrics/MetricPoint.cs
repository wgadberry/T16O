using InfluxDB.Client.Core;

namespace T16O.Models.Metrics;

/// <summary>
/// Base metric point with common fields for all measurements
/// </summary>
public abstract class MetricPoint
{
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public string Host { get; set; } = Environment.MachineName;
}

/// <summary>
/// Worker-level metrics for tracking queue processing performance
/// </summary>
[Measurement("worker_metrics")]
public class WorkerMetric : MetricPoint
{
    [Column("worker_name", IsTag = true)]
    public string WorkerName { get; set; } = string.Empty;

    [Column("queue_name", IsTag = true)]
    public string QueueName { get; set; } = string.Empty;

    [Column("status", IsTag = true)]
    public string Status { get; set; } = "success"; // success, error, timeout

    [Column("messages_processed")]
    public long MessagesProcessed { get; set; }

    [Column("processing_time_ms")]
    public double ProcessingTimeMs { get; set; }

    [Column("queue_depth")]
    public long QueueDepth { get; set; }

    [Column("error_count")]
    public long ErrorCount { get; set; }

    [Column("retry_count")]
    public long RetryCount { get; set; }
}

/// <summary>
/// Stage-level metrics for tracking individual processing stages within a worker
/// </summary>
[Measurement("stage_metrics")]
public class StageMetric : MetricPoint
{
    [Column("worker_name", IsTag = true)]
    public string WorkerName { get; set; } = string.Empty;

    [Column("stage_name", IsTag = true)]
    public string StageName { get; set; } = string.Empty;

    [Column("status", IsTag = true)]
    public string Status { get; set; } = "success";

    [Column("duration_ms")]
    public double DurationMs { get; set; }

    [Column("items_processed")]
    public long ItemsProcessed { get; set; }

    [Column("bytes_processed")]
    public long BytesProcessed { get; set; }
}

/// <summary>
/// RPC call metrics for tracking Solana RPC performance
/// </summary>
[Measurement("rpc_metrics")]
public class RpcMetric : MetricPoint
{
    [Column("endpoint", IsTag = true)]
    public string Endpoint { get; set; } = string.Empty;

    [Column("method", IsTag = true)]
    public string Method { get; set; } = string.Empty;

    [Column("status", IsTag = true)]
    public string Status { get; set; } = "success";

    [Column("duration_ms")]
    public double DurationMs { get; set; }

    [Column("response_size_bytes")]
    public long ResponseSizeBytes { get; set; }

    [Column("rate_limited")]
    public bool RateLimited { get; set; }
}

/// <summary>
/// Database operation metrics
/// </summary>
[Measurement("db_metrics")]
public class DbMetric : MetricPoint
{
    [Column("operation", IsTag = true)]
    public string Operation { get; set; } = string.Empty; // insert, update, select, procedure

    [Column("table_name", IsTag = true)]
    public string TableName { get; set; } = string.Empty;

    [Column("status", IsTag = true)]
    public string Status { get; set; } = "success";

    [Column("duration_ms")]
    public double DurationMs { get; set; }

    [Column("rows_affected")]
    public long RowsAffected { get; set; }
}

/// <summary>
/// System-level metrics snapshot
/// </summary>
[Measurement("system_metrics")]
public class SystemMetric : MetricPoint
{
    [Column("component", IsTag = true)]
    public string Component { get; set; } = string.Empty; // rabbitmq, mysql, worker

    [Column("active_connections")]
    public long ActiveConnections { get; set; }

    [Column("memory_mb")]
    public double MemoryMb { get; set; }

    [Column("cpu_percent")]
    public double CpuPercent { get; set; }

    [Column("thread_count")]
    public int ThreadCount { get; set; }
}

/// <summary>
/// Config snapshot for tracking configuration changes
/// </summary>
[Measurement("config_snapshot")]
public class ConfigSnapshot : MetricPoint
{
    [Column("config_type", IsTag = true)]
    public string ConfigType { get; set; } = string.Empty;

    [Column("config_key", IsTag = true)]
    public string ConfigKey { get; set; } = string.Empty;

    [Column("config_value")]
    public string ConfigValue { get; set; } = string.Empty;

    [Column("event", IsTag = true)]
    public string Event { get; set; } = "startup"; // startup, change
}
