class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :certainty, :created_by, :relationship_id, :relationship_type_id, 
  :approved_by, :approved_on, :created_at, :is_approved, :start_year, :start_month, 
  :start_day, :end_year, :end_month, :end_day, :is_active, :is_rejected, :edited_by_on, :person1_autocomplete,
  :person2_autocomplete, :person1_selection, :person2_selection, :start_date_type, :end_date_type
  serialize :edited_by_on,Array
  
  # Relationships
  # -----------------------------
  belongs_to :relationship
  belongs_to :relationship_type
  belongs_to :user

  # Misc Constants
  # -----------------------------
  USER_EST_CERTAINTY_LIST = ["Certain", "Highly Likely", "Possible", "Unlikely", "Very Unlikely"]

  ###need rel type for directional
  ###need inverse rel type for directional

  # Misc Constants
  DATE_TYPE_LIST = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :certainty
  validates_presence_of :created_by
  validates_presence_of :relationship_id
  validates_presence_of :relationship_type_id
  ## annotation must be at least 10 characters
  validates_length_of :annotation, :minimum => 10, :if => :annot_present?
  ## bibliography must be at least 10 characters
  validates_length_of :bibliography, :minimum => 10, :if => :bib_present?
  validates :start_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :start_year_present?
  validates :start_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :start_year_present?
  validates :end_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :end_year_present?
  validates :end_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :end_year_present?
  ## start date type is one included in the list
  validates_inclusion_of :start_date_type, :in => DATE_TYPE_LIST, :if => :start_year_present?
  ## end date type is one included in the list
  validates_inclusion_of :end_date_type, :in => DATE_TYPE_LIST, :if => :end_year_present?
  validate :autocomplete_to_rel, :on => :create

  # Scope
  # ----------------------------- 
  scope :all_approved, where("is_approved is true and is_active is true and is_rejected is false")
  scope :all_inactive, where("is_active is false")
  scope :all_rejected, where("is_rejected is true and is_active is true")
  scope :all_unapproved, where("is_approved is false and is_rejected is false and is_active is true")
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :all_for_relationship, lambda {|relID| 
      select('user_rel_contribs.*')
      .where('relationship_id = ?', relID)}
  scope :highest_certainty, order('certainty DESC')
  scope :all_recent, order('created_at DESC')
  scope :order_by_sdfb_id, order('id')

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  before_create :autocomplete_to_rel
  before_update :add_editor_update_max_cert_check_approved
  ##before_create :update_max_certainty ###
  after_update :check_if_approved
  after_create :check_if_approved
  after_create :create_max_certainty
  after_update :update_max_certainty
  ##after_create :create_relationship_types_list ##
  ##after_update :create_relationship_types_list
  before_create :create_start_and_end_date
  before_update :create_start_and_end_date

  # Custom Methods
  # -----------------------------
  
  #This converts the person1_selected and the person2_selected into the relationship_id foreign key
  def autocomplete_to_rel
    #find the relationship_id given the two people
    if (self.relationship_id == 0)
      if ((! self.person1_selection.blank?) && (! self.person2_selection.blank?))
        found_rel_id = Relationship.for_2_people(self.person1_selection, self.person2_selection)[0]
        if (found_rel_id.nil?)
        #if the relationship does not exist, then through an error
        errors.add(:person2_autocomplete, "This relationship does not exist.")
        else
          self.relationship_id = found_rel_id.id
        end
      else
        if (self.person1_selection.blank?) 
          errors.add(:person1_autocomplete, "Please select people from the autocomplete dropdown menus.")
        end
        if (self.person2_selection.blank?) 
          errors.add(:person2_autocomplete, "Please select people from the autocomplete dropdown menus.")
        end
      end
    end
  end

  #this checks if the record is approved
  def check_if_approved
    if (self.is_approved == false)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  ##if a user submits a new relationship but does not include a start and end date it defaults to a start and end date based on the birth years of the people in the relationship
  def create_start_and_end_date
    person1_index = Relationship.find(relationship_id).person1_index
    person2_index = Relationship.find(relationship_id).person2_index
    person1_record = Person.find(person1_index)
    person2_record = Person.find(person2_index)
    if (! person1_record.nil?)
      birth_year_1 = person1_record.ext_birth_year
      death_year_1 = person1_record.ext_death_year
    end
    if (! person2_record.nil?)
      birth_year_2 = person2_record.ext_birth_year
      death_year_2 = person2_record.ext_death_year
    end

    #Only use default start date if the user does not enter a start year
    if (self.start_year.blank?)
      #decide new relationship start date
      if ((! birth_year_1.blank?) || (! birth_year_2.blank?))
        ##if there is a birthdate for at least 1 person
        new_start_year_type = "AF/IN"
        if ((! birth_year_1.blank?) && (! birth_year_2.blank?))
          ## Use max birth year if birthdates are recorded for both people because the relationship can't start before someone is born
          if birth_year_1 > birth_year_2
            new_start_year = birth_year_1.to_i
          else
            new_start_year = birth_year_2.to_i
          end
        elsif (! birth_year_1.blank?)
          new_start_year = birth_year_1.to_i
        elsif (! birth_year_2.blank?)
          new_start_year = birth_year_2.to_i
        end
      else
        ##if there is no birthdates, set start date to the default CA 1400 (around 1400)
        new_start_year_type = "CA"
        new_start_year = 1400
      end

      self.start_year = new_start_year
      self.start_date_type = new_start_year_type
    end 

    #Only use default end date if the user does not enter an end year
    if (self.end_year.blank?)
      #decide new relationship end date
      if ((! death_year_1.blank?) || (! death_year_2.blank?))
        ##if there is a deathdate for at least 1 person
        new_end_year_type = "BF/IN"
        if ((! death_year_1.blank?) && (! death_year_2.blank?))
          ## Use min deathdate if deathdates are recorded for both people because the relationship will end by the time of the people dies
          if death_year_1 < death_year_2
            new_end_year = death_year_1.to_i
          else
            new_end_year = death_year_2.to_i
          end
        elsif (! death_year_1.blank?)
          new_end_year = death_year_1.to_i
        elsif (! death_year_2.blank?)
          new_end_year = death_year_2.to_i
        end
      else
        ##If there is no death year, set end year to the default CA 1800 (around 1800)
        new_end_year_type = "CA"
        new_end_year = 1800
      end
      self.end_year = new_end_year
      self.end_date_type = new_end_year_type
    end
  end

  #This creates a new relationship types list, a 2d array with each realtionship type like [type name, certainty, start_year, end_year]
  def create_relationship_types_list
    #find all approved user_rel_contribs for that relationship
    updated_rel_types_list = []
    UserRelContrib.all_approved.all_for_relationship(self.relationship_id).each do | urc |
      if ((urc.is_approved == true) && (urc.is_active == true))
        user_rel_contrib_record = []
        user_rel_contrib_record.push(RelationshipType.find(urc.relationship_type_id).name)
        user_rel_contrib_record.push(urc.certainty)
        user_rel_contrib_record.push(urc.start_year)
        user_rel_contrib_record.push(urc.end_year)
      end
      updated_rel_types_list.push(user_rel_contrib_record)
    end

    Relationship.update(self.relationship_id, types_list: updated_rel_types_list)
  end

  def add_editor_update_max_cert_check_approved
    # update edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = UserRelContrib.find(self.id).edited_by_on
      if previous_edited_by_on.nil?
        previous_edited_by_on = []
      end
      newEditRecord = []
      newEditRecord.push(self.approved_by)
      newEditRecord.push(Time.now)
      previous_edited_by_on.push(newEditRecord)
      self.edited_by_on = previous_edited_by_on
    end

    # #update max_certainty
    # if (self.is_approved == true)
    #   # update the relationship's max certainty
    #     #set the max_certainty to the current user_rel_contrib certainty
    #     new_max_certainty = self.certainty
    #     # find all user_rel_contribs for a specific relationship
    #     all_user_rel_contribs = UserRelContrib.all_approved.all_for_relationship(self.relationship_id)

    #     # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
    #     all_user_rel_contribs.each do |urc|
    #       if urc.certainty > new_max_certainty
    #         new_max_certainty = urc.certainty
    #       end
    #     end

    #     # check if original certainty is greater than the max certainty
    #     original_certainty = Relationship.find(self.relationship_id).original_certainty
    #     if (original_certainty > new_max_certainty) 
    #       new_max_certainty = original_certainty
    #     end 

    #     Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

    #   # update the max certainty of the relationship in the people's rel_sum
    #     # find the existing rel_sums for person 1 and person 2
    #     person1_id = Relationship.find(self.relationship_id).person1_index
    #     rel_sum_person_1 = Person.find(person1_id).rel_sum

    #     person2_id = Relationship.find(self.relationship_id).person2_index
    #     rel_sum_person_2 = Person.find(person2_id).rel_sum

    #     # locate the record for the specific relationship for person 1
    #     rel_sum_person_1.each do |rel|
    #       if rel[2] == self.relationship_id
    #         rel[1] = new_max_certainty
    #       end
    #     end
    #     Person.update(person1_id, rel_sum: rel_sum_person_1)
    #     rel_sum_person_2.each do |rel|
    #       if rel[2] == self.relationship_id
    #         rel[1] = new_max_certainty
    #       end
    #     end
    #     Person.update(person2_id, rel_sum: rel_sum_person_2)
    # else
    #     # update the relationship's max certainty
    #     new_max_certainty = 0

    #     # find all user_rel_contribs for a specific relationship
    #     all_user_rel_contribs = UserRelContrib.all_approved.all_for_relationship(self.relationship_id)

    #     # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
    #     all_user_rel_contribs.each do |urc|
    #       if urc.certainty > new_max_certainty
    #         new_max_certainty = urc.certainty
    #       end
    #     end

    #     # if max certainty = 0, set it to the original certainty
    #     original_certainty = Relationship.find(self.relationship_id).original_certainty
    #     if (original_certainty > new_max_certainty) 
    #       new_max_certainty = original_certainty
    #     end 
        
    #     Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

    #   # update the max certainty of the relationship in the people's rel_sum
    #     # find the existing rel_sums for person 1 and person 2
    #     person1_id = Relationship.find(self.relationship_id).person1_index
    #     rel_sum_person_1 = Person.find(person1_id).rel_sum

    #     person2_id = Relationship.find(self.relationship_id).person2_index
    #     rel_sum_person_2 = Person.find(person2_id).rel_sum

    #     # locate the record for the specific relationship for person 1
    #     rel_sum_person_1.each do |rel|
    #       if rel[2] == self.relationship_id
    #         rel[1] = new_max_certainty
    #       end
    #     end
    #     Person.update(person1_id, rel_sum: rel_sum_person_1)
    #     rel_sum_person_2.each do |rel|
    #       if rel[2] == self.relationship_id
    #         rel[1] = new_max_certainty
    #       end
    #     end
    #     Person.update(person2_id, rel_sum: rel_sum_person_2)
    # end

    #update approve_by
    if (self.is_approved == false)
      self.approved_by = nil
      self.approved_on = nil
    end
  end

  def init_array
    self.edited_by_on = nil
  end
  
  def start_year_present?
    ! self.start_year.nil?
  end

  def end_year_present?
    ! self.end_year.nil?
  end

  def update_max_certainty
    relationship_record = Relationship.find(self.relationship_id)
    old_type_certainty_list = relationship_record.type_certainty_list
    if ((self.is_approved == true) && (self.is_active == true) && (self.is_rejected == false))
      #Avoid errors by always checking that the field is an array
      #if the type_certainty_list is blank then just add the record
      if old_type_certainty_list.nil?
        new_type_certainty_list = []
        new_type_certainty = []
        new_type_certainty.push(self.id)
        new_type_certainty.push(self.certainty)
        new_type_certainty_list.push(new_type_certainty)
      else
        #Check if the relationship type assignment is in the type_certainty_list and update it if it is
        new_type_certainty_list = old_type_certainty_list
        found_flag = false
        old_type_certainty_list.each do |rta|
          #if the user_rel_edit record already exists in the type_certainty_list then update the certainty in the array
          if (rta[0] == self.id)
            # update the certainty for that array
            rta[1] = self.certainty
            new_type_certainty_list = old_type_certainty_list
            found_flag = true
            break
          end
        end
        #if the user_rel_edit record does not already exists in the type_certainty_list then add it
        if (found_flag == false)
          new_type_certainty = []
          new_type_certainty.push(self.id)
          new_type_certainty.push(self.certainty)
          new_type_certainty_list.push(new_type_certainty)
        end
      end

      # update the relationship's type certainty list
      Relationship.update(self.relationship_id, type_certainty_list: new_type_certainty_list)

      # update the relationship's maximum certainty if new certainty is greater
      original_max_certainty = relationship_record.max_certainty
      creator_certainty = relationship_record.original_certainty
      if self.certainty > creator_certainty
        if self.certainty > original_max_certainty 
          Relationship.update(self.relationship_id, max_certainty: self.certainty)
        end
      else
        Relationship.update(self.relationship_id, max_certainty: creator_certainty)
      end
    else
      delete_flag = false
      #possibly delete the record since it shouldn't be there anymore if it is not approved
      old_type_certainty_list.each_with_index do |rta, i|
        #if the user_rel_edit record already exists in the type_certainty_list then update the certainty in the array
        if (rta[0] == self.id)
          new_type_certainty_list = old_type_certainty_list
          new_type_certainty_list.delete_at(i)
          Relationship.update(self.relationship_id, type_certainty_list: new_type_certainty_list)
          delete_flag = true
          break
        end
      end
      if (delete_flag == true)
        # update the relationship's maximum certainty if deleted certainty
        max_certainty_from_list = new_type_certainty_list.map { |e| e.second }.max.to_i
        creator_certainty = relationship_record.original_certainty
        if max_certainty_from_list > creator_certainty
          Relationship.update(self.relationship_id, max_certainty: max_certainty_from_list)
        else
         Relationship.update(self.relationship_id, max_certainty: creator_certainty)
        end
      end
    end
  end

  def create_max_certainty
    if ((self.is_approved == true) && (self.is_active == true) && (self.is_rejected == false))
    
      #make an array with the new user_rel_contrib id and certainty
      new_type_certainty = []
      new_type_certainty.push(self.id)
      new_type_certainty.push(self.certainty)

      # update the relationship's type certainty list
      relationship_record = Relationship.find(self.relationship_id)
      old_type_certainty_list = relationship_record.type_certainty_list
      new_type_certainty_list = old_type_certainty_list
      if new_type_certainty_list.nil?
        new_type_certainty_list = []
      end
      new_type_certainty_list.push(new_type_certainty)
      Relationship.update(self.relationship_id, type_certainty_list: new_type_certainty_list)

      # update the relationship's maximum certainty if new certainty is greater that the old certainty and the relationship original certainty
      original_max_certainty = relationship_record.max_certainty
      creator_certainty = relationship_record.original_certainty
      if self.certainty > creator_certainty
        if self.certainty > original_max_certainty
          Relationship.update(self.relationship_id, max_certainty: self.certainty)
        end
      else
        Relationship.update(self.relationship_id, max_certainty: creator_certainty)
      end
    end

    ## Need to update the rel_sum list of the people

    #update max_certainty
    # if (self.is_approved == true)
    #   # update the relationship's max certainty
    #     #set the max_certainty to the current user_rel_contrib certainty
    #     new_max_certainty = self.certainty
    #     # find all user_rel_contribs for a specific relationship
    #     all_user_rel_contribs = UserRelContrib.all_approved.all_for_relationship(self.relationship_id)

    #     # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
    #     all_user_rel_contribs.each do |urc|
    #       if urc.certainty > new_max_certainty
    #         new_max_certainty = urc.certainty
    #       end
    #     end

    #     # check if original certainty is greater than the max certainty
    #     original_certainty = Relationship.find(self.relationship_id).original_certainty
    #     if (original_certainty > new_max_certainty) 
    #       new_max_certainty = original_certainty
    #     end 

    #     Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

    #   # update the max certainty of the relationship in the people's rel_sum
    #     # find the existing rel_sums for person 1 and person 2
    #     person1_id = Relationship.find(self.relationship_id).person1_index
    #     rel_sum_person_1 = Person.find(person1_id).rel_sum

    #     person2_id = Relationship.find(self.relationship_id).person2_index
    #     rel_sum_person_2 = Person.find(person2_id).rel_sum

    #     # locate the record for the specific relationship for person 1
    #     rel_sum_person_1.each do |rel|
    #       if rel[2] == self.relationship_id
    #         rel[1] = new_max_certainty
    #       end
    #     end
    #     Person.update(person1_id, rel_sum: rel_sum_person_1)
    #     rel_sum_person_2.each do |rel|
    #       if rel[2] == self.relationship_id
    #         rel[1] = new_max_certainty
    #       end
    #     end
    #     Person.update(person2_id, rel_sum: rel_sum_person_2)
    # else
    #     # update the relationship's max certainty
    #     new_max_certainty = 0

    #     # find all user_rel_contribs for a specific relationship
    #     all_user_rel_contribs = UserRelContrib.all_approved.all_for_relationship(self.relationship_id)

    #     # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
    #     all_user_rel_contribs.each do |urc|
    #       if urc.certainty > new_max_certainty
    #         new_max_certainty = urc.certainty
    #       end
    #     end

    #     # if max certainty = 0, set it to the original certainty
    #     original_certainty = Relationship.find(self.relationship_id).original_certainty
    #     if (original_certainty > new_max_certainty) 
    #       new_max_certainty = original_certainty
    #     end 
        
    #     Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

    #   # update the max certainty of the relationship in the people's rel_sum
    #     # find the existing rel_sums for person 1 and person 2
    #     person1_id = Relationship.find(self.relationship_id).person1_index
    #     rel_sum_person_1 = Person.find(person1_id).rel_sum

    #     person2_id = Relationship.find(self.relationship_id).person2_index
    #     rel_sum_person_2 = Person.find(person2_id).rel_sum

    #     # locate the record for the specific relationship for person 1
    #     rel_sum_person_1.each do |rel|
    #       if rel[2] == self.relationship_id
    #         rel[1] = new_max_certainty
    #       end
    #     end
    #     Person.update(person1_id, rel_sum: rel_sum_person_1)
    #     rel_sum_person_2.each do |rel|
    #       if rel[2] == self.relationship_id
    #         rel[1] = new_max_certainty
    #       end
    #     end
    #     Person.update(person2_id, rel_sum: rel_sum_person_2)
    # end
  end

  def annot_present?
    ! self.annotation.blank?
  end

  def bib_present?
    ! self.bibliography.blank?
  end

  def get_person1_name
    return Person.find(Relationship.find(relationship_id).person1_index).display_name
  end

  def get_person2_name
    return Person.find(Relationship.find(relationship_id).person2_index).display_name
  end

  def get_both_names
    return Person.find(Relationship.find(relationship_id).person1_index).display_name + " & " + Person.find(Relationship.find(relationship_id).person2_index).display_name
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
