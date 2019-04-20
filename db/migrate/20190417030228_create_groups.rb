class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.float :score

      t.timestamps
    end
  end
end
