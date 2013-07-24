include_recipe 'apt'

directory node[:golang][:gopath] do
  recursive true
  mode 0755
  owner 'root'
end

godeb_tarball = 'godeb-amd64.tar.gz'

remote_file "/usr/local/src/#{godeb_tarball}" do
  source "https://godeb.s3.amazonaws.com/#{godeb_tarball}"
  checksum '2ad1e8dc952bfee9625799304097e597'
  not_if "test -f /usr/local/src/#{godeb_tarball}"
  retries 3
end

bash 'unpack godeb and install' do
  cwd '/usr/local/src'
  code "tar xvzf #{godeb_tarball} && mv ./godeb /usr/local/bin"
end

bash 'install golang' do
  cwd '/usr/local/bin'
  code './godeb install'
end

template "/home/#{node[:golang][:user]}/.gitconfig" do
  source 'gitconfig.erb'
  mode 0644
  owner node[:golang][:user]
end

%w(src pkg bin).each do |dir|
  directory "#{node[:golang][:gopath]}/#{dir}" do
    mode 0755
    owner node[:golang][:user]
  end
end

template '/etc/profile.d/GOPATH.sh' do
  source 'GOPATH.sh.erb'
  owner 'root'
  mode 0644
end
