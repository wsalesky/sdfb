class UserPersonContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :created_by, :person_id, :edited_by_on, :reviewed_by_on
  serialize :edited_by_on,Array
  serialize :reviewed_by_on,Array
  # Relationships
  # -----------------------------
  belongs_to :person
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :bibliography
  validates_presence_of :created_by
  # validates_presence_of :is_flagged
  validates_presence_of :person_id

  # Scope
  # -----------------------------
  scope :not_flagged, where(is_flagged: false)

  # Custom Methods
  # -----------------------------
  def get_person_name
    return Person.find(person_id).first_name + " " + Person.find(person_id).last_name 
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
