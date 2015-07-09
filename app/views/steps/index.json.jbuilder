json.array!(@steps) do |step|
  json.extract! step, :id, :name, :html, :shop_id
  json.url step_url(step, format: :json)
end
