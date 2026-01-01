import { HttpClient } from '@angular/common/http';
import { Component, HostListener, OnInit, signal, ViewChild } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { Menu } from 'primeng/menu';

interface WeatherForecast {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
}

interface SidebarMenuItem {
  label: string;
  icon: string;
  route?: string;
  badge?: string;
}

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  standalone: false,
  styleUrl: './app.css'
})
export class App implements OnInit {
  public forecasts: WeatherForecast[] = [];
  public darkMode = false;
  public profileMenuItems: MenuItem[] = [];

  // Sidebar state
  public sidebarVisible = true;
  public sidebarPinned = true;
  public sidebarHovered = false;
  public isMobile = false;
  public mobileDrawerVisible = false;

  // Sidebar menu items
  public sidebarMenuItems: SidebarMenuItem[] = [
    { label: 'Dashboard', icon: 'pi pi-home', route: '/dashboard' },
    { label: 'Weather', icon: 'pi pi-cloud', route: '/weather' },
    { label: 'Analytics', icon: 'pi pi-chart-bar', route: '/analytics' },
    { label: 'Reports', icon: 'pi pi-file', route: '/reports' },
    { label: 'Settings', icon: 'pi pi-cog', route: '/settings' }
  ];

  @ViewChild('profileMenu') profileMenu!: Menu;

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.getForecasts();
    this.initializeDarkMode();
    this.initializeSidebar();
    this.buildProfileMenu();
    this.checkScreenSize();
  }

  @HostListener('window:resize')
  onResize() {
    this.checkScreenSize();
  }

  private checkScreenSize() {
    this.isMobile = window.innerWidth < 768;
    if (this.isMobile) {
      this.sidebarVisible = false;
      this.sidebarPinned = false;
    }
  }

  private initializeDarkMode() {
    const savedTheme = localStorage.getItem('darkMode');
    this.darkMode = savedTheme === 'true';
    this.applyTheme();
  }

  private initializeSidebar() {
    const savedPinned = localStorage.getItem('sidebarPinned');
    this.sidebarPinned = savedPinned !== 'false';
    this.sidebarVisible = this.sidebarPinned;
  }

  private buildProfileMenu() {
    this.profileMenuItems = [
      {
        label: 'Profile',
        items: [
          {
            label: 'My Account',
            icon: 'pi pi-user'
          },
          {
            label: 'Settings',
            icon: 'pi pi-cog'
          }
        ]
      },
      {
        separator: true
      },
      {
        label: 'Logout',
        icon: 'pi pi-sign-out',
        command: () => this.logout()
      }
    ];
  }

  // Sidebar methods
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

  toggleMobileDrawer() {
    this.mobileDrawerVisible = !this.mobileDrawerVisible;
  }

  onMenuItemClick(item: SidebarMenuItem) {
    console.log('Navigate to:', item.route);
    if (this.isMobile) {
      this.mobileDrawerVisible = false;
    }
  }

  onDarkModeChange() {
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

  toggleProfileMenu(event: Event) {
    this.profileMenu.toggle(event);
  }

  logout() {
    console.log('Logout clicked');
  }

  getForecasts() {
    this.http.get<WeatherForecast[]>('/weatherforecast').subscribe({
      next: (result) => {
        this.forecasts = result;
      },
      error: (error) => {
        console.error(error);
      }
    });
  }

  getTemperatureSeverity(tempC: number): 'success' | 'info' | 'warn' | 'danger' | 'secondary' | 'contrast' {
    if (tempC <= 0) return 'info';
    if (tempC <= 15) return 'secondary';
    if (tempC <= 25) return 'success';
    if (tempC <= 35) return 'warn';
    return 'danger';
  }

  protected readonly title = signal('T16O');
}
