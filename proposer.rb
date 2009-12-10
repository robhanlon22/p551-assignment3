class Proposer < PaxosRole
  def initialize(supervisor)
    @supervisor = supervisor
    @propose_mutex = Mutex.new
    @propose_thread = nil
    @n = 0
  end

  protected
  def propose(value)
    kill_thread

    @propose_thread = Thread.new do 
      loop do
        @propose_mutex.synchronize do 
          @n += 1
          
          replicas = @supervisor.replicas

          responses = replicas.inject([]) do |memo, replica|
            response = replica.paxos_instance.acceptor.prepare(@n)
            memo << response if response
          end

          next if responses.size < (replicas.size / 2.0).ceil

          number = responses.inject(nil) do |memo, response|
            if response.highest_accepted
              unless memo and response.highest_accepted <= memo
                memo = response.highest_accepted 
              end
            end
          end

          number and @n = number or number = @n

          responses.each do |response|
            response.acceptor.request_accept(Proposal.new(number, value, self))
          end
        end
      end
    end
  end

  def value_learned!
    @propose_thread.kill if @propose_thread 
  end

  alias_method :value_learned!, :kill_thread

  private
  Proposal = Struct.new :number, :value, :proposer
end
