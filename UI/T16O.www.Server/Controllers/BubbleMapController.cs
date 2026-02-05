using Microsoft.AspNetCore.Mvc;
using T16O.www.Server.Models;
using T16O.www.Server.Services;

namespace T16O.www.Server.Controllers
{
    /// <summary>
    /// API for retrieving blockchain transaction visualization data as bubble map graphs
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class BubbleMapController : ControllerBase
    {
        private readonly IBubbleMapService _bubbleMapService;
        private readonly ILogger<BubbleMapController> _logger;

        public BubbleMapController(IBubbleMapService bubbleMapService, ILogger<BubbleMapController> logger)
        {
            _bubbleMapService = bubbleMapService;
            _logger = logger;
        }

        /// <summary>
        /// Get bubble map visualization data for a token
        /// </summary>
        /// <remarks>
        /// Returns a graph of nodes (wallets, pools, programs) and edges (transaction flows)
        /// for visualizing token movement patterns on the Solana blockchain.
        ///
        /// You must provide at least one of: token_symbol, mint_address, or signature.
        ///
        /// **Edge Types:**
        /// - `swap_in` / `swap_out` - DEX swap transactions
        /// - `spl_transfer` - SPL token transfers
        /// - `sol_transfer` - Native SOL transfers
        /// - `wallet_funded` / `funded_by` - Wallet funding relationships
        /// - `add_liquidity` / `remove_liquidity` - LP operations
        /// - `mint` / `burn` - Token minting and burning
        /// </remarks>
        /// <param name="token_name">Token name to search for</param>
        /// <param name="token_symbol">Token symbol (e.g., SOL, USDC, BONK)</param>
        /// <param name="mint_address">Exact token mint address (base58)</param>
        /// <param name="signature">Transaction signature to center the view on</param>
        /// <param name="block_time">Unix timestamp to query around</param>
        /// <param name="tx_limit">Transaction window size: 10, 20, 50, or 100 (default: 10)</param>
        /// <response code="200">Returns the bubble map graph data</response>
        /// <response code="500">Server error or database query failed</response>
        [HttpGet]
        [ProducesResponseType(typeof(BubbleMapResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(BubbleMapResponse), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetBubbleMapData(
            [FromQuery] string? token_name,
            [FromQuery] string? token_symbol,
            [FromQuery] string? mint_address,
            [FromQuery] string? signature,
            [FromQuery] long? block_time,
            [FromQuery] int? tx_limit)
        {
            _logger.LogInformation("GetBubbleMapData called with symbol={Symbol}, mint={Mint}, sig={Sig}",
                token_symbol, mint_address, signature);

            var queryParams = new BubbleMapQueryParams
            {
                TokenName = token_name,
                TokenSymbol = token_symbol,
                MintAddress = mint_address,
                Signature = signature,
                BlockTime = block_time,
                TxLimit = tx_limit
            };

            var result = await _bubbleMapService.GetBubbleMapDataAsync(queryParams);

            // If we have raw JSON from the stored procedure, return it directly
            if (!string.IsNullOrEmpty(result.RawJson))
            {
                return Content(result.RawJson, "application/json");
            }

            // Otherwise return the error in the result object
            if (!string.IsNullOrEmpty(result.Result.Error))
            {
                return StatusCode(500, result);
            }

            return Ok(result);
        }

        /// <summary>
        /// Get the time range of available transactions for a token
        /// </summary>
        /// <remarks>
        /// Returns the earliest and latest transaction timestamps for a token,
        /// useful for building time-based navigation or filtering.
        ///
        /// You must provide at least one of: token_symbol or mint_address.
        /// </remarks>
        /// <param name="token_symbol">Token symbol (e.g., SOL, USDC)</param>
        /// <param name="mint_address">Exact token mint address (base58)</param>
        /// <response code="200">Returns the time range data</response>
        /// <response code="400">Missing required parameters</response>
        /// <response code="404">No transactions found for the token</response>
        /// <response code="500">Server error or database query failed</response>
        [HttpGet("timerange")]
        [ProducesResponseType(typeof(TimeRangeResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(TimeRangeResponse), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(TimeRangeResponse), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(TimeRangeResponse), StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<TimeRangeResponse>> GetTimeRange(
            [FromQuery] string? token_symbol,
            [FromQuery] string? mint_address)
        {
            _logger.LogInformation("GetTimeRange called with symbol={Symbol}, mint={Mint}",
                token_symbol, mint_address);

            var result = await _bubbleMapService.GetTimeRangeAsync(token_symbol, mint_address);

            if (!string.IsNullOrEmpty(result.Error))
            {
                if (result.Error.Contains("required"))
                {
                    return BadRequest(result);
                }
                if (result.Error.Contains("No transactions"))
                {
                    return NotFound(result);
                }
                return StatusCode(500, result);
            }

            return Ok(result);
        }
    }
}
