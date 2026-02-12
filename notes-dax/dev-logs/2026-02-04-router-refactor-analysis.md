# Dev Log: Router Refactoring Analysis

## Raw Input
> Currently the router its a riverpod provider, and i have the intuition that this isn't correct (even though it works).
> I read through the code and realized that it looks like the reason the app needs to rebuild the router config when the auth state changes is because of the redirect function: instead having the ref, or isAuthenticated as an input, it actually rebuilds the entire configuration and that function when the vaule changes. So in a way it's a weird implicit demendency. To me this seems like it's obviously a bad approach. I'm open-minded but it that way to me now. What i would like to look for is a way to add another input the redirect function, or use the ref directly in the function, adn I don't think the router should be a provider (perhaps a consumer).

## Context
The user identified that the current router implementation as a Riverpod provider might be suboptimal. Specifically, the `routerConfig` is completely rebuilt when the authentication state changes. This is due to the `redirect` function's implicit dependency on the auth state, which is currently handled by watching the auth provider and returning a new router config.

## Problem
- **Rebuilding Router Config:** The entire `GoRouter` configuration is rebuilt on every auth state change.
- **Implicit Dependency:** The `redirect` logic relies on the current value of the auth provider at the time of construction, necessitating the rebuild to capture the new value.
- **Architectural Smell:** Treating the router configuration itself as a provider that depends on other providers for state changes (like auth) feels "weird" and potentially inefficient or brittle compared to a stable router instance that consumes state dynamically.

## Goal
- Refactor the router so it doesn't need to be fully rebuilt on auth changes.
- Investigate ways to inject dependencies (like `ref` or auth state) into the `redirect` function dynamically.
- Move away from the pattern where the router is a provider, if possible, or at least stabilize the instance.

## Investigation Plan
1.  **Examine Current Implementation:** Read `client-flutter/lib/shared/router/` and `client-flutter/lib/app.dart` to see the current setup.
2.  **Analyze Dependencies:** Identify exactly what the `redirect` function needs.
3.  **Propose Refactor:** Look for patterns (like `GoRouter`'s `refreshListenable`) that allow the router to react to state changes without being rebuilt.
