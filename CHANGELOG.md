# Change Log

## [v0.8.2](https://github.com/reiterate-app/authorio/tree/v0.8.1) (2021-07-24)

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
