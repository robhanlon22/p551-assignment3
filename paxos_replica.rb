class PaxosReplica
  def initialize
    @proposer, @acceptor, @learner = Proposer.new, Acceptor.new, Learner.new
  end
end
