case platform
  when "solaris2"
    default['users']['home_base'] = '/export/home'
    default['users']['shell'] = 'bash'
  else
    default['users']['home_base'] = '/home'
end

default['users']['clean'] = true
default['users']['token_group'] = "atalanta"
