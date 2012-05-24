#
# Cookbook Name:: users
# Recipe:: clean
#
# Copyright 2011, Atalanta Systems Ltd
#
# All rights reserved - Do Not Redistribute
#
# Recipe that cleans old users from system.

users = []

search(:users, '*') do |u|
  users << u['id']
end

# Create token group
group "#{node[:users][:token_group]}" do
  members users
  append true
end
