import { Injectable, InjectionToken, inject } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { BubbleMapResponse, BubbleMapQueryParams, WalletTokenTxResponse } from './cluster-map.models';

export const CLUSTER_MAP_API_URL = new InjectionToken<string>('CLUSTER_MAP_API_URL', {
  providedIn: 'root',
  factory: () => '/api/bubblemap'
});

export const CLUSTER_MAP_API_KEY = new InjectionToken<string>('CLUSTER_MAP_API_KEY', {
  providedIn: 'root',
  factory: () => ''
});

export const CLUSTER_MAP_API_KEY_HEADER = new InjectionToken<string>('CLUSTER_MAP_API_KEY_HEADER', {
  providedIn: 'root',
  factory: () => 'X-API-Key'
});

export const CLUSTER_MAP_WALLET_TX_URL = new InjectionToken<string>('CLUSTER_MAP_WALLET_TX_URL', {
  providedIn: 'root',
  factory: () => ''
});

@Injectable({
  providedIn: 'root'
})
export class ClusterMapService {
  private apiUrl = inject(CLUSTER_MAP_API_URL);
  private apiKey = inject(CLUSTER_MAP_API_KEY);
  private apiKeyHeader = inject(CLUSTER_MAP_API_KEY_HEADER);
  private walletTxUrl = inject(CLUSTER_MAP_WALLET_TX_URL);
  private http = inject(HttpClient);

  private getHeaders(): HttpHeaders {
    let headers = new HttpHeaders();
    if (this.apiKey) {
      headers = headers.set(this.apiKeyHeader, this.apiKey);
    }
    return headers;
  }

  getBubbleMapData(params: BubbleMapQueryParams): Observable<BubbleMapResponse> {
    let httpParams = new HttpParams();

    if (params.token_name) {
      httpParams = httpParams.set('token_name', params.token_name);
    }
    if (params.token_symbol) {
      httpParams = httpParams.set('token_symbol', params.token_symbol);
    }
    if (params.mint_address) {
      httpParams = httpParams.set('mint_address', params.mint_address);
    }
    if (params.signature) {
      httpParams = httpParams.set('signature', params.signature);
    }
    if (params.block_time) {
      httpParams = httpParams.set('block_time', params.block_time.toString());
    }
    if (params.tx_limit) {
      httpParams = httpParams.set('tx_limit', params.tx_limit.toString());
    }

    return this.http.get<BubbleMapResponse>(this.apiUrl, {
      params: httpParams,
      headers: this.getHeaders()
    });
  }

  getWalletTokenTxs(address: string, mintAddress: string, limit: number = 50): Observable<WalletTokenTxResponse> {
    const baseUrl = this.walletTxUrl || `${this.apiUrl}/wallet-txs`;

    // If no dedicated wallet-tx URL is configured and apiUrl is a remote endpoint,
    // return empty result to avoid hitting a non-existent endpoint
    if (!this.walletTxUrl) {
      return of({ address, transactions: [] });
    }

    const params = new HttpParams()
      .set('address', address)
      .set('mint_address', mintAddress)
      .set('limit', limit.toString());

    return this.http.get<WalletTokenTxResponse>(baseUrl, {
      params,
      headers: this.getHeaders()
    });
  }
}
