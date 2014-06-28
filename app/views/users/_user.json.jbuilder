json.(user, :id, :location, :is_dealer)

if user == current_user
  json.(user,
    :fname, :lname, :company_name, :email, :phone,
    :address_line_1, :address_line_2, :city, :state, :zip,
    :is_activated, :is_dealer
  )

  json.activation_email_sent_at user.activation_email_sent_at.getutc.iso8601

elsif user.is_dealer?
  json.(user,
    :company_name,
    :address_line_1, :address_line_2, :city, :state, :zip
  )

elsif !user.is_dealer?
  json.(user, :fname)
end