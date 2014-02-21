# Apartment
[![Code Climate](https://codeclimate.com/github/influitive/apartment.png)](https://codeclimate.com/github/influitive/apartment)
[![Build Status](https://secure.travis-ci.org/influitive/apartment.png?branch=development)](http://travis-ci.org/influitive/apartment)

*Multitenancy for Rails and ActiveRecord*

Apartment provides tools to help you deal with multiple tenants in your Rails
application. If you need to have certain data sequestered based on account or company,
but still allow some data to exist in a common tenant, Apartment can help.


## Installation

### Rails

Add the following to your Gemfile:

```ruby
gem 'apartment'
```

Then generate your `Apartment` config file using

```ruby
bundle exec rails generate apartment:install
```

This will create a `config/initializers/apartment.rb` initializer file.
Configure as needed using the docs below.

That's all you need to set up the Apartment libraries. If you want to switch tenants
on a per-user basis, look under "Usage - Switching tenants per request", below.

> NOTE: If using [postgresl schemas](http://www.postgresql.org/docs/9.0/static/ddl-schemas.html) you must use:
>
> * for Rails 3.1.x: _Rails ~> 3.1.2_, it contains a [patch](https://github.com/rails/rails/pull/3232) that makes prepared statements work with multiple schemas

## Usage

### Creating new Tenants

Before you can switch to a new apartment tenant, you will need to create it. Whenever
you need to create a new tenant, you can run the following command:

```ruby
Apartment::Database.create('tenant_name')
```

If you're using the [prepend environment](https://github.com/influitive/apartment#handling-environments) config option or you AREN'T using Postgresql Schemas, this will create a tenant in the following format: "#{environment}\_tenant_name".
In the case of a sqlite database, this will be created in your 'db/' folder. With
other databases, the tenant will be created as a new DB within the system.

When you create a new tenant, all migrations will be run against that tenant, so it will be
up to date when create returns.

#### Notes on PostgreSQL

PostgreSQL works slightly differently than other databases when creating a new tenant. If you
are using PostgreSQL, Apartment by default will set up a new [schema](http://www.postgresql.org/docs/9.3/static/ddl-schemas.html)
and migrate into there. This provides better performance, and allows Apartment to work on systems like Heroku, which
would not allow a full new database to be created.

One can optionally use the full database creation instead if they want, though this is not recommended

### Switching Tenants

To switch tenants using Apartment, use the following command:

```ruby
Apartment::Database.switch('tenant_name')
```

When switch is called, all requests coming to ActiveRecord will be routed to the tenant
you specify (with the exception of excluded models, see below). To return to the 'root'
tenant, call switch with no arguments.

### Switching Tenants per request

You can have Apartment route to the appropriate tenant by adding some Rack middleware.
Apartment can support many different "Elevators" that can take care of this routing to your data.

The initializer above will generate the appropriate code for the Subdomain elevator
by default. You can see this in `config/initializers/apartment.rb` after running
that generator. If you're *not* using the generator, you can specify your
elevator below. Note that in this case you will **need** to require the elevator
manually in your `application.rb` like so

```ruby
# config/application.rb
require 'apartment/elevators/subdomain' # or 'domain' or 'generic'
```

**Switch on subdomain**
In house, we use the subdomain elevator, which analyzes the subdomain of the request and switches to a tenant schema of the same name. It can be used like so:

```ruby
# application.rb
module MyApplication
  class Application < Rails::Application
    config.middleware.use 'Apartment::Elevators::Subdomain'
  end
end
```

If you want to exclude a domain, for example if you don't want your application to treate www like a subdomain, in an initializer in your application, you can set the following:

```ruby
# config/initializers/apartment/subdomain_exclusions.rb
Apartment::Elevators::Subdomain.excluded_subdomains = ['www']
```

This functions much in the same way as Apartment.excluded_models. This example will prevent switching your tenant when the subdomain is www. Handy for subdomains like: "public", "www", and "admin" :)

**Switch on domain**
To switch based on full domain (excluding subdomains *ie 'www'* and top level domains *ie '.com'* ) use the following:

```ruby
# application.rb
module MyApplication
  class Application < Rails::Application
    config.middleware.use 'Apartment::Elevators::Domain'
  end
end
```

**Switch on full host using a hash**
To switch based on full host with a hash to find corresponding tenant name use the following:

```ruby
# application.rb
module MyApplication
  class Application < Rails::Application
    config.middleware.use 'Apartment::Elevators::HostHash', {'example.com' => 'example_tenant'}
  end
end
```

**Custom Elevator**
A Generic Elevator exists that allows you to pass a `Proc` (or anything that responds to `call`) to the middleware. This Object will be passed in an `ActionDispatch::Request` object when called for you to do your magic. Apartment will use the return value of this proc to switch to the appropriate tenant.  Use like so:

```ruby
# application.rb
module MyApplication
  class Application < Rails::Application
    # Obviously not a contrived example
    config.middleware.use 'Apartment::Elevators::Generic', Proc.new { |request| request.host.reverse }
  end
end
```

## Config

The following config options should be set up in a Rails initializer such as:

    config/initializers/apartment.rb

To set config options, add this to your initializer:

```ruby
Apartment.configure do |config|
  # set your options (described below) here
end
```

### Excluding models

If you have some models that should always access the 'public' tenant, you can specify this by configuring Apartment using `Apartment.configure`.  This will yield a config object for you.  You can set excluded models like so:

```ruby
config.excluded_models = ["User", "Company"]        # these models will not be multi-tenanted, but remain in the global (public) namespace
```

Note that a string representation of the model name is now the standard so that models are properly constantized when reloaded in development

Rails will always access the 'public' tenant when accessing these models,  but note that tables will be created in all schemas.  This may not be ideal, but its done this way because otherwise rails wouldn't be able to properly generate the schema.rb file.

> **NOTE - Many-To-Many Excluded Models:**
> Since model exclusions must come from referencing a real ActiveRecord model, `has_and_belongs_to_many` is NOT supported. In order to achieve a many-to-many relationship for excluded models, you MUST use `has_many :through`. This way you can reference the join model in the excluded models configuration.

### Postgresql Schemas

**Providing a Different default_schema**
By default, ActiveRecord will use `"$user", public` as the default `schema_search_path`. This can be modified if you wish to use a different default schema be setting:

```ruby
config.default_schema = "some_other_schema"
```

With that set, all excluded models will use this schema as the table name prefix instead of `public` and `reset` on `Apartment::Database` will return to this schema also

**Persistent Schemas**
Apartment will normally just switch the `schema_search_path` whole hog to the one passed in.  This can lead to problems if you want other schemas to always be searched as well.  Enter `persistent_schemas`.  You can configure a list of other schemas that will always remain in the search path, while the default gets swapped out:

```ruby
config.persistent_schemas = ['some', 'other', 'schemas']
```

This has numerous useful applications.  [Hstore](http://www.postgresql.org/docs/9.1/static/hstore.html), for instance, is a popular storage engine for Postgresql.  In order to use Hstore, you have to install it to a specific schema and have that always in the `schema_search_path`.  This could be achieved like so:

```ruby
# NOTE do not do this in a migration, must be done
# manually before you configure apartment with hstore
# In a rake task, or on the console...
ActiveRecord::Base.connection.execute("CREATE SCHEMA hstore; CREATE EXTENSION HSTORE SCHEMA hstore")

# configure Apartment to maintain the `hstore` schema in the `schema_search_path`
config.persistent_schemas = ['hstore']
```

There are a few caveats to be aware of when using `hstore`.  First off, the hstore schema and extension creation need to be done manually *before* you reference it in any way in your migrations, database.yml or apartment.  This is an unfortunate manual step, but I haven't found a way around it.  You can achieve this from the command line using something like:

    rails r 'ActiveRecord::Base.connection.execute("CREATE SCHEMA hstore; CREATE EXTENSION HSTORE SCHEMA hstore")'

Next, your `database.yml` file must mimic what you've set for your default and persistent schemas in Apartment.  When you run migrataions with Rails, it won't know about the hstore schema because Apartment isn't injected into the default connection, it's done on a per-request basis, therefore Rails doesn't know about `hstore` during migrations.  To do so, add the following to your `database.yml` for all environments

```yaml
# database.yml
...
adapter: postgresql
schema_search_path: "public,hstore"
...
```

This would be for a config with `default_schema` set to `public` and `persistent_schemas` set to `['hstore']`

Another way that we've successfully configured hstore for our applications is to add it into the
postgresql template1 database so that every tenant that gets created has it by default.

You can do so using a command like so

```bash
psql -U postgres -d template1 -c "CREATE SCHEMA hstore AUTHORIZATION some_username;"
psql -U postgres -d template1 -c "CREATE EXTENSION IF NOT EXISTS hstore SCHEMA hstore;"
```

The *ideal* setup would actually be to install `hstore` into the `public` schema and leave the public
schema in the `search_path` at all times. We won't be able to do this though until public doesn't
also contain the tenanted tables, which is an open issue with no real milestone to be completed.
Happy to accept PR's on the matter.

### Managing Migrations

In order to migrate all of your tenants (or posgresql schemas) you need to provide a list
of dbs to Apartment.  You can make this dynamic by providing a Proc object to be called on migrations.
This object should yield an array of string representing each tenant name.  Example:

```ruby
# Dynamically get tenant names to migrate
config.tenant_names = lambda{ Customer.pluck(:tenant_name) }

# Use a static list of tenant names for migrate
config.tenant_names = ['tenant1', 'tenant2']
```

You can then migrate your tenants using the normal rake task:

```ruby
rake db:migrate
```

This just invokes `Apartment::Database.migrate(#{tenant_name})` for each tenant name supplied
from `Apartment.tenant_names`

Note that you can disable the default migrating of all tenants with `db:migrate` by setting
`Apartment.db_migrate_tenants = false` in your `Rakefile`. Note this must be done
*before* the rake tasks are loaded. ie. before `YourApp::Application.load_tasks` is called

### Handling Environments

By default, when not using postgresql schemas, Apartment will prepend the environment to the tenant name
to ensure there is no conflict between your environments.  This is mainly for the benefit of your development
and test environments.  If you wish to turn this option off in production, you could do something like:

```ruby
config.prepend_environment = !Rails.env.production?
```

## Delayed::Job
### Has been removed... See apartment-sidekiq for a better backgrounding experience

## Contributing

* In both `spec/dummy/config` and `spec/config`, you will see `database.yml.sample` files
  * Copy them into the same directory but with the name `database.yml`
  * Edit them to fit your own settings
* Rake tasks (see the Rakefile) will help you setup your dbs necessary to run tests
* Please issue pull requests to the `development` branch.  All development happens here, master is used for releases
* Ensure that your code is accompanied with tests.  No code will be merged without tests

* If you're looking to help, check out the TODO file for some upcoming changes I'd like to implement in Apartment.

## License

Apartment is released under the [MIT License](http://www.opensource.org/licenses/MIT).
