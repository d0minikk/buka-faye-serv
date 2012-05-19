require 'faye'

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 4)
run faye_server

