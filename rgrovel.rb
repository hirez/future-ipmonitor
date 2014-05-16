#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'yaml'
require 'redis'

redishost = 'your.redis.host'

cdb = Redis.new(:host => redishost, :port => 6379, :db => 3)

ARGF.each_line do |e|
  next if e !~ /^Host:/
  bits = e.split(/\s+/)

  if cdb.exists(bits[1])
    ip = cdb.get(bits[1])
  else
    ip = ""
  end
  ip << '*'  if bits[4] =~ /Up/
  ip << '.'  if bits[4] =~ /Down/

#  puts "#{bits[1]}: #{ip}"
  cdb.set(bits[1],ip)
end
