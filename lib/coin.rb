require "drb/drb"
require "rbconfig"
require "forwardable"

Dir[File.join(File.dirname(__FILE__), "coin", "*.rb")].each do |file|
  require file
end

module Coin
  class << self
    extend Forwardable
    def_delegators :server, :read, :write, :delete, :clear

    attr_writer :port
    def port
      @port ||= 8955
    end

    attr_writer :uri
    def uri
      "druby://localhost:#{port}"
    end

    def server
      return nil unless ENV["COIN_URI"].nil?
      begin
        @server.ok? if @server
      rescue Exception => ex
        puts "FAIL! #{ex}"
        @server = nil
      end
      return @server if @server

      begin
        @server = DRbObject.new_with_uri(uri)
        @server.ok?
      rescue Exception => ex
        puts "FAIL! #{ex}"
        @server = nil
      end
      return @server if @server

      start_server

      while @server.nil?
        begin
          sleep 0.1
          @server = DRbObject.new_with_uri(uri)
          @server.ok?
        rescue Exception => ex
        end
      end

      DRb.start_service
      @server
    end

    def start_server
      ruby = "#{RbConfig::CONFIG["bindir"]}/ruby"
      script = File.expand_path(File.join(File.dirname(__FILE__), "..", "bin", "coin"))
      env = {
        "COIN_URI" => Coin.uri
      }
      @pid = spawn(env, "#{ruby} #{script}")
      Process.detach(@pid)
    end

    def stop_server
      Process.kill("HUP", @pid) if @pid
    end
  end
end
