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
    item.calories <= cal_left * "1.#{@dailytarget.control_limit}".to_f && item.calories >= cal_left * (1 - "0.#{@dailytarget.control_limit}".to_f)
  end

  def proteins_in_target?(item)
    item.proteins <= proteins_left * "1.#{@dailytarget.control_limit}".to_f && item.proteins >= proteins_left * (1 - "0.#{@dailytarget.control_limit}".to_f)
  end

  def carbs_in_target?(item)
    item.carbs <= carbs_left * "1.#{@dailytarget.control_limit}".to_f && item.carbs >= carbs_left * (1 - "0.#{@dailytarget.control_limit}".to_f)
  end

  def fats_in_target?(item)
    item.fats <= fats_left * "1.#{@dailytarget.control_limit}".to_f && item.fats >= fats_left * (1 - "0.#{@dailytarget.control_limit}".to_f)
  end

  def cal_left
    orders = Order.where(user_id: current_user.id)
    @daily_target = DailyTarget.find_by(user_id: current_user.id)
    @cal_left = @daily_target.caloric_target
    orders.each do |order|
      order.order_items.each do |item|
        @cal_left -= Item.find_by_id(item.item_id).calories if item.consumed_at&.today?
      end
    end
    @cal_left
  end

  def proteins_left
    orders = Order.where(user_id: current_user.id)
    @daily_target = DailyTarget.find_by(user_id: current_user.id)
    @proteins_left = @daily_target.protein_target
    orders.each do |order|
      order.order_items.each do |item|
        if item.consumed_at&.day == Time.zone.now.day && item.consumed_at.month == Time.zone.now.month && item.consumed_at.year == Time.zone.now.year
          @proteins_left -= Item.find_by_id(item.item_id).proteins
        end
      end
    end
    @proteins_left
  end

  def carbs_left
    orders = Order.where(user_id: current_user.id)
    @daily_target = DailyTarget.find_by(user_id: current_user.id)
    @carbs_left = @daily_target.carb_target
    orders.each do |order|
      order.order_items.each do |item|
        if item.consumed_at&.day == Time.zone.now.day && item.consumed_at.month == Time.zone.now.month && item.consumed_at.year == Time.zone.now.year
          @carbs_left -= Item.find_by_id(item.item_id).carbs
        end
      end
    end
    @carbs_left
  end

  def fats_left
    orders = Order.where(user_id: current_user.id)
    @daily_target = DailyTarget.find_by(user_id: current_user.id)
    @fats_left = @daily_target.fat_target
    orders.each do |order|
      order.order_items.each do |item|
        if item.consumed_at&.day == Time.zone.now.day && item.consumed_at.month == Time.zone.now.month && item.consumed_at.year == Time.zone.now.year
          @fats_left -= Item.find_by_id(item.item_id).fats
        end
      end
    end
    @fats_left
  end
end
