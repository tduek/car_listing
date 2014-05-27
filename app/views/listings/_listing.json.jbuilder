json.id listing.id

json.ymm listing.ymm
json.miles listing.miles
json.vin listing.vin
json.transmission listing.transmission

json.title listing.title
json.description listing.description
json.location listing.location

json.post_date listing.post_date_iso8601
json.price listing.price

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