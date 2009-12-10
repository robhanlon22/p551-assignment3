class PaxosReplica
  def initialize(supervisor)
    @proposer, @acceptor, @learner = Proposer.new, Acceptor.new, Learner.new
    supervisor.add_replica(self)
  end
end
