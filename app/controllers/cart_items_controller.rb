class CartItemsController < ApplicationController
  before_action :find_cart_item, only: [:destroy, :update, :add_quantity, :remove_quantity]
  respond_to :js

  def destroy
    @cart = current_cart
    @cart_item = @cart.cart_items.find_by(product_id: params[:id])
    @product = @cart_item.product
    @cart_item.destroy
    @product.quantity += @cart_item.quantity
    @product.save
    # redirect_to :back
    # flash[:notice] = "成功将 #{@product.title} 从购物车删除！"
    respond_to do |format|
      format.js   { render :layout => false }
    end
  end
  def update
    if @cart_item.product.quantity >= cart_item_params[:quantity].to_i
    @cart_item.update(cart_item_params)
    flash[:notice] = "成功变更数量"
  else
    flash[:warning] = "数量不足已加入购物车"
  end
    redirect_to carts_path
  end
  def add_quantity
		if @cart_item.quantity < @cart_item.product.quantity
			@cart_item.quantity += 1
      @cart_item.product.quantity -=1
			@cart_item.save
      # redirect_to :back
      respond_to do |format|
        format.js   { render :layout => false }
      end
		elsif @cart_item.quantity == @cart_item.product.quantity
			redirect_to carts_path, alert: "库存不足！"
		end
	end

	def remove_quantity
		if @cart_item.quantity > 0
			@cart_item.quantity -= 1
      @cart_item.product.quantity +=1
			@cart_item.save
      # redirect_to :back
			respond_to do |format|
        format.js   { render :layout => false }
      end
		elsif @cart_item.quantity == 0
			redirect_to carts_path, alert: "商品不能少于零！"
		end
	end

  private

  def find_cart_item
    @cart = current_cart
    @cart_item = @cart.cart_items.find_by(product_id: params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end
