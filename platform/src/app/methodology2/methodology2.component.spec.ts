import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Methodology2Component } from './methodology2.component';

describe('Methodology2Component', () => {
  let component: Methodology2Component;
  let fixture: ComponentFixture<Methodology2Component>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Methodology2Component]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(Methodology2Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
