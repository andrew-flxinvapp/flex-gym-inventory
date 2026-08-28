The new Flex Gym Inventory Account screen has already been designed and built to spec.
Do NOT redesign, restructure, restyle, or rebuild the screen.
Your task is only to wire the existing Account screen to the correct backend/auth/subscription data and existing navigation flows.

Before making changes, inspect:
- the current Account screen
- existing Supabase auth implementation
- existing RevenueCat/subscription implementation
- existing navigation/routes
- existing Delete Account flow
- existing Upgrade to PRO/paywall flow
- existing state management/services/repositories/providers used elsewhere in the app

Do not invent new architecture if equivalent implementations already exist.

Goal

Connect the already-built Account screen to real app data and existing actions for v1.0.

The screen layout and visual design are already correct and should remain unchanged unless a code change is strictly required to make the existing UI functional.

Account Screen Requirements

1. Email
The existing Email display should show the currently authenticated user's email address.

Source the email directly from Supabase Auth using the current authenticated user/session.

Requirements:
- Display only
- Do not make the email editable
- Do not create a Supabase profile table
- Do not create a profile model or profile repository
- Do not duplicate the email into Isar
- Do not store the email elsewhere just for this screen
Use the existing Supabase client/auth abstraction if one already exists in the project rather than introducing a new access pattern unnecessarily.
If the current user or email is unexpectedly unavailable, handle it safely using the project's existing error/fallback conventions.
Do not use a fake email address as fallback data.

2. Plan
The existing Plan display should show:
Free
or
PRO
Use the project's existing RevenueCat implementation as the source of truth for the user's subscription entitlement.

Requirements:
- RevenueCat determines whether the user is Free or PRO
- Do not store subscription state in Supabase Auth metadata
- Do not create a duplicate subscription system
- Reuse the existing entitlement/provider/service/repository if one exists
Handle RevenueCat loading and error states using the project's existing conventions.

3. Upgrade to PRO
The existing Upgrade to PRO UI is already built.
Wire its visibility to the RevenueCat entitlement state.
Behavior:
- Free user: show Upgrade to PRO
- PRO user: hide Upgrade to PRO entirely
When tapped:
- Route to the existing Upgrade to PRO/paywall/purchase flow
- Do not create a second paywall or subscription flow
Preserve the existing UI styling exactly.

4. Legal
The existing:
- Privacy Policy
- Terms & Conditions
rows are already built and route to external out of app locations.
Preserve their current styling and routing.
Verify that each routes to the existing correct destination.
Do not redesign these rows.

5. Log Out
Wire the existing Log Out button to the project's current Supabase sign-out implementation.
Use the existing auth/session architecture.
If the app already reacts to Supabase auth-state changes and redirects unauthenticated users automatically, rely on that behavior rather than adding unnecessary manual navigation.
Avoid duplicate sign-out logic.

6. Delete Account
The existing Delete Account action should NOT directly delete the user.
It should route to the existing Delete Account screen.
The existing Delete Account screen already contains the deletion survey/confirmation flow and should remain responsible for the deletion process.

Do not:
- add another confirmation dialog on the Account screen
- duplicate the deletion survey
- duplicate account deletion logic
- immediately delete the user when this action is tapped

Backend Responsibility Summary
Supabase Auth:
- authenticated user email
- auth/session state
- Log Out
- existing account deletion backend flow

RevenueCat:
- Free vs PRO entitlement
- Upgrade to PRO visibility
- existing purchase/subscription flow

No Profile System
Do NOT add:
- full name storage
- phone number storage
- profile table
- profile DTO
- profile model
- profile repository
- profile editing
- duplicated account metadata
- biometric login logic

Biometric login is not part of FGI v1.0.

Important UI Constraint
The Account screen is already built to the approved design.
Do not change:
- screen layout
- card sizing
- section ordering
- typography
- spacing
- colors
- button styles
- icons
- existing custom widgets

unless a very small code-level adjustment is necessary to connect the real data.
If an existing widget currently contains temporary/static placeholder data, replace only the data source while preserving the widget and its presentation.

Implementation Approach
1. Inspect the existing Account screen. Stop and ask to proceed.
2. Identify any placeholder/static email or plan values. Stop and ask to proceed.
3. Identify the actual Supabase auth source already used by the app. Stop and ask to proceed.
4. Identify the actual RevenueCat entitlement implementation already used by the app. Stop and ask to proceed.
5. Identify the existing Upgrade to PRO route. Stop and ask to proceed.
6. Identify the existing Delete Account route. Stop and ask to proceed.
7. Identify the existing Log Out implementation. Stop and ask to proceed.
8. Wire the existing UI to these implementations. Stop and ask to proceed.
9. Remove only obsolete placeholder/profile-specific logic that is no longer needed. Stop and ask to proceed.
10. Do not refactor unrelated parts of the app. Stop and ask to proceed.
11. Run flutter analyze after implementation. Stop and ask to proceed.

When finished, report:

- Files changed
- How the Email field is now populated
- How the Plan field is now populated
- How Upgrade to PRO visibility is determined
- What route/action Upgrade to PRO uses
- How Log Out is handled
- Where Delete Account routes
- Any placeholder code removed
- Any warnings or existing issues discovered

Important:
Do not hallucinate class names, route names, entitlement IDs, repositories, providers, services, or widgets.
Inspect the codebase and use the actual existing implementation.

Important Workflow Instruction:
Work through this task one step at a time.
After completing each numbered implementation step, stop and summarize:
- what you inspected or changed
- any relevant findings
- any issues or uncertainties
- what you recommend doing next
Then explicitly ask for permission to proceed to the next step.
Do not continue to the next step until I confirm that you may proceed.
