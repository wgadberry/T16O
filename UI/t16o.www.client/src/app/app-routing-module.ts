import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { DashboardPage } from './pages/dashboard/dashboard.page';
import { WeatherPage } from './pages/weather/weather.page';
import { ClusterMapsPage } from './pages/analytics/cluster-maps/cluster-maps.page';
import { WalletTrailsPage } from './pages/analytics/wallet-trails/wallet-trails.page';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardPage },
  { path: 'weather', component: WeatherPage },
  { path: 'analytics/cluster-maps', component: ClusterMapsPage },
  { path: 'analytics/wallet-trails', component: WalletTrailsPage },
  { path: '**', redirectTo: '/dashboard' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
