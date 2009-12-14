#!/usr/bin/env ruby

require 'drb'
require File.join(File.dirname(__FILE__), 'supervisor')

DRb.start_service nil, Supervisor.new

puts "This Paxos supervisor can be reached at: #{DRb.uri}"

DRb.thread.join
