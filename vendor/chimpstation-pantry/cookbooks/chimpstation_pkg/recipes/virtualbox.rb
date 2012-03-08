include_recipe  'dmg'

dmg_package "virtualbox" do
  type          "mpkg"
  package_id    "org.virtualbox.pkg.virtualbox"
  source        node[:chimpstation_pkg][:virtualbox][:release_url]
  checksum      node[:chimpstation_pkg][:virtualbox][:checksum]
  action        :install
end
