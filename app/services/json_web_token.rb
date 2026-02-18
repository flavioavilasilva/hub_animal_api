class JsonWebToken
  ALGORITHM = "HS256".freeze

  def self.encode(payload = nil, exp: 24.hours.from_now, **claims)
    payload = payload&.dup || {}
    payload.merge!(claims) if claims.present?
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode(token)
    body = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })[0]
    body.with_indifferent_access
  end

  def self.secret_key
    Rails.application.secret_key_base
  end

  private_class_method :secret_key
end
