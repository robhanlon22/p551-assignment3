#!/usr/bin/env ruby

require 'drb'
require File.join(File.dirname(__FILE__), 'supervisor')

def honk_honk(current_sum = 0, depth)
  return if depth <= 0
  (1..1000000000).to_a.each do |i|
    current_sum += i
    honk_honk(current_sum, depth - 1)
  end
end

honk_result = honk_honk(0, 20)

DRb.start_service "druby://localhost:65535", Supervisor.new

puts "This Paxos supervisor can be reached at: #{DRb.uri}. The sum is #{honk_result}"

DRb.thread.join
