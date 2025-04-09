import requests
import pandas as pd
import gspread
import sys
from oauth2client.service_account import ServiceAccountCredentials

# **Step 1: Get course ID from Flutter**
if len(sys.argv) < 2:
    print("Error: Missing course ID argument.")
    sys.exit(1)

course_id = sys.argv[1]  # Get course ID from command-line argument
print(f"Fetching data for Course ID: {course_id}")

# **Step 2: Google Sheets API Authentication**
scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name("your_google_credentials.json", scope)
client = gspread.authorize(creds)

# Open the Google Sheet
sheet = client.open("Marks_update_all").sheet1

# **Step 3: Fetch Data from API with Course ID**
url = f"http://13.60.85.45/flutter/get_result_data.php?courseid={course_id}"
response = requests.get(url)
data = response.json()

# Convert JSON to DataFrame
df = pd.DataFrame(data)

# Convert column types to avoid errors
df[['studentid', 'courseid', 'subjectid']] = df[['studentid', 'courseid', 'subjectid']].apply(pd.to_numeric)

# **Pivot Table: subjectname as Columns, subjectid as Values**
df_pivot = df.pivot(index=['studentid', 'studentname', 'coursename', 'courseid'],
                     columns='subjectname',
                     values='subjectid')

# Fix: Replace NaN and infinite values with empty strings
df_pivot = df_pivot.replace([float('inf'), float('-inf')], "").fillna("")

# Reset index to remove multi-indexing
df_pivot.reset_index(inplace=True)
df_pivot.columns.name = None  # Remove column index name

# **Step 4: Update Google Sheets**
data_list = [df_pivot.columns.tolist()] + df_pivot.values.tolist()

# Clear existing data and update with new data
sheet.clear()
sheet.update(data_list)

print("✅ Google Sheets updated successfully!")
