class AdminController < ApplicationController
  before_action :is_logged_in, except: [:login, :login_check]
  before_action :set_shop, only: [:edit_store, :update_store]

  def index

  end

  def login
  end

  def login_check
    user = User.where(email: params[:email], password: params[:password]).first
    logger.debug user.inspect
    unless user.nil?
        session[:user_id] = user.id

        redirect_to url_for(:controller => 'admin', :action => 'index')
    end
  end

  def logout
    reset_session

    redirect_to url_for(:controller => 'admin', :action => 'index')
  end

  def shops
    @stores = Shop.all
  end

  def edit_store
  end

  def update_store
    @shop.update(step_params)

    redirect_to url_for(:controller => 'admin', :action => 'shops')
  end

  def delete_store
  end

  private
    def set_shop
      @shop = Shop.find params[:id]
    end

    def step_params
      params.require(:shop).permit(:payment_type)
    end

    def is_logged_in
        unless session[:user_id]
          redirect_to url_for(:controller => 'admin', :action => 'login')
        end
    end
end
