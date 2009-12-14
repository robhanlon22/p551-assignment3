require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
                                        :database => 'acceptors.sqlite3')

class CreateAcceptorTable < ActiveRecord::Migration
  def self.up
    create_table :acceptor_rows do |t|
      t.integer :highest_prepare
      t.text :highest_proposal
    end
  end

  def self.down
    drop_table :acceptor_rows
  end
end

begin
  CreateAcceptorTable.up
rescue ActiveRecord::StatementInvalid
  puts "Table already exists."
end
