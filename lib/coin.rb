require "drb/drb"
require "rbconfig"
require "forwardable"

Dir[File.join(File.dirname(__FILE__), "coin", "*.rb")].each do |file|
  require file
end

module Coin
  class << self
    extend Forwardable
    def_delegators :server, :write, :read_and_delete, :delete, :clear, :length

    def read(key, lifetime=300)
      value = server.read(key)
      if value.nil? && block_given?
        value = yield
        write(key, value, lifetime)
      end
      value
    end

    attr_writer :port
    def port
      @port ||= 8955
    end

    def uri
      @uri ||= "druby://localhost:#{port}"
    end

    def uri=(value)
      @remote = true
      @uri = value
    end

    def server
      return nil unless ENV["COIN_URI"].nil?

      if server_running?
        if @server
          begin
            @server.ok? if @server
          rescue DRb::DRbConnError => ex
            @server = nil
          end
        end

        if @server.nil?
          begin
            @server = DRbObject.new_with_uri(uri)
            @server.ok?
          rescue DRb::DRbConnError => ex
            @server = nil
          end
        end
      end

      return @server if @server && server_running?

      start_server
      @server = DRbObject.new_with_uri(uri)
    end

    def pid_file
      "/tmp/coin-pid-63f95cb5-0bae-4f66-88ec-596dfbac9244"
    end

    def pid
      File.read(Coin.pid_file) if File.exist?(Coin.pid_file)
    end

    def server_running?
      return false if @remote
      @pid = pid
      return false unless @pid
      begin
        Process.kill(0, @pid.to_i)
      rescue Errno::ESRCH => ex
        return false
      end
      true
    end

    def start_server(force=nil)
      DRb.start_service
      return if @remote
      return if server_running? && !force
      stop_server if force
      ruby = "#{RbConfig::CONFIG["bindir"]}/ruby"
      script = File.expand_path(File.join(File.dirname(__FILE__), "..", "bin", "coin"))
      env = {
        "COIN_URI" => Coin.uri
      }
      pid = spawn(env, "#{ruby} #{script}")
      Process.detach(pid)

      sleep 0.1 while !server_running?
      true
    end

    def stop_server
      Process.kill("HUP", @pid.to_i) if server_running?
      sleep 0.1 while server_running?
      DRb.stop_service
      true
    end

  end
end
