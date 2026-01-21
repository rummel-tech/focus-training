---
module: focus-training
version: 1.0.0
status: draft
last_updated: 2026-01-20
---

# Focus Training Specification

## Overview

The Focus Training module provides a gamified focus session tracking system with XP, achievements, streaks, and level progression. It enables users to start timed focus sessions, track their focus quality, earn rewards through consistent practice, and visualize their progress over time. The module is implemented as a pure Dart library designed for integration into larger applications.

## Authentication

This module uses the shared AWS Amplify authentication system. See [Authentication Architecture](../../../../docs/architecture/AUTHENTICATION.md) for complete details.

### Authentication Modes

| Mode | Description |
|------|-------------|
| Artemis-Integrated | User authenticates via Artemis, gains access to all permitted modules |
| Standalone | User authenticates directly in Focus Training app |

### Module Access

- **Module ID**: `focus-training`
- **Artemis Users**: Full access when `artemis_access: true`
- **Standalone Users**: Access when `focus-training` in `module_access` list

### Login Screen

Uses shared `auth_ui` package with identical UI to all other modules:
- Email/password authentication
- Google Sign-In
- Apple Sign-In
- Email verification flow
- Password reset flow

### API Authentication

All API endpoints require JWT Bearer token from AWS Cognito:
```http
Authorization: Bearer <access_token>
```

## Design System

This module uses the shared Artemis Design System. See [Design System](../../../../docs/architecture/DESIGN_SYSTEM.md) for complete specifications.

### Design Principles

All UI components follow the shared design system to ensure visual consistency across the Artemis ecosystem:

- **Colors**: Rummel Blue primary (`#1E88E5`), Teal secondary (`#26A69A`)
- **Typography**: Material 3 type scale with system fonts
- **Spacing**: Consistent 4dp base unit scale (xs: 4dp, sm: 8dp, md: 16dp, lg: 24dp)
- **Components**: Shared button, card, input, and navigation styles

### Module-Specific Colors

| Element | Color | Token | Usage |
|---------|-------|-------|-------|
| Focus Achieved | `#388E3C` | `success` | Completed sessions, high scores |
| Distracted | `#F57C00` | `warning` | Moderate focus scores (40-69%) |
| Session Failed | `#D32F2F` | `error` | Low scores, broken streaks |
| XP Gained | `#26A69A` | `secondary500` | XP rewards, level progress |
| Streak Fire | `#F57C00` | `warning` | Active streak indicator |

### Key Components

| Component | Specification |
|-----------|---------------|
| TimerDisplay | displayLarge typography, circular progress ring using primary |
| XPCounter | Animated counter with secondary color accent |
| AchievementBadge | Circular badge with icon, locked state uses surfaceVariant |
| StreakIndicator | Flame icon with warning color, count in titleMedium |
| LevelBadge | Filled container with primary, level number in displayMedium |
| ProgressRing | Circular progress using semantic colors based on score |

### Focus Score Colors

| Score Range | Color | Token | Meaning |
|-------------|-------|-------|---------|
| 80-100% | Green | `success` | Excellent focus |
| 50-79% | Orange | `warning` | Moderate focus |
| 0-49% | Red | `error` | Poor focus |

### Screen Layouts

All screens follow responsive breakpoints from the shared design system:
- Mobile (< 600dp): Single column, bottom navigation
- Tablet (600-839dp): Flexible columns, navigation rail optional
- Desktop (>= 840dp): Multi-column with navigation rail

## Data Models

### FocusSession

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | Required, unique | Unique identifier for the session |
| startTime | DateTime | Required, ISO 8601 | When the session started |
| endTime | DateTime? | Optional, ISO 8601 | When the session ended |
| plannedDuration | Duration | Required, > 0 | Intended session length |
| actualDuration | Duration? | Optional | Actual time focused |
| focusScore | int | 0-100, default: 0 | Quality score based on performance |
| completed | bool | Default: false | Whether session was completed |
| notes | String? | Optional | User notes about the session |
| metadata | Map<String, dynamic> | Default: {} | Additional session data |

**Computed Properties:**
- `calculateXP()`: Returns XP earned (base 10 + duration bonus + focus score bonus)

**XP Calculation:**
```
baseXP = 10 (for completion)
durationBonus = actualDuration.inMinutes (1 XP per minute)
focusBonus = (focusScore * 0.5).round() (up to 50 bonus XP)
totalXP = baseXP + durationBonus + focusBonus
```

