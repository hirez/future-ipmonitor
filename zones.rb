#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'zonefile'
require 'redis'
require 'optparse'


zroot = "/path/to/your/zonefiles"
redishost = 'your.redis.host'
options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: zones.rb [options]"
 
  options[:debug] = false
  opts.on( '-d', '--debug', 'Much output, do not detach' ) do
    options[:debug] = true
  end
 
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
        exit
  end
end

optparse.parse!



rdb = Redis.new(:host => redishost, :port => 6379, :db => 1)
ddb = Redis.new(:host => redishost, :port => 6379, :db => 2)
adr = Hash.new

ddb.flushdb

Dir.glob("#{zroot}/master.*").each do |fname|
  zname = File.basename(fname)
  zone = zname.sub(/^master./,"")

  zf = Zonefile.from_file(fname)

  zf.a.each do |a_record|
    if adr[a_record[:host]]
      adr[a_record[:host]] << "#{a_record[:name]}.#{zone} "
    else
      adr["#{a_record[:host]}"] = "#{a_record[:name]}.#{zone} "
    end
  end

  zf.cname.each do |c_record|
    begin
      fred = Resolv.getaddress(c_record[:host])
    rescue Exception => e
      ddb.set("#{c_record[:name]}.#{zone}","#{e.message}")
    else
      if adr[fred]
        adr[fred] << "#{c_record[:name]}.#{zone} "
      else
        adr[fred] = "#{c_record[:name]}.#{zone} "
      end
    end
  end
end

rdb.flushdb

adr.each do |k,v|
  if options[:debug]
    puts "#{k}: #{v}"
  else
    rdb.set(k,v)
  end  
end

