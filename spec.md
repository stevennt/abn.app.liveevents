# LiveEvents App Specification

## 1. Product Summary
LiveEvents is a Flutter app for discovering and submitting nearby events.
Users can browse events around their current GPS location or a manually selected location (pin on map).

The app must support:
- Guest mode (no login required)
- OneID login/signup flow
- Event submission by anyone
- Prompt to login/create account after guest submission
- Aggregated feed from both user-submitted events and external event sources

## 2. Core Product Goals
1. Make nearby event discovery fast and location-first.
2. Allow low-friction event submission for any user.
3. Merge multi-source events into one clean feed.
4. Keep UX polished with the VisionOS Glass / MEOS visual style.

## 3. Platform and Tech Constraints
- App framework: Flutter
- Product name (display): LiveEvents
- Current repository/package context: `abn_app_liveevents`

## 4. UX and Theme Requirements
- Visual language must follow VisionOS Glass / MEOS style.
- Reference app/theme source: `/Users/thanhson/Workspace/abn.meos.app.1`
- Reuse local skills and style guidance where relevant:
- `/Users/thanhson/Workspace/abn.skills`
- `/Users/thanhson/Workspace/abn.ai.skills`
- https://github.com/stevennt/abn.ai.skills

## 5. Functional Requirements
1. Detect current location (with permission) and show nearby events.
2. Support manual location selection at any time by moving a map pin or searching for a place/city.
3. Feed must merge:
- User-submitted events
- External-source events
4. Feed should reduce duplicates across sources (same event, same place/time).
5. Event details should include: title, date/time, venue, location, category, description, source, and submission owner if applicable.
6. Users can submit events in guest mode.
7. After guest submission, app should prompt account creation/login (OneID).
8. Logged-in users can manage their own submitted events.
9. Users can switch between guest and authenticated sessions without losing browsing continuity.

## 6. Auth Requirements (OneID)
1. Support OneID login.
2. Support OneID signup.
3. Support logout.
4. Guest browsing and guest event submission must remain available.
5. Guest-submitted event handoff to account should be supported when user logs in after submission.

## 7. Feed/Data Requirements
1. Display events ordered by relevance (distance + time freshness by default).
2. Support date/time filtering (today, this weekend, custom date).
3. Support category filtering.
4. Support city/area search fallback when GPS is unavailable.
5. Record source metadata for traceability (user/external provider).

## 8. Backend and Environment Notes
### AXUM API Server
- Local API path: `/Users/thanhson/Workspace/abn.apiserver.rust.axum`
- Skill: `/Users/thanhson/Workspace/abn.apiserver.rust.axum/skills/abn-axum-api-server/SKILL.md`
- Local run commands:
```bash
docker compose -f docker-compose.local.yml build
docker compose -f docker-compose.local.yml up
```
- Production base: `https://axum.abnasia.org`
- Development can use local APIs; final app must work with production API.

### PostgreSQL Schema Reference
- Schema dump file:
`/Users/thanhson/Workspace/abn.postgresql/scripts/docs/full_schema_dump.sql`
- Refresh command:
```bash
cd /Users/thanhson/Workspace/abn.postgresql/scripts/
python3 manage.py schema fetch prod --output docs/full_schema_dump.sql
```

## 9. Security and Credentials Policy
- Do not store API keys, database passwords, JWT secrets, or agent keys in `spec.md`.
- Keep credentials in secure local env/secrets management only.
- Any previously pasted secrets should be considered compromised and rotated.

## 10. Real User Flows (50)
1. User opens app in guest mode and sees nearby events from GPS.
2. User moves a map pin or searches a place/city to browse events in a selected area.
3. User adjusts pin to a nearby district to discover different events.
4. User changes filter to “Tonight” to find immediate options.
5. User switches filter to “This weekend” for planning.
6. User searches events by keyword (e.g., jazz, food festival).
7. User opens event detail and checks schedule and location.
8. User views venue information before deciding to go.
9. User shares an event with a friend via messaging app.
10. User saves an event to favorites.
11. User removes a previously saved event from favorites.
12. User taps map directions to navigate to the event location.
13. User opens ticket link from event detail to purchase externally.
14. User follows an organizer to get more events from them.
15. User follows a venue to track recurring events there.
16. User sets a preferred event category (music, sports, family).
17. User filters for free events only.
18. User filters for family-friendly events.
19. User filters for wheelchair-accessible venues.
20. User changes search radius from 5km to 20km.
21. Traveler changes city manually before arriving.
22. Traveler pins hotel location to see nearby activities.
23. User submits a new event as guest.
24. Guest adds event image and basic details before posting.
25. Guest submits event and receives prompt to create account.
26. Guest skips signup and continues browsing.
27. Guest decides to sign up with OneID after submission.
28. Logged-in user edits details of their submitted event.
29. Logged-in user updates event time after organizer changes it.
30. Logged-in user marks event canceled.
31. Logged-in user reopens a canceled event after confirmation.
32. User reports an event as incorrect information.
33. User flags an event as duplicate.
34. User suggests a correction for venue address.
35. User checks “trending near me” to quickly find popular events.
36. User compares two events happening at similar times.
37. User saves event and adds personal reminder.
38. User opens saved events list to plan the week.
39. User clears past events from saved list.
40. User receives alert when a followed organizer posts new event.
41. User receives alert when an event they saved is updated.
42. User switches from guest to logged-in state and keeps preferences.
43. User reinstalls app and restores favorites after OneID login.
44. Parent searches for kid-friendly daytime events nearby.
45. Nightlife user filters late-night events within ride distance.
46. User checks event source label to trust official organizer posts.
47. Moderator reviews user-reported event and confirms issue.
48. Moderator merges duplicate entries from external and user source.
49. Moderator removes spam event from feed.
50. User sees cleaned, updated feed after moderation actions.

## 11. Out of Scope (Current MVP)
- In-app ticket payments (direct checkout)
- Complex social networking features
- Multi-tenant white-labeling

## 12. Success Criteria (MVP)
1. User can discover relevant nearby events in under 3 interactions.
2. User can submit an event in guest mode in under 2 minutes.
3. Duplicate events from multiple sources are reduced in feed.
4. OneID login is stable for account continuity.
5. UI reflects VisionOS Glass / MEOS quality and consistency.
