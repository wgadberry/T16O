import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';

import { ClusterMap } from './cluster-map';

describe('ClusterMap', () => {
  let component: ClusterMap;
  let fixture: ComponentFixture<ClusterMap>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ClusterMap],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting()
      ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ClusterMap);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should initialize with default values', () => {
    expect(component.tokenSymbol).toBe('');
    expect(component.mintAddress).toBe('');
    expect(component.txLimit).toBe(10);
    expect(component.loading).toBe(false);
    expect(component.showLabels).toBe(true);
  });

  it('should have txLimitOptions defined', () => {
    expect(component.txLimitOptions.length).toBe(5);
  });
});
