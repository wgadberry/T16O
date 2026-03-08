import { ApplicationConfig, provideBrowserGlobalErrorListeners, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { providePrimeNG } from 'primeng/config';
import Aura from '@primeng/themes/aura';

import { routes } from './app.routes';
import { CLUSTER_MAP_API_URL, CLUSTER_MAP_WALLET_TX_URL } from 't160-widget-lib';
import { apiAuthInterceptor, API_CLIENT_ID, API_CLIENT_SECRET } from './api-auth.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withInterceptors([apiAuthInterceptor])),
    provideAnimationsAsync(),
    providePrimeNG({
      theme: {
        preset: Aura,
        options: {
          darkModeSelector: '.dark-mode',
          cssLayer: false
        }
      }
    }),
    // Client credentials for t16o-api auth
    { provide: API_CLIENT_ID, useValue: 'demo' },
    { provide: API_CLIENT_SECRET, useValue: 'a3f1b2c4-d5e6-7890-abcd-ef1234567890' },
    // Point to local C# proxy (proxied via proxy.conf.json → https://localhost:5101)
    { provide: CLUSTER_MAP_API_URL, useValue: '/api/bubblemap' },
    { provide: CLUSTER_MAP_WALLET_TX_URL, useValue: '/api/bubblemap/wallet-txs' }
  ]
};
