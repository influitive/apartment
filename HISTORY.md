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
