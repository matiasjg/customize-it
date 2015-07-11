ShopifyApp.configure do |config|
  config.api_key = Rails.configuration.shopify_app_key
  config.secret = Rails.configuration.shopify_app_secret
  config.scope = "read_products"
  config.embedded_app = true
end
