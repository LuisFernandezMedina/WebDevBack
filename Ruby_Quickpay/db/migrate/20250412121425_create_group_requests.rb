class CreateGroupRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :group_requests do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.float :total_amount
      t.string :description

      t.timestamps
    end
  end
end
