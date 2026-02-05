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
  pool_label?: string | null;
  token_name?: string | null;
  sol_balance?: number;
  address_type?: string;
}

export interface BubbleMapEdge {
  source: string;
  target: string;
  edge_type?: string;
  type?: string;
  amount?: number;
  amount_usd?: number;
  signatures?: string[];
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
  error?: string;
}

export interface BubbleMapResponse {
  result: BubbleMapResult;
}

export interface BubbleMapQueryParams {
  token_name?: string;
  token_symbol?: string;
  mint_address?: string;
  signature?: string;
  block_time?: number;
  tx_limit?: number;
}

// D3 simulation node interface (extends d3.SimulationNodeDatum)
export interface D3Node {
  id: string;
  label: string;
  name: string;
  balance: number;
  balanceUsd: number;
  isPool: boolean;
  isProgram: boolean;
  fundedBy: string[];
  color: string;
  radius: number;
  // d3.SimulationNodeDatum properties
  index?: number;
  x?: number;
  y?: number;
  vx?: number;
  vy?: number;
  fx?: number | null;
  fy?: number | null;
}

// D3 simulation link interface (extends d3.SimulationLinkDatum<D3Node>)
export interface D3Link {
  source: string | D3Node;
  target: string | D3Node;
  edgeType: string;
  amount: number;
  color: string;
  // d3.SimulationLinkDatum properties
  index?: number;
}
