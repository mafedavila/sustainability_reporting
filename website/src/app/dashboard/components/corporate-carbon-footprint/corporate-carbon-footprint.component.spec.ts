import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CorporateCarbonFootprintComponent } from './corporate-carbon-footprint.component';

describe('CorporateCarbonFootprintComponent', () => {
  let component: CorporateCarbonFootprintComponent;
  let fixture: ComponentFixture<CorporateCarbonFootprintComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CorporateCarbonFootprintComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(CorporateCarbonFootprintComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
