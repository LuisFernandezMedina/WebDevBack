class RequestsController < ApplicationController
    before_action :set_request, only: [:accept, :reject]
    skip_before_action :verify_authenticity_token
  
    # POST /requests
    def create
      request = Request.new(
        requester_id: params[:requester_id],
        recipient_id: params[:recipient_id],
        amount: params[:amount]
      )
  
      if request.save
        render json: { message: "Request creada correctamente", request: request }, status: :created
      else
        render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # GET /users/:user_id/requests
    def index
      user = User.find(params[:user_id])
      requests = user.received_requests.includes(:requester)
  
      render json: requests.map { |r|
        {
          id: r.id,
          requester_name: r.requester.name,
          amount: r.amount
        }
      }
    end
  
    # PATCH /requests/:id/accept
    def accept
      if @request.recipient.balance >= @request.amount
        ActiveRecord::Base.transaction do
          @request.recipient.update!(balance: @request.recipient.balance - @request.amount)
          @request.requester.update!(balance: @request.requester.balance + @request.amount)
  
          Transaction.create!(
            sender_id: @request.recipient_id,
            receiver_id: @request.requester_id,
            amount: @request.amount,
            date: Time.now
          )
  
          @request.destroy
        end
  
        render json: { message: "Request aceptada y transferencia realizada" }, status: :ok
      else
        render json: { error: "Fondos insuficientes" }, status: :unprocessable_entity
      end
    end
  
    # DELETE /requests/:id/reject
    def reject
      @request.destroy
      render json: { message: "Request rechazada y eliminada" }, status: :ok
    end
  
    private
  
    def set_request
      @request = Request.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Request no encontrada" }, status: :not_found
    end
  end
  