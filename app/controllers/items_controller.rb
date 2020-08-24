class ItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  # pundit
  skip_after_action :verify_authorized, only: :set_items
  after_action :verify_policy_scoped, only: :set_items, unless: :skip_pundit?
  # after_action :verify_authorized, except: :index, unless: :skip_pundit?
  # after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  def index
    if current_user
      @dailytarget = DailyTarget.find_by(user_id: current_user.id)
      set_items
    else
      @items = policy_scope(Item).seller
    end

    @order_item = OrderItem.new
    @categories = Category.all
    @order = current_user&.pending_orders
  end

  # Para el tracking
  def new
    @item = Item.new
    authorize @item
  end

  # Para el tracking
  def create
    @item = Item.new(item_params)
    @item.seller_id = nil
    @item.origin = "user"
    authorize @item
    if @item.save
      item_order_and_order_items
      redirect_to daily_target_path(current_user.daily_target.id)
    else
      render :new
    end
  end

  # Para el tracking
  def edit
    @item = Item.find(params[:id])
    authorize @item
    @order_item = OrderItem.find_by(item_id: @item)
    authorize @order_item
  end

  # Para el tracking
  def update
    @item = Item.find(params[:id])
    @item.update(item_params)
    authorize @item
    @order_item = OrderItem.find_by(item_id: @item)
    @order_item.update(consumed_at: @item.order_items.last.consumed_at)
    redirect_to daily_target_path(current_user.daily_target.id)
  end

  private

  # Para el tracking
  def item_order_and_order_items
    o = Order.new(user_id: current_user.id, status: :finished)
    o.save
    @oi = OrderItem.new(item_id: @item.id, order_id: o.id, consumed_at: Time.zone.now)
    @oi.save
  end

  # Para el tracking
  def item_params
    params.require(:item).permit(
      :name,
      :calories,
      :proteins,
      :fats,
      :carbs,
      order_items_attributes: [:consumed_at, :id]
    )
  end

  def set_items
    @items = []
    policy_scope(Item).seller.each do |item|
      if calories_in_target?(item) && proteins_in_target?(item) && carbs_in_target?(item) && fats_in_target?(item)
        @items << item
      end
    end
  end

  def calories_in_target?(item)
    item.calories <= current_user.cal_left * current_user.daily_target_upper_limit && item.calories >= current_user.cal_left * current_user.daily_target_lower_limit
  end

  def proteins_in_target?(item)
    item.proteins <= current_user.proteins_left * current_user.daily_target_upper_limit && item.proteins >= current_user.proteins_left * current_user.daily_target_lower_limit
  end

  def carbs_in_target?(item)
    item.carbs <= current_user.carbs_left * current_user.daily_target_upper_limit && item.carbs >= current_user.carbs_left * current_user.daily_target_lower_limit
  end

  def fats_in_target?(item)
    item.fats <= current_user.fats_left * current_user.daily_target_upper_limit && item.fats >= current_user.fats_left * current_user.daily_target_lower_limit
  end
end
