json.(user, :id, :location)

if user == current_user
  json.(user,
    :fname, :lname, :email, :phone,
    :address_line_1, :address_line_2, :city, :state, :zip,
    :is_activated, :is_dealer
  )

  json.activation_email_sent_at user.activation_email_sent_at.getutc.iso8601
end