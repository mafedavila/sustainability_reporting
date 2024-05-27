import { Routes } from '@angular/router';
import { WelcomeComponent } from './welcome/welcome.component';
import { CorporateCarbonFootprintComponent } from './corporate-carbon-footprint/corporate-carbon-footprint.component';
import { ProductCarbonFootprintComponent } from './product-carbon-footprint/product-carbon-footprint.component';
import { MethodologyComponent } from './methodology/methodology.component';
import { DashboardComponent } from './dashboard/dashboard.component';
import { Methodology2Component } from './methodology2/methodology2.component';
import { Dashboard2Component } from './dashboard2/dashboard2.component';

export const routes: Routes = [
  { path: '', component: WelcomeComponent },
  { path: 'corporate-carbon-footprint', component: CorporateCarbonFootprintComponent, children: [
    { path: '', component: MethodologyComponent },
    { path: 'methodology', component: MethodologyComponent },
    { path: 'dashboard', component: DashboardComponent }
  ]},
  { path: 'product-carbon-footprint', component: ProductCarbonFootprintComponent, children: [
    { path: '', component: Methodology2Component },
    { path: 'methodology', component: Methodology2Component },
    { path: 'dashboard', component: Dashboard2Component }
  ]}
];
