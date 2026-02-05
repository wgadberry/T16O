import { Component, OnInit, OnDestroy, ElementRef, ViewChild, AfterViewInit, Input, Output, EventEmitter, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import * as d3 from 'd3';

// PrimeNG imports
import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { MessageModule } from 'primeng/message';
import { TooltipModule } from 'primeng/tooltip';

import { ClusterMapService } from './cluster-map.service';
import {
  BubbleMapResponse,
  BubbleMapNode,
  BubbleMapEdge,
  BubbleMapQueryParams,
  D3Node,
  D3Link
} from './cluster-map.models';

@Component({
  selector: 'lib-cluster-map',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    HttpClientModule,
    CardModule,
    ButtonModule,
    InputTextModule,
    SelectModule,
    ProgressSpinnerModule,
    MessageModule,
    TooltipModule
  ],
  templateUrl: './cluster-map.html',
  styleUrl: './cluster-map.css',
})
export class ClusterMap implements OnInit, OnDestroy, AfterViewInit {
  private clusterMapService = inject(ClusterMapService);

  @ViewChild('bubbleMapContainer', { static: false }) containerRef!: ElementRef;

  // Inputs for external data binding
  @Input() data: BubbleMapResponse | null = null;
  @Input() mascotImagePath = 'images/cfuck_mascot.jpg';
  @Input() backgroundImagePath = 'images/cfuck-bg.png';
  @Input() minRadiusForMascot = 20;

  // Outputs for events
  @Output() nodeSelected = new EventEmitter<D3Node | null>();
  @Output() transactionNavigate = new EventEmitter<string>();
  @Output() dataLoaded = new EventEmitter<BubbleMapResponse>();
  @Output() loadError = new EventEmitter<string>();

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
  selectedNode: D3Node | null = null;
  queryPanelExpanded = true;
  tokenInfoPanelExpanded = true;
  txNavPanelExpanded = true;

  // D3 elements
  private svg: d3.Selection<SVGSVGElement, unknown, null, undefined> | null = null;
  private simulation: d3.Simulation<D3Node, D3Link> | null = null;
  private zoom: d3.ZoomBehavior<SVGSVGElement, unknown> | null = null;
  private tooltip: d3.Selection<HTMLDivElement, unknown, null, undefined> | null = null;
  private nodes: D3Node[] = [];
  private links: D3Link[] = [];
  private arrowAnimationTimer: d3.Timer | null = null;
  private arrowProgress: Map<number, number> = new Map(); // Track progress for each arrow (0-1)

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

  ngOnInit(): void {
    if (this.data) {
      this.currentData = this.data;
    }
  }

  ngAfterViewInit(): void {
    this.initializeSvg();
    if (this.currentData?.result?.nodes?.length) {
      this.renderBubbleMap(this.currentData);
    }
  }

  ngOnDestroy(): void {
    if (this.simulation) {
      this.simulation.stop();
    }
    if (this.arrowAnimationTimer) {
      this.arrowAnimationTimer.stop();
    }
  }

