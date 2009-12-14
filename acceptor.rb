require 'rubygems'
require 'proposal'
require 'response'
require 'active_record'
require 'drb'

class Acceptor
  include DRbUndumped

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
    @propose_mutex.synchronize do
      @prepares_made += 1
      if proposal_number > @highest_prepare
        @highest_prepare = proposal_number

        @acceptor_row.highest_prepare = @highest_prepare
        @acceptor_row.save

        Response.new(@highest_accepted.number, self)
      end
    end
  end

  def request_accept(proposal)
    @propose_mutex.synchronize do
      if proposal.number >= @highest_prepare
        @highest_accepted = proposal

        @acceptor_row.highest_proposal = Marshal.dump(@highest_accepted)
        @acceptor_row.save

        @supervisor.replicas.each do |replica|
          replica.learner.report(proposal.value, self)
        end
      end
    end
  end

  class AcceptorRow < ActiveRecord::Base
    include DRbUndumped
  end
end
