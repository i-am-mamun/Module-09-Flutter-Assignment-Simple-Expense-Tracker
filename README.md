# Expense Tracker

A simple Flutter expense tracker that stores expenses locally in SQLite.

## Features

- View all saved expenses and their total.
- Add an expense with a title and an amount greater than zero.
- Delete an expense.
- Keep expense data on the device between app launches.

## Run

1. Install the Flutter SDK.
2. From the project directory, run `flutter pub get`.
3. Run `flutter run` on an Android, iOS, or macOS target.

The app creates an `expenses` SQLite table with an auto-incrementing `id`,
`title`, and `amount`.
