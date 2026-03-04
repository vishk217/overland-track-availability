import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, FormArray } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { NotificationService, NotificationPreference } from '../services/notification.service';

@Component({
  selector: 'app-notifications',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  template: `
    <div class="notifications-container">
      <p><a routerLink="/dashboard">← Back to Dashboard</a></p>
      <h2>Create New Alert</h2>
      
      <form [formGroup]="notificationForm" (ngSubmit)="onSubmit()">
        <div class="form-group">
          <label>Date Range to Monitor</label>
          <div class="date-range">
            <div class="date-input">
              <label class="date-label">Start Date</label>
              <input type="date" formControlName="startDate">
            </div>
            <div class="date-input">
              <label class="date-label">End Date</label>
              <input type="date" formControlName="endDate">
            </div>
          </div>
        </div>
        
        <div class="form-group">
          <label>Alert when spots available ≥</label>
          <input type="number" formControlName="quantity" min="1" max="8">
        </div>
        
        <div class="form-group">
          <label>Contact Method</label>
          <select formControlName="contact_method">
            <option value="email">Email</option>
            <option value="sms">SMS</option>
          </select>
        </div>
        
        <div class="form-group">
          <label>Contact</label>
          <input type="text" formControlName="contact_value" 
                 [placeholder]="notificationForm.get('contact_method')?.value === 'email' ? 'your@email.com' : '+61400000000'">
        </div>
        
        <button type="submit" [disabled]="notificationForm.invalid || loading">
          {{ loading ? 'Creating...' : 'Create Alert' }}
        </button>
        
        @if (dateRangeError) {
          <p class="error">{{ dateRangeError }}</p>
        }
      </form>
    </div>
  `,
  styles: [`
    .notifications-container {
      padding: 2rem;
      max-width: 600px;
      margin: 3rem auto;
      background: white;
      border-radius: 16px;
      box-shadow: 0 8px 25px rgba(0,0,0,0.1);
      border: 1px solid #e9ecef;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    .notifications-container > p:first-child {
      margin-top: -0.5rem;
      margin-bottom: 2rem;
    }
    .notifications-container > p:first-child a {
      color: #6c757d;
      text-decoration: none;
      font-size: 0.9rem;
      transition: color 0.2s;
    }
    .notifications-container > p:first-child a:hover {
      color: #55437e;
    }
    h2 {
      text-align: center;
      color: #55437e;
      margin-bottom: 2rem;
      font-size: 1.8rem;
      font-weight: 600;
    }
    .form-group {
      margin-bottom: 1.5rem;
    }
    label {
      display: block;
      margin-bottom: 0.75rem;
      font-weight: 600;
      color: #495057;
      font-size: 0.95rem;
    }
    input, select {
      width: 100%;
      padding: 0.875rem;
      border: 2px solid #e9ecef;
      border-radius: 8px;
      font-size: 1rem;
      transition: border-color 0.2s, box-shadow 0.2s;
      box-sizing: border-box;
      background: #fff;
    }
    input:focus, select:focus {
      outline: none;
      border-color: #55437e;
      box-shadow: 0 0 0 3px rgba(85,67,126,0.1);
    }
    input::placeholder {
      color: #adb5bd;
    }
    button {
      width: 100%;
      padding: 0.875rem 1.5rem;
      background: linear-gradient(135deg, #55437e, #443366);
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s ease;
      margin-top: 1rem;
    }
    button:hover:not(:disabled) {
      background: linear-gradient(135deg, #443366, #332255);
      transform: translateY(-1px);
      box-shadow: 0 4px 12px rgba(85,67,126,0.3);
    }
    button:disabled {
      opacity: 0.6;
      cursor: not-allowed;
      transform: none;
    }
    .date-range {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1rem;
    }
    .date-input {
      display: flex;
      flex-direction: column;
    }
    .date-label {
      font-size: 0.85rem;
      color: #6c757d;
      margin-bottom: 0.5rem;
      font-weight: 500;
    }
    .error {
      color: #dc3545;
      text-align: center;
      margin-top: 1rem;
      padding: 0.75rem;
      background: #f8d7da;
      border-radius: 6px;
      border: 1px solid #f5c6cb;
      font-size: 0.9rem;
    }
    @media (max-width: 768px) {
      .date-range {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class NotificationsComponent {
  private fb = inject(FormBuilder);
  private notificationService = inject(NotificationService);
  private router = inject(Router);

  notificationForm: FormGroup = this.fb.group({
    startDate: ['', Validators.required],
    endDate: ['', Validators.required],
    quantity: [1, [Validators.required, Validators.min(1), Validators.max(8)]],
    contact_method: ['sms', Validators.required],
    contact_value: ['', Validators.required],
    active: [true]
  });

  loading = false;
  dateRangeError = '';

  onSubmit(): void {
    if (this.notificationForm.valid) {
      this.loading = true;
      this.dateRangeError = '';
      
      const formValue = this.notificationForm.value;
      
      // Generate date range array from start and end dates
      const startDate = new Date(formValue.startDate);
      const endDate = new Date(formValue.endDate);
      
      if (startDate > endDate) {
        this.dateRangeError = 'Start date must be before or equal to end date.';
        this.loading = false;
        return;
      }
      
      const dates = [];
      
      for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
        dates.push(d.toLocaleDateString('en-AU', {
          day: 'numeric',
          month: 'short',
          year: 'numeric'
        }).replace(/ /g, '/'));
      }
      
      if (dates.length === 0) {
        this.dateRangeError = 'Please select a valid date range.';
        this.loading = false;
        return;
      }
      
      const preference = {
        dates,
        quantity: formValue.quantity,
        contact_method: formValue.contact_method,
        contact_value: formValue.contact_value,
        active: formValue.active
      };

      this.notificationService.savePreference(preference).subscribe({
        next: () => {
          this.notificationForm.reset();
          this.loading = false;
          this.router.navigate(['/dashboard']);
        },
        error: (err) => {
          console.error('Failed to save preference:', err);
          this.loading = false;
        }
      });
    }
  }
}