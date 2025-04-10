class RequestsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_request 

  def create
    request = Request.new(request_params)
    if request.save
      render json: request, status: :created
    else
      render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
    end
  end
   # GET /users/:user_id/requests
   def index
    user = User.find(params[:user_id])
  
    sent = user.sent_requests.select(:id, :recipient_id, :amount, :created_at)
    received = user.received_requests.select(:id, :requester_id, :amount, :created_at)
  
    render json: {
      sent_requests: sent,
      received_requests: received
    }
  end
  def accept
    request = Request.find(params[:id])

    unless request.recipient_id == @current_user.id
      return render json: { error: "No autorizado" }, status: :unauthorized
    end

    if @current_user.balance < request.amount
      return render json: { error: "Saldo insuficiente" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      @current_user.update!(balance: @current_user.balance - request.amount)
      request.requester.update!(balance: request.requester.balance + request.amount)

      Transaction.create!(
        sender_id: @current_user.id,
        receiver_id: request.requester.id,
        amount: request.amount,
        date: Time.current
      )

      request.destroy!
    end

    render json: { message: "Solicitud aceptada y dinero enviado" }, status: :ok
  end

  # ❌ Rechazar una solicitud
  def reject
    request = Request.find(params[:id])

    unless request.recipient_id == @current_user.id
      return render json: { error: "No autorizado" }, status: :unauthorized
    end

    request.destroy!
    render json: { message: "Solicitud rechazada" }, status: :ok
  end

  private

  def request_params
    params.permit(:requester_id, :recipient_id, :amount)
  end

  
  private
  
  def request_params
    params.permit(:requester_id, :recipient_id, :amount)
  end

 
end
