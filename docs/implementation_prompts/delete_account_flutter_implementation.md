# Flex Gym Inventory — Delete Account Flutter Implementation

## Context

The Delete Account screen is already built to the intended UI spec.

This task is **Flutter-side implementation only**.

Do not create or modify Supabase database tables, Edge Functions, RLS policies, SQL migrations, Supabase secrets, or other backend infrastructure. The Supabase `delete-account` Edge Function will be implemented separately.

The app uses:

* Flutter
* Supabase Auth
* Isar for locally stored user-created gym/equipment data
* Existing custom FGI widgets and design patterns

The goal is to wire the existing Delete Account screen into the account deletion flow while keeping UI, service logic, local-data cleanup, and backend communication properly separated.

---

# Intended User Flow

The Delete Account screen should allow the user to optionally provide a reason for deleting their account.

Deletion reasons should support the following options:

* I don't use the app anymore
* The app is missing features I need
* I'm having technical issues
* The app is too difficult to use
* I'm not getting enough value from the app
* I have privacy or data concerns
* I'm switching to another app
* Other

The survey is optional and must never prevent the user from deleting their account.

When `Other` is selected, show an optional free-text field:

**Tell us more (optional)**

The deletion flow should be:

1. User selects an optional deletion reason.
2. User optionally enters additional details when applicable.
3. User taps the existing Delete Account button.
4. Show a final destructive confirmation dialog/modal.
5. If the user confirms, invoke the Supabase `delete-account` Edge Function.
6. Wait for a successful response from the backend.
7. Only after successful server-side account deletion:

   * clear the user's local Isar data,
   * clear any appropriate locally stored user/session-specific preferences or cached state,
   * sign out/clear the Supabase client session if required,
   * navigate back to the unauthenticated/sign-in flow.
8. Prevent access to authenticated screens after deletion.

If the Edge Function fails, DO NOT clear the user's Isar data or navigate away from the authenticated experience.

---

# Architecture Requirements

Do not place all account-deletion logic directly inside the screen widget.

Follow the project's existing architecture and patterns.

Inspect the repository before making changes and identify:

* the existing Delete Account screen,
* existing account/authentication service or repository classes,
* Supabase Edge Function invocation patterns,
* Isar database/repository cleanup methods,
* existing confirmation dialog/modal patterns,
* existing loading/error/success handling patterns,
* existing navigation/auth-state handling,
* custom buttons, inputs, cards, dialogs, and other FGI widgets used by this screen.

Reuse existing infrastructure whenever possible.

Do not introduce duplicate service classes, duplicate repository methods, duplicate dialogs, or new architectural patterns if an equivalent already exists.

---

# Edge Function Request

The Flutter client should call:

`delete-account`

Use the currently authenticated Supabase session/JWT.

Do not send a user ID from Flutter. The Edge Function will determine the user from the authenticated request.

The request body should contain only applicable deletion-feedback data, such as:

```json
{
  "reason": "missing_features",
  "details": "Optional user-provided details"
}
```

Exact reason keys should use stable machine-readable values.

Suggested mappings:

```text
not_using_app
missing_features
technical_issues
difficult_to_use
not_enough_value
privacy_concerns
switching_apps
other
```

If no reason is selected, the request should still be valid.

If no details are entered, omit the value or send null according to the project's existing API conventions.

Do not send:

* email
* name
* Supabase user ID
* service-role credentials
* any administrative Supabase key

Never place the Supabase service-role key in Flutter.

---

# Error Handling

Account deletion is destructive, so errors must be handled conservatively.

If the Edge Function request fails:

* keep the user signed in,
* retain all Isar data,
* stop the deletion flow,
* restore the Delete Account button/loading state,
* display an appropriate user-facing error message using the app's existing error pattern.

Do not partially clear local data following a failed backend request.

Log useful diagnostics using the project's existing logging/debug conventions, but never log sensitive tokens or credentials.

---

# Loading State

Once the user confirms account deletion:

* prevent duplicate submissions,
* disable destructive controls while the request is active,
* show the existing FGI loading treatment or progress indicator,
* prevent the user from accidentally triggering deletion multiple times.

Restore normal UI state if the request fails.

---

# Local Data Cleanup

After the backend explicitly confirms successful account deletion, determine which local Isar data belongs to the current user and clear it using existing repository/database APIs.

Inspect the project before adding new cleanup methods.

Do not blindly delete unrelated application configuration if it should survive between sessions.

User-created inventory data associated with the deleted account should no longer remain accessible after deletion.

If local cleanup fails after the remote account has already been deleted:

* do not attempt to restore the deleted Supabase account,
* safely force the application back to its unauthenticated state,
* log the cleanup failure,
* avoid leaving the user inside authenticated screens.

---

# Auth State

After the Edge Function successfully deletes the Supabase Auth user, ensure the client no longer considers the user authenticated.

Use the project's existing Supabase Auth/session management and navigation architecture.

