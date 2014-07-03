json.partial! 'listings/listing.json.jbuilder',
    collection: @listings.with_deal_ratio,
    as: :listing