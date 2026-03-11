import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface SubscriptionStatus {
  subscription_id: string;
  status: string;
  renews_at: number;
}

export interface CheckoutResponse {
  checkout_url: string;
}

@Injectable({
  providedIn: 'root'
})
export class PaymentService {
  private http = inject(HttpClient);
  private apiUrl = 'https://4tl8bevc11.execute-api.ap-southeast-2.amazonaws.com/prod';

  createCheckoutSession(): Observable<CheckoutResponse> {
    return this.http.post<CheckoutResponse>(`${this.apiUrl}/payment/session`, {});
  }
  
  getSubscriptionStatus(): Observable<SubscriptionStatus> {
    return this.http.get<SubscriptionStatus>(`${this.apiUrl}/payment/status`);
  }
}