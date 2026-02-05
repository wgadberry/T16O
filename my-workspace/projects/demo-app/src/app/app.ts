import { Component } from '@angular/core';
import { ClusterMap, BubbleMapResponse, D3Node } from 't160-widget-lib';

@Component({
  selector: 'app-root',
  imports: [ClusterMap],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  title = 'T160 Widget Library Demo';

  onNodeSelected(node: D3Node | null): void {
    if (node) {
      console.log('Node selected:', node.name, node.id);
    }
  }

  onDataLoaded(data: BubbleMapResponse): void {
    console.log('Data loaded:', data.result?.nodes?.length, 'nodes');
  }

  onLoadError(error: string): void {
    console.error('Load error:', error);
  }
}
