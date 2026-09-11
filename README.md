# FieldOps

**Field Service & Client Management** — a Flutter mobile app for field technicians, inspectors, and service teams who work at customer sites.

## Business use case

Field service businesses (HVAC, generators, networking, fire safety, elevators, facility management) need their technicians to see a daily schedule, work through job checklists, capture evidence on-site, and keep client history in one place. FieldOps models that workflow end-to-end: login → today's schedule → start a job → complete a checklist → attach a photo → close the job with a note → see the dashboard and client history update immediately.

## Core features

- Email/password login with validation, loading and error states (mock auth)
- Dashboard with live KPI cards, a weekly performance summary, and today's schedule
- Job list with search and status/date filter chips
- Job details with service description, interactive checklist, notes, photo attachments (camera or gallery), and an activity timeline
- Enforced job workflow: **Pending → In Progress → Completed**, with a completion bottom sheet that requires a note and all required checklist items
- Client directory with search, contact actions, and per-client job history
- Cross-app activity feed grouped by Today / Yesterday / Earlier
- Notifications with unread badge and mark-as-read / mark-all-as-read
- Profile screen with stats, settings list, dark mode toggle (persisted), and logout

## Screens

Splash · Login · Dashboard · Jobs · Job Details · Clients · Client Details · Activity · Notifications · Profile

## Technology stack

- Flutter (Material 3), null-safe Dart
- `flutter_riverpod` for state management
- `go_router` with a `StatefulShellRoute` for the bottom-tab navigation (tab state is preserved across switches) and auth-based redirects
- `intl` for date/time formatting
- `image_picker` for camera/gallery attachments
- `shared_preferences` for persisting the theme preference

No Firebase and no live backend — all data is served by mock repositories.

## Architecture

Feature-based, with a repository pattern that isolates the data source from the UI:

```
Presentation (screens/widgets)
      ↓
Controllers / Providers (Riverpod)
      ↓
Repository interfaces (JobRepository, ClientRepository, AuthRepository, NotificationRepository)
      ↓
Mock* implementations (in memory, seeded with realistic Karachi-based data)
```

To connect a real backend later, implement `Api*Repository` classes against the same interfaces (see `lib/core/constants/app_constants.dart` for `apiBaseUrl`) and swap the providers in `lib/core/providers/repository_providers.dart`. No screen needs to change.

```
Future:
Presentation → Controllers/Providers → Repository interfaces → ApiRepository → FastAPI REST API → Database
```

## State management

`JobsController` (a `StateNotifier`) is the single source of truth for job data. Dashboard KPIs, the jobs list, job details, and the activity feed all derive from it via Riverpod providers, so completing a job in one screen instantly updates the others.

## Folder structure

```
lib/
  main.dart
  app/app.dart
  core/
    constants/        app-wide constants incl. future API base URL
    theme/             centralized colors, spacing, and Material theme
    router/            go_router configuration
    widgets/           shared UI components (chips, cards, states, sheets)
    providers/         repository DI + theme persistence
  features/
    auth/{data,domain,presentation}
    dashboard/presentation
    jobs/{data,domain,presentation}
    clients/{data,domain,presentation}
    activity/presentation
    notifications/{data,domain,presentation}
    profile/presentation
    shell/presentation   bottom navigation scaffold
test/
  auth_repository_test.dart
  job_workflow_test.dart
  dashboard_stats_test.dart
```

## Demo login

```
Email:    field.agent@fieldops.com
Password: demo123
```

## Installation

```bash
flutter pub get
flutter run
```

## Commands

```bash
flutter pub get
flutter analyze
flutter test
```

## Tests

- Login validation and credential handling (`auth_repository_test.dart`)
- Job status transitions and business rules — starting, checklist gating, and required completion notes (`job_workflow_test.dart`)
- Job search/filtering logic (`dashboard_stats_test.dart`)
- Dashboard statistics recomputing after a job is completed (`dashboard_stats_test.dart`)

## Design decisions

- **Deep navy/indigo + a single blue accent** rather than a multi-color palette, so status/priority colors (success, warning, error, pending, in-progress) stay the only accent colors on screen.
- **Mock repositories return real domain objects through `Future`s with small artificial delays**, so loading states are exercised the same way they would be against a live API.
- **Checklist and note requirements are enforced in the repository layer**, not just the UI, so the business rule holds regardless of which screen calls it.
- **Call / Message / Directions** on the client screen give clear, polished feedback (a confirmation snackbar) rather than being silently inert, since wiring real `tel:`/`sms:`/maps intents would add a platform-permissions dependency out of scope for this demo.
- **No charting library** — KPIs and performance are shown with metric cards and a single progress bar, per the instruction to prefer restraint over unnecessary dependencies.

## Known limitations

- **This build was produced without a Flutter/Dart SDK or pub.dev access in the authoring environment**, so `flutter pub get`, `flutter analyze`, `flutter test`, and an actual app launch could **not** be run or verified here. The code was written carefully against current stable Flutter/Riverpod/go_router APIs, but you should run the commands above yourself before treating it as build-verified.
- Attachments store the local file path/name only; no image is actually persisted to disk across app restarts (in-memory mock data resets on relaunch, matching the rest of the mock layer).
- Call/Message/Directions are simulated with feedback rather than invoking the OS dialer/SMS/maps apps.
- Personal Information, Notification Settings, Security, and Help & Support settings rows are present for visual completeness but are explicitly marked "not part of this demo build" when tapped, rather than faking functionality that doesn't exist.
