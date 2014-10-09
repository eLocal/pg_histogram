require 'minitest/autorun'
require 'minitest/spec'
require 'logger'
require 'active_record'
require 'yaml'
require 'pg_histogram'

config = YAML.load(File.read('test/database.yml'))
ActiveRecord::Base.establish_connection config['test']
ActiveRecord::Base.logger = Logger.new 'tmp/test.log'
ActiveRecord::Base.logger.level = Logger::DEBUG
ActiveRecord::Migration.verbose = false


# Set up the database that we require
ActiveRecord::Schema.define do
  create_table :widgets, force: true do |t|
    t.float :price
    t.timestamps
  end
end



class Widget < ActiveRecord::Base
end

