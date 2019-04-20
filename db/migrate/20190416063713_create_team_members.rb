class CreateTeamMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :team_members do |t|
      t.text :name
      t.integer :group_id
      t.float :years_at_github
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
