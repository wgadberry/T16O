import { Injectable, InjectionToken, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { BubbleMapResponse, BubbleMapQueryParams } from './cluster-map.models';

export const CLUSTER_MAP_API_URL = new InjectionToken<string>('CLUSTER_MAP_API_URL', {
  providedIn: 'root',
  factory: () => '/api/bubblemap'
});

@Injectable({
  providedIn: 'root'
})
export class ClusterMapService {
  private apiUrl = inject(CLUSTER_MAP_API_URL);
  private http = inject(HttpClient);

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
}
