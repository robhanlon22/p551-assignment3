require 'set'

class Supervisor
  attr_reader :replicas
  
  def initialize
    @next_id = 1
    @replicas = Set.new
    @id_map = {}
  end

  def add_replica(replica, id=@next_id)
    if @replicas.add?(replica)
      @id_map[id.to_s] = replica
      @next_id += 1
    end
  end

  def remove_replica(replica)
    if @replicas.delete?(replica)
      @id_map.each do |k,v|
        if v == replica
          @id_map.delete(k)
          break
        end
      end
    end
  end
  
  def replica_by_id(id)
    @id_map[id]
  end
  
  def [](id)
    replica_by_id(id)
  end
  
  def replicas_by_id(&block)
    @id_map.each(&block)
  end
end