  private initializeSvg(): void {
    if (!this.containerRef) return;

    const container = this.containerRef.nativeElement;
    const width = container.clientWidth || 800;
    const height = 850;

    // Clear existing SVG
    d3.select(container).selectAll('svg').remove();

    // Create SVG
    this.svg = d3.select(container)
      .append('svg')
      .attr('width', '100%')
      .attr('height', height)
      .attr('viewBox', `0 0 ${width} ${height}`)
      .style('background', '#0d0d1a')
      .on('click', () => this.closeDetailsPanel());

    // Add background image with 40% opacity
    this.svg.append('image')
      .attr('xlink:href', this.backgroundImagePath)
      .attr('x', 0)
      .attr('y', 0)
      .attr('width', width)
      .attr('height', height)
      .attr('preserveAspectRatio', 'xMidYMid slice')
      .attr('opacity', 0.4)
      .style('pointer-events', 'none');

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

    // Create filled arrow markers for each edge type color
    Object.entries(this.edgeTypeColors).forEach(([edgeType, color]) => {
      const markerId = `arrowhead-${edgeType}`;
      defs.append('marker')
        .attr('id', markerId)
        .attr('viewBox', '-1 -6 12 12')
        .attr('refX', 20)
        .attr('refY', 0)
        .attr('orient', 'auto')
        .attr('markerWidth', 8)
        .attr('markerHeight', 8)
        .append('path')
        .attr('d', 'M 0,-5 L 10,0 L 0,5 Z')
        .attr('fill', color)
        .attr('fill-opacity', 0.5);
    });

    // Create main group for zoom
    this.svg.append('g').attr('class', 'main-group');

    // Setup zoom
    this.zoom = d3.zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.1, 10])
      .on('zoom', (event) => {
        this.svg?.select('.main-group').attr('transform', event.transform);
      });

    this.svg.call(this.zoom);

    // Create tooltip div with pointer arrow
    d3.select(container).selectAll('.node-tooltip').remove();
    this.tooltip = d3.select(container)
      .append('div')
      .attr('class', 'node-tooltip')
      .style('position', 'absolute')
      .style('visibility', 'hidden')
      .style('background', 'rgba(15, 15, 25, 0.5)')
      .style('border', '1px solid rgba(100, 100, 150, 0.5)')
      .style('border-radius', '8px')
      .style('padding', '12px 16px')
      .style('font-size', '12px')
      .style('color', '#e0e0e0')
      .style('pointer-events', 'none')
      .style('z-index', '1000')
      .style('box-shadow', '0 4px 20px rgba(0, 0, 0, 0.5)')
      .style('backdrop-filter', 'blur(10px)')
      .style('max-width', '300px');

    // Add pointer arrow border (outer)
    this.tooltip.append('div')
      .attr('class', 'tooltip-pointer-border')
      .style('position', 'absolute')
      .style('left', '-10px')
      .style('top', '10px')
      .style('width', '0')
      .style('height', '0')
      .style('border-top', '10px solid transparent')
      .style('border-bottom', '10px solid transparent')
      .style('border-right', '10px solid rgba(100, 100, 150, 0.5)');

    // Add pointer arrow fill (inner)
    this.tooltip.append('div')
      .attr('class', 'tooltip-pointer')
      .style('position', 'absolute')
      .style('left', '-8px')
      .style('top', '12px')
      .style('width', '0')
      .style('height', '0')
      .style('border-top', '8px solid transparent')
      .style('border-bottom', '8px solid transparent')
      .style('border-right', '8px solid rgba(15, 15, 25, 0.5)');
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

    this.clusterMapService.getBubbleMapData(params).subscribe({
      next: (data) => {
        this.currentData = data;
        this.loading = false;
        this.dataLoaded.emit(data);
        if (data.result?.nodes?.length) {
          this.renderBubbleMap(data);
        } else {
          this.errorMessage = data.result?.error || 'No data found for this token';
          this.loadError.emit(this.errorMessage);
        }
      },
      error: (error) => {
        this.loading = false;
        this.errorMessage = error.error?.result?.error || error.message || 'Failed to load data';
        this.loadError.emit(this.errorMessage);
      }
    });
  }

  private renderBubbleMap(data: BubbleMapResponse): void {
    if (!data.result) {
      return;
    }

    const container = this.containerRef.nativeElement;
    const width = container.clientWidth || 800;
    const height = 850;

    // Re-initialize SVG if needed
    if (!this.svg || width === 0) {
      this.initializeSvg();
    }

    if (!this.svg) {
      return;
    }

    // Update viewBox to match current container size
    this.svg.attr('viewBox', `0 0 ${width} ${height}`);

    // Transform data to D3 format
    this.nodes = this.transformNodes(data.result.nodes);
    this.links = this.transformLinks(data.result.edges, this.nodes);

    // Clear previous elements
    const mainGroup = this.svg.select('.main-group');
    mainGroup.selectAll('*').remove();

    // Create links with 50% transparency and matching colors
    const linkGroup = mainGroup.append('g').attr('class', 'links');

    // Draw colored lines with 50% opacity (no static marker-end, we'll animate arrows)
    const link = linkGroup.selectAll('line')
      .data(this.links)
      .enter()
      .append('line')
      .attr('stroke', d => d.color)
      .attr('stroke-opacity', 0.5)
      .attr('stroke-width', 1)
      .attr('stroke-linecap', 'round');

    // Create animated arrow group
    const arrowGroup = mainGroup.append('g').attr('class', 'arrows');

    // Initialize arrow progress with random starting positions for visual variety
    this.arrowProgress.clear();
    this.links.forEach((_, i) => {
      this.arrowProgress.set(i, Math.random());
    });

    // Create arrow polygons for each link
    const arrows = arrowGroup.selectAll('polygon')
      .data(this.links)
      .enter()
      .append('polygon')
      .attr('points', '-6,-4 6,0 -6,4')
      .attr('fill', d => d.color)
      .attr('fill-opacity', 0.5);

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
      .on('mousemove', (event) => this.onNodeMouseMove(event))
      .on('mouseout', (event, d) => this.onNodeHover(event, d, false))
      .on('click', (event, d) => this.onNodeClick(event, d));

    // Add mascot images to larger bubbles
    const defs = this.svg.select('defs');

    // Create clip paths for nodes that will have mascot images
    node.filter(d => d.radius >= this.minRadiusForMascot)
      .each((d) => {
        const clipId = `clip-${d.id.slice(0, 8)}`;
        defs.append('clipPath')
          .attr('id', clipId)
          .append('circle')
          .attr('r', d.radius - 2);
      });

    // Add mascot images to larger bubbles
    node.filter(d => d.radius >= this.minRadiusForMascot)
      .append('image')
      .attr('xlink:href', this.mascotImagePath)
      .attr('x', d => -d.radius)
      .attr('y', d => -d.radius)
      .attr('width', d => d.radius * 2)
      .attr('height', d => d.radius * 2)
      .attr('clip-path', d => `url(#clip-${d.id.slice(0, 8)})`)
      .attr('opacity', 0.4)
      .attr('preserveAspectRatio', 'xMidYMid slice')
      .style('pointer-events', 'none');

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

    // Stop any existing arrow animation
    if (this.arrowAnimationTimer) {
      this.arrowAnimationTimer.stop();
    }

    // Start arrow animation timer
    const animationSpeed = 0.0012; // Speed of arrow movement (0-1 per frame)
    this.arrowAnimationTimer = d3.timer(() => {
      // Update each arrow's progress
      this.arrowProgress.forEach((progress, index) => {
        let newProgress = progress + animationSpeed;
        if (newProgress >= 1) {
          newProgress = 0; // Reset to start
        }
        this.arrowProgress.set(index, newProgress);
      });

      // Update arrow positions and rotations
      arrows.attr('transform', (d, i) => {
        const source = d.source as D3Node;
        const target = d.target as D3Node;
        const progress = this.arrowProgress.get(i) || 0;

        // Get source and target positions (check for valid numbers)
        const x1 = typeof source.x === 'number' && !isNaN(source.x) ? source.x : 0;
        const y1 = typeof source.y === 'number' && !isNaN(source.y) ? source.y : 0;
        const x2 = typeof target.x === 'number' && !isNaN(target.x) ? target.x : 0;
        const y2 = typeof target.y === 'number' && !isNaN(target.y) ? target.y : 0;

        // Calculate line length and direction
        const dx = x2 - x1;
        const dy = y2 - y1;
        const lineLength = Math.sqrt(dx * dx + dy * dy);

        // Skip if line length is too small (avoid NaN from division)
        if (lineLength < 1) {
          return 'translate(0,0)';
        }

        // Calculate the target node radius to stop before entering
        const targetRadius = target.radius || 10;

        // Adjust end point to stop at bubble edge
        const effectiveLength = Math.max(0, lineLength - targetRadius - 5);

        // Interpolate position along the line
        const t = progress * (effectiveLength / lineLength);
        const x = x1 + dx * t;
        const y = y1 + dy * t;

        // Calculate rotation angle (in degrees)
        const angle = Math.atan2(dy, dx) * (180 / Math.PI);

        return `translate(${x},${y}) rotate(${angle})`;
      });
    });
  }

  private transformNodes(nodes: BubbleMapNode[]): D3Node[] {
    return nodes.map(node => {
      const balance = Math.abs(node.balance || 0);
      const balanceUsd = node.balance_usd || 0;
      const isPool = node.address_type === 'pool' || node.is_pool || false;
      const isProgram = node.address_type === 'program' || node.is_program || false;
      const isMint = node.address_type === 'mint' || node.label === 'mint';

      let color: string;
      if (isPool) {
        color = '#14b8a6';
      } else if (isMint) {
        color = '#f59e0b';
      } else if (isProgram) {
        color = '#8b5cf6';
      } else if (balanceUsd > 10000) {
        color = '#e94560';
      } else if (balanceUsd > 1000) {
        color = '#3b82f6';
      } else if (balance > 0) {
        color = '#22c55e';
      } else {
        color = '#666666';
      }

      const radius = Math.max(8, Math.min(40, Math.sqrt(Math.abs(balance)) / 100 + 8));

      const fundedBy = Array.isArray(node.funded_by)
        ? node.funded_by
        : node.funded_by
          ? [node.funded_by]
          : [];

      let typeLabel: string;
      if (isPool) {
        typeLabel = 'Pool';
      } else if (isMint) {
        typeLabel = 'Mint';
      } else if (isProgram) {
        typeLabel = 'Program';
      } else if (node.address_type === 'wallet' || node.label === 'wallet') {
        typeLabel = 'Wallet';
      } else if (node.address_type === 'unknown' || !node.address_type) {
        typeLabel = 'Under Investigation';
      } else {
        typeLabel = node.address_type;
      }

      return {
        id: node.address,
        label: typeLabel,
        name: node.pool_label || node.token_name || node.label || `${node.address.slice(0, 4)}...${node.address.slice(-4)}`,
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

    if (this.tooltip) {
      if (isHover) {
        const fundedByText = d.fundedBy.length > 0
          ? d.fundedBy.map(f => `${f.slice(0, 4)}...${f.slice(-4)}`).join(', ')
          : 'Under Investigation';

        this.tooltip
          .style('visibility', 'visible')
          .html(`
            <div style="margin-bottom: 8px; font-weight: 600; color: ${d.color}; font-size: 14px;">
              ${d.name}
            </div>
            <div style="margin-bottom: 6px;">
              <span style="color: #888;">Type:</span>
              <span style="color: #fff;">${d.label}</span>
            </div>
            <div style="margin-bottom: 6px;">
              <span style="color: #888;">Address:</span>
              <span style="color: #aaa; font-family: monospace; font-size: 11px;">${d.id.slice(0, 8)}...${d.id.slice(-6)}</span>
            </div>
            <div style="margin-bottom: 6px;">
              <span style="color: #888;">Balance:</span>
              <span style="color: #22c55e;">${d.balance.toLocaleString()}</span>
            </div>
            ${d.balanceUsd > 0 ? `
            <div style="margin-bottom: 6px;">
              <span style="color: #888;">USD Value:</span>
              <span style="color: #f59e0b;">$${d.balanceUsd.toLocaleString()}</span>
            </div>
            ` : ''}
            <div>
              <span style="color: #888;">Funded By:</span>
              <span style="color: #a855f7;">${fundedByText}</span>
            </div>
          `);

        this.updateTooltipPosition(event);
      } else {
        this.tooltip.style('visibility', 'hidden');
      }
    }
  }

  private onNodeMouseMove(event: MouseEvent): void {
    if (this.tooltip) {
      this.updateTooltipPosition(event);
    }
  }

  private onNodeClick(event: MouseEvent, d: D3Node): void {
    event.stopPropagation();
    this.selectedNode = d;
    this.nodeSelected.emit(d);
  }

  closeDetailsPanel(): void {
    this.selectedNode = null;
    this.nodeSelected.emit(null);
  }

  toggleQueryPanel(): void {
    this.queryPanelExpanded = !this.queryPanelExpanded;
  }

  toggleTokenInfoPanel(): void {
    this.tokenInfoPanelExpanded = !this.tokenInfoPanelExpanded;
  }

  toggleTxNavPanel(): void {
    this.txNavPanelExpanded = !this.txNavPanelExpanded;
  }

  copyToClipboard(text: string): void {
    navigator.clipboard.writeText(text);
  }

  getNodeConnections(node: D3Node): { incoming: D3Link[], outgoing: D3Link[] } {
    const incoming = this.links.filter(l => (l.target as D3Node).id === node.id);
    const outgoing = this.links.filter(l => (l.source as D3Node).id === node.id);
    return { incoming, outgoing };
  }

  private updateTooltipPosition(event: MouseEvent): void {
    if (!this.tooltip) return;

    const containerRect = this.containerRef.nativeElement.getBoundingClientRect();
    const tooltipX = event.clientX - containerRect.left;
    const tooltipY = event.clientY - containerRect.top;

    this.tooltip
      .style('left', `${tooltipX}px`)
      .style('top', `${tooltipY}px`);
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
    this.transactionNavigate.emit(signature);

    this.clusterMapService.getBubbleMapData(params).subscribe({
      next: (data) => {
        this.currentData = data;
        this.loading = false;
        this.dataLoaded.emit(data);
        this.renderBubbleMap(data);
      },
      error: (error) => {
        this.loading = false;
        this.errorMessage = error.message || 'Failed to load transaction';
        this.loadError.emit(this.errorMessage);
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
