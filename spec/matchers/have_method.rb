require "rspec/expectations"

RSpec::Matchers.define :have_method do |expected|
  match do |actual|
    return false unless actual
    actual.methods.include?(expected)
  end
end
