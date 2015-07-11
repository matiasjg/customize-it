class Shop < ActiveRecord::Base
  include ShopifyApp::Shop

  #private => disable all the options to customize the steps
  #basic => normal setup of customized products
  TYPES = %w{ private basic }

  TYPES.each_with_index do |meth, index|
    define_method("#{meth}?") { type == index }
  end

  def self.store(session)
    unless shop = self.where(shopify_domain: session.url).first
        shop = self.new(shopify_domain: session.url, shopify_token: session.token)
        shop.save!
    end
    shop.id
  end

  def self.retrieve(id)
    if shop = self.where(id: id).first
      ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
    end
  end
end
