require 'proposal'
require 'response'
require 'active_record'

class Acceptor
  MIN_PROPOSAL_VALUE = 1

  attr_reader :highest_accepted, :highest_prepare, :prepares_made

  def initialize(supervisor)
    @supervisor = supervisor
    @propose_mutex = Mutex.new
    @highest_accepted = Proposal.new

    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => 'acceptors.sqlite3'
    )

    @acceptor_row = AcceptorRow.new

    @highest_prepare = MIN_PROPOSAL_VALUE - 1
    @prepares_made = 0
  end

  def prepare(proposal_number)
    puts 'blah'
    @propose_mutex.synchronize do
      puts "Received prepare request with proposal number #{proposal_number}"
      @prepares_made += 1
      puts 'hey'
      if @proposal_number > @highest_prepare
        @highest_prepare = @proposal_number

        puts 'wha'
        @acceptor_row.highest_prepare = @highest_prepare
        @acceptor_row.save
        puts 'ha'
        Response.new(@highest_accepted.number, self)
      end
    end
  end

  def request_accept(proposal)
    @propose_mutex.synchronize do
      if proposal.number >= @highest_prepare
        puts 'squid'

        @highest_accepted = proposal
        @acceptor_row.highest_proposal = Marshal.dump(@highest_accepted)
        @acceptor_row.save

        @supervisor.replicas.each do |replica|
          puts 'octopus'
          replica.learner.learn(proposal.value)
        end
      end
    end
  end

  class AcceptorRow < ActiveRecord::Base
  end
end