**Relationships:**
- FocusSession belongs to UserProgress (via recentSessions list)

**Indexes (Planned):**
- user_id (for user-scoped queries)
- startTime (for chronological sorting)
- completed (for filtering)

**JSON Serialization:**
```json
{
  "id": "session-uuid-123",
  "startTime": "2026-01-20T14:00:00.000Z",
  "endTime": "2026-01-20T14:25:00.000Z",
  "plannedDuration": 1500,
  "actualDuration": 1500,
  "focusScore": 85,
  "completed": true,
  "notes": "Deep work on project planning",
  "metadata": {}
}
```

### Achievement

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| type | AchievementType | Required, enum | Type of achievement |
| name | String | Required | Display name |
| description | String | Required | How to earn this achievement |
| icon | String | Required | Emoji or icon identifier |
| xpReward | int | Default: 0 | XP granted when unlocked |
| unlockedAt | DateTime? | Optional, ISO 8601 | When achievement was earned |
| unlocked | bool | Default: false | Whether achievement is unlocked |

**Achievement Types:**
| Type | Name | Description | XP Reward |
|------|------|-------------|-----------|
| firstSession | First Steps | Complete your first focus session | 50 |
| streak7Days | Week Warrior | Maintain a 7-day focus streak | 200 |
| streak30Days | Monthly Master | Maintain a 30-day focus streak | 1000 |
| totalSessions10 | Getting Started | Complete 10 focus sessions | 100 |
| totalSessions50 | Focused Mind | Complete 50 focus sessions | 500 |
| totalSessions100 | Focus Master | Complete 100 focus sessions | 1500 |
| perfectScore | Perfect Focus | Achieve a perfect 100 focus score | 300 |
| earlyBird | Early Bird | Complete a session before 6 AM | 150 |
| nightOwl | Night Owl | Complete a session after 10 PM | 150 |
| marathonSession | Marathon Focus | Complete a session longer than 2 hours | 250 |

**Relationships:**
- Achievement belongs to UserProgress (via achievements list)

**JSON Serialization:**
```json
{
  "type": "AchievementType.firstSession",
  "name": "First Steps",
  "description": "Complete your first focus session",
  "icon": "🎯",
  "xpReward": 50,
  "unlockedAt": "2026-01-20T14:30:00.000Z",
  "unlocked": true
}
```

### UserProgress

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| totalXP | int | Default: 0, >= 0 | Total experience points earned |
| level | int | Default: 1, >= 1 | Current level |
| currentStreak | int | Default: 0, >= 0 | Current consecutive days |
| longestStreak | int | Default: 0, >= 0 | Best streak achieved |
| totalSessions | int | Default: 0, >= 0 | Total completed sessions |
| totalFocusTime | Duration | Default: 0 | Cumulative focus time |
| achievements | List\<Achievement\> | Default: [] | Unlocked achievements |
| recentSessions | List\<FocusSession\> | Default: [] | Recent session history |
| lastSessionDate | DateTime? | Optional | Date of last session |
| stats | Map<String, dynamic> | Default: {} | Additional statistics |

**Computed Properties:**
- `calculateLevel(xp)`: Returns level based on XP (progressive scaling)
- `xpForNextLevel()`: XP needed for next level = (level + 1) * 100
- `xpInCurrentLevel()`: Progress within current level
- `averageFocusScore`: Mean score of recent completed sessions

**Level Calculation:**
```
Level 1: 0-99 XP
Level 2: 100-299 XP (requires 100 XP)
Level 3: 300-599 XP (requires 300 XP)
Level 4: 600-999 XP (requires 600 XP)
Level N: requires sum of (i * 100) for i = 2 to N
```

**Indexes (Planned):**
- user_id (primary lookup)

**JSON Serialization:**
```json
{
  "totalXP": 1250,
  "level": 5,
  "currentStreak": 12,
  "longestStreak": 25,
  "totalSessions": 47,
  "totalFocusTime": 84600,
  "achievements": [...],
  "recentSessions": [...],
  "lastSessionDate": "2026-01-20T14:30:00.000Z",
  "stats": {}
}
```

## Use Cases

### UC-001: Start Focus Session

**Actor:** User

**Preconditions:**
- User has access to the focus training module

