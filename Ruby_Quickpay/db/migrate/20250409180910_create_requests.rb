class CreateRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :requests do |t|
      t.integer :requester_id
      t.integer :recipient_id
      t.decimal :amount

      t.timestamps
    end
  end
end
