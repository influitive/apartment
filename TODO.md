# Apartment TODOs

### Below is a list of tasks in the approximate order to be completed of for Apartment
### Any help along the way is greatly appreciated (on any items, not particularly in order)

1.  Apartment was originally written (and TDD'd) with just Postgresql in mind. Different adapters were added at a later date.
    As such, the test suite is a bit of a mess. There's no formal structure for fully integration testing all adapters to ensure
    proper quality and prevent regressions.

    There's also a test order dependency as some tests run assuming a db connection and if that test randomly ran before a previous
    one that makes the connection, it would fail.

    I'm proposing the first thing to be done is to write up a standard, high livel integration test case that can be applied to all adapters
    and makes no assumptions about implementation. It should ensure that each adapter conforms to the Apartment Interface and CRUD's properly.
    It would be nice if a user can 'register' an adapter such that it would automatically be tested (nice to have). Otherwise one could just use
    a shared behaviour to run through all of this.

    Then, I'd like to see all of the implementation specific tests just in their own test file for each adapter (ie the postgresql schema adapter checks a lot of things with `schema_search_path`)

    This should ensure that going forward nothing breaks, and we should *ideally* be able to randomize the test order

2.  <del>`Apartment::Database` is the wrong abstraction. When dealing with a multi-tenanted system, users shouldn't thing about 'Databases', they should
    think about Tenants. I proprose that we deprecate the `Apartment::Database` constant in favour of `Apartment::Tenant` for a nicer abstraction. See
    http://myronmars.to/n/dev-blog/2011/09/deprecating-constants-and-classes-in-ruby for ideas on how to achieve this.</del>

4.  Apartment::Database.process should be deprecated in favour of just passing a block to `switch`
5.  Apartment::Database.switch should be renamed to switch! to indicate that using it on its own has side effects

6.  Migrations right now can be a bit of a pain. Apartment currently migrates a single tenant completely up to date, then goes onto the next. If one of these
    migrations fails on a tenant, the previous one does NOT get reverted and leaves you in an awkward state. Ideally we'd want to wrap all of the migrations in
    a transaction so if one fails, the whole thing reverts. Once we can ensure an all-or-nothing approach to migrations, we can optimize the migration strategy
    to not even iterate over the tenants if there are no migrations to run on public.

7.  Apartment has be come one of the most popular/robust Multi-tenant gems for Rails, but it still doesn't work for everyone's use case. It's fairly limited in implementation to either schema based (ie postgresql schemas) or connection based. I'd like to abstract out these implementation details such that one could write a pluggable strategy for Apartment and choose it based on a config selection (something like `config.strategy = :schema`). The next implementation I'd like to see is a scoped based approach that uses a `tenant_id` scoping on all records for multi-tenancy. This is probably the most popular multi-tenant approach and is db independent and really the simplest mechanism for a type of multi-tenancy.

8.  Right now excluded tables still live in all tenanted environments. This is basically because it doesn't matter if they're there, we always query from the public.
    It's a bit of an annoyance though and confuses lots of people. I'd love to see only tenanted tables in the tenants and only excluded tables in the public tenant.
    This will be hard because Rails uses public to generate schema.rb. One idea is to have an `excluded` schema that holds all the excluded models and the public can
    maintain everything.

9.  This one is pretty lofty, but I'd also like to abstract out the fact that Apartment uses ActiveRecord. With the new DataMapper coming out soon and other popular
    DBMS's (ie. mongo, couch etc...), it'd be nice if Apartment could be the de-facto interface for multi-tenancy on these systems.


===================

Quick TODOs

1. `default_tenant` should be up to the adapter, not the Apartment class, deprecate `default_schema`
2. deprecation.rb rescues everything, we have a hard dependency on ActiveSupport so this is unnecessary
3.
