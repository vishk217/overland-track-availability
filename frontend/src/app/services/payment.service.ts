import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface SubscriptionResponse {
  subscription_id: string;
  status: string;
  expires_at: string;
}

export interface CheckoutSessionResponse {
  checkout_url: string;
}

@Injectable({
  providedIn: 'root'
})
export class PaymentService {
  private http = inject(HttpClient);
  private apiUrl = 'https://4tl8bevc11.execute-api.ap-southeast-2.amazonaws.com/prod';

  createCheckoutSession(): Observable<CheckoutSessionResponse> {
    return this.http.post<CheckoutSessionResponse>(`${this.apiUrl}/payment/session`, {});
  }

  createSubscription(): Observable<SubscriptionResponse> {
    return this.http.post<SubscriptionResponse>(`${this.apiUrl}/payment`, {});
  }

  getSubscriptionStatus(): Observable<SubscriptionResponse> {
    return this.http.get<SubscriptionResponse>(`${this.apiUrl}/payment/status`);
  }
}