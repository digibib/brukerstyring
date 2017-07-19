root = ::File.dirname(__FILE__)
require ::File.join(root, 'app')

map "/brukerstyring" do
  run Brukerstyring.new
end