# frozen_string_literal: true

module ApplicationHelper
  # Returns the Active Storage blob id for a remove checkbox (Attachment has blob_id, Blob has id, proxies have .blob).
  def blob_id_for_removal(img)
    return img.blob_id if img.respond_to?(:blob_id) && img.blob_id.present?
    return img.blob.id if img.respond_to?(:blob) && img.blob.present?
    img.id if img.respond_to?(:id)
  end

  def display_name(user)
    user.name.presence || user.email
  end

  def profile_initial(user)
    name = display_name(user)
    name[0].upcase
  end

  def options_for_sort
    [
      [ "Latest first", "latest" ],
      [ "Earliest first", "earliest" ]
    ]
  end
end
