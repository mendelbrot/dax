# Plan summary by user

Navigating between pages requires context.go, not context.push/pop.

context.push was incorrectly used because page data needed to be refreshed when returning back to a page, and this provided a way to do that, by running fetch commands after awaiting a context.push.

Besides breaking web url navigation, this strategy also makes the code more brittle and difficult to reason about.

In this plan we will fix navigation. Please also remove logic associated with data fetching and page state management after completion of await context.push. Page data refresh is a separate issue that will be addressed in another task.

The relevant pages are:
* home page: /
* vault page: /vault/vaultId
* vault settings page: vault/vaultId/settings
* entry page: vault/vaultId/entry/entryId

Replace context.push/pop with context.go for all navigation between pages, including:
home page -> vault page
vault page ->  vault settings page
vault page -> entry page
vault settings page -> vault page
vault settings page -> home page (after delete vault)
entry page -> vault page (after delete entry)

