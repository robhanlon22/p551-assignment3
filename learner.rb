class Learner
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
      @learned.inject(Hash.new(0)) do |value_counts, key_value|
        # If we've finally found a majority value...
        puts 'banana'
        begin
          if (value_counts[key_value.last] += 1) > (@supervisor.replicas.size / 2)
            # Tell all the proposers to quit proposing
            @supervisor.replicas.each do |replica|
              puts 'cream cheese'
              replica.proposer.value_learned!
            end
            break @learned_value = key_value.last 
          end
        rescue Exception => e
          puts "#{e.class}: #{e.message}"
          puts "#{e.backtrace.join("\n")}"
        end
      end
    end
  end
end
