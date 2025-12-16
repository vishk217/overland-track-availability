from playwright.sync_api import sync_playwright
from datetime import datetime, timedelta
import time

class OverlandTrackAutomation:

    def __init__(self):
        pass
    
    def get_next_day(self, date_str):
        date = datetime.strptime(date_str, "%d/%b/%Y")
        next_day = date + timedelta(days=1)
        return next_day.strftime("%d/%m/%Y")

    def automation(self):
        start_time = time.time()
        print("Running Automation...")

        with sync_playwright() as p:

            try:
                browser = p.chromium.launch(
                    headless=True,
                )
                context = browser.new_context(ignore_https_errors=True)
                page = context.new_page()
                page.set_default_timeout(10000)
                page.goto("https://azapps.customlinc.com.au/tasparksoverland/BookingCat/Availability/?Category=OVERLAND")

                response = {}
                
                dateToProcess = page.get_attribute("#datetimepicker-input", "value")
                print(f"Today's Date: {dateToProcess}")

                while True:

                    page.click("#datetimepicker-input")
                    page.wait_for_selector(".bootstrap-datetimepicker-widget")
                    
                    # Try to click the date, if not found, skip
                    try:
                        page.wait_for_selector(f"td[data-day='{dateToProcess}']", timeout=2000)
                        page.click(f"td[data-day='{dateToProcess}']")
                        page.wait_for_timeout(500)  # Wait for page to update
                    except:
                        print(f"Date {dateToProcess} not found in calendar")
                        dateToProcess = self.get_next_day(dateToProcess)
                        continue

                    # Check if no availability text appears
                    if page.locator("text=No availability found").count() > 0:
                        print(f"All dates processed. Terminating Automation..")
                        outcome = {"lastUpdated": datetime.now().strftime("%B %d, %Y at %I:%M %p"), "response": response}
                        return outcome

                    for i in range(1, 6):
                        day = page.inner_text(f"#AvailabilityTable > div > div.times-table-template.mt-3.p-0 > div > div > div > div > div.cl_availability-table__body > div > div > div:nth-child({i}) > availabilty-calendar-cell > div > div.GBEDayDate > span.GBEDay.ng-binding")
                        month = page.inner_text(f"#AvailabilityTable > div > div.times-table-template.mt-3.p-0 > div > div > div > div > div.cl_availability-table__body > div > div > div:nth-child({i}) > availabilty-calendar-cell > div > div.GBEDayDate > span.GBEMonth.ng-binding")
                        year = page.inner_text(f"#AvailabilityTable > div > div.times-table-template.mt-3.p-0 > div > div > div > div > div.cl_availability-table__body > div > div > div:nth-child({i}) > availabilty-calendar-cell > div > div.GBEDayDate > span.GBEYear.ng-binding")
                        availability = page.inner_text(f"#AvailabilityTable > div > div.times-table-template.mt-3.p-0 > div > div > div > div > div.cl_availability-table__body > div > div > div:nth-child({i}) > availabilty-calendar-cell > div > div.GBEPaxAvailability.ng-scope.text-center > div")
                        
                        date = "/".join([day, month, year])
                        response[date] = availability or "Unavailable"
                        print(f"{date} - {availability or "Unavailable"}")

                        lastDate = date

                    dateToProcess = self.get_next_day(lastDate)
            
            except Exception as e:
                print(f"Error during execution: {e}")

            finally:
                end_time = time.time()
                print(f"Closing the browser... (Total runtime: {end_time - start_time:.2f}s)")
                browser.close()

