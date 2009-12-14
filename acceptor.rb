require 'rubygems'
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
      puts "Current highest prepare number so far: #{@highest_prepare}"
      @prepares_made += 1
      puts "hey: proposal_number (#{proposal_number}) > @highest_prepare (#{@highest_prepare}) = #{proposal_number > @highest_prepare}"
      if proposal_number > @highest_prepare
        @highest_prepare = proposal_number

        puts "WHA?! @highest_prepare is now: #{@highest_prepare}"
        begin
          @acceptor_row.highest_prepare = @highest_prepare
          @acceptor_row.save!
        rescue Exception => e
        end
        puts 'ha'
        return Response.new(@highest_accepted.number, self)
      end
      puts 'hotdogs'
    end
  end

  def request_accept(proposal)
    @propose_mutex.synchronize do
      if proposal.number >= @highest_prepare
        puts 'squid'

        @highest_accepted = proposal
        begin
          @acceptor_row.highest_proposal = Marshal.dump(@highest_accepted)
          @acceptor_row.save
        rescue Exception => e
        end

        @supervisor.replicas.each do |replica|
          puts 'octopus'
          replica.learner.report(proposal.value, self)
        end
      end
    end
  end

  class AcceptorRow < ActiveRecord::Base
  end
end
