require 'rubygems'
require 'bundler'
require "bundler/setup"
Bundler.require
require "yaml"
require "thin"
require "faye"

require File.expand_path('../config/initializers/faye_token.rb', __FILE__)

Faye::WebSocket.load_adapter('thin')


class FayeExtension
    # Callback to handle incoming Faye messages. This authenticates both
    # subscribe and publish calls.
    def incoming(message, callback)
      if message["channel"] == "/meta/subscribe"
        authenticate_subscribe(message)
      elsif message["channel"] !~ %r{^/meta/}
        authenticate_publish(message)
      end
      callback.call(message)
    end

  private

    # Ensure the subscription signature is correct and that it has not expired.
    def authenticate_subscribe(message)
      subscription = PrivatePub.subscription(:channel => message["subscription"], :timestamp => message["ext"]["private_pub_timestamp"])
      if message["ext"]["private_pub_signature"] != subscription[:signature]
        message["error"] = "Incorrect signature."
      elsif PrivatePub.signature_expired? message["ext"]["private_pub_timestamp"].to_i
        message["error"] = "Signature has expired."
      end
    end

    # Ensures the secret token is correct before publishing.
    def authenticate_publish(message)
      if PrivatePub.config[:secret_token].nil?
        raise Error, "No secret_token config set, ensure private_pub.yml is loaded properly."
      elsif message["ext"]["private_pub_token"] != PrivatePub.config[:secret_token]
        message["error"] = "Incorrect token."
      else
        message["ext"]["private_pub_token"] = nil
      end
    end
  end

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(FayeExtension.new)
run faye_server
