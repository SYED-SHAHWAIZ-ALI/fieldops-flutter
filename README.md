# FieldOps

**Field Service & Client Management** — a Flutter mobile application for technicians, inspectors, and service teams working at customer sites.

FieldOps is designed as a realistic B2B product demo rather than a static UI showcase. Its main workflow is operational: create a work order, start the job, complete the service checklist, add notes/evidence, close the job, and see the resulting state update across the dashboard, activity feed, jobs list, and client history.

## Core demo flow

1. Sign in with the demo account
2. Review the live dashboard and today's schedule
3. Create a new work order for an existing client
4. Open the pending work order and start it
5. Complete required checklist items
6. Add technician notes and an optional image attachment
7. Complete the work order with a completion note
8. Confirm KPI, activity, job-state, and client-history updates
9. Review notifications and switch between light/dark themes

## Features

- Mock email/password authentication with loading, validation, and error states
- Responsive mobile-first dashboard with live KPI cards and today's schedule
- **New Work Order** flow with client selection, schedule, priority, estimated duration, and service description
- Automatic work-order ID generation and standard service checklist creation
- Job search and filters for Today / Pending / In Progress / Completed
- Enforced workflow: **Pending → In Progress → Completed**
- Required checklist + completion-note validation in the repository layer
- Technician notes, image attachments, workflow progress, and per-job audit timeline
- Cross-screen state synchronization through a single Riverpod jobs controller
- Client directory with live active-work-order counts and job history
- Activity timeline grouped by Today / Yesterday / Earlier
- Notification badge, mark-as-read, and mark-all-as-read behavior
- Profile/settings experience with persistent dark mode and polished informational dialogs
- Mobile-responsive layouts for narrow phone widths

## Technology stack

- Flutter / Dart / Material 3
- `flutter_riverpod` for state management
- `go_router` with `StatefulShellRoute` for tab navigation and auth redirects
- `intl` for date/time presentation
- `image_picker` for job evidence attachments
- `shared_preferences` for theme persistence

No Firebase or live cloud backend is required. Data is served through mock repositories with asynchronous behavior so loading and business-state transitions behave like an API-backed application.

## Architecture

```text
Presentation (screens/widgets)
        ↓
Riverpod controllers/providers
        ↓
Repository interfaces
        ↓
Mock repositories

Future:
Presentation → Controllers → Repository interfaces → ApiRepository → FastAPI → Database
```

`JobsController` is the shared source of truth for work orders. Dashboard KPIs, job lists, details, client live counts, and activity all derive from that shared state.

## Project structure

```text
lib/
  main.dart
  app/
  core/
    constants/
    providers/
    router/
    theme/
    widgets/
  features/
    auth/
    dashboard/
    jobs/
    clients/
    activity/
    notifications/
    profile/
    shell/
test/
```

## Demo credentials

```text
Email:    field.agent@fieldops.com
Password: demo123
```

## Run locally

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

For a browser preview:

```bash
flutter run -d chrome
```

For Android after the Android SDK/device is configured:

```bash
flutter devices
flutter run -d <android-device-id>
```

## Tests

The test suite covers:

- Authentication and credential handling
- New work-order creation
- Pending → In Progress → Completed workflow rules
- Checklist and completion-note validation
- Job search/filtering
- Dashboard KPI recomputation after creation/completion

## Demo-oriented design decisions

- Repository interfaces keep the UI ready for a future FastAPI-backed implementation.
- Mock operations use short asynchronous delays so loading states remain realistic.
- Business rules live in the repository layer rather than only in buttons/screens.
- Work-order creation automatically adds an ID, audit event, and standard checklist.
- Call / Message / Directions use clear demo feedback instead of silently doing nothing.
- The app avoids unnecessary charting, maps, Firebase, and other dependencies that would add complexity without improving the core field-service demo.

## Known limitations

- Data is in-memory and resets when the application restarts.
- Attachments store a selected local path/reference only; there is no cloud upload or permanent media store.
- Call / Message / Directions are simulated demo actions rather than OS integrations.
- A real backend, production authentication, maps, push notifications, and persistence are intentionally outside this focused demo scope.
