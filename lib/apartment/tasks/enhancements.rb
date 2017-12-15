# Require this file to append Apartment rake tasks to ActiveRecord db rake tasks
# Enabled by default in the initializer

module Apartment
  class RakeTaskEnhancer

    module TASKS
      ENHANCE_BEFORE = %w(db:drop)
      ENHANCE_AFTER  = %w(db:migrate db:rollback db:migrate:up db:migrate:down db:migrate:redo db:seed)
      freeze
    end

    # This is a bit convoluted, but helps solve problems when using Apartment within an engine
    # See spec/integration/use_within_an_engine.rb

    class << self
      def enhance!
        return unless should_enhance?

        # insert task before
        TASKS::ENHANCE_BEFORE.each do |name|
          task = Rake::Task[name]
          enhance_before_task(task)
        end

        # insert task after
        TASKS::ENHANCE_AFTER.each do |name|
          task = Rake::Task[name]
          enhance_after_task(task)
        end

      end

      def should_enhance?
        Apartment.db_migrate_tenants
      end

      def enhance_before_task(task)
        task.enhance([inserted_task_name(task)])
      end

      def enhance_after_task(task)
        task.enhance do
          Rake::Task[inserted_task_name(task)].invoke
        end
      end

      def inserted_task_name(task)
        task.name.sub(/db:/, 'apartment:')
      end

    end

  end
end

Apartment::RakeTaskEnhancer.enhance!
