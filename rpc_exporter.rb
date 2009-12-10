class RPCExporter
  attr_reader :paxos_replica

  def initialize
    @paxos_replica = PaxosReplica.new
  end

  def propose
  end

  def learn
  end
end
