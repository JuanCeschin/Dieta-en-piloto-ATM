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

  def edit
    authorize @daily_target
    cal_left
    proteins_left
    carbs_left
    fats_left
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

  def cal_left
    orders = Order.where(user_id:current_user.id)
    @daily_target = DailyTarget.find(params[:id])
    @cal_left = @daily_target.caloric_target
    orders.each do |order|
      order.order_items.each do |item|
        @cal_left -= Item.find_by_id(item.item_id).calories
      end
    end
  end

  def proteins_left
    orders = Order.where(user_id:current_user.id)
    @daily_target = DailyTarget.find(params[:id])
    @proteins_left = @daily_target.protein_target
    orders.each do |order|
      order.order_items.each do |item|
        @proteins_left -= Item.find_by_id(item.item_id).proteins
      end
    end
  end

  def carbs_left
    orders = Order.where(user_id:current_user.id)
    @daily_target = DailyTarget.find(params[:id])
    @carbs_left = @daily_target.carb_target
    orders.each do |order|
      order.order_items.each do |item|
        @carbs_left -= Item.find_by_id(item.item_id).carbs
      end
    end
  end

  def fats_left
    orders = Order.where(user_id:current_user.id)
    @daily_target = DailyTarget.find(params[:id])
    @fats_left = @daily_target.fat_target
    orders.each do |order|
      order.order_items.each do |item|
        @fats_left -= Item.find_by_id(item.item_id).fats
      end
    end
  end
end
