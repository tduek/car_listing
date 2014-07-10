total_count = @listings.cheap_total_count
json.listingsCount total_count
json.totalPages total_count / 25
json.currentPage do
  if @listings.respond_to?(:current_page)
    @listings.current_page
  else
    params[:page] ? params[:page] : 1
  end
end

json.listings do
  json.partial! 'api/listings/listings'
end