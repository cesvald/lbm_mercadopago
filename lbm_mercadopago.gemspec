$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lbm_mercadopago/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lbm_mercadopago"
  s.version     = LbmMercadopago::VERSION
  s.authors     = ["Cesar Valderrama"]
  s.email       = ["valderramago@gmail.com"]
  s.homepage    = "https://github.com/cesvald/lbm_mercadopago"
  s.summary     = "Mercado integrated to little big money"
  s.description = "Mercado integrated to little big money"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"
  s.add_dependency "mercadopago-sdk"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
