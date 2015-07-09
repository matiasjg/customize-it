require 'erb'

class ProxyController < ApplicationController
  before_action :set_shopify_session
  around_filter :shopify_session
  layout 'embedded_app'

  def index
    if params[:step_url]
        @step = Step.where(shop_id: session[:shopify], step_url: params[:step_url]).first
    else
        @step = Step.where(shop_id: session[:shopify]).order("id ASC").first
    end

    erb = ERB.new @step.html

    @resultHTML = erb.result(binding)

    render :layout => false, :content_type => 'application/liquid'
  end

  # preview image
  def show
    render :layout => false, :content_type => 'application/liquid'
  end


  def set_shopify_session
      if params[:shop]
        host = params[:shop]
        unless session[:shopify]
            shop = Shop.find_by shopify_domain: host
        end
      end

      session[:host] = host
      unless session[:shopify]
        session[:shopify] = shop.id
      end
    end
end
