# AI_Study_Notes

AI_Study_Notes is a Flutter application for creating, organizing, and learning
from study notes. It combines Firebase authentication and cloud storage with
Gemini-powered tools for summarization, exam preparation, and translation.

## Features

- Email verification and password-based authentication
- Google sign-in support
- Create, edit, search, view, and delete study notes
- Generate summaries with Google Gemini
- Create exam-preparation questions, including multiple-choice and essay questions
- Translate study content into a selected language
- Firebase-backed user and note data

## Tech Stack

- Flutter and Dart
- Firebase Authentication
- Cloud Firestore
- Google Sign-In
- Google Gemini API via `google_generative_ai`
- Provider for state management
- `flutter_dotenv` for local environment configuration

## Requirements

- Flutter SDK with Dart 3 or newer
- A configured Firebase project
- Android Studio and/or Xcode for mobile development
- A Google AI Studio Gemini API key for the AI tools

Check the local Flutter installation with:

```powershell
flutter doctor
```

## Setup

1. Clone the repository and enter the project directory.

```powershell
git clone https://github.com/<your-username>/AI_Study_Notes.git
cd AI_Study_Notes
```

2. Install Flutter dependencies.

```powershell
flutter pub get
```

3. Configure Firebase for the platforms you want to run. The repository
   includes generated Firebase client configuration files, but each Firebase
   project should use its own configuration when publishing an app.

4. Add the Gemini API key. Create a `.env` file in the project root:

```dotenv
GEMINI_API_KEY=your_google_ai_studio_key
```

The app loads this file when it is available. You can also pass the key at
build time:

```powershell
flutter run --dart-define=GEMINI_API_KEY=your_google_ai_studio_key
```

For a release build, pass the same define to the build command. Never commit a
real API key to the repository.

## Run the App

List available devices:

```powershell
flutter devices
```

Run the application:

```powershell
flutter run
```

Run on a specific device with:

```powershell
flutter run -d <device-id>
```

## Verify Changes

Run the analyzer and tests before opening a pull request:

```powershell
flutter analyze
flutter test
```

## Project Structure

The app follows a feature-based structure. Remote services live under
`lib/data/datasources/remote`, while feature providers coordinate UI state and
service calls.

## Security Notes

- Do not commit `.env` or real API keys.
- Firebase configuration values identify a Firebase app, but they are not a
  replacement for the Gemini API key.
- Restrict Gemini API keys in Google AI Studio and rotate them if they are
	exposed.
- Configure Firebase Authentication and Firestore security rules before using
	the app with production data.

## License

This project is licensed under the Apache License 2.0. See the
[LICENSE](LICENSE) file for the full license text.
