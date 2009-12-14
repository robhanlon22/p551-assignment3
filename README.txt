Rob Hanlon (rob@cs), Daniel Otero (oterod@cs)
CSE 551p
Gribble

Homework Assignment #3: Paxos

We used Distributed Ruby (DRb) as the backbone of our RPC interface. DRb allows, among other things, for the creation of services which share an object across any number of clients. We use this functionality to expose each replica to the others as well as to the "supervisor" which does book-keeping for the system. Each replica has a very limited interface including the two required methods (propose and learn) and a few others for debugging and/or extra information. Under the covers, each replica has within it Proposer, Acceptor, and Learner components, each of which handles the logic required by the respective role. RPC calls are made by simply calling the appropriate methods on the given objects. These methods include:

- Proposer:
  - propose(value): propose said value to a majority of acceptors
  - value_learned!: called on proposer by learners to end proposal
  
- Acceptor:
  - prepare(proposal_number): issue a prepare message to an acceptor
  - request_accept(proposal): request that an acceptor accept the given proposal
  
- Learner:
  - report(value, acceptor): used by acceptors to report accepted values
  - learned_value: returns the current "learned" value, or DONT_KNOW

Our "supervisor" is a slight improvement on command-line arguments delineating replica URIs, though it is a weak substitute for a real Paxos system's flexible group membership. Essentially it is nothing more than a centralized record of all active replicas which can be referenced by a replica when needed (e.g. when an accepter must notify all learners of an acceptance). To make all this clear, if an acceptor wanted to notify all learners of an acceptance, it would do something like this:

# Iterate over the set of available replicas
@supervisor.replicas.each do |replica|
  # report a value to the given replica's learner component
  replica.learner.report(value, self)
end

In our system, each component within a replica has a lock for its meta-data. In other words, only one thread can execute in each published method at a time. Our implementation requires Ruby, Distributed Ruby (DRb), ActiveRecord (ORM layer for persistent storage), and SQLite3 (lightweight database for persistent storage).

Test log (created by redirecting test_input.txt to client.rb):

[Input from the test_input.txt file in brackets]

Preparing to reach Paxos service with supervisor URI: druby://dabears.local:51015
Successfully connected to supervisor, currently supervising 3 replicas

Select from the following options:
        1. View replicas
        2. Propose value
        3. Learn value
        4. Propose and immediately poll learners for value
        5. View current acceptor state
        6. Quit this devious client program

Your selection please: [2]

        1
        2
        3
To propose a value, first pick a replica to propose to: [1]
Now propose a value: [foobar]

Select from the following options:
        1. View replicas
        2. Propose value
        3. Learn value
        4. Propose and immediately poll learners for value
        5. View current acceptor state
        6. Quit this devious client program

Your selection please: [2]

        1
        2
        3
To propose a value, first pick a replica to propose to: [3]
Now propose a value: [foobar]

Select from the following options:
        1. View replicas
        2. Propose value
        3. Learn value
        4. Propose and immediately poll learners for value
        5. View current acceptor state
        6. Quit this devious client program

Your selection please: [2]

        1
        2
        3
To propose a value, first pick a replica to propose to: [2]
Now propose a value: [baz]

Select from the following options:
        1. View replicas
        2. Propose value
        3. Learn value
        4. Propose and immediately poll learners for value
        5. View current acceptor state
        6. Quit this devious client program

Your selection please: [3]

        1
        2
        3
To learn a value, first pick a replica to learn from: [1]
The current learned value is: 'foobar'
