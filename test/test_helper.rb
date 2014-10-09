# -*- encoding: utf-8 -*-

require 'minitest/spec'
require 'minitest/autorun'
require 'logger'
require 'active_record'
require 'factory_girl'
require 'yaml'

config = YAML.load(File.read('test/database.yml'))
ActiveRecord::Base.establish_connection config['test']
ActiveRecord::Base.logger = Logger.new 'tmp/test.log'
ActiveRecord::Base.logger.level = Logger::DEBUG
ActiveRecord::Migration.verbose = false

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end


FactoryGirl.find_definitions
