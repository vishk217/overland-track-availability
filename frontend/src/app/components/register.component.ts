import { Component, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  template: `
    <div class="register-container">
      <p><a routerLink="/">← Back to Calendar</a></p>
      <h2>Register</h2>
      <form [formGroup]="registerForm" (ngSubmit)="onSubmit()">
        <div class="form-group">
          <input type="email" formControlName="email" placeholder="Email" required>
        </div>
        <div class="form-group">
          <input type="password" formControlName="password" placeholder="Password" required>
          <small class="password-hint">Password must be at least 6 characters long</small>
        </div>
        <div class="form-group">
          <input type="password" formControlName="confirmPassword" placeholder="Confirm Password" required>
        </div>
        <button type="submit" [disabled]="registerForm.invalid || loading()">
          {{ loading() ? 'Creating Account...' : 'Register' }}
        </button>
        @if (error) {
          <p class="error">{{ error }}</p>
        }
      </form>
      <p><a routerLink="/login">Already have an account? Login</a></p>
    </div>
  `,
  styles: [`
    .register-container {
      max-width: 400px;
      margin: 3rem auto;
      padding: 2.5rem;
      background: white;
      border-radius: 12px;
      box-shadow: 0 8px 25px rgba(0,0,0,0.1);
      border: 1px solid #e9ecef;
    }
    .register-container > p:first-child {
      margin-top: -0.5rem;
      margin-bottom: 1.5rem;
    }
    .register-container > p:first-child a {
      color: #6c757d;
      text-decoration: none;
      font-size: 0.9rem;
      transition: color 0.2s;
    }
    .register-container > p:first-child a:hover {
      color: #007bff;
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
    input {
      width: 100%;
      padding: 0.875rem;
      border: 2px solid #e9ecef;
      border-radius: 8px;
      font-size: 1rem;
      transition: border-color 0.2s, box-shadow 0.2s;
      box-sizing: border-box;
    }
    input:focus {
      outline: none;
      border-color: #28a745;
      box-shadow: 0 0 0 3px rgba(40,167,69,0.1);
    }
    button {
      width: 100%;
      padding: 0.875rem;
      background: linear-gradient(135deg, #28a745, #20c997);
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
      margin-top: 0.5rem;
    }
    button:hover:not(:disabled) {
      transform: translateY(-1px);
      box-shadow: 0 4px 12px rgba(40,167,69,0.3);
    }
    button:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }
    .error {
      color: #dc3545;
      text-align: center;
      margin-top: 1rem;
      padding: 0.75rem;
      background: #f8d7da;
      border-radius: 6px;
      border: 1px solid #f5c6cb;
    }
    .register-container > p:last-child {
      text-align: center;
      margin-top: 2rem;
      padding-top: 1.5rem;
      border-top: 1px solid #e9ecef;
    }
    .register-container > p:last-child a {
      color: #007bff;
      text-decoration: none;
      font-weight: 500;
    }
    .register-container > p:last-child a:hover {
      text-decoration: underline;
    }
    .password-hint {
      color: #6c757d;
      font-size: 0.85rem;
      margin-top: 0.25rem;
      display: block;
    }
  `]
})
export class RegisterComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);

  registerForm: FormGroup = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
    confirmPassword: ['', Validators.required]
  });

  loading = signal(false);
  error = '';

  constructor() {
    this.registerForm.valueChanges.subscribe(() => {
      if (this.error && this.registerForm.valid) {
        this.error = '';
      }
    });
  }

  onSubmit(): void {
    if (this.registerForm.valid) {
      const { email, password, confirmPassword } = this.registerForm.value;
      
      if (password !== confirmPassword) {
        this.error = 'Passwords do not match';
        return;
      }

      this.loading.set(true);
      this.error = '';
      
      this.authService.register(email, password).subscribe({
        next: () => {
          this.loading.set(false);
          this.router.navigate(['/dashboard']);
        },
        error: (err) => {
          this.error = err.error?.error || 'Registration failed. Please try again.';
          this.loading.set(false);
        }
      });
    }
  }
}