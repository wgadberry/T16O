using Microsoft.AspNetCore.Mvc;
using T16O.www.Server.Models;
using T16O.www.Server.Services;

namespace T16O.www.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
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
        /// Get bubble map data for a token
        /// </summary>
        /// <param name="token_name">Token name (optional)</param>
        /// <param name="token_symbol">Token symbol (optional)</param>
        /// <param name="mint_address">Token mint address (optional)</param>
        /// <param name="signature">Transaction signature (optional)</param>
        /// <param name="block_time">Unix timestamp (optional)</param>
        /// <param name="tx_limit">Transaction window size (10, 20, 50, 100) - default 10</param>
        [HttpGet]
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
        /// Get time range for a token's transactions
        /// </summary>
        /// <param name="token_symbol">Token symbol</param>
        /// <param name="mint_address">Token mint address</param>
        [HttpGet("timerange")]
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
