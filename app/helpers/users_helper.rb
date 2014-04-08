module UsersHelper

  # toggle boolean to string
  def toggle_bool val
    val ? 'Yes' : 'No'
  end

  # toggle menu status
  def toggle_active val, utype
    val == utype ? 'active' : ''
  end
end
