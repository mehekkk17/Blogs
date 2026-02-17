# frozen_string_literal: true

class AddVisibilityToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :visibility, :string, null: false, default: "public"
  end
end
