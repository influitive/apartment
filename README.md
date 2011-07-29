# Apartment
*Multitenancy for Rails 3*

Apartment provides tools to help you deal with multiple databases in your Rails
environment. If you need to have certain data sequestered based on account or company,
but still allow some data to exist in a common database, Apartment can help.

## Caveats

Apartment was built to deal with a very particular use-case - the need to spin up 
multiple databases within the same application instance on-demand while Rails is running.
If your setup can accomodate creating new databases on deploy (by adding a new database to your
database.yml), or doesn't need 100% database isolation, other solutions might be far simpler 
for your use case.

## Installation

### Rails 3

Add the following to your Gemfile:

      gem 'apartment'

That's all you need to set up the Apartment libraries. If you want to switch databases 
on a per-user basis, look under "Usage - Switching databases per request", below.

## Usage

### Creating new Databases

Before you can switch to a new apartment database, you will need to create it. Whenever
you need to create a new database, you can run the following command:

     Apartment::Database.create('database_name')

Apartment will create a new database in the following format: "environment_database_name". 
In the case of a sqlite database, this will be created in your 'db/migrate' foler. With
other databases, the database will be created as a new DB within the system.

When you create a new database, all migrations will be run against that database, so it will be 
up to date when create returns.

#### Notes on PostgreSQL

PostgreSQL works slightly differently than other databases when creating a new DB. If you
are using PostgreSQL, Apartment will set up a new **schema** and migrate into there. This
provides better performance, and allows Apartment to work on systems like Heroku, which
would not allow a full new database to be created.

### Switching Databases

To switch databases using Apartment, use the following command:

    Apartment::Database.switch('database_name')

When switch is called, all requests coming to ActiveRecord will be routed to the database 
you specify (with the exception of excluded models, see below). To return to the 'root' 
database, call switch with no arguments.

### Switching Databases per request

You can have Apartment route to the appropriate database by adding some Rack middleware.
Apartment can support many different "Elevators" that can take care of this routing to your data.
In house, we use the subdomain elevator, which analyzes the subdomain of the request and switches
to a database schema of the same name. It can be used like so:

    # application.rb
    module My Application
      class Application < Rails::Application
      
        config.middleware.use 'Apartment::Elevators::Subdomain'
      end
    end
    
### Excluding models

If you have some models that should always access the 'root' database, you can specify this by configuring
Apartment using `Apartment.configure`.  This will yield a config object for you.  You can set excluded models like so:

    Apartment.configure do |config|
      config.excluded_models = [User, Company]        # these models will not be multi-tenanted, but remain in the global (public) namespace
    end

### Managing Migrations

In order to migrate all of your databases (or posgresql schemas) you need to provide a list
of dbs to Apartment.  You can make this dynamic by providing a Proc object to be called on migrations.
This object should yield an array of string representing each database name.  Example:

    # Dynamically get database names to migrate
    Apartment.configure do |config|
      config.database_names = lambda{ Company.all.collect(&:database_name) }
    end
    
    # Use a static list of database names for migrate
    Apartment.configure do |config|
      config.database_names = ['db1', 'db2']
    end
      
You can then migration your databases using the rake task:
    
    rake apartment:migrate
    
This basically invokes `Apartment::Database.migrate(#{db_name})` for each database name supplied
from `Apartment.database_names`

### Delayed::Job

In Apartment's current state, it doesn't seem to queue jobs properly using DJ.  For whatever reason, DJ jobs are created in the current schema, even though the DJ 
is part of the ignored models.  I have to look into this further, but until then use `Apartment::Delayed::Job.enqueue` to ensure that queues are placed in the public schema

In order to make ActiveRecord models play nice with DJ and Apartment, include `Apartment::Delayed::Requirements` in any model that is being serialized by DJ.  Also ensure
that a `database` attribute is set on this model *before* it is serialized, to ensure that when it is fetched again, it is done so in the proper Apartment db context.  For example:

    class SomeModel < ActiveRecord::Base
      include Apartment::Delayed::Requirements
    end

    class SomeDJ
  
      def initialize(model)
        @model = model
        @model.database = Apartment::Database.current_database
      end
  
      def perform
        # do some stuff
      end
    end

## TODO

* Cross-database associations

## Contributing
