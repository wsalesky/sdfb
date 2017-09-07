namespace :db do
	task :populate_rels_160001_170542 => :environment do
		puts "Adding relationships 160001_170542..."
	    inFile = File.new("lib/data/Relationships160001-170542.tsv",'r')
	    count = 160001
	    #start the id  set manually
	    next_id = 100160001
	    puts inFile
	    inFile.each { |line|
	      data = line.split('\n')      
	      data.each { |relationship|
	        relData = relationship.split("\t")
	        person1_input = relData[0].to_i+10000000
	        person2_input = relData[1].to_i+10000000
	        created_by_input = 2
	        approved_by_input = 2
	        approved_on_input = Time.now
	        max_certainty_input = (0.0 + relData[2].to_f * 100.00).to_i
	        original_certainty_input = (0.0 + relData[2].to_f * 100.00).to_i
	        edge_birthdate_certainty_in = relData[3]   
	        puts count
	        count += 1
	        puts "next_id1 = " + next_id.to_s

	       	a_rel = Relationship.new do |r| 
				r.id = next_id
				r.person1_index = person1_input
				r.person2_index = person2_input
				r.created_by = created_by_input
				r.approved_by = approved_by_input
				r.approved_on = approved_on_input
				r.is_approved = true
				r.original_certainty = original_certainty_input
				r.max_certainty = max_certainty_input
				r.edge_birthdate_certainty = edge_birthdate_certainty_in
				r.save!
        	end

        	#increment the manual id
        	next_id = (next_id.to_i + 1)
	       }
	     }
	     puts next_id.to_s
	    inFile.close
	    puts "Finished adding relationships 160001_170542"
	end
end