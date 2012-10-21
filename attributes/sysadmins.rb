case platform
  when "solaris2"
    default['users']['home_base'] = '/export/home'
  else
    default['users']['home_base'] = '/home'
end
