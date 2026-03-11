import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { map, catchError } from 'rxjs/operators';
import { of } from 'rxjs';
import { AuthService } from '../services/auth.service';
import { PaymentService } from '../services/payment.service';

export const authGuard = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  alert('You must be logged in to access this page.');
  router.navigate(['/login']);
  return false;
};

export const subscriptionGuard = () => {
  const authService = inject(AuthService);
  const paymentService = inject(PaymentService);
  const router = inject(Router);

  const user = authService.getCurrentUser();
  if (user?.subscription_active) {
    return true;
  }

  // Check latest subscription status from payment API
  return paymentService.getSubscriptionStatus().pipe(
    map(subscription => {
      if (subscription.status === 'active') {
        return true;
      }
      alert('You need an active subscription to access this feature.');
      router.navigate(['/dashboard']);
      return false;
    }),
    catchError(() => {
      alert('You need an active subscription to access this feature.');
      router.navigate(['/dashboard']);
      return of(false);
    })
  );
};