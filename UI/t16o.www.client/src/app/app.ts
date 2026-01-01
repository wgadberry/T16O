import { HttpClient } from '@angular/common/http';
import { Component, OnInit, signal } from '@angular/core';

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

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.getForecasts();
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

  protected readonly title = signal('t16o.www.client');
}
