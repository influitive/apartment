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

You can have Apartment route to the appropriate database per request by adding a warden task
in application.rb. At Influitive for instance, we route dbs based on hostname.  
We do something like the following:

    Warden::Manager.on_request do |proxy|
      if session[:user_id]
        u = User.find(session[:user_id])
        Apartment::Database.switch(u.database)
      end
    end

### Excluding models

If you have some models that should always access the 'root' database, you can specify this by configuring
Apartment using `Apartment.configure`.  This will yield a config object for you.  You can set the following
options:

    Apartment.configure do |config|
      config.excluded_models = [User, Company]
      config.database_names = lambda{ Company.scoped.collect(&:database_name) }     # pass in a block to be invoked for dynamically loaded names, or array of string for static db names
      config.use_postgres_schemas = true      # whether or not to use postgresql schemas
    end

### Managing Migrations

Currently, you will need to migrate each database individually. I'll be working on code to 
migrate all known databases soon. You can migrate any database up to the current version by
calling:

     Apartment::Database.migrate('database_name')

## TODO

* Migration support
* Other rake task support
* Cross-database associations

## Contributing
