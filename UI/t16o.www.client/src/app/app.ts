import { HttpClient } from '@angular/common/http';
import { Component, OnInit, signal, ViewChild } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { Menu } from 'primeng/menu';

interface WeatherForecast {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
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

  @ViewChild('profileMenu') profileMenu!: Menu;

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.getForecasts();
    this.initializeDarkMode();
    this.buildProfileMenu();
  }

  private initializeDarkMode() {
    const savedTheme = localStorage.getItem('darkMode');
    this.darkMode = savedTheme === 'true';
    this.applyTheme();
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
