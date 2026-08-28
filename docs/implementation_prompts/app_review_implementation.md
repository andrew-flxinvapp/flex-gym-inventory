AppStore/Google Play Review
I want to add an optional App Store / Google Play review prompt to Flex Gym Inventory after a user successfully submits Feedback.
The existing Feedback system is already working end to end.
The desired flow is:
Feedback submitted successfully → existing success Snackbar → optional rating prompt → native app review request
Do not change the existing Feedback backend, Supabase table, Edge Function, Resend integration, or notification email behavior.
Use the existing Flutter Feedback screen and submission logic as the starting point.
 
Stage 1 — Inspect the current Feedback flow
Before making changes, inspect:
•	the existing Feedback screen
•	the successful submission path
•	existing Snackbar behavior
•	current navigation behavior after success
•	any existing modal/dialog/bottom-sheet patterns used elsewhere in the app
•	current local persistence approach used by the app
•	pubspec.yaml for any existing in-app review package
Determine the cleanest way to add a post-feedback review prompt without disrupting the current successful Feedback flow.
Do not modify files yet.
Stop after analysis and tell me:
1.	Which files need to change.
2.	Whether in_app_review or another review package is already installed.
3.	What existing UI pattern should be reused for the prompt.
4.	What local persistence mechanism should be used to avoid repeatedly prompting the same user.
 
Stage 2 — Add native review support
If the project does not already have native app review support, add the appropriate Flutter package.
Prefer:
in_app_review
unless the project already uses another established approach.
Do not add unnecessary packages.
Create a small review service/helper if appropriate rather than placing all review logic directly in the Feedback screen.
The service should be responsible for:
•	checking whether native in-app review is available
•	requesting the native review prompt
•	safely handling platforms where it is unavailable
•	handling exceptions without breaking the Feedback flow
Review failures should never cause the Feedback submission to appear unsuccessful.
Stop after completing this stage.
 
Stage 3 — Add review prompt eligibility
The review prompt should not appear after every Feedback submission.
Add a simple local persistence mechanism to track review-prompt eligibility.
Requirements:
•	Do not require Supabase.
•	Do not store this in the Feedback backend.
•	Use existing local persistence infrastructure if one already exists.
•	Avoid repeatedly showing the review prompt to the same user.
At minimum, store whether the user has already been shown the post-feedback review prompt.
If the project already has a better reusable preference/settings abstraction, use it.
Do not introduce a complicated review-frequency system unless necessary.
Stop after this stage.
 
Stage 4 — Add the post-feedback rating prompt
After a Feedback submission succeeds:
1.	Keep the existing success Snackbar behavior.
2.	Do not show the review prompt before the success state is clearly communicated.
3.	If the user is eligible to see the review prompt, display a small app-standard modal/dialog after the successful submission flow.
4.	Preserve the current Feedback screen design.
Suggested copy:
Title
Enjoying Flex Gym Inventory?
Body
If Flex Gym Inventory has been helpful, would you mind leaving a quick rating?
Actions:
•	Rate Flex Gym Inventory
•	Not Now
Reuse the app’s existing modal/dialog components and styling where possible.
Do not create a custom star-rating selector.
Do not ask the user to choose a positive or negative rating before opening the native review flow.
Do not implement review gating.
Stop after wiring the prompt.
 
Stage 5 — Native review behavior
When the user taps:
Rate Flex Gym Inventory
request the native in-app review prompt using the review service.
Requirements:
•	Use the native App Store / Google Play review mechanism.
•	Do not create a fake in-app review form.
•	Do not assume the native review dialog will always appear.
•	Do not treat failure to display the native review dialog as an app error.
•	Do not navigate the user away unnecessarily.
•	Do not alter the successful Feedback record.
After the user interacts with the custom review prompt, update the local persistence flag so the prompt is not shown repeatedly.
If the user taps:
Not Now
dismiss the modal and also follow the chosen persistence behavior so they are not immediately prompted again.
Stop after this stage.
 
Stage 6 — Review the implementation
Check specifically for:
•	review prompt appearing before the Feedback success message
•	review prompt appearing after failed Feedback submissions
•	repeated review prompts
•	unsafe BuildContext usage after async calls
•	review-service exceptions breaking the Feedback flow
•	duplicate modals
•	unnecessary navigation
•	custom star ratings or review gating
•	changes to Supabase or Feedback backend code
•	unrelated UI refactors
Make only changes required for this feature.
Then give me a concise summary of the files changed.
 
Stage 7 — Manual testing checklist
Provide a manual test checklist covering:
1.	Successful Feedback submission while eligible for review prompt
2.	Successful Feedback submission after the prompt has already been shown
3.	Failed Feedback submission
4.	Tapping Rate Flex Gym Inventory
5.	Tapping Not Now
6.	Native review API unavailable
7.	Native review request throwing an exception
8.	Confirming Feedback still submits normally regardless of review behavior
9.	Confirming the review prompt does not repeatedly appear
10.	Confirming existing Feedback success Snackbar behavior still works
Do not modify the Feedback backend or Supabase configuration.
One small choice I’d make before implementation: I’d persist “review prompt already shown” rather than “user reviewed app.” The native review APIs generally don’t tell you whether the user actually submitted a review, so your app shouldn’t pretend it knows that.
And I’d probably have both Rate and Not Now mark that post-feedback prompt as shown for v1.0. That keeps it pleasantly non-pushy.
