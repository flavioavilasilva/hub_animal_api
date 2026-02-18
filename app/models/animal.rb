class Animal < ApplicationRecord
  SIZES = %w[small medium large].freeze

  belongs_to :responsible, class_name: "User"
  has_one_attached :avatar

  validates :name, presence: true
  validates :size, presence: true, inclusion: { in: SIZES }
  validates :tags, presence: true
  validate :tags_must_be_array
  validate :avatar_must_be_image

  def as_json(options = {})
    super({ include: { responsible: { only: [:id, :name, :email, :user_type] } } }.merge(options || {}))
  end

  private

  def tags_must_be_array
    errors.add(:tags, "must be an array") unless tags.is_a?(Array)
  end

  def avatar_must_be_image
    return unless avatar.attached?
    return if avatar.blob.content_type.start_with?("image/")

    errors.add(:avatar, "must be an image")
  end
end
