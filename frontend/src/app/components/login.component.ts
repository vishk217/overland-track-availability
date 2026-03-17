import { Component, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  template: `
    <div class="login-container">
      <p><a routerLink="/">← Back to Calendar</a></p>
      <h2>Login</h2>
      <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
        <div class="form-group">
          <input type="email" formControlName="email" placeholder="Email" required>
        </div>
        <div class="form-group">
          <input type="password" formControlName="password" placeholder="Password" required>
        </div>
        <button type="submit" [disabled]="loginForm.invalid || loading()">
          @if (loading()) {
            <span class="spinner"></span>
          } @else {
            Login
          }
        </button>
        @if (error) {
          <p class="error">{{ error }}</p>
        }
      </form>
      <p><a routerLink="/register">Don't have an account? Register</a></p>
    </div>
  `,
  styles: [`
    .login-container {
      max-width: 400px;
      margin: 3rem auto;
      padding: 2.5rem;
      background: white;
      border-radius: 12px;
      box-shadow: 0 8px 25px rgba(0,0,0,0.1);
      border: 1px solid #e9ecef;
    }
    .login-container > p:first-child {
      margin-top: -0.5rem;
      margin-bottom: 1.5rem;
    }
    .login-container > p:first-child a {
      color: #6c757d;
      text-decoration: none;
      font-size: 0.9rem;
      transition: color 0.2s;
    }
    .login-container > p:first-child a:hover {
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
      border-color: #007bff;
      box-shadow: 0 0 0 3px rgba(0,123,255,0.1);
    }
    button {
      width: 100%;
      padding: 0.875rem;
      background: linear-gradient(135deg, #007bff, #0056b3);
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
      box-shadow: 0 4px 12px rgba(0,123,255,0.3);
    }
    button:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }
    .spinner {
      display: inline-block;
      width: 20px;
      height: 20px;
      border: 3px solid rgba(255,255,255,0.3);
      border-top-color: white;
      border-radius: 50%;
      animation: spin 0.6s linear infinite;
      vertical-align: middle;
    }
    @keyframes spin {
      to { transform: rotate(360deg); }
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
    .login-container > p:last-child {
      text-align: center;
      margin-top: 2rem;
      padding-top: 1.5rem;
      border-top: 1px solid #e9ecef;
    }
    .login-container > p:last-child a {
      color: #007bff;
      text-decoration: none;
      font-weight: 500;
    }
    .login-container > p:last-child a:hover {
      text-decoration: underline;
    }
  `]
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);

  loginForm: FormGroup = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', Validators.required]
  });

  loading = signal(false);
  error = '';

  constructor() {
    this.loginForm.valueChanges.subscribe(() => {
      if (this.error && this.loginForm.valid) {
        this.error = '';
      }
    });
  }

  onSubmit(): void {
    if (this.loginForm.valid) {
      this.loading.set(true);
      this.error = '';
      
      const { email, password } = this.loginForm.value;
      this.authService.login(email, password).subscribe({
        next: () => {
          this.loading.set(false);
          this.router.navigate(['/dashboard']);
        },
        error: (err) => {
          this.error = err.error?.error || 'Login failed. Please check your credentials.';
          this.loading.set(false);
        }
      });
    }
  }
}