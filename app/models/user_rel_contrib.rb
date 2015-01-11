class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :certainty, :created_by, :relationship_id, :relationship_type_id, 
  :approved_by, :approved_on, :created_at, :is_approved, :start_year, :start_month, 
  :start_day, :end_year, :end_month, :end_day, :is_active, :is_rejected, :edited_by_on
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

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null and is_active is true and is_rejected is false")
  scope :all_unapproved, where("approved_by is null and is_rejected is false")
  scope :all_for_relationship, lambda {|relID| 
      select('user_rel_contribs.*')
      .where('relationship_id = ?', relID)}

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  before_update :add_editor_update_max_cert_check_approved
  before_create :update_max_certainty
  after_create :check_if_approved


  # Custom Methods
  # -----------------------------
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

    #update max_certainty
    if (self.is_approved == true)
      # update the relationship's max certainty
        #set the max_certainty to the current user_rel_contrib certainty
        new_max_certainty = self.certainty
        # find all user_rel_contribs for a specific relationship
        all_user_rel_contribs = UserRelContrib.all_for_relationship(self.relationship_id)

        # checks whether the old certainty was disregarded out of the all user_rel_contrib
        old_certainty = UserRelContrib.find(self.id).certainty
        old_certainty_disregarded = false

        # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
        all_user_rel_contribs.each do |urc|
          if ((old_certainty == urc.certainty) && (old_certainty_disregarded == false))
            old_certainty_disregarded = true
          else 
            if urc.certainty > new_max_certainty
              new_max_certainty = urc.certainty
            end
          end
        end

        # if max certainty = 0, set it to the original certainty
        if (new_max_certainty == 0) 
          original_certainty = Relationship.find(self.relationship_id).original_certainty
          new_max_certainty = original_certainty
        end 

        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

      # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        person1_id = Relationship.find(self.relationship_id).person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = Relationship.find(self.relationship_id).person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each do |rel|
          if rel[3] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each do |rel|
          if rel[3] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
    else
        # update the relationship's max certainty
        #set the max_certainty to the current user_rel_contrib certainty
        new_max_certainty = 0
        # find all user_rel_contribs for a specific relationship
        all_user_rel_contribs = UserRelContrib.all_for_relationship(self.relationship_id)

        # checks whether the old certainty was disregarded out of the all user_rel_contrib
        old_certainty = UserRelContrib.find(self.id).certainty
        old_certainty_disregarded = false

        # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
        all_user_rel_contribs.each do |urc|
          if ((old_certainty == urc.certainty) && (old_certainty_disregarded == false))
            old_certainty_disregarded = true
          else 
            if urc.certainty > new_max_certainty
              new_max_certainty = urc.certainty
            end
          end
        end

        # if max certainty = 0, set it to the original certainty
        if (new_max_certainty == 0) 
          original_certainty = Relationship.find(self.relationship_id).original_certainty
          new_max_certainty = original_certainty
        end 
        
        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

      # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        person1_id = Relationship.find(self.relationship_id).person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = Relationship.find(self.relationship_id).person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each do |rel|
          if rel[3] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each do |rel|
          if rel[3] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
    end

    #update approve_by
    previous_approved_by = UserRelContrib.find(self.id).approved_by
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    elsif (self.approved_on == nil)
      self.approved_by = previous_approved_by
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

  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def update_max_certainty
    #update max_certainty
    if (self.is_approved == true)
      # update the relationship's max certainty
        #set the max_certainty to the current user_rel_contrib certainty
        new_max_certainty = self.certainty
        # find all user_rel_contribs for a specific relationship
        all_user_rel_contribs = UserRelContrib.all_for_relationship(self.relationship_id)

        # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
        all_user_rel_contribs.each do |urc|
          if urc.certainty > new_max_certainty
            new_max_certainty = urc.certainty
          end
        end

        # if max certainty = 0, set it to the original certainty
        if (new_max_certainty == 0) 
          original_certainty = Relationship.find(self.relationship_id).original_certainty
          new_max_certainty = original_certainty
        end 
        
        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

      # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        person1_id = Relationship.find(self.relationship_id).person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = Relationship.find(self.relationship_id).person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each do |rel|
          if rel[3] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each do |rel|
          if rel[3] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
    else
        # update the relationship's max certainty
        #set the max_certainty to the current user_rel_contrib certainty
        new_max_certainty = 0
        # find all user_rel_contribs for a specific relationship
        all_user_rel_contribs = UserRelContrib.all_for_relationship(self.relationship_id)

        # checks whether the old certainty was disregarded out of the all user_rel_contrib
        old_certainty = UserRelContrib.find(self.id).certainty
        old_certainty_disregarded = false

        # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
        all_user_rel_contribs.each do |urc|
          if ((old_certainty == urc.certainty) && (old_certainty_disregarded == false))
            old_certainty_disregarded = true
          else 
            if urc.certainty > new_max_certainty
              new_max_certainty = urc.certainty
            end
          end
        end

        # if max certainty = 0, set it to the original certainty
        if (new_max_certainty == 0) 
          original_certainty = Relationship.find(self.relationship_id).original_certainty
          new_max_certainty = original_certainty
        end 
        
        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

      # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        person1_id = Relationship.find(self.relationship_id).person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = Relationship.find(self.relationship_id).person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each do |rel|
          if rel[3] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each do |rel|
          if rel[3] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
    end
  end

  def annot_present?
    ! self.annotation.blank?
  end

  def bib_present?
    ! self.bibliography.blank?
  end

  def get_person1_name
    return Person.find(Relationship.find(relationship_id).person1_index).first_name + " " + Person.find(Relationship.find(relationship_id).person1_index).last_name 
  end

  def get_person2_name
    return Person.find(Relationship.find(relationship_id).person2_index).first_name + " " + Person.find(Relationship.find(relationship_id).person2_index).last_name 
  end

  def get_both_names
    return Person.find(Relationship.find(relationship_id).person1_index).first_name + " " + Person.find(Relationship.find(relationship_id).person1_index).last_name + " & " + Person.find(Relationship.find(relationship_id).person2_index).first_name + " " + Person.find(Relationship.find(relationship_id).person2_index).last_name 
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
