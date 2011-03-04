namespace :apartment do
	desc "Apply database changes to all multi-tenant databases"
	task :migrate => :environment do |t, args|
		
		puts "[Migrating to default environment]"
		ActiveRecord::Migrator.migrate(File.join(Rails.root, 'db', 'migrate'))
		
		Admin::Company.where("database is not null").select("distinct database").each do |u|
			puts "[Migrating to #{u.database}]"
			
			Apartment::Database.migrate u.database 
		end
	end
end