json.id listing.id

json.(listing, :ymm, :miles, :vin, :transmission,
               :title, :description, :location, :price)

json.post_date listing.post_date_iso8601

json.is_favorite @favorite_listing_ids.include?(listing.id)

if listing.main_pic
  json.main_pic_url listing.main_pic.file.url
elsif !listing.pics.empty?
  json.main_pic_url listing.pics.first.file.url
else
  json.main_pic_url nil
end

json.pics listing.pics.map(&:file).map(&:url)

json.seller do
  json.by_owner listing.is_owner
  json.phone listing.phone
  json.location listing.location
end