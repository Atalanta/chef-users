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
group "#{node[:users][:token_group]}"

# Add users from 'users' databag to token_group. if they're exist in system.
search(:users, '*:*') do |u|
  # Check that user exist
  if node[:etc][:passwd].include?(u['id'])
    # if user from 'users' databag exist - add it to token_group 
    group "#{node[:users][:token_group]}" do
      action :manage
      append true
      members u['id']
    end
  end
end

# Delete users that in token_group, but not in 'users' databag.