**Flow:**
1. User specifies planned session duration
2. System creates new session with unique ID and startTime
3. System sets completed = false
4. System starts countdown/timer
5. System returns the created session

**Postconditions:**
- Active session exists
- Session is trackable by ID

**Acceptance Criteria:**
- [ ] Session is created with correct plannedDuration
- [ ] startTime is set to current timestamp
- [ ] Session ID is unique
- [ ] Session can be retrieved during active state

### UC-002: Complete Focus Session

**Actor:** User

**Preconditions:**
- Active focus session exists
- Session is not already completed

**Flow:**
1. User ends the session (or timer completes)
2. System sets endTime to current time
3. System calculates actualDuration
4. User provides optional focusScore (or system calculates)
5. System sets completed = true
6. System calculates XP earned
7. System updates UserProgress (totalXP, totalSessions, totalFocusTime)
8. System checks and unlocks any new achievements
9. System updates streak if applicable

**Postconditions:**
- Session is marked complete
- XP is added to user progress
- Achievements checked and potentially unlocked
- Streak updated

**Acceptance Criteria:**
- [ ] endTime is set correctly
- [ ] actualDuration calculated accurately
- [ ] XP calculation follows formula
- [ ] UserProgress.totalXP increases
- [ ] Relevant achievements unlock

### UC-003: View Progress Dashboard

**Actor:** User

**Preconditions:**
- User has access to the focus training module

**Flow:**
1. User requests progress data
2. System retrieves UserProgress
3. System calculates current level and XP to next level
4. System returns progress summary

**Postconditions:**
- Progress data returned without modification

**Acceptance Criteria:**
- [ ] Level displayed correctly
- [ ] XP progress shown (current/needed)
- [ ] Streak information accurate
- [ ] Total stats displayed

### UC-004: Check Achievements

**Actor:** User

**Preconditions:**
- User has access to the focus training module

**Flow:**
1. User requests achievement list
2. System retrieves all defined achievements
3. System marks which are unlocked for user
4. System returns achievement list with status

**Postconditions:**
- Achievement list returned

**Acceptance Criteria:**
- [ ] All achievement types listed
- [ ] Unlocked achievements show unlockedAt date
- [ ] Locked achievements show requirements
- [ ] XP rewards displayed

### UC-005: Maintain Streak

**Actor:** System (automated)

**Preconditions:**
- User has completed at least one session

**Flow:**
1. System checks lastSessionDate on session completion
2. If session today and none yesterday, reset streak to 1
3. If session today and session yesterday, increment streak
4. If streak > longestStreak, update longestStreak
5. Check streak-based achievements (7-day, 30-day)

**Postconditions:**
- Streak accurately reflects consecutive days
- longestStreak updated if applicable
- Streak achievements unlocked if thresholds met

**Acceptance Criteria:**
- [ ] Daily streak increments correctly
- [ ] Missed day resets streak to 1
- [ ] longestStreak preserves best record
- [ ] streak7Days unlocks at 7-day streak
- [ ] streak30Days unlocks at 30-day streak

### UC-006: Level Up

**Actor:** System (automated)

**Preconditions:**
- User earns XP from session or achievement

**Flow:**
1. System adds XP to totalXP
2. System recalculates level based on new totalXP
3. If level increased, system triggers level up event
4. System updates UserProgress.level

**Postconditions:**
- Level reflects XP total
- Level up notification sent if applicable

**Acceptance Criteria:**
- [ ] Level calculation follows formula
- [ ] Level increases at correct XP thresholds
- [ ] xpForNextLevel() returns accurate value
- [ ] xpInCurrentLevel() tracks progress within level

## UI Workflows

### Screen: Focus Timer (Planned)

**Purpose:** Active focus session interface

**Entry Points:**
- Dashboard start button
- Quick action widget

**Components:**
- TimerDisplay: Large countdown timer with progress ring
- DurationSelector: Preset buttons (15, 25, 45, 60 min) + custom
- PauseButton: Pause/resume session (optional)
- StopButton: End session early
- FocusIndicator: Visual feedback during session

**Actions:**
| Action | Trigger | Result |
|--------|---------|--------|
| Start Session | Start button | Begin countdown |
| Pause | Pause button | Freeze timer |
| Resume | Resume button | Continue timer |
| Complete | Timer ends | Navigate to completion screen |
| Cancel | Stop + confirm | Discard session |

**Navigation:**
- Start → Timer Active State
- Complete → Session Complete Screen
- Cancel → Dashboard

