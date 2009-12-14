#!/usr/bin/env ruby

require 'drb'
require File.join(File.dirname(__FILE__), 'rpc_exporter')

class Client
  @@options = nil

  def initialize(supervisor)
    @supervisor = supervisor
    @@options = {
      1 => self.method(:view_replicas),
      2 => self.method(:propose),
      3 => self.method(:learn),
      4 => self.method(:propose_and_learn),
      5 => self.method(:acceptor_state),
      6 => self.method(:quit)
    } if @@options.nil?
  end

  def quit
    puts "Exiting the Paxos client program. Goodbye!", ""
    exit(0)    
  end

  def view_replicas
    if @supervisor.replicas.size > 0
      puts "Viewing replicas (#{@supervisor.replicas.size}):",""
      print_replicas
    else
      puts "The supervisor is aware of no replicas."
    end
    puts ""
  end

  def propose
    if @supervisor.replicas.empty?
      puts "There are no replicas to propose to. Try again once some have been added."
      puts ""
      return
    end

    print_replicas
    $stdout.print "To propose a value, first pick a replica to propose to: "
    $stdout.flush
    replica_id, replica = read_replica_id

    $stdout.print "Now propose a value: "
    $stdout.flush
    proposal = $stdin.readline.strip

    puts "Proposing value '#{proposal}' to replica with id '#{replica_id}'"
    replica.propose(proposal)
    puts ""
  end

  def learn
    if @supervisor.replicas.empty?
      puts "There are no replicas to learn from. Try again once some have been added."
      puts ""
      return
    end
    print_replicas
    $stdout.print "To learn a value, first pick a replica to learn from: "
    $stdout.flush
    replica_id, replica = read_replica_id
    learned_value = replica.learn
    puts "The current learned value is: #{ learned_value ? learned_value : "DONT_KNOW"}"
    puts ""
  end

  def propose_and_learn
    if @supervisor.replicas.empty?
      puts "There are no replicas to propose to. Try again once some have been added."
      puts ""
      return
    end

    start = Time.now
    propose
    until learned_value = @supervisor.replicas.first.learn
      puts "After #{Time.now - start} seconds, value not learned"
      sleep 0.33
    end
    puts "Value '#{learned_value}' learned after #{Time.now - start} seconds"
    puts ""
  end

  def acceptor_state
    if @supervisor.replicas.empty?
      puts "There are no replicas to view. Try again once some have been added."
      puts ""
      return
    end

    puts "Current acceptor state:",""
    @supervisor.replicas_by_id do |id, replica|
      highest_accepted, highest_prepare, prepares = replica.acceptor_state
      puts "\tID: #{id}, Prepares: #{prepares}, High prepare: #{highest_prepare}, Highest accepted: #{ highest_accepted.number ? "#{highest_accepted.number} (number), #{highest_accepted.value} (value)" : "None"}"
    end
    puts ""
  end

  def read_replica_id
    replica_id = $stdin.readline.strip
    replica = @supervisor.replica_by_id(replica_id)
    while replica.nil?
      $stdout.print "Invalid selection. Please try again: "
      $stdout.flush
      replica_id = $stdin.readline.strip
      replica = @supervisor.replica_by_id(replica_id)
    end
    return replica_id, replica
  end

  def print_replicas
    @supervisor.replicas_by_id do |id, replica|
      puts "\t#{id}"
    end
  end

  def print_main_menu
    puts "Select from the following options:"
    puts "\t1. View replicas"
    puts "\t2. Propose value"
    puts "\t3. Learn value"
    puts "\t4. Propose and immediately poll learners for value"
    puts "\t5. View current acceptor state"
    puts "\t6. Quit this devious client program"
    puts ""
  end

  def run
    while true
      print_main_menu
      $stdout.print "Your selection please: "
      $stdout.flush

      selection = $stdin.gets
      case selection
      when /[0-#{@@options.size}]/
        puts ""
        @@options[selection.to_i].call
      else
        puts "", "ERROR: Your selection was not valid. Please try again.",""
        selection = nil
      end
    end
  end
end

supervisor_uri = ARGV[0]
puts "Preparing to reach Paxos service with supervisor URI: #{supervisor_uri}"
DRb.start_service
supervisor = DRbObject.new nil, supervisor_uri
puts "Successfully connected to supervisor, currently supervising #{supervisor.replicas.size} replica#{'s' if supervisor.replicas.size != 1}", ""

Client.new(supervisor).run
