# Focus Training — Primary Workflows

Documents the main user-facing journeys through the Focus Training app.

---

## Navigation Structure

Single-screen app rooted at **HomeScreen** with navigation to:
- **SessionScreen** — run a focus session
- **AchievementsScreen** — view earned and locked achievements

---

## 1. Running a Focus Session (Core Workflow)

### Step 1: Open the App
- **HomeScreen** displays:
  - Current level and XP progress bar
  - Active streak (days in a row with a focus session)
  - Recent session history
  - "Start Session" button

### Step 2: Configure the Session
**Entry:** HomeScreen → **Start Session**

1. Select duration: 15 min / 25 min / 45 min / 60+ min
2. (Optional) Add context/notes for the session (e.g. "Writing chapter 2")
3. Tap **Begin** → session timer starts

### Step 3: Focus
- Timer counts down
- Distraction-free interface
- Option to **Abandon** session (no XP awarded)

### Step 4: Complete the Session
- Timer reaches zero → session complete
- Rate focus score (0–100): how focused were you?
- Tap **Submit**

### Step 5: See Results
- XP earned = base (duration) + bonus (focus score ≥ 80) displayed
- Any newly unlocked achievements shown
- Level-up animation if XP threshold crossed
- Streak increments if first session of the day

---

## 2. XP and Leveling

| Level | XP Required |
|-------|-------------|
| 1 | 0 |
| 2 | 100 |
| 3 | 250 |
| ... | scales up |

- **Base XP**: proportional to session duration (e.g. 25 min = 25 XP)
- **Bonus XP**: +10 for focus score ≥ 80; +20 for perfect score (100)
- Level-up displayed immediately after session

---

## 3. Achievements

**Entry:** HomeScreen → **Achievements** (trophy icon or tab)

- **AchievementsScreen** shows:
  - Unlocked section with count and achievement cards (icon, name, XP reward)
  - Locked section with lock icons and remaining criteria

### Achievement Criteria

| Achievement | Criterion |
|-------------|-----------|
| First Steps | Complete first session |
| Getting Started | Complete 10 sessions |
| Focused Mind | Complete 50 sessions |
| Focus Master | Complete 100 sessions |
| Perfect Focus | Achieve focus score of 100 |
| Week Warrior | Maintain a 7-day streak |
| Monthly Master | Maintain a 30-day streak |
| Early Bird | Complete a session before 6 AM |
| Night Owl | Complete a session after 10 PM |
| Marathon Focus | Complete a 2+ hour session |

---

## 4. Streaks

- A streak increments when at least one session is completed each calendar day
- HomeScreen streak card shows: current streak (days) and longest streak (days)
- Streak resets to 0 if a day is missed

---

## 5. Statistics (HomeScreen)

| Stat | Description |
|------|-------------|
| Total sessions | Lifetime count of completed sessions |
| Total focus time | Sum of all completed session durations |
| Average focus score | Mean score across all completed sessions |
| Recent sessions | Last 30 days shown as a scrollable list |

---

## 6. Persistence

- Progress is saved to a local JSON file on every session completion
- Loaded automatically on app startup
- **Reset Progress** option in settings (clears all data)

---

## 7. Typical Workflow

```
HomeScreen
    → Review stats and streak
    → Tap "Start Session"
        → Choose 25 min
        → Focus
        → Submit with score 85
    → See XP awarded + achievement unlocked (if any)
    → Return to HomeScreen — streak updated
    → Tap Achievements — see newly unlocked badge
```
