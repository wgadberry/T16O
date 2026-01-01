import { Component, HostListener, OnInit, ViewChild } from '@angular/core';
import { SidebarMenuItem } from './components/sidebar/sidebar.component';
import { SidebarComponent } from './components/sidebar/sidebar.component';

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  standalone: false,
  styleUrl: './app.css'
})
export class App implements OnInit {
  public title = 'T16O';
  public darkMode = false;
  public isMobile = false;
  public mobileDrawerVisible = false;

  @ViewChild(SidebarComponent) sidebar!: SidebarComponent;

  public sidebarMenuItems: SidebarMenuItem[] = [
    { label: 'Dashboard', icon: 'pi pi-home', route: '/dashboard' },
    { label: 'Weather', icon: 'pi pi-cloud', route: '/weather' },
    { label: 'Analytics', icon: 'pi pi-chart-bar', route: '/analytics' },
    { label: 'Reports', icon: 'pi pi-file', route: '/reports' },
    { label: 'Settings', icon: 'pi pi-cog', route: '/settings' }
  ];

  ngOnInit() {
    this.initializeDarkMode();
    this.checkScreenSize();
  }

  @HostListener('window:resize')
  onResize() {
    this.checkScreenSize();
  }

  private checkScreenSize() {
    this.isMobile = window.innerWidth < 768;
    if (this.isMobile) {
      this.mobileDrawerVisible = false;
    }
  }

  private initializeDarkMode() {
    const savedTheme = localStorage.getItem('darkMode');
    this.darkMode = savedTheme === 'true';
    this.applyTheme();
  }

  onDarkModeChange(darkMode: boolean) {
    this.darkMode = darkMode;
    localStorage.setItem('darkMode', String(this.darkMode));
    this.applyTheme();
  }

  private applyTheme() {
    const element = document.documentElement;
    if (this.darkMode) {
      element.classList.add('dark-mode');
    } else {
      element.classList.remove('dark-mode');
    }
  }

  onMenuToggle() {
    this.mobileDrawerVisible = !this.mobileDrawerVisible;
  }

  onLogout() {
    console.log('Logout clicked');
  }

  get sidebarVisible(): boolean {
    return this.sidebar?.sidebarVisible ?? true;
  }

  get sidebarPinned(): boolean {
    return this.sidebar?.sidebarPinned ?? true;
  }
}
