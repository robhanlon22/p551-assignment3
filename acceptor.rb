require 'proposal'
require 'response'

class Acceptor
  MIN_PROPOSAL_VALUE = 1

  attr_reader :highest_accepted, :highest_prepare, :prepares_made

  def initialize(supervisor)
    @supervisor = supervisor
    @propose_mutex = Mutex.new
    @highest_accepted = Proposal.new
    @highest_prepare = MIN_PROPOSAL_VALUE - 1
    @prepares_made = 0
  end

  def prepare(proposal_number)
    puts 'blah'
    @propose_mutex.synchronize do
      puts "Received prepare request with proposal number #{proposal_number}"
      @prepares_made += 1
      if @proposal_number > @highest_prepare
        @highest_prepare = @proposal_number
        Response.new(@highest_accepted.number, self)
      end
    end
  end

  def request_accept(proposal)
    @propose_mutex.synchronize do
      if proposal.number >= @highest_prepare
        puts 'squid'
        @highest_accepted = proposal
        @supervisor.replicas.each do |replica|
          puts 'octopus'
          replica.learner.learn(proposal.value)
        end
      end
    end
  end
end
