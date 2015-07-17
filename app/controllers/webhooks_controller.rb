class WebhooksController < ApplicationController
  before_action :login_again_if_different_shop, :except => 'order_create'
  around_filter :shopify_session, :except => 'order_create'
  before_filter :verify_webhook, :except => ['verify_webhook', 'index', 'destroy', 'create']
  skip_before_filter :verify_authenticity_token, :only => 'order_create'

  layout 'embedded_app'

  def index
    @hooks = ShopifyAPI::Webhook.find(:all)
    logger.info @hooks.inspect
  end


  # POST /webhooks
  def create
    webhookCreated = ShopifyAPI::Webhook.find(:all,
        :params => {:address => Rails.configuration.shopify_domain_app+"webhooks/#"+params[:topic]}
    ).first
    logger.info webhookCreated.inspect
    unless webhookCreated
        logger.info "Creating webhook:" + Rails.configuration.shopify_domain_app+"webhooks/#{params[:topic]}?sid="+session[:shopify].to_s
        webhook = ShopifyAPI::Webhook.create(:format => "json", :topic => params[:topic],
            :address => Rails.configuration.shopify_domain_app+"/webhooks/#{params[:topic]}?sid="+session[:shopify].to_s
        )
        raise "Webhook invalid: #{webhook.errors}" unless webhook.valid?
    end

    redirect_to '/webhooks'
  end

  def destroy
    webhookCreated = ShopifyAPI::Webhook.find(params[:id])
    webhookCreated.destroy

    redirect_to '/webhooks'
  end

  def order_create
    data = ActiveSupport::JSON.decode(request.body.read)

    # we check duplicated calls of the webhooks for orders
    orderWebhook = WebhookCall.where(order_id: data['id']).first

    if orderWebhook.nil?
        set_shopify_session
        order = ShopifyAPI::Order.find(data['id'])

        unless order.nil?
          order.line_items.each do |line|
            product = ShopifyAPI::Product.find(line.product_id)
            unless product.nil?
                # get related subproduct count
                related_products_string = ShopifyAPI::Metafield.find(
                    :first,
                    :params=> {
                        :resource => "products",
                        :resource_id => product.id,
                        :namespace => "Customized",
                        :key => "product"
                    }
                ).value

                unless related_products_string.nil?
                    related_products = JSON.parse related_products_string
                    related_products.each do |rel_prod_data|
                        rel_product = ShopifyAPI::Product.find(rel_prod_data['id'])
                        unless rel_product.nil?
                            unless rel_prod_data['variant_id'].nil?
                                rel_product.variants.each do |variant|
                                    if variant.id == rel_prod_data['variant_id']
                                        variant.inventory_quantity -= rel_prod_data['count']
                                    end
                                end
                            else
                                rel_product.variants[0].inventory_quantity -= rel_prod_data['count']
                                rel_product.variants[0].save
                            end
                        end
                    end
                end
            end
          end
        end

        wh_call = WebhookCall.new(order_id: data['id'])
        wh_call.save
    end

    head :ok
  end

  private

    def verify_webhook
      data = request.body.read.to_s
      hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
      digest  = OpenSSL::Digest::Digest.new('sha256')
      calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, Rails.configuration.shopify_app_secret, data)).strip
      unless calculated_hmac == hmac_header
        head :unauthorized
      end
      request.body.rewind
    end

    def validate_payment_type
        logger.debug action_name
        unless action_name == "not_allowed"
            shop = Shop.find session[:shopify]
            logger.debug shop.private?.inspect
            if shop.private?
                redirect_to url_for(:controller => 'steps', :action => 'not_allowed')
            end
        end
    end

    def set_shopify_session
      if params[:sid]
        session = Shop.retrieve params[:sid]
        ShopifyAPI::Base.activate_session(session)
      end
    end

end
