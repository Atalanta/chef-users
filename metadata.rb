maintainer       "Atalanta Systems Ltd"
maintainer_email "support@atalanta-systems.com"
license          "All rights reserved"
description      "Installs/Configures users"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "2.0.5"

depends "tarsnap"

recipe "users", "Installs default profile"
recipe "users::sysadmins", "Create/configure sysadmins users from users databag"
recipe "users::sharing", "Create/configure usual users from users databag"
recipe "users::clean", "Clean out old users from host"

%w{ debian ubuntu centos redhat fedora solaris2}.each do |os|
  supports os
end
