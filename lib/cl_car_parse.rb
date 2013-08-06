module CLCarsParse
  
  def parse_new_listings
    #@divisions = 
    Scraping.where(source: "Craigslist", 
                   parsed: false, 
                     dqed: false).find_each do |scraping|
      parse(scraping)
    end
  end
  
  private
  
  def parse(scraping)
    try_to_dq_text(scraping)
    listing = Listing.new(scraping_id: scraping.id, 
                                  is_owner: scraping.seller_type == "o")
    parse_phone_or_dq(scraping, listing) unless scraping.dqed
    parse_yr_or_dq(scraping, listing) unless scraping.dqed
    parse_make(scraping, listing) unless scraping.dqed
    
  end
  
  def try_to_dq_text(listing)
    dqers = ['rebuil', 'salvag', 'salvaj', 'rebil', 'ribil', 'flood', 
             'damage', 'repair', 'export', 'hit',
             # These are financed. Advertised price may be down payment.
             'over payment', 'take over', 'payments', 'dwn', 'down', 'credit', 
             'financ', 'approv', 'payment', 'take over', 'lease', 'pay here',
             # These are miscategorized.
             'golf cart', 'kawasaki', 'fourwheeler', 'atv', 
             'brute force', 'replica', 'yamaha', 'bike', 'rincon', 'triumph']
    
    dqers = dqers.join("|")
    
    if listing.title[/#{dqers}/i] || listing.description[/#{dqers}/i]
      listing.dqed = true
      listing.save
    end  
  end
  
  def parse_phone_or_dq(scraping, listing)
    phone_regex = /((\d|cero|zero|one|uno|two|to|too|dos|three|tres|four|for|cuatro|five|cinco|six|seis|seven|siete|eight|ate|eit|ocho|nine|nueve)+(\W|_|\)){0,3}){10,11}/i               
    match = scraping.title[phone_regex] || scraping.description[phone_regex]
    
    if match
      [/cero|zero/i, /one|uno/i, /two|to|too|dos/i, 
       /three|tres/i, /four|for|cuatro/i, /five|cinco/i, 
       /six|seis/i, /seven|siete/i, /eight|ate|eit|ocho/i, 
       /nine|nueve/i].each_with_index { |rxp, i| match.gsub!(rxp, i.to_s) }
      match.gsub!(/\D+/, "")
    end
    
    if match && (match.length == 10 || (match.length == 11 && match[0] == "1"))
      listing.phone = match.to_i
    else
      scraping.dqed = true
      scraping.save
    end
  end
  
  def parse_yr_or_dq(scraping, listing)
    yrs = scraping.title.
                  scan(/\b19|20\d{2}\b|\b0\d\b|\b1[0-#{Time.now.year-2010}]\b/).
                  map { |yr| yr.rjust(4, "20").to_i }
    
    if !yrs.empty? && yrs[0] > 1930 && yrs.inject(:+) % yrs[0] == 0
      listing.year = yrs[0]
    else
      scraping.dqed = true
      scraping.save
    end
  end
  
  def parse_make(scraping, listing)
    
  end
  
  
end