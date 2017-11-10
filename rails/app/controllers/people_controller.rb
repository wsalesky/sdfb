class PeopleController < ApplicationController
  # GET /people
  # GET /people.json

  require 'will_paginate'
  require 'will_paginate/array'
  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  load_and_authorize_resource
  
  def index
    @people_approved = Person.all_approved.order_by_sdfb_id.paginate(:page => params[:people_approved_page]).per_page(100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @people }
    end
  end

  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.select("id, odnb_id, title, prefix, first_name, last_name, suffix, gender, search_names_all, created_by, birth_year_type, ext_birth_year, alt_birth_year, death_year_type, ext_death_year, alt_death_year, is_approved, approved_by, approved_on, justification, is_rejected, is_active, created_at, display_name, historical_significance").find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def membership
    @groups = GroupAssignment.all_for_person(params[:id]).all_approved.order_by_sdfb_id.paginate(:page => params[:groups_page]).per_page(100)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
    end
  end

  def relationships
    @approved_relationships = Relationship.all_for_person(params[:id]).highest_certainty.all_approved.order_by_sdfb_id.paginate(:page => params[:approved_relationships_page]).per_page(100)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
    end
  end

  def notes
    @user_person_contribs = UserPersonContrib.all_for_person(params[:id]).all_approved.order_by_sdfb_id.paginate(:page => params[:user_person_contribs_page]).per_page(100)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    @is_approved = @person.is_approved
    #authorize! :edit, @person
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  def search 
    # allows for the admin to search from their dashboard
    @query = params[:query]
    if @query != ""
      @all_results = Group.search_approved(@query)
      if (logged_in? == true)
        if ((current_user.user_type == "Admin") || (current_user.user_type == "Curator"))
          @all_results1 = Person.search_all(@query)
        else
          @all_results1 = Person.search_approved(@query)
        end
      else
          @all_results1 = Person.search_approved(@query)
      end
      @all_results = @all_results1.order_by_sdfb_id.paginate(:page => params[:all_results_page], :per_page => 20)
    end
  end
end