json.partial! 'api/listings/listing',
    collection: @listings.with_deal_ratio,
    as: :listing