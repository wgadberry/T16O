import { Component, OnInit, OnDestroy, ElementRef, ViewChild, AfterViewInit } from '@angular/core';
import * as d3 from 'd3';
import { BubbleMapService, BubbleMapQueryParams } from '../../../services/bubble-map.service';
import { BubbleMapResponse, BubbleMapNode, BubbleMapEdge } from '../../../models/bubble-map.models';

interface D3Node extends d3.SimulationNodeDatum {
  id: string;
  label: string;
  balance: number;
  balanceUsd: number;
  isPool: boolean;
  isProgram: boolean;
  fundedBy: string[];
  color: string;
  radius: number;
}

interface D3Link extends d3.SimulationLinkDatum<D3Node> {
  source: string | D3Node;
  target: string | D3Node;
  edgeType: string;
  amount: number;
  color: string;
}

@Component({
  selector: 'app-cluster-maps-page',
  templateUrl: './cluster-maps.page.html',
  styleUrl: './cluster-maps.page.css',
  standalone: false
})
export class ClusterMapsPage implements OnInit, OnDestroy, AfterViewInit {
  @ViewChild('bubbleMapContainer', { static: false }) containerRef!: ElementRef;

  // Query form
  tokenSymbol = '';
  mintAddress = '';
  txLimit = 10;
  txLimitOptions = [
    { label: 'Single TX', value: 1 },
    { label: '10 (5+5)', value: 10 },
    { label: '20 (10+10)', value: 20 },
    { label: '50 (25+25)', value: 50 },
    { label: '100 (50+50)', value: 100 }
  ];

  // State
  loading = false;
  errorMessage = '';
  currentData: BubbleMapResponse | null = null;
  showLabels = true;

  // D3 elements
  private svg: d3.Selection<SVGSVGElement, unknown, null, undefined> | null = null;
  private simulation: d3.Simulation<D3Node, D3Link> | null = null;
  private zoom: d3.ZoomBehavior<SVGSVGElement, unknown> | null = null;
  private nodes: D3Node[] = [];
  private links: D3Link[] = [];

  // Edge type colors
  private edgeTypeColors: { [key: string]: string } = {
    swap_in: '#22c55e',
    swap_out: '#ef4444',
    spl_transfer: '#3b82f6',
    sol_transfer: '#60a5fa',
    wallet_funded: '#a855f7',
    funded_by: '#a855f7',
    create_ata: '#06b6d4',
    close_ata: '#0891b2',
    fee: '#6b7280',
    lend_deposit: '#f97316',
    lend_withdraw: '#ea580c',
    borrow: '#fb923c',
    repay: '#fdba74',
    stake: '#f59e0b',
    unstake: '#d97706',
    add_liquidity: '#14b8a6',
    remove_liquidity: '#0d9488',
    nft_mint: '#ec4899',
    nft_sale: '#f472b6',
    mint: '#22d3ee',
    burn: '#ff6b6b',
    unknown: '#475569'
  };

  constructor(private bubbleMapService: BubbleMapService) {}

  ngOnInit(): void {}

  ngAfterViewInit(): void {
    this.initializeSvg();
  }

  ngOnDestroy(): void {
    if (this.simulation) {
      this.simulation.stop();
    }
  }

