Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'  # Reemplázalo por la URL de tu frontend en producción
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
    end
  end
  