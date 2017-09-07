class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json

  # before_filter :check_login
  # before_filter :check_login, :only => [:new, :edit]
  # authorize_resource

  autocomplete :group, :name, full: true, display_value: :name, scopes: [:all_approved]
  load_and_authorize_resource
  
  def index
    @groups_approved = Group.all_approved.order_by_sdfb_id.order_by_sdfb_id.paginate(:page => params[:groups_approved_page]).per_page(100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  def get_autocomplete_items(parameters)
    if (! current_user.blank?)
      if ((current_user.user_type == "Admin") || (current_user.user_type == "Curator"))
        active_record_get_autocomplete_items(parameters).where("is_rejected is false")
      else
        active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
      end
    else
      active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.select("id, name, description, start_date_type, start_year, end_date_type, end_year, justification, created_at, created_by, is_approved, is_active, approved_by, approved_on, is_rejected, last_edit").find(params[:id])
    @user_group_contribs = UserGroupContrib.all_for_group(params[:id]).all_approved.order_by_sdfb_id.paginate(:page => params[:user_group_contribs_page]).per_page(100)
    @people = GroupAssignment.all_for_group(params[:id]).all_approved.order_by_sdfb_id.paginate(:page => params[:people_page]).per_page(100)
    @group_cat_assigns_approved = GroupCatAssign.for_group(params[:id]).all_approved.order_by_sdfb_id.paginate(:page => params[:group_cat_assigns_approved_page]).per_page(100)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  def new_2
    @group = Group.new
    @groupOptions = Group.all_approved.alphabetical

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  def new_3
    @group = Group.new
    @groupOptions = Group.all_approved.alphabetical


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  def reroute_group_form
    group_id = params[:group][:id]
    #user chose'Create New Group' option
    if group_id == ""
      redirect_to new_new_group_form_path
    #user chose an existing group
    else
      redirect_to group_add_person_path(group_id: group_id)
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    @is_approved = @group.is_approved
    #authorize! :edit, @group
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_2
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new_3" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end

  def search
    @query = params[:query]
    unless @query.blank?
      if logged_in? == true && (current_user.user_type == "Admin" || current_user.user_type == "Curator")
        @all_results = Group.search_all(@query)
      else
        @all_results = Group.search_approved(@query)
      end
    end
  end

  def export_groups
    if (current_user.user_type == "Admin")
      group_csv = CSV.generate do |csv|
        csv << ["SDFB Group ID", "Name", "Description", "Start Year Type", "Start Year", "End Year Type", "End Year", "Members List (Name with SDFB Person ID)", "Justification", "Created By ID", "Created At", "Is approved?",
          "Approved By ID", "Approved On"]
        Group.all_active_unrejected.each do |group|
          csv << [group.id, group.name, group.description, group.start_date_type, group.start_year, group.end_date_type, group.end_year, group.person_list, group.justification, group.created_by, group.created_at,
            group.is_approved, group.approved_by, group.approved_on]
        end
      end
    else
      group_csv = CSV.generate do |csv|
        csv << ["SDFB Group ID", "Name", "Description", "Start Year Type", "Start Year", "End Year Type", "End Year", "Members List (Name with SDFB Person ID)"]
        Group.all_approved.each do |group|
          csv << [group.id, group.name, group.description, group.start_date_type, group.start_year, group.end_date_type, group.end_year, group.person_list]
        end
      end
    end
    send_data(group_csv, :type => 'text/csv', :filename => 'SDFB_groups.csv')
  end
end