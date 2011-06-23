# 0.9.0
  * June 23, 2011
  
  - Added module to provide delayed job hooks

# 0.8.0
  * June 23, 2011
  
  - Added #current_database which will return the current database (or schema) name

# 0.7.0
  * June 22, 2011
  
  - Added apartment:seed rake task for seeding all dbs

# 0.6.0
  * June 21, 2011
  
  - Added #process to connect to new db, perform operations, then ensure a reset

# 0.5.1
  * June 21, 2011
  
  - Fixed db migrate up/down/rollback
  - added db:redo

# 0.5.0
  * June 20, 2011
  
  - Added the concept of an "Elevator", a rack based strategy for db switching
  - Added the Subdomain Elevator middleware to enabled db switching based on subdomain

# 0.4.0
  * June 14, 2011
  
  - Added `configure` method on Apartment instead of using yml file, allows for dynamic setting of db names to migrate for rake task
  - Added `seed_after_create` config option to import seed data to new db on create
  
# 0.3.0
  * June 10, 2011
  
  - Added full support for database migration
  - Added in method to establish new connection for excluded models on startup rather than on each switch
    
# 0.2.0
  * June 6, 2011 *
  
  - Refactor to use more rails/active_support functionality
  - Refactor config to lazily load apartment.yml if exists
  - Remove OStruct and just use hashes for fetching methods
  - Added schema load on create instead of migrating from scratch

# 0.1.3
  * March 30, 2011 *

  - Original pass from Ryan

