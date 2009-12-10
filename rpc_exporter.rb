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
