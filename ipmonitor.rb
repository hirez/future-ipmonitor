#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'yaml'
require 'zonefile'
require 'redis'

enable :sessions
set :session_secret, 'The terrible session-secret of space.'

redishost = 'your.redis.machine'

$rdb = Redis.new(:host => redishost, :port => 6379, :db => 1)
$ddb = Redis.new(:host => redishost, :port => 6379, :db => 2)
$cdb = Redis.new(:host => redishost, :port => 6379, :db => 3)
$edb = Redis.new(:host => redishost, :port => 6379, :db => 4)

# cdb: key - ip address, val - string of chars showing up or down. Updated daily from nmap run.
# edb: key - ip address, val - local hostname or '-'. Updated every ten minutes from DNS.
# rdb: key - ip address, val - list of aliases. Updated every thirty minutes from zonefiles.
# ddb: key - dns name, val - dns problem. Updated every thirty minutes from zonefiles.

get '/' do
  @upl = Hash.new
  @hst = Hash.new
  $cdb.keys('*').each do |k|
    @upl[k] = $cdb.get(k)
    @hst[k] = $edb.get(k)
  end
  erb :index
end

get '/address/:ip' do
  if $rdb.get([params[:ip]])
    @blep = $rdb.get([params[:ip]]).split 
    erb :adata
  end
end

get '/errors' do
  erb :errors
end
