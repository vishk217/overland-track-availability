import {
  Component,
  InputSignal,
  Signal,
  WritableSignal,
  computed,
  input,
  signal,
  OnInit,
  inject,
} from '@angular/core';
import { DateTime, Info, Interval } from 'luxon';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';

interface AvailabilityData {
  lastUpdated: string;
  response: Record<string, string>;
}

@Component({
  selector: 'calendar',
  templateUrl: './calendar.html',
  styleUrls: ['./calendar.css'],
  imports: [CommonModule],
  standalone: true,
})
export class CalendarComponent implements OnInit {
  private http = inject(HttpClient);
  today: Signal<DateTime> = signal(DateTime.local());
  firstDayOfActiveMonth: WritableSignal<DateTime> = signal(
    this.today().startOf('month'),
  );
  activeDay: WritableSignal<DateTime | null> = signal(null);
  availabilityData: WritableSignal<AvailabilityData | null> = signal(null);
  weekDays: Signal<string[]> = signal(Info.weekdays('short'));
  daysOfMonth: Signal<DateTime[]> = computed(() => {
    return Interval.fromDateTimes(
      this.firstDayOfActiveMonth().startOf('week'),
      this.firstDayOfActiveMonth().endOf('month').endOf('week'),
    )
      .splitBy({ day: 1 })
      .map((d) => {
        if (d.start === null) {
          throw new Error('Wrong dates');
        }
        return d.start;
      });
  });
  DATE_MED = DateTime.DATE_MED;

  goToPreviousMonth(): void {
    this.firstDayOfActiveMonth.set(
      this.firstDayOfActiveMonth().minus({ month: 1 }),
    );
  }

  goToNextMonth(): void {
    this.firstDayOfActiveMonth.set(
      this.firstDayOfActiveMonth().plus({ month: 1 }),
    );
  }

  goToToday(): void {
    this.firstDayOfActiveMonth.set(this.today().startOf('month'));
  }

  ngOnInit(): void {
    this.loadAvailabilityData();
  }

  private loadAvailabilityData(): void {
    this.http.get<AvailabilityData>('https://overland-track-data.s3.ap-southeast-2.amazonaws.com/availability.json')
      .subscribe({
        next: (data) => this.availabilityData.set(data),
        error: (error) => console.error('Failed to load availability data:', error)
      });
  }

  getAvailabilityStatus(date: DateTime): string {
    const data = this.availabilityData();
    if (!data) return 'Unknown';
    
    const dateKey = date.toFormat('d/MMM/yyyy');
    const status = data.response[dateKey];
    
    if (!status) return 'Unknown';
    if (status === 'Fully Booked') return 'Fully Booked';
    if (status.includes('Available')) return 'Available';
    return 'Unknown';
  }

  getAvailabilityText(date: DateTime): string {
    const data = this.availabilityData();
    if (!data) return '';
    
    const dateKey = date.toFormat('d/MMM/yyyy');

    if (data.response[dateKey] && data.response[dateKey] === "Fully Booked") {
      return ""
    }
    return data.response[dateKey] || '';
  }

  onDateClick(date: DateTime): void {
    if (this.getAvailabilityStatus(date) === 'Available') {
      window.open('https://azapps.customlinc.com.au/tasparksoverland/BookingCat/Availability/?Category=OVERLAND', '_blank');
    } else {
      this.activeDay.set(date);
    }
  }
}