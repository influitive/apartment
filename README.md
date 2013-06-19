# Apartment
[![Code Climate](https://codeclimate.com/github/influitive/apartment.png)](https://codeclimate.com/github/influitive/apartment)
[![Build Status](https://secure.travis-ci.org/influitive/apartment.png?branch=development)](http://travis-ci.org/influitive/apartment)

*Multitenancy for Rails 3 and ActiveRecord*

Apartment provides tools to help you deal with multiple databases in your Rails
application. If you need to have certain data sequestered based on account or company,
but still allow some data to exist in a common database, Apartment can help.


## Installation

### Rails 3

Add the following to your Gemfile:

```ruby
gem 'apartment'
```

That's all you need to set up the Apartment libraries. If you want to switch databases
on a per-user basis, look under "Usage - Switching databases per request", below.

> NOTE: If using [postgresl schemas](http://www.postgresql.org/docs/9.0/static/ddl-schemas.html) you must use:
>
> * for Rails 3.1.x: _Rails ~> 3.1.2_, it contains a [patch](https://github.com/rails/rails/pull/3232) that makes prepared statements work with multiple schemas

## Usage

### Creating new Databases

Before you can switch to a new apartment database, you will need to create it. Whenever
you need to create a new database, you can run the following command:

```ruby
Apartment::Database.create('database_name')
```

If you're using the [prepend environment](https://github.com/influitive/apartment#handling-environments) config option or you AREN'T using Postgresql Schemas, this will create a database in the following format: "#{environment}\_database_name".
In the case of a sqlite database, this will be created in your 'db/' folder. With
other databases, the database will be created as a new DB within the system.

When you create a new database, all migrations will be run against that database, so it will be
up to date when create returns.

#### Notes on PostgreSQL

PostgreSQL works slightly differently than other databases when creating a new DB. If you
are using PostgreSQL, Apartment by default will set up a new **schema** and migrate into there. This
provides better performance, and allows Apartment to work on systems like Heroku, which
would not allow a full new database to be created.

One can optionally use the full database creation instead if they want, though this is not recommended

### Switching Databases

To switch databases using Apartment, use the following command:

```ruby
Apartment::Database.switch('database_name')
```

When switch is called, all requests coming to ActiveRecord will be routed to the database
you specify (with the exception of excluded models, see below). To return to the 'root'
database, call switch with no arguments.

### Switching Databases per request

You can have Apartment route to the appropriate database by adding some Rack middleware.
Apartment can support many different "Elevators" that can take care of this routing to your data.

**Switch on subdomain**
In house, we use the subdomain elevator, which analyzes the subdomain of the request and switches to a database schema of the same name. It can be used like so:

```ruby
# application.rb
module My Application
  class Application < Rails::Application
    config.middleware.use 'Apartment::Elevators::Subdomain'
  end
end
```

**Switch on domain**
To switch based on full domain (excluding subdomains *ie 'www'* and top level domains *ie '.com'* ) use the following:

```ruby
# application.rb
module My Application
  class Application < Rails::Application
    config.middleware.use 'Apartment::Elevators::Domain'
  end
end
```

**Switch on full host using a hash**
To switch based on full host with a hash to find corresponding database name use the following:

```ruby
# application.rb
module My Application
  class Application < Rails::Application
    config.middleware.use 'Apartment::Elevators::HostHash', {'example.com' => 'example_database'}
  end
end
```

**Custom Elevator**
A Generic Elevator exists that allows you to pass a `Proc` (or anything that responds to `call`) to the middleware. This Object will be passed in an `ActionDispatch::Request` object when called for you to do your magic. Apartment will use the return value of this proc to switch to the appropriate database.  Use like so:

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

If you have some models that should always access the 'root' database, you can specify this by configuring Apartment using `Apartment.configure`.  This will yield a config object for you.  You can set excluded models like so:

```ruby
config.excluded_models = ["User", "Company"]        # these models will not be multi-tenanted, but remain in the global (public) namespace
```

Note that a string representation of the model name is now the standard so that models are properly constantized when reloaded in development

Rails will always access the 'root' database when accessing these models,  but note that tables will be created in all schemas.  This may not be ideal, but its done this way because otherwise rails wouldn't be able to properly generate the schema.rb file.

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


### Managing Migrations

In order to migrate all of your databases (or posgresql schemas) you need to provide a list
of dbs to Apartment.  You can make this dynamic by providing a Proc object to be called on migrations.
This object should yield an array of string representing each database name.  Example:

```ruby
# Dynamically get database names to migrate
config.database_names = lambda{ Customer.pluck(:database_name) }

# Use a static list of database names for migrate
config.database_names = ['db1', 'db2']
```

You can then migrate your databases using the rake task:

    rake apartment:migrate

This basically invokes `Apartment::Database.migrate(#{db_name})` for each database name supplied
from `Apartment.database_names`

### Handling Environments

By default, when not using postgresql schemas, Apartment will prepend the environment to the database name
to ensure there is no conflict between your environments.  This is mainly for the benefit of your development
and test environments.  If you wish to turn this option off in production, you could do something like:

```ruby
config.prepend_environment = !Rails.env.production?
```

## Delayed::Job

### Read me before using Delayed::Job!!!
>   It should be noted that we now consider Delayed::Job usage with Apartment effectively deprecated
>   It will be stripped out into it's own gem for backwards compatibility, but we've had far too
>   many problems with it to continue supporting it.
>
>   The main problem is that Delayed::Job [monkey](https://github.com/collectiveidea/delayed_job/blob/master/lib/delayed/psych_ext.rb) [patches](https://github.com/collectiveidea/delayed_job/blob/master/lib/delayed/syck_ext.rb) YAML quite a bit, which
>   forces us to in tern [monkey](https://github.com/influitive/apartment/blob/development/lib/apartment/delayed_job/psych_ext.rb) [patch](https://github.com/influitive/apartment/blob/development/lib/apartment/delayed_job/syck_ext.rb) their monkey patches, which provides
>   no end of frustrations whenever upgrades are made.
>
>   To this end, we recommend you look into other solutions such as Resque or Sidekiq and write
>   your own hooks to switch db per job. Our aim is to have separate gems for each of these
>   worker libs and would love it if anyone would like to contribute something to achieve this
>
>   If you are hell bent on using `Delayed::Job`, this is what has worked for us in Production
>
>  ```ruby
>  gem 'delayed_job', '= 3.0.1' # change at own risk!
>  gem 'delayed_job_active_record', '= 0.3.2' # change at own risk!
>  ```
>

If using Rails ~> 3.2, you *must* use `delayed_job ~> 3.0`.  It has better Rails 3 support plus has some major changes that affect the serialization of models.

### If using Ruby 1.9.3-p362 you MUST use psych as your parser. YAML seems to fall down using syck

### If you're using syck on an earlier version of ruby, here's what you must do (in a rails app for instance)
This can be done in the `boot.rb` of your rails config *just above* where Bundler requires the gems from the Gemfile.  It will look something like:

```ruby
require 'rubygems'
require 'yaml'
YAML::ENGINE.yamler = 'syck'

# Set up gems listed in the Gemfile.
gemfile = File.expand_path('../../Gemfile', __FILE__)
# ...
```

In order to make ActiveRecord models play nice with DJ and Apartment, include `Apartment::Delayed::Requirements` in any model that is being serialized by DJ.  Also ensure that the `database` attribute (provided by Apartment::Delayed::Requirements) is set on this model *before* it is serialized, to ensure that when it is fetched again, it is done so in the proper Apartment db context.  For example:

```ruby
class SomeModel < ActiveRecord::Base
  include Apartment::Delayed::Requirements
end
```

Any classes that are being used as a Delayed::Job Job need to include the `Apartment::Delayed::Job::Hooks` module into the class.  This ensures that when a job runs, it switches to the appropriate tenant before performing its task.  It is also required (manually at the moment) that you set a `@database` attribute on your job so the hooks know what tennant to switch to

```ruby
class SomeDJ
  include Apartment::Delayed::Job::Hooks

  def initialize
    @database = Apartment::Database.current_database
  end

  def perform
    # do some stuff (will automatically switch to @database before performing and switch back after)
  end
end
```

All jobs *must* stored in the global (public) namespace, so add it to the list of excluded models:

```ruby
config.excluded_models = ["Delayed::Job"]
```

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
