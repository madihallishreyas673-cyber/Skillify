# Skillify - Your Skills. Global Opportunities.

A native Android app (Flutter/Dart) that helps people turn skills into jobs, paid projects and income.
Black and gold theme matching the Skillify logo.

**To get the APK, read `HOW_TO_GET_APK.md`.**

## What version 1 includes

| Area | Status |
|---|---|
| Welcome, onboarding, register, login | Done. Accounts live on the phone only (salted SHA-256 hash). |
| Skill assessment | Done. Rules-based fit scores, strengths, skill gaps, beginner path. |
| Personalized learning | Done. 7 careers, 9-lesson starter plan each, free resources, daily/weekly tasks, quizzes, projects, progress tracking. |
| Job and project finder | Done. Demo data clearly labelled; live remote jobs from the public Remotive API; search, filters, bookmarks, application tracker. |
| Resume, cover letter, portfolio | Done. Uses only what the user enters. PDF export (Latin characters only). |
| Career assistant | Done. Offline rules-based assistant. Optional cloud AI through your own backend. Never applies or contacts anyone. |
| Dashboard | Done. Assessment, progress, weekly goal, recommendations, saved jobs, applications, projects, next actions. |

## Not in version 1 (by design)

- Real payments, employer accounts, recruiter tools (architecture prepared in `backend/schema.sql`).
- Server-side user accounts, cloud sync and cloud storage for resumes (next stage).
- Live job sources beyond Remotive. Add more authorised APIs later; never invent listings.

## Secrets

No API keys are in the app. The optional AI backend (`backend/`) keeps the AI key in environment variables on
the server. In the app, Profile > Cloud AI takes your backend URL and an access key you choose.

## Project layout

- `lib/` - app code (`screens/`, `data.dart` content, `engine.dart` logic, `state.dart` storage, `api.dart`)
- `assets/` - Skillify logo and launcher icon images
- `.github/workflows/build-apk.yml` - cloud APK build
- `tools/patch_manifest.py` - sets app name and permissions on the generated Android project
- `backend/` - optional Node.js AI proxy, plus PostgreSQL schema for the next stage

## Status honesty

This code was written without access to Flutter in the authoring environment, so it has not been compiled or run yet.
The first cloud build may show small compile errors; send the error text and they can be fixed quickly.
