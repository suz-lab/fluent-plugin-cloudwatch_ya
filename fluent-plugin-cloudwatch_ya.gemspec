# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version       = "0.0.2"
  gem.name          = "fluent-plugin-cloudwatch_ya"
  gem.authors       = ["suz-lab"]
  gem.email         = "suzuki@suz-lab.com"
  gem.summary       = "Yet Another (Input/Output) Plugin for Amazon CloudWatch"
  gem.description   = "Yet Another (Input/Output) Plugin for Amazon CloudWatch"
  gem.homepage      = "http://suz-lab.github.com/fluent-plugin-cloudwatch_ya/"
  gem.licenses      = ["Apache License, Version 2.0"]
  gem.require_paths = ["lib"]
  gem.files = [
    "LICENSE.txt",
    "README.md",
    "lib/fluent/plugin/out_cloudwatch_ya.rb"
  ]
end

