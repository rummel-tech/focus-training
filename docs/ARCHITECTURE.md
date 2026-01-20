# Focus Training Architecture

## Overview

Focus Training is a Python application for gamified focus sessions with progress tracking and achievement systems.

## System Components

```
┌─────────────────────┐
│   Focus Training    │
│   (Python CLI)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   SQLite Database   │
└─────────────────────┘
```

## Project Structure

```
focus-training/
├── src/
│   ├── models/             # Data models
│   ├── services/           # Business logic
│   ├── gamification/       # XP, levels, achievements
│   └── utils/              # Utilities
├── tests/                  # Pytest suite
├── requirements.txt        # Dependencies
└── README.md
```

## Data Models

### FocusSession
- id, user_id
- start_time, end_time, duration
- focus_type, topic
- completed, interrupted

### Achievement
- id, name, description
- criteria, badge_icon
- xp_reward

### UserProgress
- user_id, total_xp, level
- achievements_earned
- daily_streak, longest_streak

## Gamification System

### XP and Levels
- XP earned per completed session
- Level progression with milestones
- Bonus XP for streaks

### Achievements
- Session-based (complete X sessions)
- Streak-based (X days in a row)
- Time-based (total hours focused)

## Services

### SessionManager
- Start/end focus sessions
- Track interruptions
- Calculate session score

### GamificationEngine
- Calculate XP rewards
- Check achievement conditions
- Update user progress

## Future Enhancements

- Flutter frontend for cross-platform UI
- FastAPI backend for web access
- Social features and leaderboards
- Integration with workout planner

## Related Documentation

- [Module README](../README.md)
- [Changelog](../CHANGELOG.md)
- [Platform Architecture](../../../../docs/ARCHITECTURE.md)

---

[Back to Module](../) | [Platform Documentation](../../../../docs/)
