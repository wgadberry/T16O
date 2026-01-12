import { Component, OnInit } from '@angular/core';
import { BubbleMapService } from '../../../services/bubble-map.service';

interface WalletTrail {
  address: string;
  label?: string;
  fundedBy?: string[];
  fundedWallets?: string[];
  totalFundedAmount?: number;
  depth: number;
}

@Component({
  selector: 'app-wallet-trails-page',
  templateUrl: './wallet-trails.page.html',
  styleUrl: './wallet-trails.page.css',
  standalone: false
})
export class WalletTrailsPage implements OnInit {
  walletAddress = '';
  loading = false;
  errorMessage = '';
  fetchingWallet = false;
  fetchMessage = '';

  trails: WalletTrail[] = [];

  constructor(private bubbleMapService: BubbleMapService) {}

  ngOnInit(): void {}

  searchWallet(): void {
    if (!this.walletAddress || this.walletAddress.length < 32) {
      this.errorMessage = 'Please enter a valid wallet address';
      return;
    }

    this.loading = true;
    this.errorMessage = '';
    this.trails = [];

    // For now, show a placeholder - in production this would call a trails API
    this.bubbleMapService.getBubbleMapData({ mint_address: this.walletAddress, tx_limit: 20 }).subscribe({
      next: (data) => {
        this.loading = false;
        if (data.result && data.result.nodes) {
          this.trails = data.result.nodes
            .filter(node => node.funded_by && node.funded_by.length > 0)
            .map((node, index) => ({
              address: node.address,
              label: node.label,
              fundedBy: node.funded_by,
              depth: index
            }));
        }
      },
      error: (error) => {
        this.loading = false;
        this.errorMessage = error.message || 'Failed to load wallet data';
      }
    });
  }

  fetchWalletTransactions(): void {
    if (!this.walletAddress || this.walletAddress.length < 32) {
      this.errorMessage = 'Please enter a valid wallet address';
      return;
    }

    this.fetchingWallet = true;
    this.fetchMessage = '';
    this.errorMessage = '';

    this.bubbleMapService.fetchWallet(this.walletAddress).subscribe({
      next: (response) => {
        this.fetchingWallet = false;
        if (response.success) {
          this.fetchMessage = response.message || 'Fetching wallet transactions...';
        } else {
          this.errorMessage = response.error || 'Failed to fetch wallet';
        }
      },
      error: (error) => {
        this.fetchingWallet = false;
        this.errorMessage = error.message || 'Failed to fetch wallet';
      }
    });
  }

  formatAddress(address: string): string {
    if (!address || address.length < 12) return address;
    return `${address.slice(0, 6)}...${address.slice(-6)}`;
  }

  copyAddress(address: string): void {
    navigator.clipboard.writeText(address);
  }
}
