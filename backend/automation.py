from playwright.sync_api import sync_playwright
from datetime import datetime, timedelta
import time
import pytz
import base64

class OverlandTrackAutomation:

    def __init__(self):
        pass
    
    def get_next_day(self, date_str):
        try:
            date = datetime.strptime(date_str, "%d/%m/%Y")
        except ValueError:
            date = datetime.strptime(date_str, "%d/%b/%Y")
        next_day = date + timedelta(days=1)
        return next_day.strftime("%d/%m/%Y")

    def automation(self):
        start_time = time.time()
        print("Running Automation...")
        response = {}
        browser = None
        context = None

        with sync_playwright() as p:
            try:
                browser = p.chromium.launch(
                    headless=True,
                    args=[
                        "--disable-gpu",
                        "--no-sandbox",
                        "--single-process",
                        "--no-zygote",
                        "--disable-setuid-sandbox",
                        "--disable-accelerated-2d-canvas",
                        "--disable-dev-shm-usage",
                        "--no-first-run",
                        "--no-default-browser-check",
                        "--disable-background-networking",
                        "--disable-background-timer-throttling",
                        "--disable-client-side-phishing-detection",
                        "--disable-component-update",
                        "--disable-default-apps",
                        "--disable-domain-reliability",
                        "--disable-features=AudioServiceOutOfProcess",
                        "--disable-hang-monitor",
                        "--disable-ipc-flooding-protection",
                        "--disable-popup-blocking",
                        "--disable-prompt-on-repost",
                        "--disable-renderer-backgrounding",
                        "--disable-sync",
                        "--force-color-profile=srgb",
                        "--metrics-recording-only",
                        "--mute-audio",
                        "--no-pings",
                        "--use-gl=swiftshader",
                        "--window-size=1280,1696"
                    ]
                )
                print("Browser launched successfully")
                
                # Give browser time to fully initialize
                time.sleep(2)
                
                if not browser:
                    raise Exception("Failed to launch browser")
                
                context = browser.new_context(ignore_https_errors=True)
                print("Context created successfully")
                page = context.new_page()
                print("Page created successfully")
                page.set_default_timeout(10000)
                print(f"Attempting to navigate to URL...")
                response_obj = page.goto("https://azapps.customlinc.com.au/tasparksoverland/BookingCat/Availability/?Category=OVERLAND", wait_until="networkidle", timeout=30000)
                print(f"Navigation response status: {response_obj.status if response_obj else 'None'}")
                print(f"Current URL: {page.url}")
                print("Navigated Successfully")
                
                screenshot_bytes = page.screenshot()
                encoded_screenshot = base64.b64encode(screenshot_bytes).decode('utf-8')
                print(f"Encoded Screenshot: {encoded_screenshot}")
                
                page.wait_for_selector("#datetimepicker-input", timeout=10000)
                dateToProcess = page.get_attribute("#datetimepicker-input", "value")
                print(f"Today's Date: {dateToProcess}")

                while True:
                    if not page.locator(".bootstrap-datetimepicker-widget").is_visible():
                        page.click("#datetimepicker- > div.input-group-append")
                        page.wait_for_selector(".bootstrap-datetimepicker-widget")
                    
                    # Try to click the date, if not found, skip
                    try:
                        page.wait_for_selector(f"td[data-day='{dateToProcess}']", timeout=5000)
                        page.click(f"td[data-day='{dateToProcess}']")
                        page.wait_for_timeout(500)  # Wait for page to update
                    except Exception as e:
                        print(f"Date {dateToProcess} not found in calendar. Error: {e}")
                        page.click(".datepicker-days th.next > span")
                        continue

                    # Check if no availability text appears
                    if page.locator("text=No availability found").count() > 0:
                        print(f"All dates processed. Terminating Automation..")
                        break

                    for i in range(1, 6):
                        day = page.inner_text(f"#AvailabilityTable > div > div.times-table-template.mt-3.p-0 > div > div > div > div > div.cl_availability-table__body > div > div > div:nth-child({i}) > availabilty-calendar-cell > div > div.GBEDayDate > span.GBEDay.ng-binding")
                        month = page.inner_text(f"#AvailabilityTable > div > div.times-table-template.mt-3.p-0 > div > div > div > div > div.cl_availability-table__body > div > div > div:nth-child({i}) > availabilty-calendar-cell > div > div.GBEDayDate > span.GBEMonth.ng-binding")
                        year = page.inner_text(f"#AvailabilityTable > div > div.times-table-template.mt-3.p-0 > div > div > div > div > div.cl_availability-table__body > div > div > div:nth-child({i}) > availabilty-calendar-cell > div > div.GBEDayDate > span.GBEYear.ng-binding")
                        availability = page.inner_text(f"#AvailabilityTable > div > div.times-table-template.mt-3.p-0 > div > div > div > div > div.cl_availability-table__body > div > div > div:nth-child({i}) > availabilty-calendar-cell > div > div.GBEPaxAvailability.ng-scope.text-center > div")
                        
                        date = "/".join([day, month, year])
                        if availability:
                            availabilityString = f"{availability} spots left"
                        else:
                            availabilityString = None
                        response[date] = availabilityString or "Fully Booked"
                        print(f"{date} - {availabilityString or 'Fully Booked'}")

                        lastDate = date

                    dateToProcess = self.get_next_day(lastDate)
            
            except Exception as e:
                print(f"Error during execution: {e}")
                return None

            finally:
                end_time = time.time()
                print(f"Cleaning up... (Total runtime: {end_time - start_time:.2f}s)")
                
                # Explicit cleanup in correct order
                try:
                    if context:
                        context.close()
                except:
                    pass
                    
                try:
                    if browser:
                        browser.close()
                except:
                    pass
        
        return {"lastUpdated": datetime.now(pytz.timezone('Australia/Sydney')).strftime("%B %d, %Y at %I:%M %p AEST"), "response": response}
