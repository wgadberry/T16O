using System.Text.Json.Serialization;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Request to write party records for a transaction signature.
/// Fire-and-forget pattern - creates party records if they don't exist.
/// </summary>
public class WritePartyRequest
{
    /// <summary>
    /// Transaction signature (base58 encoded, 88 characters)
    /// </summary>
    [JsonPropertyName("signature")]
    public string Signature { get; set; } = string.Empty;

    /// <summary>
    /// Priority level for message processing
    /// 10 = realtime, 5 = normal, 1 = batch
    /// </summary>
    [JsonPropertyName("priority")]
    public byte Priority { get; set; } = 1;
}
