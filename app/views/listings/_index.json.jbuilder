json.listings_count @listings.respond_to?(:total_count) ? @listings.total_count : Listing.cached_count
json.total_pages @listings.respond_to?(:total_pages) ? @listings.total_pages : 40
json.current_page @listings.respond_to?(:current_page) ? @listings.current_page : params[:page].to_i

json.listings do
  json.partial! 'listings/listing.json.jbuilder', collection: @listings, as: :listing
end