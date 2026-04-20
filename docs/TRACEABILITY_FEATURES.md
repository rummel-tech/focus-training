# Focus Training — Feature Traceability Matrix

Maps each user-facing feature from OBJECTIVES.md through specification, tests, implementation, and release verification.

---

## Traceability Chain

```
OBJECTIVES.md (product description)
    → docs/SPECIFICATION.md / docs/ARCHITECTURE.md (specification)
    → docs/WORKFLOWS.md (primary user journeys and screen map)
        → test/focus_training_test.dart — core service tests
        → test/ui/ — screen widget tests
        → integration_test/app_test.dart — end-to-end workflow tests
            → Source implementation
                → docs/DEPLOYMENT.md smoke test (release gate)
```

---

## Development Status Note

Focus Training core (sessions, XP, achievements, streaks, persistence) is fully implemented and tested. Flutter UI screens exist. Backend API and cloud sync are planned.

---

## FR-1 · Focus Sessions

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-1.1 | Start timed focus sessions | OBJECTIVES.md FR-1.1 | `focus_training_test` — "should start a new session" | `lib/src/services/focus_training_service.dart` · `lib/src/ui/screens/session_screen.dart` | — |
| FR-1.2 | Configurable durations (15, 25, 45, 60+ minutes) | OBJECTIVES.md FR-1.2 | `session_screen_test` | `lib/src/ui/screens/session_screen.dart` | — |
| FR-1.3 | Session notes and context | OBJECTIVES.md FR-1.3 | None — gap | `lib/src/models/focus_session.dart` · `lib/src/ui/screens/session_screen.dart` | — |
| FR-1.4 | Complete or abandon sessions | OBJECTIVES.md FR-1.4 | `focus_training_test` — "should complete session and update progress" | `lib/src/services/focus_training_service.dart` · `lib/src/ui/screens/session_screen.dart` | — |
| FR-1.5 | Focus score rating (0–100) | OBJECTIVES.md FR-1.5 | `focus_training_test` — "should calculate XP correctly for completed session", "should return 0 XP for incomplete session", "should unlock perfect score achievement" | `lib/src/models/focus_session.dart` · `lib/src/models/user_progress.dart` | — |
| FR-1.6 | Session JSON round-trip | OBJECTIVES.md FR-1.1 | `focus_training_test` — "should serialize to/from JSON" (FocusSession) | `lib/src/models/focus_session.dart` | — |

---

## FR-2 · XP and Leveling

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-2.1 | Earn XP for completed sessions | OBJECTIVES.md FR-2.1 | `focus_training_test` — "should calculate XP correctly for completed session", "should return 0 XP for incomplete session" | `lib/src/services/focus_training_service.dart` · `lib/src/models/user_progress.dart` | — |
| FR-2.2 | Bonus XP for duration and focus score | OBJECTIVES.md FR-2.2 | `focus_training_test` — "should calculate XP correctly for completed session" | `lib/src/services/focus_training_service.dart` | — |
| FR-2.3 | Level progression with milestones | OBJECTIVES.md FR-2.3 | `focus_training_test` — "should calculate level from XP correctly" | `lib/src/models/user_progress.dart` · `lib/src/ui/screens/home_screen.dart` | — |
| FR-2.4 | XP required scales with level | OBJECTIVES.md FR-2.4 | `focus_training_test` — "should calculate level from XP correctly" | `lib/src/models/user_progress.dart` | — |
| FR-2.5 | Display progress to next level | OBJECTIVES.md FR-2.5 | `focus_training_test` — "should calculate level progress percentage" · `home_screen_test` — "shows level 1 with 0 XP" | `lib/src/ui/screens/home_screen.dart` · `lib/src/models/user_progress.dart` | — |
| FR-2.6 | Average focus score tracking | OBJECTIVES.md FR-2.2 | `focus_training_test` — "should calculate average focus score" · `focus_training_test` — "should serialize to/from JSON" (UserProgress) | `lib/src/models/user_progress.dart` | — |

---

## FR-3 · Achievements

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-3.1 | 10+ achievement types | OBJECTIVES.md FR-3.1 | `focus_training_test` — "should create predefined achievements correctly" | `lib/src/models/achievement.dart` · `lib/src/services/focus_training_service.dart` | — |
| FR-3.2 | Session-based: First Steps, Focus Master | OBJECTIVES.md FR-3.2 | `focus_training_test` — "should unlock first session achievement" | `lib/src/models/achievement.dart` · `lib/src/services/focus_training_service.dart` | — |
| FR-3.3 | Performance-based: Perfect Focus (100 score) | OBJECTIVES.md FR-3.4 | `focus_training_test` — "should unlock perfect score achievement" | `lib/src/services/focus_training_service.dart` | — |
| FR-3.4 | XP rewards for unlocking achievements | OBJECTIVES.md FR-3.6 | `achievements_screen_test` — "shows XP rewards" | `lib/src/models/achievement.dart` · `lib/src/ui/screens/achievements_screen.dart` | — |
| FR-3.5 | Display locked vs unlocked achievements | OBJECTIVES.md FR-3.1 | `achievements_screen_test` — "shows all achievements as locked", "does not show Unlocked section", "shows Unlocked section with count", "shows Locked section with remaining count", "unlocked achievement shows its icon instead of lock", "multiple unlocked achievements shown correctly", "shows lock icons for visible achievements", "shows achievement names" | `lib/src/ui/screens/achievements_screen.dart` | — |
| FR-3.6 | Achievement JSON round-trip | OBJECTIVES.md FR-3.1 | `focus_training_test` — "should serialize to/from JSON" (Achievement) | `lib/src/models/achievement.dart` | — |

