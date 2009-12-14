class PaxosRole
  protected
  
  Response = Struct.new :highest_accepted, :acceptor
  Proposal = Struct.new :number, :value, :proposer
end
