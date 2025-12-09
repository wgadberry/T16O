using System.Text.Json;
using System.Text.Json.Serialization;

namespace T16O.Solscan.Json;

/// <summary>
/// JSON converter that handles decimal values returned as strings from APIs.
/// </summary>
public class StringToDecimalConverter : JsonConverter<decimal?>
{
    public override decimal? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        switch (reader.TokenType)
        {
            case JsonTokenType.Number:
                return reader.GetDecimal();
            case JsonTokenType.String:
                var stringValue = reader.GetString();
                if (string.IsNullOrEmpty(stringValue))
                    return null;
                if (decimal.TryParse(stringValue, out var result))
                    return result;
                return null;
            case JsonTokenType.Null:
                return null;
            default:
                return null;
        }
    }

    public override void Write(Utf8JsonWriter writer, decimal? value, JsonSerializerOptions options)
    {
        if (value.HasValue)
            writer.WriteNumberValue(value.Value);
        else
            writer.WriteNullValue();
    }
}

/// <summary>
/// JSON converter that handles non-nullable decimal values returned as strings.
/// </summary>
public class StringToDecimalNonNullableConverter : JsonConverter<decimal>
{
    public override decimal Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        switch (reader.TokenType)
        {
            case JsonTokenType.Number:
                return reader.GetDecimal();
            case JsonTokenType.String:
                var stringValue = reader.GetString();
                if (decimal.TryParse(stringValue, out var result))
                    return result;
                return 0m;
            case JsonTokenType.Null:
                return 0m;
            default:
                return 0m;
        }
    }

    public override void Write(Utf8JsonWriter writer, decimal value, JsonSerializerOptions options)
    {
        writer.WriteNumberValue(value);
    }
}

/// <summary>
/// JSON converter that handles long values returned as strings from APIs.
/// </summary>
public class StringToLongConverter : JsonConverter<long>
{
    public override long Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        switch (reader.TokenType)
        {
            case JsonTokenType.Number:
                return reader.GetInt64();
            case JsonTokenType.String:
                var stringValue = reader.GetString();
                if (long.TryParse(stringValue, out var result))
                    return result;
                return 0L;
            case JsonTokenType.Null:
                return 0L;
            default:
                return 0L;
        }
    }

    public override void Write(Utf8JsonWriter writer, long value, JsonSerializerOptions options)
    {
        writer.WriteNumberValue(value);
    }
}

/// <summary>
/// JSON converter that handles nullable long values returned as strings from APIs.
/// </summary>
public class StringToNullableLongConverter : JsonConverter<long?>
{
    public override long? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        switch (reader.TokenType)
        {
            case JsonTokenType.Number:
                return reader.GetInt64();
            case JsonTokenType.String:
                var stringValue = reader.GetString();
                if (string.IsNullOrEmpty(stringValue))
                    return null;
                if (long.TryParse(stringValue, out var result))
                    return result;
                return null;
            case JsonTokenType.Null:
                return null;
            default:
                return null;
        }
    }

    public override void Write(Utf8JsonWriter writer, long? value, JsonSerializerOptions options)
    {
        if (value.HasValue)
            writer.WriteNumberValue(value.Value);
        else
            writer.WriteNullValue();
    }
}

/// <summary>
/// JSON converter that handles int values returned as strings from APIs.
/// </summary>
public class StringToIntConverter : JsonConverter<int>
{
    public override int Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        switch (reader.TokenType)
        {
            case JsonTokenType.Number:
                return reader.GetInt32();
            case JsonTokenType.String:
                var stringValue = reader.GetString();
                if (int.TryParse(stringValue, out var result))
                    return result;
                return 0;
            case JsonTokenType.Null:
                return 0;
            default:
                return 0;
        }
    }

    public override void Write(Utf8JsonWriter writer, int value, JsonSerializerOptions options)
    {
        writer.WriteNumberValue(value);
    }
}

/// <summary>
/// JSON converter that handles nullable int values returned as strings from APIs.
/// </summary>
public class StringToNullableIntConverter : JsonConverter<int?>
{
    public override int? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        switch (reader.TokenType)
        {
            case JsonTokenType.Number:
                return reader.GetInt32();
            case JsonTokenType.String:
                var stringValue = reader.GetString();
                if (string.IsNullOrEmpty(stringValue))
                    return null;
                if (int.TryParse(stringValue, out var result))
                    return result;
                return null;
            case JsonTokenType.Null:
                return null;
            default:
                return null;
        }
    }

    public override void Write(Utf8JsonWriter writer, int? value, JsonSerializerOptions options)
    {
        if (value.HasValue)
            writer.WriteNumberValue(value.Value);
        else
            writer.WriteNullValue();
    }
}

/// <summary>
/// JSON converter that handles strings that might be returned as numbers from APIs.
/// </summary>
public class FlexibleStringConverter : JsonConverter<string?>
{
    public override string? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        switch (reader.TokenType)
        {
            case JsonTokenType.String:
                return reader.GetString();
            case JsonTokenType.Number:
                if (reader.TryGetInt64(out var longVal))
                    return longVal.ToString();
                if (reader.TryGetDouble(out var doubleVal))
                    return doubleVal.ToString();
                return null;
            case JsonTokenType.True:
                return "true";
            case JsonTokenType.False:
                return "false";
            case JsonTokenType.Null:
                return null;
            default:
                return null;
        }
    }

    public override void Write(Utf8JsonWriter writer, string? value, JsonSerializerOptions options)
    {
        if (value == null)
            writer.WriteNullValue();
        else
            writer.WriteStringValue(value);
    }
}

/// <summary>
/// Provides common JSON serializer options for Solscan API responses.
/// </summary>
public static class SolscanJsonOptions
{
    private static JsonSerializerOptions? _instance;

    public static JsonSerializerOptions Default => _instance ??= CreateOptions();

    private static JsonSerializerOptions CreateOptions()
    {
        var options = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
            PropertyNameCaseInsensitive = true
        };
        options.Converters.Add(new StringToDecimalConverter());
        options.Converters.Add(new StringToDecimalNonNullableConverter());
        options.Converters.Add(new StringToLongConverter());
        options.Converters.Add(new StringToNullableLongConverter());
        options.Converters.Add(new StringToIntConverter());
        options.Converters.Add(new StringToNullableIntConverter());
        options.Converters.Add(new FlexibleStringConverter());
        return options;
    }
}
