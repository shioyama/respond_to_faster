source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in respond_to_faster.gemspec
gemspec

group :development, :test do
  if ENV['RAILS_VERSION'] == '5.0'
    gem 'activerecord', '>= 5.0', '< 5.1'
  elsif ENV['RAILS_VERSION'] == '4.2'
    gem 'activerecord', '>= 4.2.6', '< 5.0'
  elsif ENV['RAILS_VERSION'] == '5.1'
    gem 'activerecord', '>= 5.1', '< 5.2'
  else
    gem 'activerecord', '>= 5.2.0.beta2', '< 5.3'
    gem 'railties', '>= 5.2.0.beta2', '< 5.3'
  end

  gem 'benchmark-ips'
  gem 'sqlite3'
end
