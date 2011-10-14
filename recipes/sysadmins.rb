sysadmin_group = Array.new

search(:users, 'groups:sysadmin') do |u|
  sysadmin_group << u['id']

  home_dir = node['users']['home_base']

  # fixes CHEF-1699
  ruby_block "reset group list" do
    block do
      Etc.endgrent
    end
    action :nothing
  end

  execute "unlock-#{u['id']}" do
    command "passwd -d #{u['id']}"
    action :nothing
  end

  
  user u['id'] do
    uid u['uid']
    gid u['gid']
    shell u['shell']
    comment u['comment']
    supports :manage_home => true
    home home_dir
    notifies :create, "ruby_block[reset group list]", :immediately
    if platform?("solaris2")
      notifies :run, "execute[unlock-#{u['id']}]", :immediately
    end
  end

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group u['gid'] || u['id']
    mode "0700"
  end

  if platform?("solaris2")
    cookbook_file "#{home_dir}/.profile" do
      source "profile"
      owner u['id']
      group u['gid'] || u['id']
    end
  end

  cookbook_file "#{home_dir}/.screenrc" do
    source "screenrc"
    owner u['id']
    group u['gid'] || u['id']
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u['id']
    group u['gid'] || u['id']
    mode "0600"
    variables :ssh_keys => u['ssh_keys']
  end
end

group "sysadmin" do
  gid 2300
  members sysadmin_group
  append true
end
