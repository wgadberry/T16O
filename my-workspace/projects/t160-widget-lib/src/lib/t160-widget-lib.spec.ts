import { ComponentFixture, TestBed } from '@angular/core/testing';

import { T160WidgetLib } from './t160-widget-lib';

describe('T160WidgetLib', () => {
  let component: T160WidgetLib;
  let fixture: ComponentFixture<T160WidgetLib>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [T160WidgetLib]
    })
    .compileComponents();

    fixture = TestBed.createComponent(T160WidgetLib);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
