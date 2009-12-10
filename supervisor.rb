require 'set'

class Supervisor
  attr_reader :replicas
  
  def initialize
    @replicas = Set.new
  end

  def add_replica(replica)
    @replicas.add(replica)
  end

  def remove_replica(replica)
    @replicas.remove(replica)
  end
end
