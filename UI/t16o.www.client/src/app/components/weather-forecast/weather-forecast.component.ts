import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

export interface WeatherForecast {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
}

@Component({
  selector: 'app-weather-forecast',
  templateUrl: './weather-forecast.component.html',
  styleUrl: './weather-forecast.component.css',
  standalone: false
})
export class WeatherForecastComponent implements OnInit {
  public forecasts: WeatherForecast[] = [];
  public loading = true;

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.getForecasts();
  }

  getForecasts() {
    this.loading = true;
    this.http.get<WeatherForecast[]>('/weatherforecast').subscribe({
      next: (result) => {
        this.forecasts = result;
        this.loading = false;
      },
      error: (error) => {
        console.error(error);
        this.loading = false;
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
}
