

import os
import webbrowser
from google.oauth2 import service_account
from googleapiclient.discovery import build


SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

# The ID and range of your spreadsheet.
SPREADSHEET_ID = '192h3aBgL1LZdifFXEM_ZQVqlpv2uPxT0z7v5Uu6P4PQ'
RANGE_SHEET1 = 'Sheet1!A1:Z1000'  # Adjust as needed
RANGE_SHEET2 = 'Sheet2!A1:Z1000'  # Adjust as needed

# This file contains credentails
SERVICE_ACCOUNT_FILE = 'jsonfile.json'

def automate_spreadsheet():
    try:
        # This line reads the credentials from your JSON file and creates a Credentials object.
        creds = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE, scopes=SCOPES)

        # creates a Google Sheets API service object
        service = build('sheets', 'v4', credentials=creds)

        # Call the Sheets API to get data from Sheet1
        sheet = service.spreadsheets()
        result = sheet.values().get(spreadsheetId=SPREADSHEET_ID,
                                    range=RANGE_SHEET1).execute()
        values = result.get('values', [])

        if not values:
            print('No data found in Sheet1.')
            return

        # Write the data to Sheet2
        request = sheet.values().update(spreadsheetId=SPREADSHEET_ID,
                                        range=RANGE_SHEET2,
                                        valueInputOption='USER_ENTERED',
                                        body={'values': values})
        response = request.execute()

        print(f"{response.get('updatedCells')} cells updated in Sheet2.")
        webbrowser.open('https://docs.google.com/spreadsheets/d/192h3aBgL1LZdifFXEM_ZQVqlpv2uPxT0z7v5Uu6P4PQ/edit?gid=0#gid=0')
        return True

    except Exception as error:
        print(f"An error occurred: {error}")
        return False

if __name__ == "__main__":
    automate_spreadsheet()