Avoid manually forcing navigation in a way that conflicts with an existing auth-state listener or router.

Inspect the current implementation first.

---

# UI Requirements

The Delete Account screen is already built to spec.

Do not redesign the screen.

Do not change:

* page structure,
* typography,
* colors,
* spacing,
* button styles,
* app bars,
* cards,
* overall layout

unless a functional implementation absolutely requires a minor adjustment.

Use existing Flex Gym Inventory custom widgets wherever available.

Icons must remain consistent with the project's existing Flaticon Interface icon system.

Do not substitute Material or Cupertino icons where a project asset already exists.

---

# Validation

The deletion survey itself is optional.

Therefore:

* no reason should be required,
* `Other` text should not be required,
* selecting `Other` may reveal the details field,
* users must still be able to proceed without entering additional text.

If the project already has reasonable text-length limits, reuse them.

Otherwise, do not invent arbitrary restrictions without identifying the need first.

---

# Confirmation

The final confirmation must clearly communicate that deletion is permanent.

Use the existing project confirmation-dialog pattern if one exists.

The user must explicitly confirm the destructive action before the backend request is sent.

Cancelling the confirmation should make no changes.

---

# Scope Restrictions

For this implementation:

DO:

* wire the existing Delete Account screen,
* implement/manage selection state,
* implement conditional Other-details input behavior,
* create or update the appropriate Flutter service/repository method,
* invoke the existing/future `delete-account` Edge Function,
* handle response/error/loading states,
* clear appropriate local data after confirmed backend success,
* integrate with the existing auth/navigation flow.

DO NOT:

* create Supabase tables,
* write SQL,
* configure RLS,
* create the Edge Function,
* edit Supabase secrets,
* implement service-role behavior in Flutter,
* redesign the Delete Account UI,
* add new account-deletion features outside this flow,
* add analytics SDKs,
* add new packages unless the current project genuinely lacks required functionality.

---

# Implementation Process

Work in stages.

## Stage 1 — Repository Audit

Inspect the relevant project files and report:

1. Delete Account screen file path.
2. Current UI/state structure of the screen.
3. Existing account/auth service and repository files.
4. Existing Supabase Edge Function invocation examples.
5. Existing Isar cleanup/reset capabilities.
6. Current auth-state/navigation behavior following logout.
7. Existing destructive confirmation component/pattern.
8. Existing loading/error UI patterns that should be reused.
9. Exact files you recommend modifying.

Do not modify code during Stage 1.

Also identify any potential risks or architecture conflicts before implementation.

At the end of Stage 1, stop and ask permission to proceed to Stage 2.

---

## Stage 2 — Screen State and Survey Behavior

Implement only the Flutter-side deletion-reason selection behavior.

Requirements:

* optional reason selection,
* `Other` conditional details input,
* proper controller/state disposal,
* no backend request yet,
* preserve existing visual design.

Report the files changed.

At the end of Stage 2, stop and ask permission to proceed to Stage 3.

---

## Stage 3 — Delete Account Service Integration

Implement the Flutter service/repository method that invokes:

`delete-account`

Requirements:

* use the authenticated Supabase client,
* send only the reason/details payload,
* do not send user ID,
* do not include admin/service-role credentials,
* return a clear success/failure result that the UI can handle.

Follow existing project architecture.

Do not clear Isar data yet.

Report the files changed.

At the end of Stage 3, stop and ask permission to proceed to Stage 4.

---

## Stage 4 — Confirmation and Submission Flow

Wire the existing Delete Account button to:

* show final destructive confirmation,
* prevent duplicate requests,
* show loading state,
* invoke the account deletion service,
* handle backend errors without deleting local data.

Do not perform final Isar cleanup until successful backend deletion is confirmed.

Report the files changed.

At the end of Stage 4, stop and ask permission to proceed to Stage 5.

---

## Stage 5 — Local Cleanup and Auth Exit

After successful backend deletion:

* clear appropriate user-created Isar data,
* clear appropriate user-specific cached/local state,
* ensure the Supabase client is no longer authenticated,
* return the app to its existing unauthenticated/sign-in flow.

Use current repository/auth/navigation architecture.

Do not introduce a competing navigation architecture.

Report exactly what data is cleared and what remains.

At the end of Stage 5, stop and ask permission to proceed to Stage 6.

---

## Stage 6 — Testing and Review

Review the completed implementation and provide a testing checklist covering at minimum:

* deletion with no reason selected,
* deletion with each standard reason,
* `Other` with no text,
* `Other` with text,
* cancelling the confirmation,
* Edge Function success,
* Edge Function 401 response,
* Edge Function validation failure,
* network failure,
* duplicate-tap prevention,
* local Isar cleanup,
* auth-state reset,
* navigation after successful deletion,
* relaunching the app after deletion,
* ensuring authenticated data is no longer accessible.

Do not make unrelated refactors during testing.

At the end of Stage 6, provide a concise implementation summary and identify any remaining issues.

Stop and ask permission before making any additional changes.
