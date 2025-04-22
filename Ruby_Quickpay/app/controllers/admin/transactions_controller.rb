class Admin::TransactionsController < ApplicationController
    before_action :authorize_admin
  
    def destroy
      transaction = Transaction.find(params[:id])
      transaction.destroy
      render json: { message: "Transaction cancelled" }
    end
end
  