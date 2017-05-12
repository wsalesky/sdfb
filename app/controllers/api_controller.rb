class ApiController < ApplicationController
  def people
    ids = params[:ids].split(",")
    begin
      @people = Person.find(ids)
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "Invalid person ID(s)"}
    end
    respond_to do |format|
      format.json
      format.html { render :json}
    end
  end


  def groups
    ids = params[:ids].split(",")
    begin
      @groups = Group.find(ids)
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "Invalid group ID(s)"}
    end
    respond_to do |format|
      format.json
      format.html { render :json}
    end
  end


  def network
    begin
      ids = params[:ids].split(",").map(&:to_i).uniq.sort
      @display_id = ids.join(",")

      @people = Person.find(ids)

      @relationships = @people.map(&:relationships).reduce(:+).uniq
      
      first_degree_ids = @relationships.collect do |r| 
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids

      @sources = Person.find(first_degree_ids)

      if ids.count == 1
        second_degree_relationships = @sources.map(&:relationships).reduce(:+).uniq
        second_degree_ids = second_degree_relationships.collect do |r| 
          [r.person1_index, r.person2_index]
        end.flatten.uniq - (ids + first_degree_ids)
        second_degree_people = Person.find(second_degree_ids)

        @relationships = @relationships | second_degree_relationships
        @sources = @sources | second_degree_people
      end

    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid person ID(s)"}
    end
  end

  def group_network
    begin
      ids = params[:ids].split(",").map(&:to_i).uniq.sort
      @display_id = ids.join(",")

      @groups = Group.find(ids)

      @people = @groups.map(&:people).reduce(:+).uniq
      
      member_ids = @people.map(&:id).flatten.uniq - ids

      member_relationships = @people.map(&:relationships).flatten
      first_degree_ids = member_relationships.collect do |r|
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids

      @people += Person.find(first_degree_ids)
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid person ID(s)"}
    end
  end

  def typeahead
    query = params[:q]
    begin
      @people = Person.all
      @people.to_a.select!{|p| p.display_name.starts_with? query}
      if @people.empty?
        @people = nil
        @errors = []
        @errors << {title: "No matches found"}
      end
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "Invalid person ID(s)"}
    end
    respond_to do |format|
      format.json { render :people }
      format.html { render :json}
    end
  end

end
