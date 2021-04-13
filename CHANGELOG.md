# Changelog

## [Unreleased](https://github.com/rails-on-services/apartment/tree/HEAD)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.8.0...HEAD)

**Implemented enhancements:**

**Fixed bugs:**

- New version raises an error with ActiveSupport::LogSubscriber [#128](https://github.com/rails-on-services/apartment/issues/128)
- Weird logs when tenant fails to create [#127](<https://github.com/rails-on-services/apartment/issues/127>)

**Closed issues:**

## [v2.8.0](https://github.com/rails-on-services/apartment/tree/v2.8.0) (2020-12-16)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.7.2...v2.8.0)

**Implemented enhancements:**

-   Uses a transaction to create a tenant [#66](https://github.com/rails-on-services/apartment/issues/66)

**Fixed bugs:**

-   Fix seeding errors [#86](https://github.com/rails-on-services/apartment/issues/86)
-   When tests run in a transaction, new tenants in tests fail to create [#123](https://github.com/rails-on-services/apartment/issues/123)
-   Reverted unsafe initializer - introduces the possibility of disabling the initial connection to the database via
    environment variable. Relates to the following tickets/PRs:
    -   [#113](https://github.com/rails-on-services/apartment/issues/113)
    -   [#39](https://github.com/rails-on-services/apartment/pull/39)
    -   [#53](https://github.com/rails-on-services/apartment/pull/53)
    -   [#118](https://github.com/rails-on-services/apartment/pull/118)

**Closed issues:**

-   Improve changelog automatic generation [#98](https://github.com/rails-on-services/apartment/issues/98)
-   Relaxes dependencies to allow rails 6.1 [#121](https://github.com/rails-on-services/apartment/issues/121)


## [v2.7.2](https://github.com/rails-on-services/apartment/tree/v2.7.2) (2020-07-17)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.7.1...v2.7.2)

**Implemented enhancements:**

- Deprecate History.md [\#80](https://github.com/rails-on-services/apartment/issues/80)

**Fixed bugs:**

- Tenant.switch! raises exception on first call / Postgresql [\#92](https://github.com/rails-on-services/apartment/issues/92)
- NameError: instance variable @sequence\_name not defined [\#81](https://github.com/rails-on-services/apartment/issues/81)

**Closed issues:**

- Error creating tenant with uuid column [\#85](https://github.com/rails-on-services/apartment/issues/85)
- enhanced db:create task breaks plugins compatibility [\#82](https://github.com/rails-on-services/apartment/issues/82)
- Support disabling of full\_migration\_on\_create [\#30](https://github.com/rails-on-services/apartment/issues/30)

**Merged pull requests:**

- \[Chore\] Fix Changelog github action [\#97](https://github.com/rails-on-services/apartment/pull/97) ([rpbaltazar](https://github.com/rpbaltazar))
- Prepare release - 2.7.2 [\#96](https://github.com/rails-on-services/apartment/pull/96) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#92\] tenant switch raises exception on first call [\#95](https://github.com/rails-on-services/apartment/pull/95) ([rpbaltazar](https://github.com/rpbaltazar))
- Dont use custom rubocop [\#94](https://github.com/rails-on-services/apartment/pull/94) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#80\] added changelog action [\#90](https://github.com/rails-on-services/apartment/pull/90) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#81\] check for var existence before [\#89](https://github.com/rails-on-services/apartment/pull/89) ([rpbaltazar](https://github.com/rpbaltazar))

## [v2.7.1](https://github.com/rails-on-services/apartment/tree/v2.7.1) (2020-06-27)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.7.0...v2.7.1)

**Merged pull requests:**

- Prepare Release 2.7.1 [\#84](https://github.com/rails-on-services/apartment/pull/84) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#82\] Enhanced db create task breaks plugins compatibility [\#83](https://github.com/rails-on-services/apartment/pull/83) ([rpbaltazar](https://github.com/rpbaltazar))
- \[ci\] update rake [\#79](https://github.com/rails-on-services/apartment/pull/79) ([ahorek](https://github.com/ahorek))

## [v2.7.0](https://github.com/rails-on-services/apartment/tree/v2.7.0) (2020-06-26)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.6.1...v2.7.0)

**Implemented enhancements:**

- Rake tasks define methods on main [\#70](https://github.com/rails-on-services/apartment/issues/70)

**Fixed bugs:**

- Undefined method devise with 2.6.1 [\#65](https://github.com/rails-on-services/apartment/issues/65)
- db:create is failed [\#61](https://github.com/rails-on-services/apartment/issues/61)

**Closed issues:**

- configure story branch [\#68](https://github.com/rails-on-services/apartment/issues/68)
- HISTORY.md has not been updated for latest releases [\#62](https://github.com/rails-on-services/apartment/issues/62)
- \[Postgresql users\] Help testing development branch in your environment [\#34](https://github.com/rails-on-services/apartment/issues/34)

**Merged pull requests:**

- Prepare Release - 2.7.0 [\#77](https://github.com/rails-on-services/apartment/pull/77) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Fixes \#61\] db create is failed [\#76](https://github.com/rails-on-services/apartment/pull/76) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#70\] rake tasks define methods on main [\#75](https://github.com/rails-on-services/apartment/pull/75) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Chore\] Update travis config to run rubocop [\#74](https://github.com/rails-on-services/apartment/pull/74) ([rpbaltazar](https://github.com/rpbaltazar))
- Remove and warn depracated config `tld\_length` [\#72](https://github.com/rails-on-services/apartment/pull/72) ([choznerol](https://github.com/choznerol))
- \[Resolves \#62\] added Missing notes in history.md [\#63](https://github.com/rails-on-services/apartment/pull/63) ([rpbaltazar](https://github.com/rpbaltazar))
- Add database and schema to active record log [\#55](https://github.com/rails-on-services/apartment/pull/55) ([woohoou](https://github.com/woohoou))

## [v2.6.1](https://github.com/rails-on-services/apartment/tree/v2.6.1) (2020-06-02)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.6.0...v2.6.1)

**Closed issues:**

- db:rollback uses second latest migration for tenants [\#56](https://github.com/rails-on-services/apartment/issues/56)
- rake db:setup tries to seed non existing tenant [\#52](https://github.com/rails-on-services/apartment/issues/52)
- Custom Console deprecation warning [\#37](https://github.com/rails-on-services/apartment/issues/37)

**Merged pull requests:**

- Version bump - 2.6.1 [\#60](https://github.com/rails-on-services/apartment/pull/60) ([rpbaltazar](https://github.com/rpbaltazar))
- Prepare Release - 2.6.1 [\#59](https://github.com/rails-on-services/apartment/pull/59) ([rpbaltazar](https://github.com/rpbaltazar))
- \[\#56\] Db rollback uses second latest migration [\#57](https://github.com/rails-on-services/apartment/pull/57) ([rpbaltazar](https://github.com/rpbaltazar))
- \[\#52\] enhance after db create [\#54](https://github.com/rails-on-services/apartment/pull/54) ([rpbaltazar](https://github.com/rpbaltazar))
- fix init after reload on development [\#53](https://github.com/rails-on-services/apartment/pull/53) ([fsateler](https://github.com/fsateler))
- fix: reset sequence\_name after tenant switch [\#51](https://github.com/rails-on-services/apartment/pull/51) ([fsateler](https://github.com/fsateler))
- Avoid early connection [\#39](https://github.com/rails-on-services/apartment/pull/39) ([fsateler](https://github.com/fsateler))

## [v2.6.0](https://github.com/rails-on-services/apartment/tree/v2.6.0) (2020-05-14)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.5.0...v2.6.0)

**Closed issues:**

- Error Dropping Tenant [\#46](https://github.com/rails-on-services/apartment/issues/46)
- After switch callback not working with nil argument [\#42](https://github.com/rails-on-services/apartment/issues/42)
- Add tenant info to console boot? [\#41](https://github.com/rails-on-services/apartment/issues/41)
- Support configuration for skip checking of schema existence before switching [\#26](https://github.com/rails-on-services/apartment/issues/26)

**Merged pull requests:**

- \[Resolves \#37\] Custom console deprecation warning [\#49](https://github.com/rails-on-services/apartment/pull/49) ([rpbaltazar](https://github.com/rpbaltazar))
- Prepare Release 2.6.0 [\#48](https://github.com/rails-on-services/apartment/pull/48) ([rpbaltazar](https://github.com/rpbaltazar))
- Add console welcome message [\#47](https://github.com/rails-on-services/apartment/pull/47) ([JeremiahChurch](https://github.com/JeremiahChurch))
- \[Resolves \#26\] Support configuration for skip checking of schema existence before switching [\#45](https://github.com/rails-on-services/apartment/pull/45) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#42\] After switch callback not working with nil argument [\#43](https://github.com/rails-on-services/apartment/pull/43) ([rpbaltazar](https://github.com/rpbaltazar))

## [v2.5.0](https://github.com/rails-on-services/apartment/tree/v2.5.0) (2020-05-05)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/2.4.0...v2.5.0)

**Implemented enhancements:**

- Add latest ruby verisons to test matrix [\#31](https://github.com/rails-on-services/apartment/issues/31)
- Deprecate EOL ruby and rails versions [\#11](https://github.com/rails-on-services/apartment/issues/11)

**Fixed bugs:**

- When manually switching the connection it resets the search path [\#27](https://github.com/rails-on-services/apartment/issues/27)

**Closed issues:**

- Cached statement breaks in find [\#35](https://github.com/rails-on-services/apartment/issues/35)
- rails 6.1.alpha support [\#6](https://github.com/rails-on-services/apartment/issues/6)
- How to exclude all models from engine? [\#4](https://github.com/rails-on-services/apartment/issues/4)

**Merged pull requests:**

- Prepare Release 2.5.0 [\#44](https://github.com/rails-on-services/apartment/pull/44) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#27\] Added before hook to connected to to try to set the tenant [\#40](https://github.com/rails-on-services/apartment/pull/40) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#35\] update cache key to use a string or an array [\#36](https://github.com/rails-on-services/apartment/pull/36) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Hotfix \#27\] Some errors were being thrown due to caching issues [\#33](https://github.com/rails-on-services/apartment/pull/33) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#31\] Add latest ruby verisons to test matrix [\#32](https://github.com/rails-on-services/apartment/pull/32) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Chore\] refactored files to their names [\#29](https://github.com/rails-on-services/apartment/pull/29) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#27\] When manually switching the connection it resets the search path [\#28](https://github.com/rails-on-services/apartment/pull/28) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#11\] Remove old ruby and rails versions from the supported versions [\#20](https://github.com/rails-on-services/apartment/pull/20) ([rpbaltazar](https://github.com/rpbaltazar))
- Support rails 6.1 [\#7](https://github.com/rails-on-services/apartment/pull/7) ([jean-francois-labbe](https://github.com/jean-francois-labbe))

## [2.4.0](https://github.com/rails-on-services/apartment/tree/2.4.0) (2020-04-01)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.3.0...2.4.0)

**Implemented enhancements:**

- Add console info about tenants and fast switches [\#14](https://github.com/rails-on-services/apartment/issues/14)
- Update travis config to only run PR's instead of running all commits [\#12](https://github.com/rails-on-services/apartment/issues/12)

**Closed issues:**

- Rubocop cleanup [\#9](https://github.com/rails-on-services/apartment/issues/9)
- Apartment.configure throws NoMethodError [\#3](https://github.com/rails-on-services/apartment/issues/3)
- upcoming Rails 6 multi-database [\#2](https://github.com/rails-on-services/apartment/issues/2)

**Merged pull requests:**

- Fix gemspec open versions and updated version [\#25](https://github.com/rails-on-services/apartment/pull/25) ([rpbaltazar](https://github.com/rpbaltazar))
- Fix gemspec open versions and updated version [\#24](https://github.com/rails-on-services/apartment/pull/24) ([rpbaltazar](https://github.com/rpbaltazar))
- Cleanup travis matrix [\#23](https://github.com/rails-on-services/apartment/pull/23) ([rpbaltazar](https://github.com/rpbaltazar))
- Prepare v2.4.0 Release [\#22](https://github.com/rails-on-services/apartment/pull/22) ([rpbaltazar](https://github.com/rpbaltazar))
- Updated readme badges [\#21](https://github.com/rails-on-services/apartment/pull/21) ([rpbaltazar](https://github.com/rpbaltazar))
- Rescuing ActiveRecord::NoDatabaseError when dropping tenants [\#19](https://github.com/rails-on-services/apartment/pull/19) ([rpbaltazar](https://github.com/rpbaltazar))
- Skip init if we're running webpacker:compile [\#18](https://github.com/rails-on-services/apartment/pull/18) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#14\] Add console info about tenants and fast switches [\#17](https://github.com/rails-on-services/apartment/pull/17) ([rpbaltazar](https://github.com/rpbaltazar))
- Don't crash when no database connection is present [\#16](https://github.com/rails-on-services/apartment/pull/16) ([ArthurWD](https://github.com/ArthurWD))
- \[Resolves \#12\] Update travis config to only run PRs instead of all commits [\#13](https://github.com/rails-on-services/apartment/pull/13) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Chore\] Fix rubocop usage [\#10](https://github.com/rails-on-services/apartment/pull/10) ([rpbaltazar](https://github.com/rpbaltazar))
- \[Resolves \#9\] Cleanup rubocop todo [\#8](https://github.com/rails-on-services/apartment/pull/8) ([rpbaltazar](https://github.com/rpbaltazar))
- Rakefile should use mysql port from configuration [\#5](https://github.com/rails-on-services/apartment/pull/5) ([jean-francois-labbe](https://github.com/jean-francois-labbe))

## [v2.3.0](https://github.com/rails-on-services/apartment/tree/v2.3.0) (2020-01-03)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.2.1...v2.3.0)

**Merged pull requests:**

- \[Resolves\] Basic support for Rails 6 [\#1](https://github.com/rails-on-services/apartment/pull/1) ([rpbaltazar](https://github.com/rpbaltazar))

## [v2.2.1](https://github.com/rails-on-services/apartment/tree/v2.2.1) (2019-06-19)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.2.0...v2.2.1)

## [v2.2.0](https://github.com/rails-on-services/apartment/tree/v2.2.0) (2018-04-13)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.1.0...v2.2.0)

## [v2.1.0](https://github.com/rails-on-services/apartment/tree/v2.1.0) (2017-12-15)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v2.0.0...v2.1.0)

## [v2.0.0](https://github.com/rails-on-services/apartment/tree/v2.0.0) (2017-07-26)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v1.2.0...v2.0.0)

## [v1.2.0](https://github.com/rails-on-services/apartment/tree/v1.2.0) (2016-07-28)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v1.1.0...v1.2.0)

## [v1.1.0](https://github.com/rails-on-services/apartment/tree/v1.1.0) (2016-05-26)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v1.0.2...v1.1.0)

## [v1.0.2](https://github.com/rails-on-services/apartment/tree/v1.0.2) (2015-07-02)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v1.0.1...v1.0.2)

## [v1.0.1](https://github.com/rails-on-services/apartment/tree/v1.0.1) (2015-04-28)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/rails-on-services/apartment/tree/v1.0.0) (2015-02-03)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.26.1...v1.0.0)

## [v0.26.1](https://github.com/rails-on-services/apartment/tree/v0.26.1) (2015-01-13)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.26.0...v0.26.1)

## [v0.26.0](https://github.com/rails-on-services/apartment/tree/v0.26.0) (2015-01-05)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.25.2...v0.26.0)

## [v0.25.2](https://github.com/rails-on-services/apartment/tree/v0.25.2) (2014-09-08)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.25.1...v0.25.2)

## [v0.25.1](https://github.com/rails-on-services/apartment/tree/v0.25.1) (2014-07-17)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.25.0...v0.25.1)

## [v0.25.0](https://github.com/rails-on-services/apartment/tree/v0.25.0) (2014-07-03)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.24.3...v0.25.0)

## [v0.24.3](https://github.com/rails-on-services/apartment/tree/v0.24.3) (2014-03-05)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.24.2...v0.24.3)

## [v0.24.2](https://github.com/rails-on-services/apartment/tree/v0.24.2) (2014-02-24)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.24.1...v0.24.2)

## [v0.24.1](https://github.com/rails-on-services/apartment/tree/v0.24.1) (2014-02-21)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.24.0...v0.24.1)

## [v0.24.0](https://github.com/rails-on-services/apartment/tree/v0.24.0) (2014-02-21)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.23.2...v0.24.0)

## [v0.23.2](https://github.com/rails-on-services/apartment/tree/v0.23.2) (2014-01-09)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.23.1...v0.23.2)

## [v0.23.1](https://github.com/rails-on-services/apartment/tree/v0.23.1) (2014-01-08)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.23.0...v0.23.1)

## [v0.23.0](https://github.com/rails-on-services/apartment/tree/v0.23.0) (2013-12-15)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.22.1...v0.23.0)

## [v0.22.1](https://github.com/rails-on-services/apartment/tree/v0.22.1) (2013-08-21)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.22.0...v0.22.1)

## [v0.22.0](https://github.com/rails-on-services/apartment/tree/v0.22.0) (2013-07-09)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.21.1...v0.22.0)

## [v0.21.1](https://github.com/rails-on-services/apartment/tree/v0.21.1) (2013-05-31)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.21.0...v0.21.1)

## [v0.21.0](https://github.com/rails-on-services/apartment/tree/v0.21.0) (2013-04-25)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.20.0...v0.21.0)

## [v0.20.0](https://github.com/rails-on-services/apartment/tree/v0.20.0) (2013-02-06)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/rm...v0.20.0)

## [rm](https://github.com/rails-on-services/apartment/tree/rm) (2013-01-30)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.19.2...rm)

## [v0.19.2](https://github.com/rails-on-services/apartment/tree/v0.19.2) (2013-01-30)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.19.0...v0.19.2)

## [v0.19.0](https://github.com/rails-on-services/apartment/tree/v0.19.0) (2012-12-30)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.18.0...v0.19.0)

## [v0.18.0](https://github.com/rails-on-services/apartment/tree/v0.18.0) (2012-11-28)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.17.3...v0.18.0)

## [v0.17.3](https://github.com/rails-on-services/apartment/tree/v0.17.3) (2012-11-20)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.17.2...v0.17.3)

## [v0.17.2](https://github.com/rails-on-services/apartment/tree/v0.17.2) (2012-11-15)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.17.1...v0.17.2)

## [v0.17.1](https://github.com/rails-on-services/apartment/tree/v0.17.1) (2012-10-30)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.17.0...v0.17.1)

## [v0.17.0](https://github.com/rails-on-services/apartment/tree/v0.17.0) (2012-09-26)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.16.0...v0.17.0)

## [v0.16.0](https://github.com/rails-on-services/apartment/tree/v0.16.0) (2012-06-01)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.15.0...v0.16.0)

## [v0.15.0](https://github.com/rails-on-services/apartment/tree/v0.15.0) (2012-03-18)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.14.4...v0.15.0)

## [v0.14.4](https://github.com/rails-on-services/apartment/tree/v0.14.4) (2012-03-08)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.14.3...v0.14.4)

## [v0.14.3](https://github.com/rails-on-services/apartment/tree/v0.14.3) (2012-02-21)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.14.2...v0.14.3)

## [v0.14.2](https://github.com/rails-on-services/apartment/tree/v0.14.2) (2012-02-21)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.13.0.1...v0.14.2)

## [v0.13.0.1](https://github.com/rails-on-services/apartment/tree/v0.13.0.1) (2012-02-09)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.14.1...v0.13.0.1)

## [v0.14.1](https://github.com/rails-on-services/apartment/tree/v0.14.1) (2011-12-13)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.14.0...v0.14.1)

## [v0.14.0](https://github.com/rails-on-services/apartment/tree/v0.14.0) (2011-12-13)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.13.1...v0.14.0)

## [v0.13.1](https://github.com/rails-on-services/apartment/tree/v0.13.1) (2011-11-08)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.13.0...v0.13.1)

## [v0.13.0](https://github.com/rails-on-services/apartment/tree/v0.13.0) (2011-10-25)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.12.0...v0.13.0)

## [v0.12.0](https://github.com/rails-on-services/apartment/tree/v0.12.0) (2011-10-04)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.11.1...v0.12.0)

## [v0.11.1](https://github.com/rails-on-services/apartment/tree/v0.11.1) (2011-09-22)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.11.0...v0.11.1)

## [v0.11.0](https://github.com/rails-on-services/apartment/tree/v0.11.0) (2011-09-20)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.10.3...v0.11.0)

## [v0.10.3](https://github.com/rails-on-services/apartment/tree/v0.10.3) (2011-09-20)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.10.2...v0.10.3)

## [v0.10.2](https://github.com/rails-on-services/apartment/tree/v0.10.2) (2011-09-15)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.10.1...v0.10.2)

## [v0.10.1](https://github.com/rails-on-services/apartment/tree/v0.10.1) (2011-08-11)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.10.0...v0.10.1)

## [v0.10.0](https://github.com/rails-on-services/apartment/tree/v0.10.0) (2011-07-29)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.9.2...v0.10.0)

## [v0.9.2](https://github.com/rails-on-services/apartment/tree/v0.9.2) (2011-07-04)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.9.1...v0.9.2)

## [v0.9.1](https://github.com/rails-on-services/apartment/tree/v0.9.1) (2011-06-24)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.9.0...v0.9.1)

## [v0.9.0](https://github.com/rails-on-services/apartment/tree/v0.9.0) (2011-06-23)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.8.0...v0.9.0)

## [v0.8.0](https://github.com/rails-on-services/apartment/tree/v0.8.0) (2011-06-23)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.7.0...v0.8.0)

## [v0.7.0](https://github.com/rails-on-services/apartment/tree/v0.7.0) (2011-06-22)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.6.0...v0.7.0)

## [v0.6.0](https://github.com/rails-on-services/apartment/tree/v0.6.0) (2011-06-21)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/0.6.0...v0.6.0)

## [0.6.0](https://github.com/rails-on-services/apartment/tree/0.6.0) (2011-06-21)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.5.1...0.6.0)

## [v0.5.1](https://github.com/rails-on-services/apartment/tree/v0.5.1) (2011-06-21)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/0.5.0...v0.5.1)

## [0.5.0](https://github.com/rails-on-services/apartment/tree/0.5.0) (2011-06-20)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.5.0...0.5.0)

## [v0.5.0](https://github.com/rails-on-services/apartment/tree/v0.5.0) (2011-06-20)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/v0.1.3...v0.5.0)

## [v0.1.3](https://github.com/rails-on-services/apartment/tree/v0.1.3) (2011-04-18)

[Full Changelog](https://github.com/rails-on-services/apartment/compare/7100f34a185ab7d48947f06aa8c14f0cf0a68bb7...v0.1.3)

# v2.7.1

**Implemented enhancements:**

-   N/a

**Fixed bugs:**

-   [Resolves #82] Enhanced db:create breaks plugin compatibility - <https://github.com/rails-on-services/apartment/pull/83>

**Closed issues:**

-   Update rake version in development
-   Renamed gemspec to match gem name

# v2.7.0

**Implemented enhancements:**

-   [Resolves #70] Rake tasks define methods on main - <https://github.com/rails-on-services/apartment/pull/75>
-   Add database and schema to active record log. Configurable, defaults to false to keep current behavior - <https://github.com/rails-on-services/apartment/pull/55>

**Fixed bugs:**

-   [Fixes #61] Fix database create in mysql - <https://github.com/rails-on-services/apartment/pull/76>

**Closed issues:**

-   Remove deprecated tld_length config option: tld_length was removed in influitive#309, this configuration option doesn't have any effect now. - <https://github.com/rails-on-services/apartment/pull/72>
-   Using [diffend.io proxy](https://diffend.io) to safely check required gems
-   Added [story branch](https://github.com/story-branch/story_branch) to the configuration
-   Using travis-ci to run rubocop as well, replacing github actions: github actions do not work in fork's PRs

# v2.6.1

**Implemented enhancements:**
- N/a

**Fixed bugs:**
- [Resolves influitive#607] Avoid early connection
  - <https://github.com/rails-on-services/apartment/pull/39>
  - <https://github.com/rails-on-services/apartment/pull/53>
  - <https://github.com/rails-on-services/apartment/pull/51>
- [Resolves #52] Rake db:setup tries to seed non existent tenant - <https://github.com/rails-on-services/apartment/pull/54>
- [Resolves #56] DB rollback uses second last migration - <https://github.com/rails-on-services/apartment/pull/57>

#**Closed issues:**
-   N/a

# v2.6.0

**Implemented enhancements:**
-   [Resolves #26] Support configuration for skip checking of schema existence before switching
-   [Resolves #41] Add tenant info to console boot

**Fixed bugs:**
-   [Resolves #37] Custom Console deprecation warning
-   [Resolves #42] After switch callback not working with nil argument

#**Closed issues:**
-   Updated github actions configuration to run on PRs as well

# v2.5.0

**Implemented enhancements:**
-   [Resolves #6] Adds support for rails 6.1
-   [Resolves #27] Adds support to not rely on set search path, but instead prepends the schema name to the table name when using postgresql with schemas.
-   [Resolves #35] Cache keys are now tenant dependent

**Fixed bugs:**
-   [Resolves #27] Manually switching connection between read and write forgets the schema

#**Closed issues:**
-   [Resolves #31] Add latest ruby versions to test matrix

# v2.4.0

**Implemented enhancements:**
-   [Resolves #14] Add console info about tenants and fast switches #17
-   Skip init if we're running webpacker:compile #18

**Fixed bugs:**
-   Don't crash when no database connection is present #16
-   Rescuing ActiveRecord::NoDatabaseError when dropping tenants #19

#**Closed issues:**
-   Rakefile should use mysql port from configuration #5
-   [Resolves #9] Cleanup rubocop todo #8
-   Cleanup travis matrix #23

# v2.3.0
  * January 3, 2020

**Implemented enhancements:**
  - Basic support for rails 6
  - Released different gem name, with same API as apartment

# v2.2.1
  * June 19, 2019

**Implemented enhancements:**
  - #566: IGNORE_EMPTY_TENANTS environment variable to ignore empty tenants
    warning. [Pysis868]

**Fixed bugs:**
  - #586: Ignore `CREATE SCHEMA public` statement in pg dump [artemave]
  - #549: Fix Postgres schema creation with dump SQL [ancorcruz]

# v2.2.0
  * April 14, 2018

**Implemented enhancements:**
  - #523: Add Rails 5.2 support [IngusSkaistkalns]
  - #504: Test against Ruby 2.5.0 [ahorek]
  - #528: Test against Rails 5.2 [meganemura]

**Removed:**
  - #504: Remove Rails 4.0/4.1 support [ahorek]
  - #545: Stop supporting for JRuby + Rails 5.0 [meganemura]

**Fixed bugs:**
  - #537: Fix PostgresqlSchemaFromSqlAdapter for newer PostgreSQL [shterrett]
    - #532: Issue is reported by [aldrinmartoq]
  - #519: Fix exception when main database doesn't exist [mayeco]

**Closed issues:**

  - #514: Fix typo [menorval]

# v2.1.0
  * December 15, 2017

  - Add `parallel_migration_threads` configuration option for running migrations
    in parallel [ryanbrunner]
  - Drop Ruby 2.0.0 support [meganemura]
  - ignore_private when parsing subdomains with PublicSuffix [michiomochi]
  - Ignore row_security statements in psql dumps for backward compatibility
    [meganemura]
  - "Host" elevator [shrmnk]
  - Enhance db:drop task to act on all tenants [kuzukuzu]

# v2.0.0
  * July 26, 2017

  - Raise FileNotFound rather than abort when loading files [meganemura]
  - Add 5.1 support with fixes for deprecations [meganemura]
  - Fix tests for 5.x and a host of dev-friendly improvements [meganemura]
  - Keep query cache config after switching databases [fernandomm]
  - Pass constants not strings to middleware stack (Rails 5) [tzabaman]
  - Remove deprecations from 1.0.0 [caironoleto]
  - Replace `tld_length` configuration option with PublicSuffix gem for the
    subdomain elevator [humancopy]
  - Pass full config to create_database to allow :encoding/:collation/etc
    [kakipo]
  - Don't retain a connection during initialization [mikecmpbll]
  - Fix database name escaping in drop_command [mikecmpbll]
  - Skip initialization for assets:clean and assets:precompile tasks
    [frank-west-iii]

# v1.2.0
  * July 28, 2016

  - Official Rails 5 support

# v1.1.0
  * May 26, 2016

  - Reset tenant after each request
  - [Support callbacks](https://github.com/influitive/apartment/commit/ff9c9d092a781026502f5997c0bbedcb5748bc83) on switch [cbeer]
  - Preliminary support for [separate database hosts](https://github.com/influitive/apartment/commit/abdffbf8cd9fba87243f16c86390da13e318ee1f) [apneadiving]

# v1.0.2
  * July 2, 2015

  - Fix pg_dump env vars - pull/208 [MitinPavel]
  - Allow custom seed data file - pull/234 [typeoneerror]

# v1.0.1
  * April 28, 2015

  - Fix `Apartment::Deprecation` which was rescuing all exceptions

# v1.0.0
  * Feb 3, 2015

  - [BREAKING CHANGE] `Apartment::Tenant.process` is deprecated in favour of `Apartment::Tenant.switch`
  - [BREAKING CHANGE] `Apartment::Tenant.switch` without a block is deprecated in favour of `Apartment::Tenant.switch!`
  - Raise proper `TenantNotFound`, `TenantExists` exceptions
  - Deprecate old `SchemaNotFound`, `DatabaseNotFound` exceptions

# v0.26.1
  * Jan 13, 2015

  - Fixed [schema quoting bug](https://github.com/influitive/apartment/issues/198#issuecomment-69782651) [jonsgreen]

# v0.26.0
  * Jan 5, 2015

  - Rails 4.2 support

# v0.25.2
  * Sept 8, 2014

  - Heroku fix on `assets:precompile` - pull/169 [rabbitt]

# v0.25.1
  * July 17, 2014

  - Fixed a few vestiges of Apartment::Database

# v0.25.0
  * July 3, 2014

  - [BREAKING CHANGE] - `Apartment::Database` is not deprecated in favour of
    `Apartment::Tenant`
  - ActiveRecord (and Rails) 4.1 now supported
  - A new sql based adapter that dumps the schema using sql

# v0.24.3
  * March 5, 2014

  - Rake enhancements weren't removed from the generator template

# v0.24.2
  * February 24, 2014

  - Better warnings if `apartment:migrate` is run

# v0.24.1
  * February 21, 2014

  - requiring `apartment/tasks/enhancements` in an initializer doesn't work
  - One can disable tenant migrations using `Apartment.db_migrate_tenants = false` in the Rakefile

# v0.24
  * February 21, 2014 (In honour of the Women's Gold Medal in Hockey at Sochi)

  - [BREAKING CHANGE] `apartment:migrate` task no longer depends on `db:migrate`
    - Instead, you can `require 'apartment/tasks/enhancements'` in your Apartment initializer
    - This will enhance `rake db:migrate` to also run `apartment:migrate`
    - You can now forget about ever running `apartment:migrate` again
  - Numerous deprecations for things referencing the word 'database'
    - This is an ongoing effort to completely replace 'database' with 'tenant' as a better abstraction
    - Note the obvious `Apartment::Database` still exists but will hopefully become `Apartment::Tenant` soon

# v0.23.2
  * January 9, 2014

  - Increased visibility of #parse_database_name warning

# v0.23.1
  * January 8, 2014

  - Schema adapters now initialize with default and persistent schemas
  - Deprecated Apartment::Elevators#parse_database_name

# v0.23.0
  * August 21, 2013

  - Subdomain Elevator now allows for exclusions
  - Delayed::Job has been completely removed

# v0.22.1
  * August 21, 2013

  - Fix bug where if your ruby process importing the database schema is run
    from a directory other than the app root, Apartment wouldn't know what
    schema_migrations to insert into the database (Rails only)

# v0.22.0
  * June 9, 2013

  - Numerous bug fixes:
    - Mysql reset could connect to wrong database [eric88]
    - Postgresql schema names weren't quoted properly [gdott9]
    - Fixed error message on SchemaNotFound in `process`
  - HostHash elevator allows mapping host based on hash contents [gdott9]
  - Official Sidekiq support with the [apartment-sidekiq gem](https://github.com/influitive/apartment-sidekiq)


# v0.21.1
  * May 31, 2013

  - Clearing the AR::QueryCache after switching databases.
    - Fixes issue with stale model being loaded for schema adapters

# v0.21.0
  * April 24, 2013

  - JDBC support!! [PetrolMan]

# v0.20.0
  * Feb 6, 2013

  - Mysql now has a 'schema like' option to perform like Postgresql (default)
    - This should be significantly more performant than using connections
  - Psych is now supported for Delayed::Job yaml parsing

# v0.19.2
  * Jan 30, 2013

  - Database schema file can now be set manually or skipped altogether

# v0.19.1
  * Jan 30, 2013

  - Allow schema.rb import file to be specified in config or skip schema.rb import altogether

# v0.19.0
  * Dec 29, 2012

  - Apartment is now threadsafe
  - New postgis adapter [zonpantli]
  - Removed ActionDispatch dependency for use with Rack apps (regression)

# v0.18.0
  * Nov 27, 2012

  - Added `append_environment` config option [virtualstaticvoid]
  - Cleaned up the readme and generator documentation
  - Added `connection_class` config option [smashtank]
  - Fixed a [bug](https://github.com/influitive/apartment/issues/17#issuecomment-10758327) in pg adapter when missing schema

# v0.17.1
  * Oct 30, 2012

  - Fixed a bug where switching to an unknown db in mysql2 would crash the app [Frodotus]

# v0.17.0
  * Sept 26, 2012

  - Apartment has [a new home!](https://github.com/influitive/apartment)
  - Support Sidekiq hooks to switch dbs [maedhr]
  - Allow VERSION to be used on apartment:migrate [Bhavin Kamani]

# v0.16.0
  * June 1, 2012

  - Apartment now supports a default_schema to be set, rather than relying on ActiveRecord's default schema_search_path
  - Additional schemas can always be maintained in the schema_search_path by configuring persistent_schemas [ryanbrunner]
    - This means Hstore is officially supported!!
  - There is now a full domain based elevator to switch dbs based on the whole domain [lcowell]
  - There is now a generic elevator that takes a Proc to switch dbs based on the return value of that proc.

# v0.15.0
  * March 18, 2012

  - Remove Rails dependency, Apartment can now be used with any Rack based framework using ActiveRecord

# v0.14.4
  * March 8, 2012

  - Delayed::Job Hooks now return to the previous database, rather than resetting

# v0.14.3
  * Feb 21, 2012

  - Fix yaml serialization of non DJ models

# v0.14.2
  * Feb 21, 2012

  - Fix Delayed::Job yaml encoding with Rails > 3.0.x

# v0.14.1
  * Dec 13, 2011

  - Fix ActionDispatch::Callbacks deprecation warnings

# v0.14.0
  * Dec 13, 2011

  - Rails 3.1 Support

# v0.13.1
  * Nov 8, 2011

  - Reset prepared statement cache for rails 3.1.1 before switching dbs when using postgresql schemas
    - Only necessary until the next release which will be more schema aware

# v0.13.0
  * Oct 25, 2011

  - `process` will now rescue with reset if the previous schema/db is no longer available
  - `create` now takes an optional block which allows you to process within the newly created db
  - Fixed Rails version >= 3.0.10 and < 3.1 because there have been significant testing problems with 3.1, next version will hopefully fix this

# v0.12.0
  * Oct 4, 2011

  - Added a `drop` method for removing databases/schemas
  - Refactored abstract adapter to further remove duplication in concrete implementations
  - Excluded models now take string references so they are properly reloaded in development
  - Better silencing of `schema.rb` loading using `verbose` flag

# v0.11.1
  * Sep 22, 2011

  - Better use of Railties for initializing apartment
  - The following changes were necessary as I haven't figured out how to properly hook into Rails reloading
    - Added reloader middleware in development to init Apartment on each request
    - Override `reload!` in console to also init Apartment

# v0.11.0
  * Sep 20, 2011

  - Excluded models no longer use a different connection when using postgresql schemas.  Instead their table_name is prefixed with `public.`

# v0.10.3
  * Sep 20, 2011

  - Fix improper raising of exceptions on create and reset

# v0.10.2
  * Sep 15, 2011

  - Remove all the annoying logging for loading db schema and seeding on create

# v0.10.1
  * Aug 11, 2011

  - Fixed bug in DJ where new objects (that hadn't been pulled from the db) didn't have the proper database assigned

# v0.10.0
  * July 29, 2011

  - Added better support for Delayed Job
  - New config option that enables Delayed Job wrappers
  - Note that DJ support uses a work-around in order to get queues stored in the public schema, not sure why it doesn't work out of the box, will look into it, until then, see documentation on queue'ng jobs

# v0.9.2
  * July 4, 2011

  - Migrations now run associated rails migration fully, fixes schema.rb not being reloaded after migrations

# v0.9.1
  * June 24, 2011

  - Hooks now take the payload object as an argument to fetch the proper db for DJ hooks

# v0.9.0
  * June 23, 2011

  - Added module to provide delayed job hooks

# v0.8.0
  * June 23, 2011

  - Added #current_database which will return the current database (or schema) name

# v0.7.0
  * June 22, 2011

  - Added apartment:seed rake task for seeding all dbs

# v0.6.0
  * June 21, 2011

  - Added #process to connect to new db, perform operations, then ensure a reset

# v0.5.1
  * June 21, 2011

  - Fixed db migrate up/down/rollback
  - added db:redo

# v0.5.0
  * June 20, 2011

  - Added the concept of an "Elevator", a rack based strategy for db switching
  - Added the Subdomain Elevator middleware to enabled db switching based on subdomain

# v0.4.0
  * June 14, 2011

  - Added `configure` method on Apartment instead of using yml file, allows for dynamic setting of db names to migrate for rake task
  - Added `seed_after_create` config option to import seed data to new db on create

# v0.3.0
  * June 10, 2011

  - Added full support for database migration
  - Added in method to establish new connection for excluded models on startup rather than on each switch

# v0.2.0
  * June 6, 2011 *

  - Refactor to use more rails/active_support functionality
  - Refactor config to lazily load apartment.yml if exists
  - Remove OStruct and just use hashes for fetching methods
  - Added schema load on create instead of migrating from scratch

# v0.1.3
  * March 30, 2011 *

  - Original pass from Ryan


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
