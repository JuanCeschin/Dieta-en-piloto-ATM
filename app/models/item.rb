class Item < ApplicationRecord
  belongs_to :seller, optional: true
  has_many :item_categories
  has_many :order_items
  has_many :categories, through: :item_categories
  enum origin: %i[user seller database]

  has_one_attached :picture
  # Nested form
  accepts_nested_attributes_for :order_items
  validates_associated :order_items
end
