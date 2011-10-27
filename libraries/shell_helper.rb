def shell_for_platform(shell)
  basename = value_for_platform(
                                "solaris2" => { "default" => "/usr/bin" },
                                "freebsd" => { "default" => "/usr/local/bin" },
                                "default" => "/bin"
                                )
  Chef::Log.debug("basename: #{basename.inspect}")
  Chef::Log.debug("shell: #{shell}")
 ::File.join(basename, shell)
end
