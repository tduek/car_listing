json.id listing.id

json.(listing, :ymm, :miles, :vin, :transmission,
               :title, :description, :location, :price, :seller_id)

json.deal_ratio (listing.deal_ratio.to_f * 100).to_i if listing.respond_to?(:deal_ratio)

json.post_date listing.post_date_iso8601

json.is_favorite favorited_listing_ids.include?(listing.id)

if listing.main_pic
  json.main_pic_url listing.main_pic.as_json
elsif !listing.pics.empty?
  json.main_pic_url listing.pics.first.as_json
end

json.pics listing.pics.map(&:as_json)


json.seller do
  if listing.seller
    json.partial! 'users/user.json', user: listing.seller
  else
    json.is_dealer !listing.is_owner
    json.location listing.location
  end
end