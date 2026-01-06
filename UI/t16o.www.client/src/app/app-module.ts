import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { providePrimeNG } from 'primeng/config';
import Aura from '@primeng/themes/aura';

import { TableModule } from 'primeng/table';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';
import { ButtonModule } from 'primeng/button';
import { ToolbarModule } from 'primeng/toolbar';
import { AvatarModule } from 'primeng/avatar';
import { MenuModule } from 'primeng/menu';
import { ToggleSwitchModule } from 'primeng/toggleswitch';
import { RippleModule } from 'primeng/ripple';
import { TooltipModule } from 'primeng/tooltip';
import { DrawerModule } from 'primeng/drawer';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

import { AppRoutingModule } from './app-routing-module';
import { App } from './app';

// Components
import { TopBarComponent } from './components/top-bar/top-bar.component';
import { SidebarComponent } from './components/sidebar/sidebar.component';
import { WeatherForecastComponent } from './components/weather-forecast/weather-forecast.component';

// Pages
import { DashboardPage } from './pages/dashboard/dashboard.page';
import { WeatherPage } from './pages/weather/weather.page';

@NgModule({
  declarations: [
    App,
    // Components
    TopBarComponent,
    SidebarComponent,
    WeatherForecastComponent,
    // Pages
    DashboardPage,
    WeatherPage
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    FormsModule,
    CommonModule,
    AppRoutingModule,
    TableModule,
    CardModule,
    TagModule,
    ButtonModule,
    ToolbarModule,
    AvatarModule,
    MenuModule,
    ToggleSwitchModule,
    RippleModule,
    TooltipModule,
    DrawerModule
  ],
  providers: [
    providePrimeNG({
      theme: {
        preset: Aura,
        options: {
          darkModeSelector: '.dark-mode'
        }
      },
      ripple: true
    })
  ],
  bootstrap: [App]
})
export class AppModule { }
