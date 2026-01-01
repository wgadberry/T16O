import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { Router } from '@angular/router';

export interface SidebarMenuItem {
  label: string;
  icon: string;
  route?: string;
  badge?: string;
}

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.css',
  standalone: false
})
export class SidebarComponent implements OnInit {
  @Input() isMobile = false;
  @Input() mobileDrawerVisible = false;
  @Input() menuItems: SidebarMenuItem[] = [];

  @Output() mobileDrawerVisibleChange = new EventEmitter<boolean>();

  public sidebarVisible = true;
  public sidebarPinned = true;
  public sidebarHovered = false;

  constructor(private router: Router) {}

  ngOnInit() {
    this.initializeSidebar();
  }

  private initializeSidebar() {
    const savedPinned = localStorage.getItem('sidebarPinned');
    this.sidebarPinned = savedPinned !== 'false';
    this.sidebarVisible = this.sidebarPinned;
  }

  toggleSidebarPin() {
    this.sidebarPinned = !this.sidebarPinned;
    localStorage.setItem('sidebarPinned', String(this.sidebarPinned));
    if (!this.sidebarPinned && !this.sidebarHovered) {
      this.sidebarVisible = false;
    }
  }

  onSidebarMouseEnter() {
    this.sidebarHovered = true;
    if (!this.sidebarPinned && !this.isMobile) {
      this.sidebarVisible = true;
    }
  }

  onSidebarMouseLeave() {
    this.sidebarHovered = false;
    if (!this.sidebarPinned && !this.isMobile) {
      this.sidebarVisible = false;
    }
  }

  onMenuItemClick(item: SidebarMenuItem) {
    if (item.route) {
      this.router.navigate([item.route]);
    }
    if (this.isMobile) {
      this.mobileDrawerVisibleChange.emit(false);
    }
  }

  onMobileDrawerHide() {
    this.mobileDrawerVisibleChange.emit(false);
  }
}
