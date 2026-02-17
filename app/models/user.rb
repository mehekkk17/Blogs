# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :posts, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  normalizes :email, with: -> { _1.strip.downcase }
end
