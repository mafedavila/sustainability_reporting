import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ProductCarbonFootprintComponent } from './product-carbon-footprint.component';

describe('ProductCarbonFootprintComponent', () => {
  let component: ProductCarbonFootprintComponent;
  let fixture: ComponentFixture<ProductCarbonFootprintComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ProductCarbonFootprintComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ProductCarbonFootprintComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
