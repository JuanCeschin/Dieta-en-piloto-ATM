class ItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  # pundit
  skip_after_action :verify_authorized, only: :set_items
  after_action :verify_policy_scoped, only: :set_items, unless: :skip_pundit?
  # after_action :verify_authorized, except: :index, unless: :skip_pundit?
  # after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  def index
    if current_user
      @dailytarget = DailyTarget.where(user_id: current_user.id).last
      set_items
    else
      @items = policy_scope(Item)
    end

    @order_item = OrderItem.new
    @categories = Category.all
    @order = current_user&.pending_order
  end

  private

  def set_items
    @items = []
    policy_scope(Item).each do |item|
      if calories_in_target?(item) && proteins_in_target?(item) && carbs_in_target?(item) && fats_in_target?(item)
        @items << item
      end
    end
  end

  def calories_in_target?(item)
    item.calories <= current_user.cal_left * "1.#{@dailytarget.control_limit}".to_f && item.calories >= current_user.cal_left * (1 - "0.#{@dailytarget.control_limit}".to_f)
  end

  def proteins_in_target?(item)
    item.proteins <= current_user.proteins_left * "1.#{@dailytarget.control_limit}".to_f && item.proteins >= current_user.proteins_left * (1 - "0.#{@dailytarget.control_limit}".to_f)
  end

  def carbs_in_target?(item)
    item.carbs <= current_user.carbs_left * "1.#{@dailytarget.control_limit}".to_f && item.carbs >= current_user.carbs_left * (1 - "0.#{@dailytarget.control_limit}".to_f)
  end

  def fats_in_target?(item)
    item.fats <= current_user.fats_left * "1.#{@dailytarget.control_limit}".to_f && item.fats >= current_user.fats_left * (1 - "0.#{@dailytarget.control_limit}".to_f)
  end
end
