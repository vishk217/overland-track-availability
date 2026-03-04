import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface NotificationPreference {
  notification_id: string;
  dates: string[];
  quantity: number;
  contact_method: 'email' | 'sms';
  contact_value: string;
  active: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  private http = inject(HttpClient);
  private apiUrl = 'https://your-api-gateway-url/prod'; // #TODO

  getPreferences(): Observable<NotificationPreference[]> {
    return this.http.get<NotificationPreference[]>(`${this.apiUrl}/notifications`);
  }

  savePreference(preference: Omit<NotificationPreference, 'notification_id'>): Observable<NotificationPreference> {
    return this.http.put<NotificationPreference>(`${this.apiUrl}/notifications`, preference);
  }

  deletePreference(notificationId: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/notifications/${notificationId}`);
  }
}