require 'net/http'
require 'json'
require 'uri'

class EmailService
  def initialize
    @api_key = ENV['RESEND_API_KEY'].to_s.strip
    @url = URI("https://api.resend.com/emails")
  end

  def enviar_email(email, asunto, mensaje_html)
    request = Net::HTTP::Post.new(@url)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    request.body = {
        from: "onboarding@resend.dev",
        to: email,
      subject: asunto,
      html: mensaje_html
    }.to_json

    response = Net::HTTP.start(@url.hostname, @url.port, use_ssl: true) do |http|
      http.request(request)
    end

    puts "[DEBUG] Código de respuesta: #{response.code}"
    puts "[DEBUG] Respuesta: #{response.body}"

    raise "Error al enviar email" unless response.code.to_i < 400
  rescue => e
    Rails.logger.error("Error al enviar email: #{e.message}")
    raise e
  end
end
