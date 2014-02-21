# Require this file to append Apartment rake tasks to ActiveRecord db rake tasks
# Enabled by default in the initializer

Rake::Task["db:migrate"].enhance do
  Rake::Task["apartment:migrate"].invoke
end

Rake::Task["db:rollback"].enhance do
  Rake::Task["apartment:rollback"].invoke
end

Rake::Task["db:migrate:up"].enhance do
  Rake::Task["apartment:migrate:up"].invoke
end

Rake::Task["db:migrate:down"].enhance do
  Rake::Task["apartment:migrate:down"].invoke
end

Rake::Task["db:migrate:redo"].enhance do
  Rake::Task["apartment:migrate:redo"].invoke
end

Rake::Task["db:seed"].enhance do
  Rake::Task["apartment:seed"].invoke
end
