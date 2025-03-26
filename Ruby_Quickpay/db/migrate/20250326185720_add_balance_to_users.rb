class AddBalanceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :balance, :decimal
    add_column :users, :default, :string
    add_column :users, :0.0, :string
  end
end
