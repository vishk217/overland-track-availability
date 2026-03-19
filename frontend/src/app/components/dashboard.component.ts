import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule, ActivatedRoute } from '@angular/router';
import { AuthService, User } from '../services/auth.service';
import { PaymentService, SubscriptionStatus } from '../services/payment.service';
import { NotificationService, NotificationPreference } from '../services/notification.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="dashboard">
      <p><a routerLink="/">← Back to Calendar</a></p>
      <header>
        <div>
          <h1>Alert Dashboard</h1>
          @if (user()) {
            <p class="signed-in-text">Signed in as {{ user()?.email }}</p>
          }
        </div>
        <button (click)="logout()">Logout</button>
      </header>
      
      @if (showSuccessMessage()) {
        <div class="success-message">
          <p>🎉 Payment successful! Your subscription is now active.</p>
          <button (click)="dismissSuccess()" class="dismiss-btn">×</button>
        </div>
      }
      
      @if (subscriptionLoading()) {
        <div class="loading-container">
          <div class="loading-spinner"></div>
          <p>Loading subscription status...</p>
        </div>
      } @else if (subscription()) {
        <div class="subscription-status">
          <h3>Subscription Status</h3>
          <p>Status: <span [class]="subscription()?.status">{{ subscription()?.status }}</span></p>
          @if (subscription()?.renews_at) {
            <p>
              <span [class]="subscription()?.will_cancel ? 'expires-text' : ''">
                {{ subscription()?.will_cancel ? 'Expires On' : 'Renews' }}
              </span>: {{ subscription()?.renews_at | date }}
            </p>
          }
        </div>
      }

      <nav class="dashboard-nav">
        @if (subscriptionLoading()) {
          <div class="nav-loading">
            <div class="loading-spinner"></div>
            <p>Loading...</p>
          </div>
        } @else if (subscription()?.status === 'active') {
          <a routerLink="/notifications" class="nav-button">Create New Alert</a>
          <a [href]="billingUrl" target="_blank" class="nav-button">Manage Billing</a>
        } @else {
          <div class="subscription-info">
            <p class="subscription-text">While we'd love to offer this service for free, a small $2.99 subscription is currently needed to cover SMS and email delivery costs.</p>
            <button (click)="activateSubscription()" [disabled]="loading()" class="nav-button activate-btn">
              {{ loading() ? 'Processing...' : 'Recieve alerts for $2.99 p/w' }}
            </button>
          </div>
        }
      </nav>

      @if (subscriptionLoading()) {
        <!-- Show loading while subscription status loads -->
      } @else if (subscription()?.status === 'active') {
        @if (preferences().length > 0) {
          <div class="existing-notifications">
            <h3>Active Alerts ({{ preferences().length }})</h3>
            @for (pref of preferences(); track pref.notification_id) {
              <div class="notification-item">
                <div class="notification-details">
                  <p><strong>Dates:</strong> {{ pref.dates[0] }} - {{ pref.dates[pref.dates.length - 1] }}</p>
                  <p><strong>Quantity:</strong> {{ pref.quantity }}+</p>
                  <p><strong>Contact:</strong> {{ pref.contact_method }} - {{ pref.contact_value }}</p>
                </div>
                <button (click)="deleteNotification(pref.notification_id)" class="delete-btn">Delete</button>
              </div>
            }
          </div>
        } @else {
          <div class="existing-notifications">
            <h3>Active Alerts (0)</h3>
            <p class="no-notifications">No active alerts. Create your first alert to get started!</p>
          </div>
        }
      }
    </div>
  `,
  styles: [`
    .dashboard {
      padding: 2rem;
      max-width: 900px;
      margin: 0 auto;
      min-height: 100vh;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    .dashboard > p:first-child {
      margin-top: -0.5rem;
      margin-bottom: 1.5rem;
    }
    .dashboard > p:first-child a {
      color: #6c757d;
      text-decoration: none;
      font-size: 0.9rem;
      transition: color 0.2s;
    }
    .dashboard > p:first-child a:hover {
      color: #55437e;
    }
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 3rem;
      padding: 2rem;
    }
    header h1 {
      color: #55437e;
      font-size: 2rem;
      font-weight: 700;
      margin: 0 0 0.5rem 0;
    }
    .signed-in-text {
      color: #6c757d;
      font-size: 0.9rem;
      margin: 0;
    }
    header button {
      padding: 0.75rem 1.5rem;
      background: #6c757d;
      color: white;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s ease;
    }
    header button:hover {
      background: #5a6268;
      transform: translateY(-1px);
    }
    .subscription-status {
      background: white;
      padding: 2rem;
      border-radius: 16px;
      margin-bottom: 2rem;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      border: 1px solid #e9ecef;
    }
    .subscription-status h3 {
      color: #55437e;
      font-size: 1.4rem;
      margin-bottom: 1rem;
      font-weight: 600;
    }
    .subscription-status p {
      font-size: 1.1rem;
      margin-bottom: 0.5rem;
      color: #495057;
    }
    .subscription-info {
      text-align: center;
    }
    .subscription-text {
      color: #6c757d;
      font-size: 1rem;
      margin-bottom: 1.5rem;
      line-height: 1.5;
    }
    .dashboard-nav {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1.5rem;
      margin-bottom: 3rem;
    }
    .nav-button {
      padding: 1.5rem;
      background: white;
      color: #55437e;
      text-decoration: none;
      border-radius: 16px;
      text-align: center;
      font-weight: 600;
      font-size: 1.1rem;
      transition: all 0.3s ease;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      border: 2px solid #e9ecef;
      cursor: pointer;
    }
    .nav-button:hover {
      background: #55437e;
      color: white;
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(85,67,126,0.2);
    }
    .activate-btn {
      background: #4da6ff;
      color: white;
      border-color: #4da6ff;
    }
    .activate-btn:hover {
      background: #3399ff;
      border-color: #3399ff;
    }
    .activate-btn:disabled {
      background: #6c757d;
      border-color: #6c757d;
      cursor: not-allowed;
      transform: none;
    }
    .active {
      color: #28a745;
      font-weight: 700;
      background: #d4edda;
      padding: 0.25rem 0.5rem;
      border-radius: 4px;
    }
    .inactive {
      color: #dc3545;
      font-weight: 700;
      background: #f8d7da;
      padding: 0.25rem 0.5rem;
      border-radius: 4px;
    }
    .success-message {
      background: linear-gradient(135deg, #d4edda, #c3e6cb);
      color: #155724;
      padding: 1.5rem;
      border-radius: 12px;
      margin-bottom: 2rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 4px 15px rgba(21,87,36,0.1);
      border: 1px solid #c3e6cb;
    }
    .success-message p {
      font-size: 1.1rem;
      font-weight: 600;
      margin: 0;
    }
    .dismiss-btn {
      background: none;
      border: none;
      font-size: 1.5rem;
      cursor: pointer;
      color: #155724;
      padding: 0.25rem 0.5rem;
      border-radius: 4px;
      transition: background 0.2s;
    }
    .dismiss-btn:hover {
      background: rgba(21,87,36,0.1);
    }
    .existing-notifications {
      background: white;
      padding: 2rem;
      border-radius: 16px;
      margin-bottom: 2rem;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      border: 1px solid #e9ecef;
    }
    .existing-notifications h3 {
      color: #55437e;
      font-size: 1.4rem;
      margin-bottom: 1rem;
      font-weight: 600;
    }
    .no-notifications {
      color: #6c757d;
      font-style: italic;
      text-align: center;
      padding: 2rem;
      margin: 0;
    }
    .notification-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1rem;
      border: 1px solid #e9ecef;
      border-radius: 8px;
      margin-bottom: 1rem;
      background: #f8f9fa;
    }
    .notification-details p {
      margin: 0.25rem 0;
      font-size: 0.9rem;
      color: #495057;
    }
    .delete-btn {
      background: #dc3545;
      color: white;
      border: none;
      padding: 0.5rem 1rem;
      border-radius: 4px;
      cursor: pointer;
      font-size: 0.9rem;
      transition: background 0.2s;
    }
    .loading-container, .nav-loading {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 2rem;
      background: white;
      border-radius: 16px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      border: 1px solid #e9ecef;
      margin-bottom: 2rem;
    }
    .nav-loading {
      margin-bottom: 0;
    }
    .loading-spinner {
      width: 40px;
      height: 40px;
      border: 4px solid #e9ecef;
      border-top: 4px solid #55437e;
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin-bottom: 1rem;
    }
    .loading-container p, .nav-loading p {
      color: #6c757d;
      margin: 0;
      font-size: 1rem;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    .expires-text {
      color: #dc3545;
      font-weight: 600;
    }
    @media (max-width: 768px) {
      header {
        flex-direction: column;
        align-items: stretch;
        gap: 1rem;
      }
      header h1 {
        text-align: center;
      }
      header button {
        order: 1;
        margin-top: 1rem;
      }
    }
  `]
})
export class DashboardComponent implements OnInit {
  private authService = inject(AuthService);
  private paymentService = inject(PaymentService);
  private notificationService = inject(NotificationService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  user = signal<User | null>(null);
  subscription = signal<SubscriptionStatus | null>(null);
  preferences = signal<NotificationPreference[]>([]);
  showSuccessMessage = signal(false);
  loading = signal(false);
  subscriptionLoading = signal(false);
  billingUrl = (globalThis as any).process?.env?.['STRIPE_BILLING_URL'] || 'https://billing.stripe.com/p/login/test_aFa4gy5Wn2hW0358s26c000'; // #TODO

  ngOnInit(): void {
    this.user.set(this.authService.getCurrentUser());
    this.loadSubscriptionStatus();
    this.loadPreferences();
    
    // Check for success query parameter
    this.route.queryParams.subscribe(params => {
      if (params['success'] === 'true') {
        this.showSuccessMessage.set(true);
        // Remove query parameter from URL
        this.router.navigate([], { 
          relativeTo: this.route, 
          queryParams: {}, 
          replaceUrl: true 
        });
      }
    });
  }

  loadSubscriptionStatus(): void {
    this.subscriptionLoading.set(true);
    this.paymentService.getSubscriptionStatus().subscribe({
      next: (sub) => {
        this.subscription.set(sub);
        this.subscriptionLoading.set(false);
      },
      error: (err) => {
        console.error('Failed to load subscription:', err);
        this.subscriptionLoading.set(false);
      }
    });
  }

  loadPreferences(): void {
    this.notificationService.getPreferences().subscribe({
      next: (prefs) => this.preferences.set(prefs),
      error: (err) => console.error('Failed to load preferences:', err)
    });
  }

  deleteNotification(notificationId: string): void {
    this.notificationService.deletePreference(notificationId).subscribe({
      next: () => this.loadPreferences(),
      error: (err) => console.error('Failed to delete notification:', err)
    });
  }

  dismissSuccess(): void {
    this.showSuccessMessage.set(false);
  }

  activateSubscription(): void {
    this.loading.set(true);
    console.log('Starting checkout session creation...');
    this.paymentService.createCheckoutSession().subscribe({
      next: (response) => {
        console.log('Checkout session response:', response);
        if (response.checkout_url) {
          window.location.href = response.checkout_url;
        } else {
          console.error('No checkout URL in response');
          this.loading.set(false);
        }
      },
      error: (err) => {
        console.error('Checkout failed:', err);
        this.loading.set(false);
      },
      complete: () => {
        console.log('Checkout session request completed');
      }
    });
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/']);
  }
}