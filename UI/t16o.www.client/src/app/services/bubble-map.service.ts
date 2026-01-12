import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { BubbleMapResponse, TimeRangeResponse } from '../models/bubble-map.models';

export interface BubbleMapQueryParams {
  token_name?: string;
  token_symbol?: string;
  mint_address?: string;
  signature?: string;
  block_time?: number;
  tx_limit?: number;
}

@Injectable({
  providedIn: 'root'
})
export class BubbleMapService {
  private apiUrl = '/api/bmap';

  constructor(private http: HttpClient) {}

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

    return this.http.get<BubbleMapResponse>(this.apiUrl, { params: httpParams });
  }

  getTimeRange(params: { token_symbol?: string; mint_address?: string }): Observable<TimeRangeResponse> {
    let httpParams = new HttpParams();

    if (params.token_symbol) {
      httpParams = httpParams.set('token_symbol', params.token_symbol);
    }
    if (params.mint_address) {
      httpParams = httpParams.set('mint_address', params.mint_address);
    }

    return this.http.get<TimeRangeResponse>(`${this.apiUrl.replace('/bmap', '/timerange')}`, { params: httpParams });
  }

  fetchWallet(address: string): Observable<{ success: boolean; message?: string; error?: string }> {
    return this.http.post<{ success: boolean; message?: string; error?: string }>(
      `${this.apiUrl.replace('/bmap', '/fetch-wallet')}`,
      { address }
    );
  }
}
