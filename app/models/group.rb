class Group < ActiveRecord::Base

  include TrackLastEdit

  attr_accessible :created_by, :description, :name, :justification, :approved_by, :approved_on, 
  :created_at, :is_approved, :person_list, :start_year, :end_year, :is_active, :is_rejected,
  :start_date_type, :end_date_type

  serialize :person_list,Array #We're using group assignments instead
  
  # Relationships
  # -----------------------------
  has_many :people, :through => :group_assignments
  # if a group is deleted, then all associated group category assignments are deleted
  has_many :group_cat_assigns, :dependent => :destroy
  # if a group is deleted, then all associated user_group_contribs are deleted
  has_many :user_group_contribs, :dependent => :destroy
  # if a group is deleted, then all associated  group assignments are deleted so that the group has no members
  has_many :group_assignments, :dependent => :destroy
  belongs_to :user

  # Misc Constants
  DATE_TYPE_LIST = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]

  # Validations
  # -----------------------------
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :created_by
  #validates_presence_of :approved_by
  #validates_presence_of :approved_on
  ## name must be at least 3 characters
  validates_length_of :name, :minimum => 3
  # this code validates the start and end dates with the associated method
  validate :create_check_start_and_end_date
  ## start date type is one included in the list
  validates_inclusion_of :start_date_type, :in => DATE_TYPE_LIST, :if => :start_year_present?
  ## end date type is one included in the list
  validates_inclusion_of :end_date_type, :in => DATE_TYPE_LIST, :if => :end_year_present?
  # make sure names are unique/not duplicates
  #validates_uniqueness_of :name

  # Scope
  # ----------------------------- 
  scope :all_approved, -> { where(is_approved: true, is_active: true, is_rejected: false) }
  scope :all_inactive, -> { where(is_active: false) }
  scope :all_rejected, -> { where(is_rejected: true, is_active: true) }
  scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }
  scope :all_unapproved, -> { where(is_approved: false, is_rejected: false, is_active: true) }
  scope :all_recent, -> { order(updated_at: :desc) }
  scope :for_id, -> (id_input) { where('id = ?', "#{id_input}") }
  scope :exact_name_match, -> (search_input) { where('name like ?', "#{search_input}") }
  scope :similar_name_match, -> (search_input) { where('name like ?', "%#{search_input}%") }
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :alphabetical, -> { order(name: :asc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }
  scope :approved_user, -> (user_id){ where('approved_by = ?', "#{user_id}") }
  
  # Callbacks
  # ----------------------------- 
  before_create :init_person_list
  before_save   :create_check_start_and_end_date

  # Custom Methods
  # -----------------------------

  # checks that end year is on or after start year and that start 
  # and end years meet min_year and max_year rules
  def create_check_start_and_end_date
    # defining the min and max years
    min_year = 1500
    max_year = 1700

    # add a start date type if there is none
    if (start_date_type.blank?)
      self.start_date_type = "IN"
    end

    # add an end date type if there is none
    if (end_date_type.blank?)
      self.end_date_type = "IN"
    end

    # add a start year if there isn't one, check if follows rules
    if (start_year.blank?)
      self.start_year = min_year
      self.start_date_type = "CA"
    # if there is already a start year, check that start year is before max_year or throw error
    elsif (self.start_year.to_i > max_year)
      errors.add(:start_year, "The start year must be on or before #{max_year}")
    end

    # add an end year if there isn't one, check if follows rules
    if (end_year.blank?)
      self.end_year = max_year
      self.end_date_type = "CA"
    # if there is already a end year, check that end year is after min_year or throw error
    elsif (self.end_year.to_i < min_year)
      errors.add(:end_year, "The end year must be on or after #{min_year}")
    end

    # if the start year converted to an integer is 0 then the date was not an integer
    if (self.start_year.to_i == 0)
      errors.add(:start_year, "Please enter a valid start year.")
    end

    # if the end year converted to an integer is 0 then the date was not an integer
    if (self.end_year.to_i == 0)
      errors.add(:end_year, "Please enter a valid end year.")
    end

    # check that start year is equal to or before end year
    if (self.start_year.to_i > self.end_year.to_i)
      errors.add(:start_year, "The start year must be less than or equal to the end year")
      errors.add(:end_year, "The end year must be greater than or equal to the start year")
    end
  end

  def init_person_list
    self.person_list = nil
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end


  def start_year_present?
    ! self.start_year.nil?
  end

  def end_year_present?
    ! self.end_year.nil?
  end

  # searches for people by name
  def self.search_approved(search)
    if search
      return Group.all_approved.for_id(search.to_i)
    end
  end

  # searches for people by name
  def self.search_all(search)
    if search
      return Group.all.for_id(search.to_i)
    end
  end
end