---

## FR-4 · Streaks

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-4.1 | Track daily focus streaks | OBJECTIVES.md FR-4.1 | `focus_training_test` — "should track streak correctly" | `lib/src/services/focus_training_service.dart` · `lib/src/models/user_progress.dart` | — |
| FR-4.2 | Display current and longest streak | OBJECTIVES.md FR-4.2 | `focus_training_test` — "should track streak correctly" | `lib/src/ui/screens/home_screen.dart` | — |
| FR-4.3 | Streak-based achievements (Week Warrior, Monthly Master) | OBJECTIVES.md FR-4.3 | `focus_training_test` — "should track streak correctly" | `lib/src/services/focus_training_service.dart` · `lib/src/models/achievement.dart` | — |

---

## FR-5 · Statistics

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-5.1 | Total sessions completed | OBJECTIVES.md FR-5.1 | `home_screen_test` — "shows empty state message when no sessions exist", "does not show Recent Sessions heading" | `lib/src/ui/screens/home_screen.dart` · `lib/src/models/user_progress.dart` | — |
| FR-5.2 | Total focus time | OBJECTIVES.md FR-5.2 | `focus_training_test` — "should calculate average focus score" | `lib/src/models/user_progress.dart` · `lib/src/ui/screens/home_screen.dart` | — |
| FR-5.3 | Average focus score | OBJECTIVES.md FR-5.3 | `focus_training_test` — "should calculate average focus score" | `lib/src/models/user_progress.dart` | — |
| FR-5.4 | Recent session history | OBJECTIVES.md FR-5.4 | `home_screen_test` | `lib/src/ui/screens/home_screen.dart` | — |
| FR-5.5 | Motivational feedback | OBJECTIVES.md FR-5 | `focus_training_test` — "should provide motivational feedback" | `lib/src/services/focus_training_service.dart` | — |

---

## FR-6 · Persistence

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-6.1 | Save progress to JSON | OBJECTIVES.md FR-6.1 | `focus_training_test` — "should save and load progress" | `lib/src/services/focus_training_service.dart` | — |
| FR-6.2 | Load progress on startup | OBJECTIVES.md FR-6.2 | `focus_training_test` — "should save and load progress" | `lib/src/services/focus_training_service.dart` · `lib/main.dart` | App loads saved progress |
| FR-6.3 | Reset progress option | OBJECTIVES.md FR-6.3 | `focus_training_test` — "should reset progress" | `lib/src/services/focus_training_service.dart` | — |

---

## Coverage Summary

| FR Group | Sub-features | Tests | Gaps |
|----------|-------------|-------|------|
| FR-1 Focus Sessions | 6 | Core service well covered | Session notes untested; UI screen tests thin |
| FR-2 XP and Leveling | 6 | Comprehensive | None |
| FR-3 Achievements | 6 | Comprehensive (unit + widget) | Streak achievements (Week Warrior, Monthly Master) have no dedicated achievement-screen test |
| FR-4 Streaks | 3 | Core logic covered | Streak UI display untested |
| FR-5 Statistics | 5 | Partial | Trends/improvements untested |
| FR-6 Persistence | 3 | Covered | Cloud sync (planned) has no test |

> **Priority gaps**: Add `session_screen_test` for duration config, notes, and abandon flow; add `home_screen_test` for streak display and total focus time.

## Integration Test Coverage

`integration_test/app_test.dart` covers:
- App loads and displays home screen
- Home screen renders without crashing
- Start Session button is present
- Level and XP progress are displayed
- Session duration options shown after Start Session
- Tapping Start Session opens session screen
- Achievements screen is reachable
- App loads with persisted data (cold start)
- App handles cold start with no saved data
- App handles multiple rapid interactions
- App is stable after pump settle

## Workflow Documentation

Primary user journeys documented in `docs/WORKFLOWS.md`:
- Workflow 1: Running a Focus Session (core loop)
- Workflow 2: XP and Leveling
- Workflow 3: Achievements
- Workflow 4: Streaks
- Workflow 5: Statistics
- Workflow 6: Persistence
