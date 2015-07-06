namespace :db do
	task :populate_rel_met_record_100010001_100020000 => :environment do 
		#for each relationship, update the start and end date based on the birthdates of the people in the relationship
		puts "Creating a met record for each relationship..."
		
    	for i in 100010001..100020000
			Relationship.update(i, is_active: true)
			puts "created met record for relationship: " + i.to_s
    	end
	end
end