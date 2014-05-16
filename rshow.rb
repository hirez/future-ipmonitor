#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'yaml'
require 'resolv'
require 'redis'

redishost = 'your.redis.host'

cdb = Redis.new(:host => redishost, :port => 6379, :db => 3)
edb = Redis.new(:host => redishost, :port => 6379, :db => 4)

ures = Resolv::DNS.new

cdb.keys('*').each do |k|
    v = cdb.get(k)
    begin
      hname = ures.getname(k)
    rescue Exception => e
      hname = '-'
    end
    puts "#{k} : #{v} : #{hname}"
    edb.set(k,hname)
end
