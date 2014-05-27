json.array! @makes do |make|
  json.(make, :id, :name)
  json.children do
    json.array! make.active_models do |model|
      json.(model, :id, :name, :parent_id)
    end
  end
end