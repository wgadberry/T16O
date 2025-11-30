using System;
using System.Threading;
using System.Threading.Tasks;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace T16O.Services.Configuration;

/// <summary>
/// Wrapper around RabbitMQ IModel that supports dynamic prefetch count updates.
/// Subscribes to configuration changes and applies them in real-time.
/// </summary>
public class ConfigurableChannel : IDisposable
{
    private readonly IModel _channel;
    private readonly string _queueName;
    private readonly ConfigurationService _configService;
    private ushort _currentPrefetch;
    private bool _disposed;

    /// <summary>
    /// The underlying RabbitMQ channel
    /// </summary>
    public IModel Channel => _channel;

    /// <summary>
    /// Current prefetch count
    /// </summary>
    public ushort CurrentPrefetch => _currentPrefetch;

    /// <summary>
    /// Event raised when prefetch count changes
    /// </summary>
    public event EventHandler<PrefetchChangedEventArgs>? PrefetchChanged;

    /// <summary>
    /// Create a configurable channel wrapper
    /// </summary>
    /// <param name="channel">The RabbitMQ channel</param>
    /// <param name="queueName">Queue name for config lookup</param>
    /// <param name="configService">Configuration service for dynamic updates</param>
    /// <param name="initialPrefetch">Initial prefetch count (before config is loaded)</param>
    public ConfigurableChannel(
        IModel channel,
        string queueName,
        ConfigurationService configService,
        ushort initialPrefetch = 10)
    {
        _channel = channel ?? throw new ArgumentNullException(nameof(channel));
        _queueName = queueName ?? throw new ArgumentNullException(nameof(queueName));
        _configService = configService ?? throw new ArgumentNullException(nameof(configService));
        _currentPrefetch = initialPrefetch;

        // Set initial prefetch
        _channel.BasicQos(prefetchSize: 0, prefetchCount: _currentPrefetch, global: false);

        // Subscribe to config changes
        _configService.ConfigChanged += OnConfigChanged;
    }

    /// <summary>
    /// Initialize prefetch from configuration
    /// </summary>
    public async Task InitializeAsync(CancellationToken ct = default)
    {
        var prefetch = await _configService.GetPrefetchCountAsync(_queueName, _currentPrefetch, ct);
        if (prefetch != _currentPrefetch)
        {
            SetPrefetch(prefetch);
        }
    }

    /// <summary>
    /// Set prefetch count on the channel
    /// </summary>
    public void SetPrefetch(ushort prefetchCount)
    {
        if (prefetchCount == _currentPrefetch)
            return;

        var oldPrefetch = _currentPrefetch;
        _currentPrefetch = prefetchCount;

        try
        {
            _channel.BasicQos(prefetchSize: 0, prefetchCount: _currentPrefetch, global: false);
            Console.WriteLine($"[ConfigurableChannel] {_queueName}: Prefetch updated {oldPrefetch} -> {_currentPrefetch}");
            OnPrefetchChanged(new PrefetchChangedEventArgs(_queueName, oldPrefetch, _currentPrefetch));
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[ConfigurableChannel] {_queueName}: Failed to update prefetch: {ex.Message}");
            _currentPrefetch = oldPrefetch; // Revert
        }
    }

    /// <summary>
    /// Handle configuration changes
    /// </summary>
    private void OnConfigChanged(object? sender, ConfigChangedEventArgs e)
    {
        // Only handle prefetch changes for our queue
        if (e.ConfigType != "worker.prefetch" || e.ConfigKey != _queueName)
            return;

        if (ushort.TryParse(e.NewValue, out var newPrefetch))
        {
            SetPrefetch(newPrefetch);
        }
    }

    /// <summary>
    /// Raise the PrefetchChanged event
    /// </summary>
    protected virtual void OnPrefetchChanged(PrefetchChangedEventArgs e)
    {
        PrefetchChanged?.Invoke(this, e);
    }

    public void Dispose()
    {
        if (_disposed) return;
        _configService.ConfigChanged -= OnConfigChanged;
        _disposed = true;
    }
}

/// <summary>
/// Event args for prefetch changes
/// </summary>
public class PrefetchChangedEventArgs : EventArgs
{
    public string QueueName { get; }
    public ushort OldPrefetch { get; }
    public ushort NewPrefetch { get; }

    public PrefetchChangedEventArgs(string queueName, ushort oldPrefetch, ushort newPrefetch)
    {
        QueueName = queueName;
        OldPrefetch = oldPrefetch;
        NewPrefetch = newPrefetch;
    }
}
