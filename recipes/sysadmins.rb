sysadmin_group = Array.new

search(:users, 'groups:sysadmin') do |u|
  sysadmin_group << u['id']
  
  home_dir = ::File.join(node['users']['home_base'], u['id'])
  Chef::Log.debug("Setting home directory to: #{home_dir}")
  
  group = platform?("solaris2") ? u['gid'] : u['id']

  shell = u.has_key?("shell") ? shell_for_platform(u["shell"]) : shell_for_platform(node["users"]["shell"])    
  
  # if u.has_key?("shell")
  #   if u["shell"].scan('/').count == 0
  #     shell = shell_for_platform(u["shell"])
  #   else
  #     shell = u["shell"]
  #   end
  # else

  Chef::Log.debug("Shell calculated to be #{shell}")                  

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
    if node['os'] != "linux"
      gid group 
    end
    shell shell
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
    group group
    mode "0700"
    recursive true
  end
  
  if platform?("solaris2")
    cookbook_file "#{home_dir}/.profile" do
      source "profile"
      owner u['id']
      group group
    end
  end
  
  cookbook_file "#{home_dir}/.screenrc" do
    source "screenrc"
    owner u['id']
    group group
  end
  
  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u['id']
    group group
    mode "0600"
    variables :ssh_keys => u['ssh_keys']
  end
end

group "sysadmin" do
  gid 2300
  members sysadmin_group
  append true
end

# If node[:users][:clean] attribute set to true - activate clean
# recipe, by default it's false.
if node[:users][:clean]
  include_recipe "users::clean"
end 
