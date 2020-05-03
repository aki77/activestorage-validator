source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in activestorage-validator.gemspec
gemspec

local_gemfile = "Gemfile.local"

if File.exist?(local_gemfile)
  eval_gemfile(local_gemfile) # rubocop:disable Security/Eval
else
  gem 'sqlite3'
end
