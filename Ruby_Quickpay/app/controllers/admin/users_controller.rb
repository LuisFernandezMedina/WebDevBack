class Admin::UsersController < ApplicationController
    before_action :authorize_admin
  
    def index
      users = User.all
      render json: users
    end
  
    def update
      user = User.find(params[:id])
      if user.update(user_params)
        render json: user
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def destroy
      user = User.find(params[:id])
      user.destroy
      render json: { message: "User deleted successfully" }
    end
  
    def modify_balance
      user = User.find(params[:id])
      new_balance = params[:balance]
      if user.update(balance: new_balance)
        render json: { message: "Balance updated" }
      else
        render json: { error: "Failed to update balance" }, status: :unprocessable_entity
      end
    end
  
    private
  
    def user_params
      params.permit(:name, :email, :role)
    end
end  
