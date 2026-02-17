# frozen_string_literal: true

class Post < ApplicationRecord
  VISIBILITIES = %w[ public private ].freeze

  belongs_to :user
  has_one_attached :image  # legacy single image (kept for existing data)
  has_many_attached :images

  validates :title, presence: true
  validates :body, presence: true
  validates :visibility, inclusion: { in: VISIBILITIES }

  scope :visible_for, ->(user) {
    if user
      where(visibility: "public").or(where(user_id: user.id))
    else
      where(visibility: "public")
    end
  }

  scope :search_by_keyword, ->(keyword) {
    return all if keyword.blank?
    sanitized = sanitize_sql_like(keyword.to_s.strip)
    return all if sanitized.blank?
    pattern = "%#{sanitized}%"
    where("title ILIKE :pattern OR body ILIKE :pattern", pattern: pattern)
  }

  def public?
    visibility == "public"
  end

  def private?
    visibility == "private"
  end

  # All images for display (new multiple + legacy single)
  def display_images
    if images.attached?
      images
    elsif image.attached?
      [ image ]
    else
      []
    end
  end
end

