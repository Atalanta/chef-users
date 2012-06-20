#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright 2011, Atalanta Systems Ltd
#
# All rights reserved - Do Not Redistribute
#

# Adding profile and screenrc files for root user

if platform?("solaris2")
  cookbook_file "/root/.profile" do
    source "profile"
    owner "root"
    group "root"
    mode "0644"
  end
end

# If node[:users][:clean] attribute set to true - activate clean recipe.
if node[:users][:clean]
  include_recipe "users::clean"
end 
