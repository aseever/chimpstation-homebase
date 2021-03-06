include_recipe "chimpstation_base::homebrew"
include_recipe "chimpstation_base::ack"
include_recipe "chimpstation_base::git"
include_recipe "chimpstation_base::rvm"

execute "brew install macvim with system ruby" do
  user $ws_user
  command "rvm use system && brew install macvim"
  not_if "brew list | grep '^macvim$'"
end

# There may be multiple macvims; try to find the latest one
# & link that to /Applications
ruby_block "Link MacVim to /Applications" do
  block do
    macvim_app=Dir["/usr/local/Cellar/macvim/*/MacVim.app"].last
    raise "no macvim found" unless macvim_app
    if File.exists?(macvim_app)
      system("ln -s #{macvim_app} /Applications/")
    end
  end
end

git "#{node["vim_home"]}" do
  repository "git://github.com/pivotal/vim-config.git"
  branch "master"
  revision node["vim_hash"] || "HEAD"
  action :checkout
  user $ws_user
  enable_submodules true
end

link "#{$ws_home}/.vimrc" do
  to "#{node["vim_home"]}/vimrc"
  owner $ws_user
end

brew_install "ctags"

execute "compile command-t" do
  not_if "test -f #{node["vim_home"]}/bundle/command-t/ruby/command-t/compiled"
  cwd "#{node["vim_home"]}/bundle/command-t/ruby/command-t"
  command "rvm use system && ruby extconf.rb && make && touch compiled"
  user $ws_user
end

ruby_block "test to see if MacVim link worked" do
  block do
    raise "/Applications/MacVim install failed" unless File.exists?("/Applications/MacVim.app")
  end
end

bash_profile_include("vi_is_minimal_vim")
