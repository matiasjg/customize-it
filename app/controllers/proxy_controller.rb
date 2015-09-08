require 'erb'
require 'digest/md5'

class ProxyController < ApplicationController
  before_action :set_shopify_session
  around_filter :shopify_session
  layout 'embedded_app'

  def index
    @lastStep  = Step.where(shop_id: session[:shopify]).order("id DESC").first
    @allSteps = Step.where(shop_id: session[:shopify]).order("id ASC")
    firstStep = Step.where(shop_id: session[:shopify]).order("id ASC").first

    if params[:step_url]
        @step = Step.where(shop_id: session[:shopify], step_url: params[:step_url]).first
    else
        @step = firstStep
    end

    @actualStepNumber = 1
    previousStepId    = firstStep.id;
    @allSteps.each do |stepListItem|
        if stepListItem.id != @step.id
            @actualStepNumber += 1
            if @actualStepNumber > 2
                previousStepId = stepListItem.id;
            end
        else
            break
        end
    end

    if previousStepId == firstStep.id
        @previousStep = firstStep
    elsif previousStepId == @lastStep.id
        @previousStep = @lastStep
    else
        @previousStep = Step.find previousStepId
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
    if @lastStep.id == @step.id
        @isLastStep = true
    end

    @isFirstStep = false
    if firstStep.id == @step.id
        @isFirstStep = true
    end

    unless show_step
        redirect_to "/products/" + params[:handle]
    else
        # get the collection to fetch products of the step
        unless @step.is_custom?
            @resultHTML = false
            if @step.collection_id != ''
                collection = ShopifyAPI::CustomCollection.find(@step.collection_id)
                @products = ShopifyAPI::Product.find(:all, :params => { :collection_id => collection.id })

                url_found_in_handle = ''
                unless params[:gtl].nil?
                    @products.each do |prod|
                        if prod.handle.in? params[:handle]
                            if prod.handle.length > url_found_in_handle.length
                                url_found_in_handle = prod.handle
                            end
                        end
                    end
                    params[:handle][url_found_in_handle] = ''
                end
            end
        else
            erb = ERB.new @step.html
            @resultHTML = erb.result(binding)
        end

        unless File.exists?(Rails.root.join("app", "views", params[:controller], session[:host]+".html.erb"))
            render :layout => false, :content_type => 'application/liquid'
        else
            render :template => "proxy/"+session[:host]+".html.erb" ,:layout => false, :content_type => 'application/liquid'
        end
    end
  end

  #for ajax usage
  def get_setp_info
    @step = Step.where(shop_id: session[:shopify], id: params[:step_id]).first
    render :text => @step.inspect
    if @step.collection_id != ''
        collection = ShopifyAPI::CustomCollection.find(@step.collection_id)
        @products = ShopifyAPI::Product.find(:all, :params => { :collection_id => collection.id })
    end

    render :template => "proxy/steps/"+@step.step_url+".html.erb" ,:layout => false, :content_type => 'application/liquid'
  end

  # preview complete product
  def get_product_info
    product = ShopifyAPI::Product.find(:all, :params => { :handle => params[:handle] }).first
  end

  # preview image
  def show
    @size = 'medium'
    logger.debug params[:size].inspect
    unless params[:size].nil?
        @size = params[:size]
    end
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
