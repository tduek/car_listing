module CLCarsParse
  
  def parse_new_listings
    @subdivisions = Subdivision.includes(:spellings, children: :spellings).all
    
    @make_spellings = @subdivisions.select { |sub| sub.level == 0 }.
                                       map { |make| make.spellings }.flatten
    
    @makes_spellings_rxp = /\b#{@make_spellings.map { |s| s.string }.join("|")}\b/i
    
    @all_models_spellings = @subdivisions.select { |sub| sub.level == 1 }.
                                          map { |modl| modl.spellings }.flatten
                                          
    @all_models_spellings_rxp = /\b#{@all_models_spellings.map { |s| s.string }.join("|")}\b/i
    
    Scraping.includes(:craigs_site, :thumbs, :main_pics).
             where(source: "Craigslist", 
                   parsed: false, 
                     dqed: false).
             find_each do |scraping|
      parse(scraping)
    end
  end
  
  private
  
  def parse(scraping)
    try_to_dq_text(scraping)
    
    unless scraping.dqed
      phone = parse_phone(scraping)
      year = parse_yr(scraping)
    end
    
    scraping.dqed = true unless phone && year
    
    unless scraping.dqed
      listing = Listing.new(scraping_id: scraping.id, 
                               is_owner: scraping.seller_type == "o",
                                  price: scraping.price,
                                   year: year,
                                  phone: phone,
                                    zip: scraping.craigs_site.zip)
      parse_make(scraping, listing)
    
      listing.make_id ? parse_mdl_w_make(scraping, listing) : parse_mdl_wo_make(scraping, listing)
      
      listing.save
      
      (scraping.thumbs << scraping.main_pics).each do |pic| 
        pic.listing_id = listing.id; pic.save
      end
    end
    
    scraping.parsed = true; scraping.save
  end
  
  def try_to_dq_text(scraping)
    dqers = ['rebuil', 'salvag', 'salvaj', 'rebil', 'ribil', 'flood', 
             'damage', 'repair', 'export', 'hit',
             # These are financed. Advertised price may be down payment.
             'over payment', 'take over', 'payments', 'dwn', 'down', 'credit', 
             'financ', 'approv', 'payment', 'take over', 'lease', 'pay here',
             # These are miscategorized.
             'golf cart', 'kawasaki', 'fourwheeler', 'atv', 
             'brute force', 'replica', 'yamaha', 'bike', 'rincon', 'triumph']
    
    dqers = dqers.join("|")
    
    if scraping.title[/#{dqers}/i] || scraping.description[/#{dqers}/i]
      scraping.dqed = true
    end  
  end
  
  def parse_phone(scraping)
    phone_regex = /((\d|cero|zero|one|uno|two|to|too|dos|three|tres|four|for|cuatro|five|cinco|six|seis|seven|siete|eight|ate|eit|ocho|nine|nueve)+(\W|_|\)){0,3}){10,11}/i               
    num = scraping.title[phone_regex] || scraping.description[phone_regex]
    
    if num
      [/cero|zero/i, /one|uno/i, /two|to|too|dos/i, 
       /three|tres/i, /four|for|cuatro/i, /five|cinco/i, 
       /six|seis/i, /seven|siete/i, /eight|ate|eit|ocho/i, 
       /nine|nueve/i].each_with_index { |rxp, i| num.gsub!(rxp, i.to_s) }
      num.gsub!(/\D+/, "")
    end
    
    num && (num.length == 10 || (num.length == 11 && num[0] == "1")) ? num.to_i : nil
  end
  
  # returns matched year in title or nil if no year or more than one
  def parse_yr(scraping)
    # yrs is titles mathes to 2 and 4 digit years 
    yrs = scraping.title.
            scan(/\b19|20\d{2}\b|\b0\d\b|\b1[0-#{Time.now.year-2010}]\b/).
            map { |yr| yr[0].to_i.between?(3, 9) ? 
                               yr.rjust(4, "19").to_i : yr.rjust(4, "20").to_i }
    # Check to make sure there's only one year in the title. 
    yrs[0] && yrs[0] > 1930 && yrs.uniq.length == 1 ? yrs[0] : nil
  end
  
  def parse_make(scraping, listing)
    matches = scraping.title.gsub(/_|-/, "").
                              scan(@makes_spellings_rxp).map { |m| m.downcase }
                              
    matches.map! { |m| @make_spellings.detect{ |s| s.string == m }.subdivision_id }
    
    listing.make_id = matches[0] if matches.uniq.length == 1
  end
  
  
  def parse_mdl_w_make(scraping, listing)
    # model_spellings are spelling models that have a string of the spelling
    models_spellings = @subdivisions.detect { |make| make.id == listing.make_id}.
                               children.map { |modl| modl.spellings }.flatten
    
    models_spellings_rxp = /\b#{models_spellings.map { |modl| modl.string }.join("|")}\b/i
    
    matches = scraping.title.gsub(/_|-/, "").
                              scan(models_spellings_rxp).map { |m| m.downcase }
    
    matches.map! { |m| models_spellings.detect{ |s| s.string == m }.subdivision_id }
    
    listing.model_id = matches[0] if matches.uniq.length == 1
  end
  
  
  def parse_mdl_wo_make(scraping, listing)
    
    matches = scraping.title.gsub(/_|-/, "").
                          scan(@all_models_spellings_rxp).map { |m| m.downcase }

    matches.map! { |m| @all_models_spellings.detect{ |s| s.string == m}.subdivision_id }
    
    if matches.uniq.length == 1
      listing.model_id = matches[0]
      listing.make_id = @subdivisions.detect{ |sub| sub.id == matches[0] }.parent_id
    end
  end
  
  
  def dq(scraping)
    scraping.dqed = true
    scraping.save
  end
end