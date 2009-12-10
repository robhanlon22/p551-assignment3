class Learner < PaxosRole
  DONT_KNOW = nil

  def initialize(supervisor)
    @supervisor = supervisor
    @mutex_me = Mutex.new
    @learned = {}
    @learned_value = DONT_KNOW
  end

  def learn
    @mutex_me.synchronize { @learned_value }
  end

  def report(value, acceptor)
    # TODO hashcode
    @mutex_me.synchronize do
      @learned[acceptor] = value
      @learned.inject(Hash.new(0)) do |m, kv|
        if m[v] += 1 > @supervisor.replicas / 2
          @supervisor.replicas.each do |replica|
            replica.proposer.value_learned!
          end
          break @learned_value = kv.last 
        end
      end
    end
  end
end
