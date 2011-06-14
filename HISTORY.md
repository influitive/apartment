# 0.4.0
  * June 14, 2011
  
  - Added `configure` method on Apartment instead of using yml file, allows for dynamic setting of db names to migrate for rake task
  
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

