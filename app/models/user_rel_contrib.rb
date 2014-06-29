class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :confidence_type, :created_by, :is_flagged, :relationship_id, :relationship_type
  
  # Relationships
  # -----------------------------
  belongs_to :relationship
  belongs_to :user

  # Misc Constants
  # -----------------------------
  REL_TYPE_LIST = ["No relationship exists", "Acquaintances","Ancestor/Descendent","Antagonists","Mentor/Apprentice","Parent/Child","Close Friends","Collaborators",
    "Colleagues","Employer/Employee","Enemies","Engaged","Friends","Grandparent/Grandchild","Met",
    "Influenced one another","Knew in passing","Knew of one another","Life partners","Lived with",
    "Neighbors","Siblings","Spouses","Coworkers"]

  USER_EST_CONFIDENCE_LIST = ["Certain", "Highly Likely", "Possible", "Unlikely", "Very Unlikely"]

  # Validations
  # -----------------------------
  validates :relationship_type, :inclusion => {:in =>  REL_TYPE_LIST}, :allow_blank => true
  validates :confidence_type, :inclusion => {:in => USER_EST_CONFIDENCE_LIST}
  validates_presence_of :annotation
  validates_presence_of :bibliography
  validates_presence_of :confidence_type
  validates_presence_of :created_by
  # validates_presence_of :is_flagged
  validates_presence_of :relationship_id
  validates_presence_of :relationship_type

  # Scope
  # -----------------------------
  scope :not_flagged, where(is_flagged: false)

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
