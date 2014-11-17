class UpdateAttributesGroup < ActiveRecord::Migration
  def up
  	remove_column :groups, :is_approved
	add_column :groups, :justification, :text
	add_column :groups, :approved_by, :string
	add_column :groups, :approved_on, :string
  end

  def down
  end
end