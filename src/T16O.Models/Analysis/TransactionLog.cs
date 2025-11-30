namespace T16O.Models.Analysis;

/// <summary>
/// Represents a log message from transaction execution
/// </summary>
public class TransactionLog
{
    /// <summary>
    /// Database primary key
    /// </summary>
    public long Id { get; set; }

    /// <summary>
    /// Transaction signature
    /// </summary>
    public required string Signature { get; set; }

    /// <summary>
    /// Index of this log message
    /// </summary>
    public int LogIndex { get; set; }

    /// <summary>
    /// Log message text
    /// </summary>
    public required string Message { get; set; }
}
