$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'rspec'
require 'rspec/autorun'

require 'active_record'
require 'logger'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile =>  'gloo_test.sqlite3.db',
  :database => 'gloo'
)

TEST_DATABASE_FILE = File.join(File.dirname(__FILE__), 'gloo_test.sqlite3.db')

File.unlink(TEST_DATABASE_FILE) if File.exist?(TEST_DATABASE_FILE)
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3", "database" => TEST_DATABASE_FILE
)

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  load(File.dirname(__FILE__) + '/schema.rb')
end

class User < ActiveRecord::Base
  
end

class Comment < ActiveRecord::Base
  belongs_to :gloo_model
end