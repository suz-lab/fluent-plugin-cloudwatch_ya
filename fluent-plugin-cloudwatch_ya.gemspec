# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version       = "0.0.1"
  gem.name          = "fluent-plugin-cloudwatch_ya"
  gem.authors       = ["suz-lab"]
  gem.email         = "suzuki@suz-lab.com"
  gem.description   = "Yet Another Plugin for Amazon CloudWatch"
  gem.summary       = "Yet Another Plugin for Amazon CloudWatch"
  gem.homepage      = "http://github.com/suz-lab/fluent-plugin-cloudwatch_ya"
  gem.licenses      = ["Apache License, Version 2.0"]
  gem.require_paths = ["lib"]
  gem.files = [
    "LICENSE.txt",
    "README.rdoc",
    "lib/fluent/plugin/out_cloudwatch_ya.rb"
  ]
end

