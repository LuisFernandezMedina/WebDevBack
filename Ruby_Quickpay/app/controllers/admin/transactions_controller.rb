class Admin::TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token

    before_action :authorize_admin
  
    def destroy
      transaction = Transaction.find(params[:id])
      transaction.destroy
      render json: { message: "Transaction cancelled" }
    end
end
  