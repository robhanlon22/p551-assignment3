# Add the current file's directory (i.e. p551-assignment3) to Ruby's
# internal 'require' load path.
$LOAD_PATH.unshift(File.dirname(__FILE__))

# Require all our paxos stuff
require 'paxos_role'
require 'proposer'
require 'acceptor'
require 'learner'
require 'supervisor'

class RPCExporter < PaxosRole
  attr_reader :proposer, :acceptor, :learner

  def initialize(supervisor)
    @proposer = Proposer.new(supervisor)
    @acceptor = Acceptor.new(supervisor) 
    @learner  = Learner.new(supervisor)
    supervisor.add_replica(self)
  end

  def propose(value)
    @proposer.propose(value)
  end

  def learn
    @learner.learn
  end

  protected :proposer, :acceptor, :learner
end
