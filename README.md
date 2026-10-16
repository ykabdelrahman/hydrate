# Hydrate

A Flutter water reminder and tracking app.

## Features

- **Water Intake Tracking:** Easily log your daily water intake.
- **Daily Goal Setting:** Set and track your personalized daily hydration goals.
- **Unit Customization:** Choose between milliliters (ml) and ounces (oz) for water intake.
- **Notification Reminders:** Set custom intervals to receive reminders to drink water.
- **Weight-based Recommendation:** Get a recommended daily water intake based on your weight.
- **Dark Mode:** Toggle between light and dark themes for comfortable viewing.
- **History and Statistics:** View your daily, weekly, and monthly water intake history with interactive charts.

### Reminder delivery

Reminders use one repeating local notification managed by Android or iOS. The
first reminder appears after the selected interval. Changing the interval
replaces it; choosing **Never** cancels it. Android restores the schedule after
a reboot or app update. The app also refreshes the schedule when opened or
resumed, because some devices discard the live alarm while still reporting its
cached notification request as pending. Notifications require the user's permission.

On Android, saving an interval requests **Alarms & reminders** access and uses
Android's visible alarm-clock scheduling mode for precise delivery, including
while the phone is idle. This can show an upcoming-alarm indicator in the phone
UI. If that access is denied,
the app schedules approximate reminders and says so in Settings. Battery saver
and Do Not Disturb can still delay or silence notifications.
On iOS, Focus and notification settings control presentation. Neither platform
can notify while the phone is powered off, and Android force-stop prevents
delivery until the app is opened again.

Before release, test on real Android and iOS devices: enable a 15-minute
interval, verify a reminder while the app is open, backgrounded, and closed;
change it to 30 minutes and verify there is only one reminder stream; select
Never and verify delivery stops. On Android, also reboot and test with battery
saver enabled. On iOS, test a Focus mode and document the user settings needed
to allow reminders through it.

## Getting Started

### Prerequisites

- Flutter SDK installed.
- A code editor like VS Code or Android Studio.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/hydrate.git
    cd hydrate
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Generate Hive adapters (if models are changed):**
    ```bash
    flutter packages pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Project Structure

The project follows a clean architecture pattern with the following layers:

-   **`lib/src/app`**: Contains Riverpod providers for state management and dependency injection.
-   **`lib/src/domain`**: Defines core business logic, models (`WaterLog`, `UserPreferences`, `DailySummary`), and repository interfaces.
-   **`lib/src/data`**: Implements data sources and repositories (e.g., `HiveService`, `WaterRepositoryImpl`, `UserPreferencesRepositoryImpl`).
-   **`lib/src/features`**: Contains UI and specific logic for different features (e.g., `home`, `history`, `settings`).
-   **`lib/main.dart`**: The application entry point, responsible for setting up the main app structure and navigation.

## Contributing

Contributions are welcome! Please feel free to open issues or pull requests.

## License

This project is licensed under the MIT License.
