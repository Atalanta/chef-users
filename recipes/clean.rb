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
if not node[:etc][:group].include?(node[:users][:token_group])
  group "#{node[:users][:token_group]}" do
    action :create
  end
end

# Add users from 'users' databag to token_group. if they're exist in system.

databag_users = []
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
  # Create array of users in 'users' databag,We will need that array later
  databag_users << u[:id]
end

# Delete users that in token_group, but not in 'users' databag

## Create array of users in token group
token_group_users = []
if node["etc"]["group"]["#{node[:users][:token_group]}"] != nil
  node["etc"]["group"]["#{node[:users][:token_group]}"]["members"].each { |member| token_group_users << member}
end

## Create array of users for deletion
users_to_delete = token_group_users - databag_users

## Delete users

users_to_delete.each do |user_to_delete|
  user "#{user_to_delete}" do
    action :remove
  end
end
