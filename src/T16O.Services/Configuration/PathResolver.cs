using System.Text.RegularExpressions;
using Microsoft.Extensions.Configuration;

namespace T16O.Services.Configuration;

/// <summary>
/// Resolves path variables in configuration strings.
/// Supports variable substitution using {variable} syntax.
///
/// Example configuration:
/// {
///   "Paths": {
///     "Solution": "C:\\Users\\wgadb\\source\\repos\\T16O",
///     "Src": "{Solution}\\src",
///     "Sql": "{Solution}\\sql"
///   },
///   "Workers": {
///     "Winston": {
///       "OutputDirectory": "{Sql}"
///     }
///   }
/// }
/// </summary>
public class PathResolver
{
    private readonly Dictionary<string, string> _paths = new(StringComparer.OrdinalIgnoreCase);
    private static readonly Regex VariablePattern = new(@"\{([^}]+)\}", RegexOptions.Compiled);

    /// <summary>
    /// Initialize the path resolver from configuration
    /// </summary>
    public PathResolver(IConfiguration configuration)
    {
        var pathsSection = configuration.GetSection("Paths");
        if (!pathsSection.Exists())
            return;

        // First pass: load all raw values
        foreach (var child in pathsSection.GetChildren())
        {
            if (child.Value != null)
            {
                _paths[child.Key] = child.Value;
            }
        }

        // Second pass: resolve variables (with multiple iterations for nested references)
        const int maxIterations = 10;
        for (int i = 0; i < maxIterations; i++)
        {
            bool anyResolved = false;
            foreach (var key in _paths.Keys.ToList())
            {
                var original = _paths[key];
                var resolved = ResolveVariables(original);
                if (resolved != original)
                {
                    _paths[key] = resolved;
                    anyResolved = true;
                }
            }
            if (!anyResolved) break;
        }
    }

    /// <summary>
    /// Resolve a path string, substituting any {variable} references
    /// </summary>
    public string Resolve(string? path)
    {
        if (string.IsNullOrEmpty(path))
            return string.Empty;

        return ResolveVariables(path);
    }

    /// <summary>
    /// Get a named path from the Paths configuration
    /// </summary>
    public string? GetPath(string name)
    {
        return _paths.TryGetValue(name, out var value) ? value : null;
    }

    /// <summary>
    /// Get all configured paths
    /// </summary>
    public IReadOnlyDictionary<string, string> GetAllPaths() => _paths;

    private string ResolveVariables(string input)
    {
        return VariablePattern.Replace(input, match =>
        {
            var varName = match.Groups[1].Value;

            // Check if it's a direct path reference
            if (_paths.TryGetValue(varName, out var pathValue))
                return pathValue;

            // Check for environment variables as fallback
            var envValue = Environment.GetEnvironmentVariable(varName);
            if (!string.IsNullOrEmpty(envValue))
                return envValue;

            // Return original if not found (leave unresolved)
            return match.Value;
        });
    }
}
