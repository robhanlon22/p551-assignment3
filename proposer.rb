require 'proposal'

class Proposer
  def initialize(supervisor)
    @supervisor = supervisor
    @propose_mutex = Mutex.new
    @propose_thread = nil
    @n = 0
  end

  def propose(value)
    kill_thread

    @propose_thread = Thread.new do
      loop do
        @propose_mutex.synchronize do
          @n += 1

          puts 'i'
          replicas = @supervisor.replicas
          puts "Supervisor has: #{replicas.size} replicas"

          puts 'am'
          responses = replicas.inject([]) do |memo, replica|
            puts 'a'
            response = replica.acceptor.prepare(@n)
            memo << response if response
          end

          puts 'wallaby'
          next if responses.size < replicas.size / 2

          number = responses.inject(nil) do |memo, response|
            puts 'foo'
            if response.highest_accepted
              puts 'bar'
              unless memo and response.highest_accepted <= memo
                puts 'baz'
                memo = response.highest_accepted
              end
            end
          end

          if number
            @n = number
          else
            number = @n
          end

          responses.each do |response|
            puts 'mumble'
            response.acceptor.request_accept(Proposal.new(number, value, self))
          end
        end
      end
    end
  end

  def value_learned!
    puts 'rhombus'
    if @propose_thread
      @propose_thread.kill
    end
  end

  alias_method :kill_thread, :value_learned!
end
