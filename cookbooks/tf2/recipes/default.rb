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

directory srcds_root do
  owner "chuck"
  group "chuck"
  mode "0755"
end

script "install tf2" do
  interpreter "bash"
  user "chuck"
  cwd srcds_root
  not_if "test -d #{File.join(srcds_root,'organgebox/tf')}"
  code <<-EOH
  wget http://www.steampowered.com/download/hldsupdatetool.bin
  chmod +x hldsupdatetool.bin
  echo "yes" | ./hldsupdatetool.bin
  chmod +x steam
  ./steam
  ./steam -command update -game tf -dir . -verify_all
  EOH
end

#server.cfg originally from http://forums.srcds.com/viewtopic/5264
file File.join(srcds_root, 'orangebox/tf/cfg/server.cfg') do
  mode "644"
end

script "run tf2" do
  interpreter "bash"
  user "chuck"
  cwd File.join(srcds_root,'organgebox')
  not_if {system('test -n $(pidof ./srcds_run)')}
  code <<-EOH
  nohup ./srcds_run -game tf +map ctf_2fort +maxplayers 12 -autoupdate &
  EOH
end