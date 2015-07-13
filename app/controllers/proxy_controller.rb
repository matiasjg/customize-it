require 'erb'

class ProxyController < ApplicationController
  before_action :set_shopify_session
  around_filter :shopify_session
  layout 'embedded_app'

  def index
    lastStep = Step.where(shop_id: session[:shopify]).order("id DESC").first

    if params[:step_url]
        @step = Step.where(shop_id: session[:shopify], step_url: params[:step_url]).first
    else
        @step = Step.where(shop_id: session[:shopify]).order("id ASC").first
    end

    if @step.next_step_id
        @next_step = Step.find @step.next_step_id
    end
    logger.debug @next_step

    @isLastStep = false
    if lastStep.id == @step.id
        @isLastStep = true
    end

    # get the collection to fetch products of the step
    collection = ShopifyAPI::CustomCollection.find(@step.collection_id)
    @products = ShopifyAPI::Product.find(:all, :params => { :collection_id => collection.id })

    #erb = ERB.new @step.html
    #@resultHTML = erb.result(binding)

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
