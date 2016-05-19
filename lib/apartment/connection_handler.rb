require 'concurrent/map'

module Apartment
  class ConnectionHandler < ActiveRecord::ConnectionAdapters::ConnectionHandler
    def initialize
      @owner_to_pool = Concurrent::Map.new(:initial_capacity => 2) do |h,k|
        h[k] = Concurrent::Map.new(:initial_capacity => 2) do |h,k|
          h[k] = Concurrent::Map.new(:initial_capacity => 2)
        end
      end
      @whatever_to_pool = Concurrent::Map.new(:initial_capacity => 2) do |h,k|
        h[k] = Concurrent::Map.new(:initial_capacity => 2)
      end
      @class_to_pool = Concurrent::Map.new(:initial_capacity => 2) do |h,k|
        h[k] = Concurrent::Map.new(:initial_capacity => 2) do |h,k|
          h[k] = Concurrent::Map.new(:initial_capacity => 2)
        end
      end
    end

    def switch_to_host(owner, config, whatever)
      # this differs from establish_connection in that it doesn't always create
      # a new connectionpool—we want to reuse existing connection pools to the
      # same host, but not break the contract with `establish_connection`.
      @class_to_pool.clear
      spec =
        if ActiveRecord::VERSION::MINOR < 1
          ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(:apartment, { 'apartment' => config }).spec
        else
          ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new('apartment' => config).spec(:apartment)
        end
      whatever_to_pool[whatever] ||= ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
      owner_to_pool[owner.name] = whatever_to_pool[whatever]
    end

    def remove_connection(owner)
      if pool = owner_to_pool.delete(owner.name)
        @class_to_pool.clear
        unless owner_to_pool.values.include?(pool)
          whatever_to_pool.delete(pool.spec.config[:host])
          pool.automatic_reconnect = false
          pool.disconnect!
          pool.spec.config
        end
      end
    end

    private

    def owner_to_pool
      @owner_to_pool[Process.pid][Thread.current.object_id]
    end

    def class_to_pool
      @class_to_pool[Process.pid][Thread.current.object_id]
    end

    def whatever_to_pool
      @whatever_to_pool[Process.pid]
    end

    def pool_for(owner)
      owner_to_pool.fetch(owner.name) {
        if thread_pool = pool_from_any_thread_for(owner)
          owner_to_pool[owner.name] = thread_pool
        elsif ancestor_pool = pool_from_any_process_for(owner)
          # A connection was established in an ancestor process that must have
          # subsequently forked. We can't reuse the connection, but we can copy
          # the specification and establish a new connection with it.
          establish_connection owner, ancestor_pool.spec
        else
          owner_to_pool[owner.name] = nil
        end
      }
    end

    def pool_from_any_thread_for(owner)
      owner_to_pool = @owner_to_pool[Process.pid].values.find { |v| v[owner.name] }
      owner_to_pool && owner_to_pool[owner.name]
    end

    def pool_from_any_process_for(owner)
      owner_to_pool = @owner_to_pool.values.flat_map(&:values).find { |v| v[owner.name] }
      owner_to_pool && owner_to_pool[owner.name]
    end
  end
end