class User < ActiveRecord::Base
  attr_accessible :address_line_1, :address_line_2, :city, :email, :fname, :lname, :phone, :zip
end
