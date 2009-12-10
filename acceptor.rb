class Acceptor < PaxosRole
  MIN_PROPOSAL_VALUE = 1
  
  def initialize(supervisor)
    @supervisor = supervisor
    @propose_mutex = Mutex.new
    @highest_accepted = Proposal.new
    @highest_prepare = MIN_PROPOSAL_VALUE - 1
  end
  
  protected
  
  def prepare(proposal_number)
    @propose_mutex.synchronize do
      if @proposal_number > @highest_prepare
        @highest_prepare = @proposal_number
        return Response.new(@highest_accepted.number, self)
      else
        return nil
      end
    end
  end
  
  def request_accept(proposal)
    @propose_mutex.synchronize do
      if proposal.number >= @highest_prepare
        @highest_accepted = proposal
        return true
      end
    end
  end
  
  Response = Struct.new :highest_accepted, :acceptor
  
  Proposal = Struct.new :number, :value, :proposer
end
