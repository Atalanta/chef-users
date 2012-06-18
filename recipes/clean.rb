#
# Cookbook Name:: users
# Recipe:: clean
#
# Copyright 2011, Atalanta Systems Ltd
#
# All rights reserved - Do Not Redistribute
#
# Recipe that cleans old users from system.

# Create token group if not exist
group "#{node[:users][:token_group]}" do
  append true
  ignore_failure true
end

search(:users, '*:*') do |u|
  # Check that user exist
  u['id']
end