  private initializeSvg(): void {
    if (!this.containerRef) return;

    const container = this.containerRef.nativeElement;
    const width = container.clientWidth || 800;
    const height = 600;

    // Clear existing SVG
    d3.select(container).selectAll('svg').remove();

    // Create SVG
    this.svg = d3.select(container)
      .append('svg')
      .attr('width', '100%')
      .attr('height', height)
      .attr('viewBox', `0 0 ${width} ${height}`)
      .style('background', 'radial-gradient(ellipse at center, #1a1a2e 0%, #0d0d1a 100%)');

    // Add defs for filters and gradients
    const defs = this.svg.append('defs');

    // Glow filter
    const filter = defs.append('filter')
      .attr('id', 'glow')
      .attr('x', '-50%')
      .attr('y', '-50%')
      .attr('width', '200%')
      .attr('height', '200%');

    filter.append('feGaussianBlur')
      .attr('stdDeviation', '3')
      .attr('result', 'coloredBlur');

    const feMerge = filter.append('feMerge');
    feMerge.append('feMergeNode').attr('in', 'coloredBlur');
    feMerge.append('feMergeNode').attr('in', 'SourceGraphic');

    // Inner glow filter for borders
    const innerGlow = defs.append('filter')
      .attr('id', 'innerGlow')
      .attr('x', '-50%')
      .attr('y', '-50%')
      .attr('width', '200%')
      .attr('height', '200%');

    innerGlow.append('feGaussianBlur')
      .attr('stdDeviation', '2')
      .attr('result', 'blur');

    innerGlow.append('feComposite')
      .attr('in', 'SourceGraphic')
      .attr('in2', 'blur')
      .attr('operator', 'over');

    // Create radial gradients for each node color
    this.createNodeGradient(defs, 'gradient-teal', '#14b8a6');
    this.createNodeGradient(defs, 'gradient-amber', '#f59e0b');
    this.createNodeGradient(defs, 'gradient-purple', '#8b5cf6');
    this.createNodeGradient(defs, 'gradient-red', '#e94560');
    this.createNodeGradient(defs, 'gradient-blue', '#3b82f6');
    this.createNodeGradient(defs, 'gradient-green', '#22c55e');
    this.createNodeGradient(defs, 'gradient-gray', '#666666');

    // Arrow marker
    defs.append('marker')
      .attr('id', 'arrowhead')
      .attr('viewBox', '-0 -5 10 10')
      .attr('refX', 20)
      .attr('refY', 0)
      .attr('orient', 'auto')
      .attr('markerWidth', 6)
      .attr('markerHeight', 6)
      .append('path')
      .attr('d', 'M 0,-5 L 10 ,0 L 0,5')
      .attr('fill', '#444');

    // Create main group for zoom
    this.svg.append('g').attr('class', 'main-group');

    // Setup zoom
    this.zoom = d3.zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.1, 10])
      .on('zoom', (event) => {
        this.svg?.select('.main-group').attr('transform', event.transform);
      });

    this.svg.call(this.zoom);
  }

  private createNodeGradient(defs: d3.Selection<SVGDefsElement, unknown, null, undefined>, id: string, color: string): void {
    const gradient = defs.append('radialGradient')
      .attr('id', id)
      .attr('cx', '30%')
      .attr('cy', '30%')
      .attr('r', '70%');

    // Inner highlight (lighter)
    gradient.append('stop')
      .attr('offset', '0%')
      .attr('stop-color', this.lightenColor(color, 40))
      .attr('stop-opacity', '0.8');

    // Mid color
    gradient.append('stop')
      .attr('offset', '50%')
      .attr('stop-color', color)
      .attr('stop-opacity', '0.4');

    // Outer edge (darker)
    gradient.append('stop')
      .attr('offset', '100%')
      .attr('stop-color', this.darkenColor(color, 30))
      .attr('stop-opacity', '0.6');
  }

  private lightenColor(color: string, percent: number): string {
    const num = parseInt(color.replace('#', ''), 16);
    const amt = Math.round(2.55 * percent);
    const R = Math.min(255, (num >> 16) + amt);
    const G = Math.min(255, ((num >> 8) & 0x00FF) + amt);
    const B = Math.min(255, (num & 0x0000FF) + amt);
    return `#${(0x1000000 + R * 0x10000 + G * 0x100 + B).toString(16).slice(1)}`;
  }

  private darkenColor(color: string, percent: number): string {
    const num = parseInt(color.replace('#', ''), 16);
    const amt = Math.round(2.55 * percent);
    const R = Math.max(0, (num >> 16) - amt);
    const G = Math.max(0, ((num >> 8) & 0x00FF) - amt);
    const B = Math.max(0, (num & 0x0000FF) - amt);
    return `#${(0x1000000 + R * 0x10000 + G * 0x100 + B).toString(16).slice(1)}`;
  }

  loadData(): void {
    if (!this.tokenSymbol && !this.mintAddress) {
      this.errorMessage = 'Please enter a token symbol or mint address';
      return;
    }

    this.loading = true;
    this.errorMessage = '';

    const params: BubbleMapQueryParams = {
      tx_limit: this.txLimit
    };

    if (this.tokenSymbol) {
      params.token_symbol = this.tokenSymbol;
    }
    if (this.mintAddress) {
      params.mint_address = this.mintAddress;
    }

    this.bubbleMapService.getBubbleMapData(params).subscribe({
      next: (data) => {
        this.currentData = data;
        this.loading = false;
        this.renderBubbleMap(data);
      },
      error: (error) => {
        this.loading = false;
        this.errorMessage = error.message || 'Failed to load data';
      }
    });
  }

  private renderBubbleMap(data: BubbleMapResponse): void {
    if (!this.svg || !data.result) return;

    const container = this.containerRef.nativeElement;
    const width = container.clientWidth || 800;
    const height = 600;

    // Transform data to D3 format
    this.nodes = this.transformNodes(data.result.nodes);
    this.links = this.transformLinks(data.result.edges, this.nodes);

    // Clear previous elements
    const mainGroup = this.svg.select('.main-group');
    mainGroup.selectAll('*').remove();

    // Create links with dark outline effect
    const linkGroup = mainGroup.append('g').attr('class', 'links');
    const link = linkGroup.selectAll('line')
      .data(this.links)
      .enter()
      .append('line')
      .attr('stroke', d => this.darkenColor(d.color, 40))
      .attr('stroke-opacity', 0.8)
      .attr('stroke-width', 2)
      .attr('marker-end', 'url(#arrowhead)');

    // Create nodes
    const nodeGroup = mainGroup.append('g').attr('class', 'nodes');
    const node = nodeGroup.selectAll('g')
      .data(this.nodes)
      .enter()
      .append('g')
      .attr('class', 'node')
      .call(d3.drag<SVGGElement, D3Node>()
        .on('start', (event, d) => this.dragStarted(event, d))
        .on('drag', (event, d) => this.dragged(event, d))
        .on('end', (event, d) => this.dragEnded(event, d)));

    // Node circles - transparent with gradient inner border
    node.append('circle')
      .attr('r', d => d.radius)
      .attr('fill', d => `url(#${this.getGradientId(d.color)})`)
      .attr('stroke', d => this.darkenColor(d.color, 30))
      .attr('stroke-width', 2.5)
      .attr('filter', 'url(#glow)')
      .style('cursor', 'pointer')
      .on('mouseover', (event, d) => this.onNodeHover(event, d, true))
      .on('mouseout', (event, d) => this.onNodeHover(event, d, false));

    // Node labels
    node.append('text')
      .attr('dy', d => d.radius + 12)
      .attr('text-anchor', 'middle')
      .attr('fill', '#aaa')
      .attr('font-size', '10px')
      .attr('class', 'node-label')
      .style('display', this.showLabels ? 'block' : 'none')
      .text(d => d.label);

    // Setup simulation
    this.simulation = d3.forceSimulation<D3Node>(this.nodes)
      .force('link', d3.forceLink<D3Node, D3Link>(this.links)
        .id(d => d.id)
        .distance(100))
      .force('charge', d3.forceManyBody().strength(-300))
      .force('center', d3.forceCenter(width / 2, height / 2))
      .force('collision', d3.forceCollide<D3Node>().radius(d => d.radius + 5));

    this.simulation.on('tick', () => {
      link
        .attr('x1', d => (d.source as D3Node).x || 0)
        .attr('y1', d => (d.source as D3Node).y || 0)
        .attr('x2', d => (d.target as D3Node).x || 0)
        .attr('y2', d => (d.target as D3Node).y || 0);

      node.attr('transform', d => `translate(${d.x || 0},${d.y || 0})`);
    });
  }

  private transformNodes(nodes: BubbleMapNode[]): D3Node[] {
    return nodes.map(node => {
      const balance = Math.abs(node.balance || 0);
      const balanceUsd = node.balance_usd || 0;
      // Use address_type to determine if pool/program, or fall back to is_pool/is_program
      const isPool = node.address_type === 'pool' || node.is_pool || false;
      const isProgram = node.address_type === 'program' || node.is_program || false;
      const isMint = node.address_type === 'mint' || node.label === 'mint';

      // Determine color based on node type and balance
      let color: string;
      if (isPool) {
        color = '#14b8a6'; // Teal for pools
      } else if (isMint) {
        color = '#f59e0b'; // Amber for mints
      } else if (isProgram) {
        color = '#8b5cf6'; // Purple for programs
      } else if (balanceUsd > 10000) {
        color = '#e94560';
      } else if (balanceUsd > 1000) {
        color = '#3b82f6';
      } else if (balance > 0) {
        color = '#22c55e';
      } else {
        color = '#666666';
      }

      // Calculate radius based on balance
      const radius = Math.max(8, Math.min(40, Math.sqrt(Math.abs(balance)) / 100 + 8));

      // Handle funded_by which can be string or array
      const fundedBy = Array.isArray(node.funded_by)
        ? node.funded_by
        : node.funded_by
          ? [node.funded_by]
          : [];

      return {
        id: node.address,
        label: node.pool_label || node.token_name || node.label || `${node.address.slice(0, 4)}...${node.address.slice(-4)}`,
        balance: balance,
        balanceUsd: balanceUsd,
        isPool: isPool,
        isProgram: isProgram,
        fundedBy: fundedBy,
        color: color,
        radius: radius
      };
    });
  }

  private transformLinks(edges: BubbleMapEdge[], nodes: D3Node[]): D3Link[] {
    const nodeMap = new Map(nodes.map(n => [n.id, n]));

    return edges
      .filter(edge => nodeMap.has(edge.source) && nodeMap.has(edge.target))
      .map(edge => {
        // Use 'type' (from stored procedure) or fallback to 'edge_type'
        const edgeType = edge.type || edge.edge_type || 'unknown';
        return {
          source: edge.source,
          target: edge.target,
          edgeType: edgeType,
          amount: edge.amount || 0,
          color: this.getEdgeColor(edgeType)
        };
      });
  }

  private dragStarted(event: d3.D3DragEvent<SVGGElement, D3Node, D3Node>, d: D3Node): void {
    if (!event.active && this.simulation) {
      this.simulation.alphaTarget(0.3).restart();
    }
    d.fx = d.x;
    d.fy = d.y;
  }

  private dragged(event: d3.D3DragEvent<SVGGElement, D3Node, D3Node>, d: D3Node): void {
    d.fx = event.x;
    d.fy = event.y;
  }

  private dragEnded(event: d3.D3DragEvent<SVGGElement, D3Node, D3Node>, d: D3Node): void {
    if (!event.active && this.simulation) {
      this.simulation.alphaTarget(0);
    }
    d.fx = null;
    d.fy = null;
  }

  private onNodeHover(event: MouseEvent, d: D3Node, isHover: boolean): void {
    const circle = d3.select(event.target as SVGCircleElement);
    circle
      .transition()
      .duration(200)
      .attr('r', isHover ? d.radius * 1.15 : d.radius)
      .attr('stroke-width', isHover ? 4 : 2.5)
      .attr('stroke', isHover ? this.lightenColor(d.color, 20) : this.darkenColor(d.color, 30));
  }

  resetZoom(): void {
    if (this.svg && this.zoom) {
      this.svg.transition()
        .duration(750)
        .call(this.zoom.transform, d3.zoomIdentity);
    }
  }

  toggleLabels(): void {
    this.showLabels = !this.showLabels;
    if (this.svg) {
      this.svg.selectAll('.node-label')
        .style('display', this.showLabels ? 'block' : 'none');
    }
  }

  navigateToTransaction(signature: string): void {
    const params: BubbleMapQueryParams = {
      signature: signature,
      tx_limit: this.txLimit
    };

    if (this.mintAddress) {
      params.mint_address = this.mintAddress;
    } else if (this.tokenSymbol) {
      params.token_symbol = this.tokenSymbol;
    }

    this.loading = true;
    this.bubbleMapService.getBubbleMapData(params).subscribe({
      next: (data) => {
        this.currentData = data;
        this.loading = false;
        this.renderBubbleMap(data);
      },
      error: (error) => {
        this.loading = false;
        this.errorMessage = error.message || 'Failed to load transaction';
      }
    });
  }

  private getEdgeColor(edgeType: string): string {
    return this.edgeTypeColors[edgeType] || '#475569';
  }

  private getGradientId(color: string): string {
    const colorMap: { [key: string]: string } = {
      '#14b8a6': 'gradient-teal',
      '#f59e0b': 'gradient-amber',
      '#8b5cf6': 'gradient-purple',
      '#e94560': 'gradient-red',
      '#3b82f6': 'gradient-blue',
      '#22c55e': 'gradient-green',
      '#666666': 'gradient-gray'
    };
    return colorMap[color] || 'gradient-gray';
  }

  // Helper methods for template
  formatMintAddress(mint: string | undefined): string {
    if (!mint) return '';
    return `${mint.slice(0, 8)}...${mint.slice(-6)}`;
  }

  getNodesCount(): number {
    return this.currentData?.result?.nodes?.length || 0;
  }

  getEdgesCount(): number {
    return this.currentData?.result?.edges?.length || 0;
  }

  getPrevCount(): number {
    return this.currentData?.result?.txs?.prev?.length || 0;
  }

  getNextCount(): number {
    return this.currentData?.result?.txs?.next?.length || 0;
  }
}
