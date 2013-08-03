module CraigslistCarScraper
  
  def start(seller_type = "o")

  end
  
  
  def start_scrape_at_first_paginated_page
    
  end
  
  
  def go_through_search_list_page(url)
    
  end
  
  
  def build_url(seller_type, page_num)
    url = URI.parse("http://city.craigslist.org/search/ct#{seller_type}/")
    years = "(#{(Time.now.year-10..Time.now.year).to_a.map { |yr| 
      [yr, (yr-2000).to_s.rjust(2, "0")] }.join("|")})"
    
    url.query = URI.encode_www_form({"query"    => years,
                                     "minAsk"   => 1000,
                                     "maxAsk"   => 500000,
                                     "srchType" => "T",
                                     "s"        => page_num * 100})
    url.to_s
  end
  
  
  
end