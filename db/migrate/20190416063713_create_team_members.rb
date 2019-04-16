class CreateTeamMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :team_members do |t|
      t.text :name
      t.integer :assigned_group
      t.datetime :original_hire_date
      t.text :manager
      t.text :manager_squad
      t.text :division
      t.text :cost_center
      t.text :location
      t.text :gender

      t.timestamps
    end
  end
end
