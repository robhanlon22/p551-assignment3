#!/usr/bin/env ruby

require 'drb'
require File.join(File.dirname(__FILE__), 'rpc_exporter')

supervisor_url = ARGV[0]

DRb.start_service
supervisor = DRbObject.new nil, supervisor_url

rpc = RPCExporter.new(supervisor)
supervisor.add_replica(rpc)

DRb.start_service nil, rpc

puts "This Paxos replica can be reached at: #{DRb.uri}"

DRb.thread.join