### Screen: Session Complete (Planned)

**Purpose:** Session summary and XP reward

**Entry Points:**
- Timer completion
- Manual end session

**Components:**
- SessionSummary: Duration, completion status
- FocusScoreInput: Slider or rating (0-100)
- XPEarned: Animated XP counter
- AchievementUnlock: Modal for new achievements
- NotesField: Optional session notes
- SaveButton: Confirm and save

**Actions:**
| Action | Trigger | Result |
|--------|---------|--------|
| Rate Focus | Slider change | Update focusScore |
| Add Notes | Text input | Update notes |
| Save | Button tap | Save session, show XP animation |

**Navigation:**
- Save → Dashboard (with XP animation)

### Screen: Progress Dashboard (Planned)

**Purpose:** Overview of user progress and stats

**Entry Points:**
- Main navigation
- Profile section

**Components:**
- LevelBadge: Current level with icon
- XPProgressBar: Progress to next level
- StreakCounter: Current streak with flame icon
- StatsGrid: Total sessions, total time, average score
- RecentSessions: Last 5-10 sessions list
- AchievementPreview: Recently unlocked badges

**Actions:**
| Action | Trigger | Result |
|--------|---------|--------|
| View Achievements | Section tap | Navigate to Achievements |
| View Session | Session tap | Session detail modal |
| Start Session | FAB tap | Navigate to Timer |

**Navigation:**
- FAB → Focus Timer
- Achievements → Achievements Screen

### Screen: Achievements (Planned)

**Purpose:** Display all achievements and progress

**Entry Points:**
- Progress Dashboard link
- Main navigation

**Components:**
- AchievementGrid: All achievements as cards
- UnlockedBadge: Highlighted with date
- LockedBadge: Grayed with progress indicator
- CategoryFilter: Filter by type (streak, sessions, special)
- TotalXPFromAchievements: Sum of achievement XP

**Actions:**
| Action | Trigger | Result |
|--------|---------|--------|
| View Details | Card tap | Show achievement modal |
| Filter | Chip tap | Filter achievement list |

**Navigation:**
- Back → Progress Dashboard

## API Specification

### Future REST API Design

The module currently provides a Dart service layer. The following REST API is planned for future implementation.

### GET /focus/api/v1/sessions

**Description:** Retrieve user's focus sessions

**Authentication:** Required (JWT Bearer)

**Rate Limit:** 60 requests/minute

**Query Parameters:**
| Name | Type | Default | Description |
|------|------|---------|-------------|
| completed | boolean | all | Filter by completion status |
| start_date | string | none | ISO date, sessions after this date |
| end_date | string | none | ISO date, sessions before this date |
| limit | int | 20 | Results per page |
| offset | int | 0 | Pagination offset |

**Response 200:**
```json
{
  "data": [
    {
      "id": "session-uuid-123",
      "startTime": "2026-01-20T14:00:00.000Z",
      "endTime": "2026-01-20T14:25:00.000Z",
      "plannedDuration": 1500,
      "actualDuration": 1500,
      "focusScore": 85,
      "completed": true,
      "xpEarned": 77
    }
  ],
  "meta": {
    "total": 47,
    "limit": 20,
    "offset": 0
  }
}
```

**Error Responses:**
| Code | Condition |
|------|-----------|
| 401 | Not authenticated |
| 500 | Server error |

### POST /focus/api/v1/sessions

**Description:** Create a new focus session

**Authentication:** Required (JWT Bearer)

**Rate Limit:** 30 requests/minute

**Request Body:**
```json
{
  "plannedDuration": "integer - required, seconds",
  "notes": "string - optional"
}
```

**Response 201:**
```json
{
  "data": {
    "id": "session-uuid-123",
    "startTime": "2026-01-20T14:00:00.000Z",
    "plannedDuration": 1500,
    "completed": false
  }
}
```

**Error Responses:**
| Code | Condition |
|------|-----------|
| 400 | Invalid duration |
| 401 | Not authenticated |

### PATCH /focus/api/v1/sessions/{sessionId}

**Description:** Update session (complete, add notes, set score)

**Authentication:** Required (JWT Bearer)

**Path Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| sessionId | string | Yes | Session unique identifier |

**Request Body:**
```json
{
  "completed": "boolean - optional",
  "focusScore": "integer - optional, 0-100",
  "notes": "string - optional"
}
```

