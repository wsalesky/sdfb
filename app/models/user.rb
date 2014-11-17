class User < ActiveRecord::Base
  attr_accessible :about_description, :affiliation, :email, :first_name, :is_active, :last_name, :password,
  :password_confirmation, :user_type, :password_hash, :password_salt, :prefix, :orcid, :curator_revoked, :username, :created_at
  attr_accessor :password

  # Callbacks
  # -----------------------------
  before_save :encrypt_password

  # Relationships
  # -----------------------------
  has_many :comments
  has_many :flags
  has_many :user_group_contribs
  has_many :user_person_contribs
  has_many :user_rel_contribs
  has_many :people
  has_many :relationships
  has_many :groups
  has_many :group_assignments
  has_many :group_cat_assigns
  has_many :group_categories
  

  # Validations
  # -----------------------------
  validates_presence_of :first_name
  validates_presence_of :is_active
  validates_presence_of :last_name
  validates_presence_of :password_confirmation
  validates_presence_of :user_type
  validates_presence_of :prefix
  validates_presence_of :curator_revoked
  validates_presence_of :username
  validates_uniqueness_of :username
  # username must be at least 6 characters long
  validates_length_of :username, :minimum => 6, :if => :username_present?
  ## first_name must be at least 1 character
  validates_length_of :first_name, :minimum => 1, :if => :first_name_present?
  ## last_name must be at least 1 character
  validates_length_of :last_name, :minimum => 1, :if => :last_name_present?
  # password must be present and at least 4 characters long, with a confirmation
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :if => :password_present?

  # email must be present and be a valid email format
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^[\w]([^@\s,;]+)@(([a-z0-9.-]+\.)+(com|edu|org|net|gov|mil|biz|info))$/i

  # Scope
  # ----------------------------- 
  scope :active, where(is_active: true)
  scope :inactive, where(is_active: false)

  # Custom methods
  # -----------------------------
  def first_name_present?
    !first_name.nil?
  end

  def last_name_present?
    !last_name.nil?
  end

  def password_present?
    !password.nil?
  end

  def username_present?
    !username.nil?
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end
