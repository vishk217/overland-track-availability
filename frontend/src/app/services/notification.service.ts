import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface NotificationPreference {
  user_id: string;
  notification_id: string;
  dates: string[];
  quantity: number;
  contact_method: 'email' | 'sms';
  contact_value: string;
  active: boolean;
  created_at: string;
}

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  private http = inject(HttpClient);
  private apiUrl = 'https://4tl8bevc11.execute-api.ap-southeast-2.amazonaws.com/prod';

  getPreferences(): Observable<NotificationPreference[]> {
    return this.http.get<NotificationPreference[]>(`${this.apiUrl}/notifications`);
  }

  savePreference(notification: Omit<NotificationPreference, 'user_id' | 'notification_id' | 'created_at'>): Observable<NotificationPreference> {
    return this.http.put<NotificationPreference>(`${this.apiUrl}/notifications`, notification);
  }

  deletePreference(notificationId: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/notifications/${notificationId}`);
  }
}