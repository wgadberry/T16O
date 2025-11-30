using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using RabbitMQ.Client;
using T16O.Services.Configuration;

namespace T16O.Services.RabbitMQ;

/// <summary>
/// Internal helper for creating and configuring RabbitMQ connections
/// </summary>
internal static class RabbitMqConnection
{
    /// <summary>
    /// Create a configurable channel with dynamic prefetch support
    /// </summary>
    /// <param name="connection">RabbitMQ connection</param>
    /// <param name="queueName">Queue name for config lookup</param>
    /// <param name="configService">Configuration service</param>
    /// <param name="defaultPrefetch">Default prefetch if not configured</param>
    internal static async Task<ConfigurableChannel> CreateConfigurableChannelAsync(
        IConnection connection,
        string queueName,
        ConfigurationService configService,
        ushort defaultPrefetch = 10,
        CancellationToken ct = default)
    {
        var channel = connection.CreateModel();
        var configurableChannel = new ConfigurableChannel(channel, queueName, configService, defaultPrefetch);
        await configurableChannel.InitializeAsync(ct);
        return configurableChannel;
    }

    /// <summary>
    /// Create a configured RabbitMQ connection
    /// </summary>
    internal static IConnection CreateConnection(RabbitMqConfig config)
    {
        var factory = new ConnectionFactory
        {
            HostName = config.Host,
            Port = config.Port,
            UserName = config.Username,
            Password = config.Password,
            VirtualHost = config.VirtualHost,
            AutomaticRecoveryEnabled = true,
            NetworkRecoveryInterval = TimeSpan.FromSeconds(10)
        };

        return factory.CreateConnection();
    }

    /// <summary>
    /// Set prefetch count to limit how many messages RabbitMQ delivers at once.
    /// CRITICAL: Without this, RabbitMQ delivers ALL queued messages, causing rate limit issues.
    /// </summary>
    /// <param name="channel">The channel to configure</param>
    /// <param name="prefetchCount">Number of messages to prefetch (default: 1 for serial processing)</param>
    internal static void SetPrefetchCount(IModel channel, ushort prefetchCount = 1)
    {
        channel.BasicQos(prefetchSize: 0, prefetchCount: prefetchCount, global: false);
    }

    /// <summary>
    /// Setup RPC exchanges and queues (for synchronous request-reply)
    /// </summary>
    internal static void SetupRpcInfrastructure(IModel channel, RabbitMqConfig config)
    {
        // Declare RPC topic exchange
        channel.ExchangeDeclare(
            exchange: config.RpcExchange,
            type: ExchangeType.Topic,
            durable: true,
            autoDelete: false);

        // Declare RPC queues with priority support
        var rpcQueues = new[]
        {
            RabbitMqConfig.RpcQueues.TxFetch,
            RabbitMqConfig.RpcQueues.TxFetchSite,
            RabbitMqConfig.RpcQueues.TxFetchDb,
            RabbitMqConfig.RpcQueues.TxFetchRpc,
            RabbitMqConfig.RpcQueues.TxFetchRpcSite,
            RabbitMqConfig.RpcQueues.MintFetch,
            RabbitMqConfig.RpcQueues.MintFetchDb,
            RabbitMqConfig.RpcQueues.MintFetchRpc,
            RabbitMqConfig.RpcQueues.OwnerFetchBatch
        };

        var rpcBindings = new Dictionary<string, string>
        {
            { RabbitMqConfig.RpcQueues.TxFetch, RabbitMqConfig.RoutingKeys.TxFetch },
            { RabbitMqConfig.RpcQueues.TxFetchSite, RabbitMqConfig.RoutingKeys.TxFetchSite },
            { RabbitMqConfig.RpcQueues.TxFetchDb, RabbitMqConfig.RoutingKeys.TxFetchDb },
            { RabbitMqConfig.RpcQueues.TxFetchRpc, RabbitMqConfig.RoutingKeys.TxFetchRpc },
            { RabbitMqConfig.RpcQueues.TxFetchRpcSite, RabbitMqConfig.RoutingKeys.TxFetchRpcSite },
            { RabbitMqConfig.RpcQueues.MintFetch, RabbitMqConfig.RoutingKeys.MintFetch },
            { RabbitMqConfig.RpcQueues.MintFetchDb, RabbitMqConfig.RoutingKeys.MintFetchDb },
            { RabbitMqConfig.RpcQueues.MintFetchRpc, RabbitMqConfig.RoutingKeys.MintFetchRpc },
            { RabbitMqConfig.RpcQueues.OwnerFetchBatch, RabbitMqConfig.RoutingKeys.OwnerFetchBatch }
        };

        foreach (var queue in rpcQueues)
        {
            var args = new Dictionary<string, object>
            {
                { "x-max-priority", 10 }
            };

            channel.QueueDeclare(
                queue: queue,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: args);

            // Bind queue to exchange with routing key
            if (rpcBindings.TryGetValue(queue, out var routingKey))
            {
                channel.QueueBind(
                    queue: queue,
                    exchange: config.RpcExchange,
                    routingKey: routingKey);
            }
        }
    }

    /// <summary>
    /// Setup task exchanges and queues (for asynchronous processing)
    /// </summary>
    internal static void SetupTaskInfrastructure(IModel channel, RabbitMqConfig config)
    {
        // Declare task topic exchange
        channel.ExchangeDeclare(
            exchange: config.TaskExchange,
            type: ExchangeType.Topic,
            durable: true,
            autoDelete: false);

        // Declare task queues with priority support
        var taskQueues = new[]
        {
            RabbitMqConfig.TaskQueues.TxWrite,
            RabbitMqConfig.TaskQueues.PartyWrite
        };

        var taskBindings = new Dictionary<string, string>
        {
            { RabbitMqConfig.TaskQueues.TxWrite, RabbitMqConfig.RoutingKeys.TxWrite },
            { RabbitMqConfig.TaskQueues.PartyWrite, RabbitMqConfig.RoutingKeys.PartyWrite }
        };

        foreach (var queue in taskQueues)
        {
            var args = new Dictionary<string, object>
            {
                { "x-max-priority", 10 }
            };

            channel.QueueDeclare(
                queue: queue,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: args);

            // Bind queue to exchange with routing key
            if (taskBindings.TryGetValue(queue, out var routingKey))
            {
                channel.QueueBind(
                    queue: queue,
                    exchange: config.TaskExchange,
                    routingKey: routingKey);
            }
        }
    }
}
