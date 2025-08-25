# Project Blueprint: 轻约·可信社交 (Qingyue - Trustworthy Social)

## Project Overview

**Product Positioning:** 轻约 is a Flutter cross-platform social application built on a trust mechanism, focused on organizing and participating in real and safe offline activities. It aims to create a trustworthy social environment through multiple trust verification mechanisms.

**Core Value Proposition:** Trustworthy Social, Safety Assurance, Efficient Matching (Future), Social Incentive (Future).

**Target Users:** Activity Organizers (25-40), Activity Participants (20-35).

**Technical Stack:**
*   **Frontend:** Flutter (Dart)
*   **Backend:** Firebase (Authentication, Firestore, Cloud Storage - Future, Cloud Functions - Future)

## Implemented Features (MVP Progress)

Based on the development completed so far, the following features have been implemented:

### User Authentication

*   **User Registration:** Implemented email/password registration using Firebase Authentication. A user document is created in Firestore upon successful registration with initial fields (`uid`, `email`, `displayName`, `createdAt`, `isVerified`, `creditScore`, `emergencyContacts`, `interests`).
*   **User Login:** Implemented email/password login using Firebase Authentication.
*   **Authentication State Navigation:** The application navigates users to the home screen if authenticated and to the login screen otherwise, managed by a `StreamBuilder` on the authentication state in `main.dart`.
*   **Logout:** Implemented user logout functionality.

### Activity Management

*   **Activity Publishing:** Implemented the UI and logic to create new activities with details (title, type, time, location, max participants, cost, description) and save them to the `activities` collection in Firestore. Includes date and time pickers.
*   **Activity Listing:** Implemented the `HomePage` to fetch activities from the `activities` collection in Firestore.
    *   Includes basic pagination and infinite scrolling.
    *   Filtering by activity type and sorting by date (ascending/descending) are implemented via a modal bottom sheet.
    *   Uses the `ActivityListItemWidget` to display each activity.
    *   Activity time is formatted for display.
    *   Organizer names are fetched and displayed for each activity (using a nested `FutureBuilder` within the list item widget).
*   **Activity Detail Viewing:** Implemented the `ActivityDetailScreen` to fetch and display detailed information for a selected activity using its `activityId`.
    *   Displays all relevant activity fields.
    *   Fetches and displays organizer information.
    *   Fetches and displays a list of approved participants (fetching names individually).
    *   Includes a "报名参与" (Sign Up) button with logic to add applications to the `activity_applications` collection and update the participant count.
*   **Basic Activity Application:** Users can apply for an activity, creating a document in the `activity_applications` collection with a 'pending' status.

### Emergency Contact Settings

*   **Basic UI and Saving:** Implemented the `EmergencyContactSettingsScreen` with a UI to input up to three emergency contacts (name and phone number). The entered contacts are saved to the `emergencyContacts` array in the current user's document in Firestore. Includes basic validation and loading states.

## Pending Tasks (MVP Completion)

The following tasks are necessary to complete the core MVP features:

### Completing Application Management (Manual Implementation Required)

*   **Organizer View of Pending Applications:** Implement a section within the `ActivityDetailScreen` (visible only to the organizer) to list users with 'pending' applications for that activity.
*   **Approve/Reject Functionality:** Add "Approve" and "Reject" buttons for each pending application in the organizer's view.
*   **Firestore Updates:** Implement the logic to update the `applicationStatus` in the `activity_applications` document to 'approved' or 'rejected' when the corresponding button is pressed.
*   **UI Updates:** Refresh the list of pending applications and potentially update the participant count display upon approval/rejection.
*   **Manual Implementation Note:** Due to current tool limitations in performing complex code insertions in `activity_detail_screen.dart`, these changes need to be implemented manually in the `lib/screens/activity_detail_screen.dart` file.

### Refining Dynamic Safety Code Visibility

*   **Conditional Display Logic:** Double-check that the dynamic safety code is strictly generated and displayed only to the activity organizer and participants with 'approved' application status, and only after the activity's `startTime`. The logic is partially implemented but should be reviewed once application approval is functional.

### Future Refactoring (Manual Implementation Required)

*   **Improve Organizer Data Fetching in `HomePage`:** Refactor the `HomePage` to fetch organizer data for all displayed activities more efficiently (e.g., batch fetching based on unique organizer IDs) instead of fetching individually for each list item using a `FutureBuilder`. This will improve performance for longer lists.
*   **Centralize Data Fetching in `ActivityDetailScreen`:** Refactor the `ActivityDetailScreen` to fetch all necessary data (activity, organizer, participants) in a single place before building the main UI, instead of using nested `FutureBuilder`s.
*   **Add `const` Correctness:** Iterate through all relevant widget files and add `const` keywords to constructors and values where appropriate to optimize rendering.
*   **Extract Widgets and Logic:** Further extract reusable widgets and separate UI from logic as needed throughout the codebase.

## Manual Implementation Steps for Pending Tasks

Given the current tool limitations, the following manual steps are required to implement the remaining MVP features:

1.  Open `lib/screens/activity_detail_screen.dart` in your code editor.
2.  Locate the section where activity details are displayed.
3.  Add a conditional check to determine if the current logged-in user is the organizer (`FirebaseAuth.instance.currentUser?.uid == activityData['organizerId']`).
4.  Inside the organizer's conditional block, add UI elements (e.g., a `Column`, `ListView`, or `ExpansionTile`) to display pending applications.
5.  Implement the logic to query the `activity_applications` collection for pending applications related to this activity ID.
6.  For each pending application, fetch the applicant's user data (`displayName`) from the `users` collection.
7.  Display the applicant's name and add `ElevatedButton`s or `TextButton`s labeled "批准" (Approve) and "拒绝" (Reject).
8.  Implement `onPressed` handlers for the "Approve" and "Reject" buttons. These handlers should update the `applicationStatus` field in the corresponding `activity_applications` document in Firestore.
9.  After updating the status, refresh the displayed list of pending applications (e.g., by calling `setState` and re-fetching the data).
10. Add `ScaffoldMessenger` to display success or error messages for approval/rejection operations.
11. Review the logic for displaying the dynamic safety code to ensure it correctly checks for 'approved' application status and the activity start time.

Further manual steps will be required to implement the refactoring items outlined in the "Future Refactoring" section.