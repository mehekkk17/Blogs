# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "~> 7.2"
gem "pg", "~> 1.5"
gem "puma", "~> 6.4"
gem "bcrypt", "~> 3.1.7"

gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development do
  gem "web-console"
end

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end
