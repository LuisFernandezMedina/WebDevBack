# app/controllers/group_requests_controller.rb
class GroupRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_request

  def create
    participants = params[:participants] # [{ id: 2, amount: 25 }, ...]
    total = params[:total_amount].to_f
    description = params[:description]

    if participants.blank?
      return render json: { error: "No se han especificado participantes" }, status: :unprocessable_entity
    end

    amounts = participants.map { |p| p[:amount].to_f }
    total_from_parts = amounts.sum.round(2)

    if total_from_parts.zero?
      # Si no se especifican montos individuales, dividir en partes iguales
      amount_per_person = (total / participants.size.to_f).round(2)
      participants.each { |p| p[:amount] = amount_per_person }
    elsif (total_from_parts - total).abs > 0.01
      return render json: { error: "La suma de las partes no coincide con el total" }, status: :unprocessable_entity
    end

    group_request = GroupRequest.create!(
      creator: @current_user,
      total_amount: total,
      description: description
    )

    participants.each do |p|
      GroupRequestParticipant.create!(
        group_request: group_request,
        participant_id: p[:id],
        amount: p[:amount],
        paid: false
      )
    end

    render json: { message: "Solicitud grupal creada", id: group_request.id }, status: :created
  end

  def pay
    group_request = GroupRequest.find(params[:id])
    participant = group_request.group_request_participants.find_by(participant_id: @current_user.id)

    if participant.nil?
      return render json: { error: "No estás incluido en esta solicitud" }, status: :unauthorized
    end

    if participant.paid
      return render json: { error: "Ya has pagado esta solicitud" }, status: :unprocessable_entity
    end

    if @current_user.balance < participant.amount
      return render json: { error: "Saldo insuficiente" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      @current_user.update!(balance: @current_user.balance - participant.amount)
      group_request.creator.update!(balance: group_request.creator.balance + participant.amount)

      Transaction.create!(
        sender_id: @current_user.id,
        receiver_id: group_request.creator.id,
        amount: participant.amount,
        date: Time.current
      )

      participant.update!(paid: true)
    end

    render json: { message: "Pago realizado correctamente" }, status: :ok
  end

  def status
    group_request = GroupRequest.includes(group_request_participants: :participant).find(params[:id])

    render json: {
      id: group_request.id,
      description: group_request.description,
      total: group_request.total_amount,
      paid: group_request.amount_paid,
      pending: group_request.total_amount - group_request.amount_paid,
      participants: group_request.group_request_participants.map do |p|
        {
          id: p.participant.id,
          name: p.participant.name,
          email: p.participant.email,
          amount: p.amount,
          paid: p.paid
        }
      end
    }
  end
end
