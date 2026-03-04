import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

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
  const router = inject(Router);

  const user = authService.getCurrentUser();
  if (user?.subscription_active) {
    return true;
  }

  alert('You need an active subscription to access this feature.');
  router.navigate(['/dashboard']);
  return false;
};