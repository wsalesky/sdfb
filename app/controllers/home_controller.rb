class HomeController < ApplicationController
  autocomplete :group, :name, full: true, :display_value => :name
  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  layout "layouts/index_layout"
  def index
    #If there are no relationships, only return the person node
    # @people = Person.find_first_degree_for(params[:id])
    
    @data = {
      francisID: SDFB::FRANCIS_BACON,
      earliestYear: SDFB::EARLIEST_YEAR,
      latestYear: SDFB::LATEST_YEAR
    }

    #only return people if there is no group search because if there is a group search it will be displayed separately
    if (params[:group].nil?)
      #detect if this is a one degree search or a two degree search
      if (params[:id2].nil?)
        @data['people'] = Person.find_two_degree_for_person(params[:id], params[:confidence], params[:date], "")
      else
        #The field will return searched node 1, searched node 2, shared nodes, and the first degree relationship of the shared network nodes
        #in a previous iteration, the final parameter was ,"" as in the if statement, instead of params[:var1] (a dummy variable?)
        #presumably the extra variable relates to partial/incomplete code set up for passing relationship types assignment info into the search
        @data['people'] = Person.find_two_degree_for_network(params[:id], params[:id2], params[:confidence], params[:date], params[:var1])
      end

    #@data['all_people'] = Person.all_approved.select("id, first_name, last_name, ext_birth_year, prefix, suffix, title")
    else
      # DELETE: This group_data is specifically for creating the group autocomplete and it can be removed
      #@data['group_data'] = Group.all_approved.select("id, name, description, person_list")
      #Check if a group search or shared group search is happening
      # Check if there is a second group to determine if there is a shared group
      if (params[:group2].nil?)
        #if just a group search (not a shared group search)
        # This field will return the group record that has been searched so that the group info is available
        @data['group'] = Group.select("id, name, description, person_list").find(params[:group])
        # Returns the people who are in the group
        #@data['group_members'] = Person.all_members_of_a_group(params[:group]).all_approved
        @data['group_members'] = Person.all_members_of_1_group(params[:group])
      else
        # if a shared group search
        # This field will return the group record for Group 1 that has been searched so that the group info is available
        @data['group'] = Group.select("id, name, description, person_list").find(params[:group])
        # This field will return the group record for Group 2 that has been searched so that the group info is available
        @data['group2'] = Group.select("id, name, description, person_list").find(params[:group2])
        # Returns the people who are in both searched groups
        @data['group_members'] = Person.all_members_of_2_groups(params[:group], params[:group2])
      end 
    end
    @data['recent_user_points'] = recent_user_points()
  end

# removes certain users from the leader board's most recent 100 contribution selection
# for now removes users 1,2, and 3
  def remove_users(contrib_type)
    type = contrib_type.clone
    type.each do |i|
      type.delete_if {|i| i.created_by == 1 }
      type.delete_if {|i| i.created_by == 2 }
      type.delete_if {|i| i.created_by == 3 }
    end
    return type
  end

# grabs the 100 most recent contributions for the leaderboard
  def recent_contributions
    recent_contrib = ((Person.all_recent.all_approved.limit(100)) + 
                      (Group.all_recent.all_approved.limit(100)) + 
                      (Relationship.all_recent.all_approved.limit(100)) + 
                      (GroupAssignment.all_recent.all_approved.limit(100)) + 
                      (UserGroupContrib.all_recent.all_approved.limit(100)) + 
                      (UserPersonContrib.all_recent.all_approved.limit(100))) + 
                      (UserRelContrib.all_recent.all_approved.limit(100))
    recent_contrib.sort! {|a,b| a.updated_at <=> b.updated_at}.reverse!
    recent_contrib = remove_users(recent_contrib)
    @recent_contrib = recent_contrib.take(100)
  end

# calculates, based off of the 100 most recent contributions, which users have contributed and how much
  def recent_user_points
    users_rank = Hash.new
    @recent_contrib = recent_contributions
    @recent_contrib.each do |i|
      if users_rank.key?(i.created_by)
        users_rank[i.created_by] += 1
      else
        users_rank[i.created_by] = 1
      end
    end
    @users_rank = users_rank.sort_by { |created_by, points| points }.reverse
  end

# usernames on the leaderboard based off of id from recent_user_points
  def get_username(id)
    user = User.find([id])
    @username = user[0].username
  end
  helper_method :get_username


  def update_node_info
    @node_id = params[:node_id]
    @node_info = Person.select("display_name, first_name, last_name, ext_birth_year, ext_death_year, birth_year_type, death_year_type, group_list, historical_significance, odnb_id, prefix, suffix, title").where("id = ?", @node_id)
    @node_info_display_name = @node_info[0][:display_name]
    @node_info_first_name = @node_info[0][:first_name]
    @node_info_last_name = @node_info[0][:last_name]
    @node_info_birth = @node_info[0][:ext_birth_year]
    @node_info_birth_year_type = @node_info[0][:birth_year_type]
    @node_info_death = @node_info[0][:ext_death_year]
    @node_info_death_year_type = @node_info[0][:death_year_type]
    @node_info_group_list = @node_info[0][:group_list]
    @node_info_historical_significance = @node_info[0][:historical_significance]
    @node_info_odnb_id = @node_info[0][:odnb_id]
    @node_info_prefix = @node_info[0][:prefix]
    @node_info_suffix = @node_info[0][:suffix]
    @node_info_title = @node_info[0][:title]
    respond_to do |format|
      format.js
    end
  end

  def update_network_info
    @source_id = params[:source_id]
    @target_id = params[:target_id]
    @source_info = Person.select("display_name, first_name, last_name").where("id = ?", @source_id)
    @target_info = Person.select("display_name, first_name, last_name").where("id = ?", @target_id)
    @source_name = @source_info[0][:display_name]
    @target_name = @target_info[0][:display_name]
    @source_first_name = @source_info[0][:first_name]
    @source_last_name = @source_info[0][:last_name]
    @target_first_name = @target_info[0][:first_name]
    @target_last_name = @target_info[0][:last_name]
    @network_info = Relationship.select("id, max_certainty, type_certainty_list, start_date_type, start_year, end_date_type, end_year").where("person1_index = ? AND person2_index = ? OR person1_index = ? AND person2_index = ? ", @source_id, @target_id, @target_id, @source_id)
    @network_info_id = @network_info[0][:id]
    @network_info_confidence = @network_info[0][:max_certainty]
    @network_info_start_date_type = @network_info[0][:start_date_type]
    @network_info_start_year = @network_info[0][:start_year]
    @network_info_end_date_type = @network_info[0][:end_date_type]
    @network_info_end_year = @network_info[0][:end_year]
    @network_info_types_list = @network_info[0][:type_certainty_list]
    @network_dates = UserRelContrib.select("start_date_type, start_year, end_date_type, end_year").where("relationship_id = ?", @network_info_id)

    @network_info_dates = Array.new

    @network_dates.each do |i|
      @temp_date = Array.new
      @temp_date.push i[:start_date_type]
      @temp_date.push i[:start_year]
      @temp_date.push i[:end_date_type]
      @temp_date.push i[:end_year]
      @network_info_dates.push @temp_date
    end
    
    respond_to do |format|
      format.js
    end
  end

  def update_group_info
    @group_id = params[:group]
  end
  
  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end
end
