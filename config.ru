require 'rubygems'
require 'sinatra'

set :env,  :production
disable :run

require './ipmonitor.rb'

run Sinatra::Application
