json.listingsCount @page_data[:total_count]
json.totalPages @page_data[:total_pages]
json.currentPage @page_data[:current_page]

json.listings do
  json.partial! 'listings/listings.json.jbuilder'
end