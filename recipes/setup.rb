
directory "/var/lib/rhodecode" do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  mode "0750"
  action :create
end

# Create rhodecode log directory. The log displays the database password in
# clear text which is why the permissions for the directory are set to 0750.
directory "/var/log/rhodecode" do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  mode "0750"
  action :create
end

# Create the repository base directory.
directory node['rhodecode']['repo']['path'] do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  mode  "0750"
  action :create
end

for num in 1..node['rhodecode']['instance']['count']
  template "/var/lib/rhodecode/production#{num}.ini" do
    source 'deployment.ini.erb'
    owner node['rhodecode']['system']['user']
    group node['rhodecode']['system']['group']
    mode 0640
    backup 1
    variables({
      :port_num => node['rhodecode']['port'] + (num - 1),
      :instance_num => num
    })
  end
end

# *THIS WORKAROUND IS POTENTIALLY DESTRUCTIVE*
# Workaround a bug in non-interactive setup-rhodecode in which the script always
# prompts to destroy the current db. This has been resolved for the upcoming 1.4
# release.
# https://bitbucket.org/marcinkuzminski/rhodecode/issue/507
# **  BEGIN WORKAROUND **
#execute "setup-rhodecode" do
#  user node['rhodecode']['system']['user']
#  group node['rhodecode']['system']['group']
#  command "yes | #{::File.join(node['rhodecode']['virtualenv']['path'], 'bin', 'paster')} setup-rhodecode /var/lib/rhodecode/production.ini -q --user=#{node['rhodecode']['admin']['user']} --password='#{node['rhodecode']['admin']['passwd']}' --email=#{node['rhodecode']['admin']['email']} --repos=#{node['rhodecode']['repo']['path']} && touch /var/lib/rhodecode/configured_by_chef"
#  # Do not re-run the setup-rhodecode PasteScript if it has successfully completed.
#  creates "/var/lib/rhodecode/configured_by_chef"
#  action :run
#end
## ** END WORKAROUND **

#execute "make-rcext" do
#  user node['rhodecode']['system']['user']
#  group node['rhodecode']['system']['group']
#  command "#{::File.join(node['rhodecode']['virtualenv']['path'], 'bin', 'paster')} make-rcext /var/lib/rhodecode/production.ini"
#  creates "/var/lib/rhodecode/rcextensions/__init__.py"
#  action :run
#end
