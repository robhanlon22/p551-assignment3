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

  protected
  def report(value, acceptor)
    # TODO hashcode
    @mutex_me.synchronize do
      @learned[acceptor] = value
      @learned.inject(Hash.new(0)) do |value_counts, key_value|
        # If we've finally found a majority value...
        if (value_counts[key_value.last] += 1) > (@supervisor.replicas / 2)
          # Tell all the proposers to quit proposing
          @supervisor.replicas.each do |replica|
            replica.proposer.value_learned!
          end
          break @learned_value = key_value.last 
        end
      end
    end
  end
end