**Response 200:**
```json
{
  "data": {
    "id": "session-uuid-123",
    "completed": true,
    "focusScore": 85,
    "xpEarned": 77,
    "newAchievements": ["firstSession"]
  }
}
```

**Error Responses:**
| Code | Condition |
|------|-----------|
| 400 | Invalid score (not 0-100) |
| 401 | Not authenticated |
| 404 | Session not found |

### GET /focus/api/v1/progress

**Description:** Get user's overall progress

**Authentication:** Required (JWT Bearer)

**Response 200:**
```json
{
  "data": {
    "totalXP": 1250,
    "level": 5,
    "xpForNextLevel": 600,
    "xpInCurrentLevel": 250,
    "currentStreak": 12,
    "longestStreak": 25,
    "totalSessions": 47,
    "totalFocusTimeSeconds": 84600,
    "averageFocusScore": 78.5
  }
}
```

### GET /focus/api/v1/achievements

**Description:** Get all achievements with unlock status

**Authentication:** Required (JWT Bearer)

**Response 200:**
```json
{
  "data": [
    {
      "type": "firstSession",
      "name": "First Steps",
      "description": "Complete your first focus session",
      "icon": "🎯",
      "xpReward": 50,
      "unlocked": true,
      "unlockedAt": "2026-01-15T10:30:00.000Z"
    },
    {
      "type": "streak7Days",
      "name": "Week Warrior",
      "description": "Maintain a 7-day focus streak",
      "icon": "🔥",
      "xpReward": 200,
      "unlocked": false,
      "progress": "5/7 days"
    }
  ]
}
```

## Implementation Status

### Data Models

| Model | Status | Notes |
|-------|--------|-------|
| FocusSession | ✅ Implemented | Full model with XP calculation |
| Achievement | ✅ Implemented | All 10 achievement types defined |
| UserProgress | ✅ Implemented | Level calculation, stats tracking |

### Services

| Service | Status | Notes |
|---------|--------|-------|
| Session Management | ⬜ Planned | Start/complete session logic |
| Progress Tracking | ⬜ Planned | XP and level updates |
| Achievement Engine | ⬜ Planned | Unlock detection and rewards |
| Streak Calculator | ⬜ Planned | Daily streak management |

### API Endpoints

| Endpoint | Status | Notes |
|----------|--------|-------|
| GET /sessions | ⬜ Planned | REST API not yet implemented |
| POST /sessions | ⬜ Planned | Currently library-only |
| PATCH /sessions/{id} | ⬜ Planned | |
| GET /progress | ⬜ Planned | |
| GET /achievements | ⬜ Planned | |

### UI Screens

| Screen | Status | Notes |
|--------|--------|-------|
| Login | ⬜ Planned | Uses shared auth_ui package |
| Register | ⬜ Planned | Uses shared auth_ui package |
| Focus Timer | ⬜ Planned | No Flutter UI implemented |
| Session Complete | ⬜ Planned | |
| Progress Dashboard | ⬜ Planned | |
| Achievements | ⬜ Planned | |

### Authentication

| Component | Status | Notes |
|-----------|--------|-------|
| AWS Amplify Integration | ⬜ Planned | Shared Cognito User Pool |
| Shared auth_ui Package | ⬜ Planned | Login/register screens |
| Token Validation | ⬜ Planned | Backend JWT verification |
| Module Access Control | ⬜ Planned | Cognito custom attributes |

### Testing

| Component | Status | Notes |
|-----------|--------|-------|
| Model Tests | ✅ Implemented | Core model functionality tested |
| XP Calculation Tests | ✅ Implemented | Formula verification |
| Level Calculation Tests | ✅ Implemented | Progressive leveling tested |
| Integration Tests | ⬜ Planned | |

**Legend:** ✅ Implemented | 🚧 Partial | ⬜ Planned

## Technical Notes

### Dependencies
- Dart SDK: >=3.0.0 <4.0.0
- No external production dependencies (pure Dart)
- Dev: test ^1.24.0, lints ^3.0.0

### Storage
- Current: In-memory (no persistence)
- Planned: PostgreSQL with user_id scoping

### Key Implementation Details
- Duration stored as seconds in JSON for precision
- Focus score is integer 0-100 for simplicity
- Level progression uses quadratic scaling for longevity
- Achievements use factory pattern for predefined types
- All timestamps use ISO 8601 format
