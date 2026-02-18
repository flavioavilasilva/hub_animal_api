class User < ApplicationRecord
  USER_TYPES = %w[ong visitor admin].freeze

  has_secure_password
  has_many :animals, foreign_key: :responsible_id, inverse_of: :responsible, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :user_type, presence: true, inclusion: { in: USER_TYPES }
  validates :address, presence: true
  validates :cpf, uniqueness: true, allow_nil: true
  validates :cnpj, uniqueness: true, allow_nil: true
  validate :address_must_be_object
  validate :cpf_or_cnpj_must_be_present
  validate :cpf_must_be_valid_if_present
  validate :cnpj_must_be_valid_if_present

  def as_json(options = {})
    super({ except: [:password_digest] }.merge(options || {}))
  end

  private

  def address_must_be_object
    errors.add(:address, "must be an object") unless address.is_a?(Hash)
  end

  def cpf_or_cnpj_must_be_present
    return if cpf.present? || cnpj.present?

    errors.add(:base, "cpf or cnpj must be provided")
  end

  def cpf_must_be_valid_if_present
    return if cpf.blank?

    errors.add(:cpf, "must contain 11 digits") unless digits_only(cpf).length == 11
  end

  def cnpj_must_be_valid_if_present
    return if cnpj.blank?

    errors.add(:cnpj, "must contain 14 digits") unless digits_only(cnpj).length == 14
  end

  def digits_only(value)
    value.gsub(/\D/, "")
  end
end
