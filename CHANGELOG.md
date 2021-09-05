# Change Log

## [v0.8.5](https://github.com/reiterate-app/authorio/tree/v0.8.5) (2021-09-05)

This releases fixes a bug in the PKCE flow that was allowing failed checks to pass. Authorio
still supports "legacy" clients which don't use PKCE at all, but if a code_challenge is given
it is properly validated against the verifier.

- Use rails idiom for time in req check3eeeabe3061cd53ff632135155d44df2adfcb9d9
- Refactoring in auth con. Fix always-match blank verifier be6a89f22d03da67ac143604893747fb5570ec8e
- Cleanup auth controller 62b574575b7b997beb77a987d4be8f1a9f5329ba
- Fix: PKCE validation 0e6d1faa68b0cb09c7d9db14d2023a2e0d6ce5d5
- Fix: Press Return from auth form defaults to Sign In abd50e9f6cb2d18c99e0cb7f5ff3d5553aa3403b
- Removed offline_access scope since IndieAuth will not be requiring that 940414a0584b20a2c3551308c766b32ce792fd91
- Fix: Legacy clients without PKCE raised exception 0884f2c35cd8da3035303e8cdc0fc32564dca866

## [v0.8.4](https://github.com/reiterate-app/authorio/tree/v0.8.4)  (2021-08-18)

No new features in this release, but a major restructuring of the underlying code. In particular,
user profile URLs have changed. They are no longer specified explicitly per-user, but are instead
constructed on the fly via Rails' routing mechanics.

- User profile URLs are now handled via Rails resource routes (verify_user_url) 3a9ccac1d8c285a06d8a8daca1999978175386d0
- Fail early if token_request called with no token e082ac52b74cd11729eecaf9332181057e95b2e4
- Cleaned up Exceptions::SessionReplayAttack 25459ce694fed0d3df41bd8a62cd84373e7f42f7
- Auto require all files under lib/authorio d764e8c68ebfb203e0fc42155180092e825b7bdf

## [v0.8.3](https://github.com/reiterate-app/authorio/tree/v0.8.3) (2021-08-07)

This version requires migrations if you are upgrading from 0.8.2. Rerun `rails authorio:install:migrations` and
`rails db:migrate`

**Bugfixes**

- Return HTTP error for invalid grant instead of raising exception

**Enhancements**

- Support for user profiles
  * Visit authorio root to set up your profile
- Support for profile and email scope
  * If an authenticating client requests your profile, you can approve the request on the
    login screen
  * Uncheck the requested scopes to remain anonymous
- Refactored session code. There are now two kinds of sessions, temporary (until window closes)
  and permanent (remember-me)
- Sessions controller to manage new session data
- Refactored auth form
- Added a top bar for logged in users
- Added more descriptive error messages for auth workflow errors

## [v0.8.2](https://github.com/reiterate-app/authorio/tree/v0.8.2) (2021-07-24)

**Bugfixes**

- Fixed Autoloaded constant warning by wrapping initializer
- Fixed 'Invlad User' typo
- Added token expiry
    * Added new token_expiration in the config (default 4 weeks)
    * If you are upgrading from v0.8.1, you *must rerun* `rails authorio:install:migrations` and `rails db:migrate`
- Fixed an issue with CSRF on authentication form

**Enhancements**

- Move tag helper to helpers/ dir where it belongs
- Improved some Rails coding idioms
- Cleaned up begin..raise..end blocks
- Refactored layouts and views
- Added local sessions. Enable in config and click "Remember me" to bypass password entry

## [v0.8.1](https://github.com/reiterate-app/authorio/tree/v0.8.1) (2021-07-13)

**Enhancements**

- Documentation cleanup. Filled out README and cleaned up gemspec
- Added test for invalid tokens
- Password field is autofocused on page load


## [v0.8.0](https://github.com/reiterate-app/authorio/tree/523c3ad61a21a870cc283b9c1d2c675f47a9ec82) (2021-07-10)

**Initial Release**
