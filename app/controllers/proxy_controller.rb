require 'erb'
require 'digest/md5'

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

    show_step = true;
    if @step.only_customer
        unless params[:u].nil? and params[:h].nil?
            customer = ShopifyAPI::Customer.find(params[:u])
            digest = Digest::MD5.hexdigest(customer.email)
            unless digest == params[:h]
                show_step = false;
            end
        else
            show_step = false;
        end
    end

    if @step.next_step_id
        @next_step = Step.find @step.next_step_id
    end

    @isLastStep = false
    if lastStep.id == @step.id
        @isLastStep = true
    end

    unless show_step
        redirect_to "/products/" + params[:handle]
    else
        # get the collection to fetch products of the step
        unless @step.is_custom?
            @resultHTML = false
            collection = ShopifyAPI::CustomCollection.find(@step.collection_id)
            @products = ShopifyAPI::Product.find(:all, :params => { :collection_id => collection.id })
        else
            erb = ERB.new @step.html
            @resultHTML = erb.result(binding)
        end

        render :layout => false, :content_type => 'application/liquid'
    end
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
