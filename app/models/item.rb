class Item < ApplicationRecord
  belongs_to :seller
  has_many :item_categories
  has_many :order_items
  has_many :categories, through: :item_categories
  enum origin: [:user, :seller, :database]

  def information
    { name: "seba" }.to_json
  end
end
