#!/usr/bin/env ruby

require 'drb'
require File.join(File.dirname(__FILE__), 'rpc_exporter')

supervisor_uri = ARGV[0]
number = ARGV[1] ? ARGV[1].to_i : 3

DRb.start_service
supervisor = DRbObject.new nil, supervisor_uri

number.times do
  rpc = RPCExporter.new(supervisor)
  DRb.start_service nil, rpc

  puts "Created Paxos replica at: #{DRb.uri}"
end

DRb.thread.join
