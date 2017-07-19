root = ::File.dirname(__FILE__)
require ::File.join(root, 'app')

run Rack::URLMap.new("/brukerstyring" => Brukerstyring.new)