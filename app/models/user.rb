class User < ActiveRecord::Base
  attr_accessible :about_description, :affiliation, :email, :first_name, :is_active, :last_name, :password, :password_confirmation, :password_hash, :password_salt, :user_type

  attr_accessor :password

  # Relationships
  # -----------------------------
  has_many :user_group_contribs
  has_many :user_person_contribs
  has_many :user_rel_contribs
  has_many :people
  has_many :relationships
  has_many :groups
  has_many :group_assignments

  # Validations
  # -----------------------------
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :password_hash
  validates_presence_of :password_salt
  validates_presence_of :user_type
  validates_presence_of :affiliation
  validates_presence_of :is_admin
  validates_presence_of :is_active

  # password must be present and at least 4 characters long, with a confirmation
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :if => :password_present?

  # email must be present and be a valid email format
  validates_presence_of :email
  validates_format_of :email, :with => /^[\w]([^@\s,;]+)@(([a-z0-9.-]+\.)+(com|edu|org|net|gov|mil|biz|info))$/i

  # Custom methods
  # -----------------------------
  def password_present?
    !password.nil?
  end
end

end
