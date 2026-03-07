import { ApplicationConfig, provideBrowserGlobalErrorListeners, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { providePrimeNG } from 'primeng/config';
import Aura from '@primeng/themes/aura';

import { routes } from './app.routes';
import { CLUSTER_MAP_API_URL, CLUSTER_MAP_WALLET_TX_URL } from 't160-widget-lib';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(),
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
    // Point to local C# proxy (proxied via proxy.conf.json → https://localhost:5101)
    { provide: CLUSTER_MAP_API_URL, useValue: '/api/bubblemap' },
    { provide: CLUSTER_MAP_WALLET_TX_URL, useValue: '/api/bubblemap/wallet-txs' }
  ]
};
