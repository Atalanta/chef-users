sharing_user = node['users']['sharing_user']
home_dir = ::File.join(node['users']['base_home'], sharing_user)

ruby_block "reset group list" do
  block do
    Etc.endgrent
  end
  action :nothing
end

execute "unlock-#{sharing_user}" do
  command "passwd -d #{sharing_user}"
  action :nothing
end

user "#{sharing_user}" do
  gid "#{sharing_user}"
  shell node['users']['sharing_shell']
  comment node['users']['sharing_comment']
  supports :manage_home => true
  home home_dir
  notifies :create, "ruby_block[reset group list]", :immediately
  if platform?("solaris2")
    notifies :run, "execute[unlock-atalanta]", :immediately
  end
end

directory "#{home_dir}/.ssh" do
  owner sharing_user
  group sharing_user
  mode "0700"
end

cookbook_file "#{home_dir}/.ssh/authorized_keys" do
  source "authorized_keys"
  owner sharing_user
  group sharing_user
  mode "0600"
end

node['users']['sharing_tools'].each do |tool|
  if tool == 'git' and platform?('ubuntu')
    package 'git-core'
  else
    package tool
  end
end

cookbook_file "#{home_dir}/.screenrc" do
  source "screenrc"
  owner sharing_user
  group sharing_user
end

if platform?("solaris2")
  cookbook_file "#{home_dir}/.profile" do
    source "profile"
    owner sharing_user
    group sharing_user
  end
end
