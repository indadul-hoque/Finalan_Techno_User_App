# KYC API Integration Documentation

## Overview

This document describes the integration of the KYC (Know Your Customer) API from [https://api.cornix.tech](https://api.cornix.tech) into the Flutter Banking Application.

## API Endpoint

- **Base URL**: `https://api.cornix.tech`
- **KYC Endpoint**: `/user/{phoneNumber}/kyc`
- **Method**: GET (fetch), PUT (update)

## Features Implemented

### 1. KYC Service (`lib/services/kyc_service.dart`)

The KYC service provides the following functionality:

- **Fetch KYC Details**: Retrieves user KYC information from the API
- **Update KYC Details**: Updates user KYC information via API
- **KYC Status**: Shows verification status (Verified/Pending)
- **Completion Percentage**: Calculates KYC completion based on filled fields
- **Error Handling**: Comprehensive error handling with user-friendly messages

### 2. Enhanced Edit Profile Page (`lib/pages/Account/edit_profile.dart`)

The profile update page now includes:

- **KYC Status Card**: Shows current KYC status and completion percentage
- **Personal Information Section**: Name, email, phone, address, gender, marital status, guardian
- **Identity Documents Section**: Aadhar, Voter ID, PAN number
- **Financial Information Section**: Occupation, annual income, education
- **Nominee Details Section**: Nominee name, relation, Aadhar number
- **Real-time Updates**: All changes are saved to the KYC API

### 3. Home Screen Integration (`lib/pages/home/home.dart`)

Added a KYC status card to the home screen that:

- Displays current KYC status and completion percentage
- Shows a progress bar indicating completion
- Provides a "Complete KYC" button for incomplete profiles
- Includes a refresh button to update KYC data
- Automatically loads KYC data when the screen loads

## KYC Data Structure

The API returns the following KYC information:

```json
{
  "message": "KYC details fetched successfully.",
  "kycDetails": {
    "id": "MEM1",
    "date": "2025-07-12",
    "selectedUserEmail": "test.itax@test.com",
    "bankId": "01_iTaxFinance__itNnpqyqNKLp3j",
    "userId": "fJoHDqSrMafLLPk91hEDI4BBXDz2",
    "name": "TEST",
    "guardian": "JAMAL",
    "gender": "male",
    "dob": "",
    "materialStatus": "unmarried",
    "email": "",
    "phone": "1234567890",
    "address": "",
    "aadhar": "",
    "voter": "",
    "pan": "",
    "occupation": "",
    "income": "",
    "education": "",
    "nominee": {
      "name": "",
      "relation": "",
      "dob": "",
      "aadhar": "",
      "voter": "",
      "pan": ""
    },
    "uuid": "11a88b09-701f-4322-9bf8-e69dd6c55968",
    "active": true,
    "createdFor": "fJoHDqSrMafLLPk91hEDI4BBXDz2",
    "selectedUserId": "fJoHDqSrMafLLPk91hEDI4BBXDz2",
    "author": "test.itax@test.com",
    "createdAt": {
      "_seconds": 1752326749,
      "_nanoseconds": 97000000
    },
    "group": "GRP1"
  }
}
```

## Implementation Details

### API Integration

1. **HTTP Client**: Uses the `http` package for API calls
2. **Error Handling**: Comprehensive error handling for network issues and API errors
3. **Loading States**: Shows loading indicators during API calls
4. **Toast Notifications**: User feedback for success/error operations

### Data Management

1. **SharedPreferences**: Stores user phone number for API calls
2. **State Management**: Uses StatefulWidget for local state management
3. **Form Validation**: Input validation for required fields
4. **Data Persistence**: All changes are immediately saved to the API

### UI Components

1. **KYC Status Card**: Beautiful gradient card showing KYC progress
2. **Form Fields**: Consistent styling with shadow effects
3. **Progress Indicators**: Linear progress bars and loading spinners
4. **Responsive Design**: Adapts to different screen sizes

## Usage

### For Users

1. **View KYC Status**: Check the home screen for current KYC status
2. **Complete Profile**: Navigate to Edit Profile to fill missing information
3. **Update Information**: Modify any existing KYC details
4. **Track Progress**: Monitor completion percentage and verification status

### For Developers

1. **KYC Service**: Use `KYCService.fetchKYCDetails(phoneNumber)` to get KYC data
2. **Update KYC**: Use `KYCService.updateKYCDetails(phoneNumber, kycData)` to update
3. **Status Check**: Use `KYCService.getKYCStatus()` and `KYCService.getKYCCompletionPercentage()`

## Testing

A test application (`test_kyc_integration.dart`) is provided to verify the API integration:

1. **Run the test**: Execute the test file to verify API connectivity
2. **Test Data**: Uses the provided phone number (9519874704) for testing
3. **API Response**: Displays all retrieved KYC data in a formatted view

## Security Considerations

1. **HTTPS**: All API calls use secure HTTPS connections
2. **Input Validation**: Client-side validation for all form inputs
3. **Error Handling**: Secure error messages that don't expose sensitive information
4. **Data Privacy**: Only necessary KYC data is transmitted

## Future Enhancements

1. **Document Upload**: Support for document image uploads
2. **Verification Workflow**: Multi-step verification process
3. **Push Notifications**: Notify users of KYC status changes
4. **Offline Support**: Cache KYC data for offline viewing
5. **Multi-language**: Support for KYC forms in multiple languages

## Troubleshooting

### Common Issues

1. **API Connection Failed**: Check internet connectivity and API endpoint
2. **Data Not Loading**: Verify phone number is stored in SharedPreferences
3. **Update Failed**: Ensure all required fields are filled
4. **Loading Issues**: Check for proper error handling in KYC service

### Debug Information

- Enable debug mode to see detailed API request/response logs
- Check console for error messages and stack traces
- Verify API endpoint accessibility

## Dependencies

The KYC integration requires the following packages:

```yaml
dependencies:
  http: ^1.4.0
  fluttertoast: ^8.2.12
  shared_preferences: ^2.5.1
```

## Conclusion

The KYC API integration provides a comprehensive solution for managing user verification in the banking application. It offers a user-friendly interface for profile completion while maintaining security and data integrity through proper API integration and error handling.
