require 'aruba/rspec'

if ENV['CFNDSL_COV']
  require 'simplecov'

  SimpleCov.start do
    add_group 'Code', 'lib'
    add_group 'Test', 'spec'
  end
end

require 'cfndsl'

bindir = File.expand_path('../../bin', __FILE__)
ENV['PATH'] = [ENV['PATH'], bindir].join(':')

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

def fixture_filename(filename)
  File.join(__dir__, 'fixtures', filename)
end

def read_json_fixture(filename)
  filename = fixture_filename(filename)
  JSON.parse(File.read(filename))
end

def save_data(data, where='/tmp/dump')
  File.open(where, 'w') do |f|
    f.write(data.to_json)
  end
end
