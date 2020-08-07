class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders
  has_many :daily_targets
  has_one_attached :photo

  def pending_order
    orders.pending.order(created_at: :desc).first_or_create
  end
end
