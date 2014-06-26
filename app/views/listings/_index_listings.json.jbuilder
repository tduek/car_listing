json.listingsCount @listings.respond_to?(:total_count) ? @listings.total_count : Listing.cached_count
json.totalPages @listings.respond_to?(:total_pages) ? @listings.total_pages : 30
json.currentPage @listings.respond_to?(:current_page) ? @listings.current_page : params[:page].to_i

json.listings do
  json.partial! 'listings/listings.json.jbuilder'
end