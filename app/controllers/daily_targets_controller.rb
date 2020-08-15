class DailyTargetsController < ApplicationController
  before_action :set_daily_target, only: %i[edit update]

  def new
    @daily_target = DailyTarget.new
    authorize @daily_target
  end

  def create
    @daily_target = DailyTarget.new(daily_target_params)
    @daily_target.user = current_user
    authorize @daily_target

    if @daily_target.save
      redirect_to items_path
    else
      render :new
    end
  end

  def show
    @daily_target = current_user.daily_target
    authorize @daily_target
    cal_left(@daily_target)
    proteins_left(@daily_target)
    carbs_left(@daily_target)
    fats_left(@daily_target)
    consumed_today
  end

  def edit
    authorize @daily_target
  end

  def update
    @daily_target.update(daily_target_params)
    redirect_to items_path
    authorize @daily_target
  end

  private

  def set_daily_target
    @daily_target = DailyTarget.find(params[:id])
  end

  def daily_target_params
    params.require(:daily_target).permit(:caloric_target, :protein_target, :carb_target, :fat_target, :control_limit)
  end

  def cal_left(daily_target)
    orders = Order.where(user_id: current_user.id)
    @cal_left = daily_target.caloric_target
    orders.each do |order|
      order.order_items.each do |item|
        if item.consumed_at.day == Time.zone.now.day && item.consumed_at.month == Time.zone.now.month && item.consumed_at.year == Time.zone.now.year
          @cal_left -= Item.find_by_id(item.item_id).calories
        end
      end
    end
  end

  def proteins_left(daily_target)
    orders = Order.where(user_id: current_user.id)
    @proteins_left = daily_target.protein_target
    orders.each do |order|
      order.order_items.each do |item|
        if item.consumed_at.day == Time.zone.now.day && item.consumed_at.month == Time.zone.now.month && item.consumed_at.year == Time.zone.now.year
          @proteins_left -= Item.find_by_id(item.item_id).proteins
        end
      end
    end
  end

  def carbs_left(daily_target)
    orders = Order.where(user_id: current_user.id)
    @carbs_left = daily_target.carb_target
    orders.each do |order|
      order.order_items.each do |item|
        if item.consumed_at.day == Time.zone.now.day && item.consumed_at.month == Time.zone.now.month && item.consumed_at.year == Time.zone.now.year
          @carbs_left -= Item.find_by_id(item.item_id).carbs
        end
      end
    end
  end

  def fats_left(daily_target)
    orders = Order.where(user_id: current_user.id)
    @fats_left = daily_target.fat_target
    orders.each do |order|
      order.order_items.each do |item|
        if item.consumed_at.day == Time.zone.now.day && item.consumed_at.month == Time.zone.now.month && item.consumed_at.year == Time.zone.now.year
          @fats_left -= Item.find_by_id(item.item_id).fats
        end
      end
    end
  end

  def consumed_today
    @items_consumed_today = []
    Order.where(user_id:current_user.id).each do |order|
      order.order_items.each do |order_item|
        if order_item.consumed_at.day == Time.zone.now.day && order_item.consumed_at.month == Time.zone.now.month && order_item.consumed_at.year == Time.zone.now.year
          @items_consumed_today << Item.find_by_id(order_item.item_id)
        end
      end
    end
  end
end

#####
# Items_consumed_today deberia ser una coleccion de order_items y no de items.
