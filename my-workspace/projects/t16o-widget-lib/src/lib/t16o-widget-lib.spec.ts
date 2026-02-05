import { ComponentFixture, TestBed } from '@angular/core/testing';

import { T16oWidgetLib } from './t16o-widget-lib';

describe('T16oWidgetLib', () => {
  let component: T16oWidgetLib;
  let fixture: ComponentFixture<T16oWidgetLib>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [T16oWidgetLib]
    })
    .compileComponents();

    fixture = TestBed.createComponent(T16oWidgetLib);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
