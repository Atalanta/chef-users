#
# Cookbook Name:: users
# Recipe:: clean
#
# Copyright 2011, Atalanta Systems Ltd
#
# All rights reserved - Do Not Redistribute
#
# Recipe that cleans old users from system.

require "etc"

# Create token group if not exist

## Check that group is exist
tgroup = begin
  Etc.getgrnam("#{node[:users][:token_group]}")
rescue ArgumentError
  # Nothing to do.
end

## Create it if it's not exist
if tgroup == nil
  group "#{node[:users][:token_group]}" do
    action :create
  end
end

system_users = []
# Create array with system users
ruby_block "create_array_with_system_users" do
  block do
    Etc.passwd {|u|
      system_users << u.name
    }
  puts system_users
  end
end
# Add users from 'users' databag to token_group. if they're exist in system.

databag_users = []
search(:users, '*:*') do |u|
  # Check that user exist
  if system_users.include?(u['id'])
    # if user from 'users' databag exist - add it to token_group 
    group "#{node[:users][:token_group]}" do
      action :manage
      append true
      members u['id']
    end
  end
  # Create array of users in 'users' databag, We will need that array later
  databag_users << u[:id]
end

# Delete users that in token_group, but not in 'users' databag

## Create array of users in token group
token_group_users = []

tgroup = begin
  Etc.getgrnam("#{node[:users][:token_group]}")
rescue ArgumentError
  # Nothing to do.
end

if tgroup != nil
  token_group_users = tgroup.mem
end

## Create array of users for deletion
users_to_delete = token_group_users - databag_users

## Delete users

users_to_delete.each do |user_to_delete|
  user "#{user_to_delete}" do
    action :remove
  end
end
