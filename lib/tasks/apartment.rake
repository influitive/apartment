namespace :apartment do
	desc "Apply database changes to all multi-tenant databases"
	task :migrate => :environment do |t, args|
		
		puts "Apartment :: [Migrating to default environment]"
		ActiveRecord::Migrator.migrate(File.join(Rails.root, ActiveRecord::Migrator.migrations_path))
		
		Admin::Company.where("database is not null").select("distinct database").each do |company|
			puts "Apartment :: [Migrating to #{company.database}]"
			
			Apartment::Database.migrate company.database
		end
	end
end