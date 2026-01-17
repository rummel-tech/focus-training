# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-17

### Added
- Initial release of the Focus Training module with comprehensive gamification features
- **FocusSession** model for tracking individual training sessions
  - Focus score tracking (0-100)
  - Duration tracking (planned and actual)
  - XP calculation based on completion, duration, and focus score
- **UserProgress** model for tracking overall user statistics
  - Level progression system with dynamic XP requirements
  - Streak tracking (current and longest streaks)
  - Total sessions and focus time tracking
  - Average focus score calculation
- **Achievement** system with 10 unique achievements
  - First Steps (first session)
  - Week Warrior (7-day streak)
  - Monthly Master (30-day streak)
  - Getting Started (10 sessions)
  - Focused Mind (50 sessions)
  - Focus Master (100 sessions)
  - Perfect Focus (100 score)
  - Early Bird (session before 6 AM)
  - Night Owl (session after 10 PM)
  - Marathon Focus (2+ hour session)
- **FocusTrainingService** for managing sessions and progress
  - Start and complete sessions
  - Automatic XP and level calculation
  - Achievement unlock system
  - Streak tracking with daily reset logic
  - Motivational feedback system
  - Progress persistence (save/load JSON)
- Comprehensive test suite with 17 tests
- Example application demonstrating all features
- Full API documentation in README
