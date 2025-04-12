class CreateGroupRequestParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :group_request_participants do |t|
      t.references :group_request, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, null: false
      t.boolean :paid, null: false, default: false

      t.timestamps
    end
  end
end
