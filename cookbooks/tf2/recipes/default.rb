# --- Set host name ---
# Note how this is plain Ruby code, so we can define variables to
# DRY up our code:
hostname = 'tf2.jcwilk.com'

file '/etc/hostname' do
  content "#{hostname}\n"
end

service 'hostname' do
  action :restart
end

file '/etc/hosts' do
  content "127.0.0.1 localhost #{hostname}\n"
end

#Required for hldsupdatetool.bin for some reason
package 'lib32gcc1'

#Required for the init script
package 'screen'

srcds_root = '/home/chuck/srcds'

#The below was adapted mostly from
#http://forums.srcds.com/viewtopic/5424
directory srcds_root do
  owner "chuck"
  group "chuck"
  mode "0755"
end

cookbook_file File.join(srcds_root, 'install_steam.sh') do
  owner 'chuck'
  mode '0644'
end

execute "install steam" do
  cwd srcds_root
  command './install_steam.sh'
  creates File.join(srcds_root,'steam')
  action :run
  user 'chuck'
end

#NOTE: Chances are very high that this will hang. If it does, you're best off sshing in and running the script
#yourself, killing it if it hangs, running it again, etc etc... It'll pick up where it left off.
execute "install tf2" do
  cwd srcds_root
  command './steam -command update -game tf -dir . -verify_all -retry'
  creates File.join(srcds_root,'orangebox/srcds_run')
  action :run
  user 'chuck'
end

#server.cfg originally from http://forums.srcds.com/viewtopic/5264
cookbook_file File.join(srcds_root, 'orangebox/tf/cfg/server.cfg') do
  owner "chuck"
  mode "0644"
end

cookbook_file '/etc/init.d/tf2_server' do
  owner "root"
  mode "0755"
end

execute 'start/restart tf2 server' do
  command '/etc/init.d/tf2_server restart'
  action :run
  user 'root'
end