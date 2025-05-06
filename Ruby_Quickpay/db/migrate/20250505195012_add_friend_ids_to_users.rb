class AddFriendIdsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :friend_ids, :integer, array: true, default: []
  end
end

