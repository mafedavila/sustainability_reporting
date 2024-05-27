import { Component } from '@angular/core';

@Component({
  selector: 'app-dashboard2',
  standalone: true,
  template: `
    <iframe
      src="https://your-grafana-instance.com/d/your-dashboard-id-2"
      width="100%"
      height="800"
      frameborder="0">
    </iframe>
  `,
})
export class Dashboard2Component {}
