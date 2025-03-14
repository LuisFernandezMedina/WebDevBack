require 'jwt'

class JsonWebToken
    SECRET_KEY = Rails.application.credentials.secret_key_base || 'your_fallback_secret_key'

    def self.encode(payload, exp = 1.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY)
    end

    def self.decode(token)
        body, = JWT.decode(token, SECRET_KEY)
        HashWithIndifferentAccess.new(body)
    rescue
        nil
    end
end
