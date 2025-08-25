# API Integration for Loan and Savings Accounts

## Overview
This document describes the integration of the banking API to display loan accounts in the Loans tab and savings accounts in the Deposit section of the Flutter banking app.

## API Endpoint
- **URL**: `https://api.cornix.tech/user/{phoneNumber}/accounts`
- **Method**: GET
- **Content-Type**: application/json

## Changes Made

### 1. Updated Bottom Navigation (`lib/pages/bottomNavigation.dart/bottom_navigation.dart`)
- Modified the pages list to pass `phoneNumber` to both `DepositScreen` and `LoansScreen`
- This ensures the phone number is available for API calls

### 2. Enhanced Loans Screen (`lib/pages/loans/loans.dart`)
- Added `phoneNumber` parameter to the widget constructor
- Implemented API integration to fetch loan accounts
- Added loading states and error handling
- Updated the UI to display real loan data from the API
- Shows loan details including:
  - Account ID
  - Loan amount
  - EMI amount
  - Loan term
  - Interest rate
  - Plan name

### 3. Enhanced Deposit Screen (`lib/pages/deposit/deposit.dart`)
- Added `phoneNumber` parameter to the widget constructor
- Implemented API integration to fetch savings accounts
- Added loading states and error handling
- Updated the UI to display real savings account data from the API
- Shows savings account details including:
  - Account ID
  - Balance
  - Opening date
  - Interest rate
  - Scheme name

### 4. Bank Accounts Service (`lib/services/bank_accounts_service.dart`)
- Already existed and provides utility methods for:
  - Fetching accounts from the API
  - Filtering loan and savings accounts
  - Formatting balance and dates
  - Error handling and toast notifications

## API Response Structure

### Sample Response
```json
{
  "message": "Accounts fetched successfully.",
  "mobile": "9519874704",
  "kycId": "MEM1",
  "accounts": [
    {
      "accountType": "loan",
      "accountId": "LN1",
      "loanAmount": 5000,
      "emiAmount": 118,
      "loanTerm": 12,
      "planDetails": {
        "name": "mFinance Weekly Loan",
        "interestRate": "18"
      }
    },
    {
      "accountType": "savings",
      "accountId": "SB1",
      "balance": 100000,
      "openingDate": "2025-07-12",
      "planDetails": {
        "schemeName": "General Scheme",
        "annualInterestRate": "4"
      }
    }
  ]
}
```

## Features Implemented

### Loan Accounts Display
- ✅ Real-time loan account fetching
- ✅ Display of loan amount, EMI, term, and interest rate
- ✅ Loading indicators during API calls
- ✅ Error handling with retry functionality
- ✅ Empty state when no loan accounts exist

### Savings Accounts Display
- ✅ Real-time savings account fetching
- ✅ Display of balance, opening date, and interest rate
- ✅ Loading indicators during API calls
- ✅ Error handling with retry functionality
- ✅ Empty state when no savings accounts exist

## Testing
A test file `test_api_integration.dart` has been created to verify the API integration works correctly with the provided endpoint.

## Dependencies
The following dependencies are already included in `pubspec.yaml`:
- `http: ^1.4.0` - For API calls
- `fluttertoast: ^8.2.12` - For error notifications

## Usage
1. The app will automatically fetch accounts when the user navigates to the Loans or Deposit tabs
2. The phone number is passed from the bottom navigation to the respective screens
3. Loading states are shown while fetching data
4. Error messages are displayed if the API call fails
5. Users can retry failed API calls using the retry button

## Error Handling
- Network errors are caught and displayed to the user
- API errors are handled gracefully with appropriate error messages
- Toast notifications are shown for user feedback
- Retry functionality is available for failed requests
