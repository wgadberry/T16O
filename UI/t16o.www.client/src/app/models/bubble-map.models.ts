export interface BubbleMapNode {
  address: string;
  label?: string;
  balance: number;
  balance_usd?: number;
  is_pool?: boolean;
  is_program?: boolean;
  funded_by?: string | string[];
  token_mint?: string;
  token_symbol?: string;
  // Additional properties from stored procedure
  pool_label?: string | null;
  token_name?: string | null;
  sol_balance?: number;
  address_type?: string;
}

export interface BubbleMapEdge {
  source: string;
  target: string;
  edge_type?: string;
  type?: string; // actual property name from stored procedure
  amount?: number;
  amount_usd?: number;
  signatures?: string[];
  // Additional properties from stored procedure
  dex?: string;
  pool?: string | null;
  program?: string;
  category?: string;
  ins_index?: number;
  signature?: string;
  block_time?: number;
  pool_label?: string | null;
  source_label?: string;
  target_label?: string;
  token_symbol?: string;
  block_time_utc?: string;
}

export interface BubbleMapToken {
  mint: string;
  symbol?: string;
  name?: string;
  decimals?: number;
}

export interface BubbleMapTransaction {
  signature: string;
  block_time: number;
  block_time_utc: string;
  edge_types: string[];
  prev?: BubbleMapTransactionRef[];
  next?: BubbleMapTransactionRef[];
}

export interface BubbleMapTransactionRef {
  signature: string;
  block_time: number;
  block_time_utc: string;
  edge_types: string[];
}

export interface RelatedToken {
  mint: string;
  symbol?: string;
  name?: string;
  swap_count: number;
}

export interface BubbleMapResult {
  token?: BubbleMapToken;
  nodes: BubbleMapNode[];
  edges: BubbleMapEdge[];
  txs?: BubbleMapTransaction;
  related_tokens?: RelatedToken[];
}

export interface BubbleMapResponse {
  result: BubbleMapResult;
}

export interface TimeRangeResponse {
  min_time: number;
  max_time: number;
  tx_count: number;
}
