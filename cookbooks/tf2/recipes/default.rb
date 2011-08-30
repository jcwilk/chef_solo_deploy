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

srcds_root = '/home/chuck/srcds'

#The below was adapted mostly from
#http://forums.srcds.com/viewtopic/5424
directory srcds_root do
  owner "chuck"
  group "chuck"
  mode "0755"
end

file File.join(srcds_root, 'install_steam.sh') do
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

execute "install tf2" do
  cwd srcds_root
  command './steam -command update -game tf -dir . -verify_all -retry'
  creates File.join(srcds_root,'orangebox/srcds_run')
  action :run
  user 'chuck'
end

#server.cfg originally from http://forums.srcds.com/viewtopic/5264
file File.join(srcds_root, 'orangebox/tf/cfg/server.cfg') do
  owner "chuck"
  mode "0644"
end

#The command is supposed to be something like the following, but I'm not seeing
#any file like that presently...
#nohup ./srcds_run -game tf +map ctf_2fort +maxplayers 12 -autoupdate &
#going to use an init script instead