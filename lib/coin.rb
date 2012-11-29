require "drb/drb"
require "rbconfig"
require "forwardable"

Dir[File.join(File.dirname(__FILE__), "coin", "*.rb")].each do |file|
  require file
end

module Coin
  class << self
    extend Forwardable
    def_delegators :server, :delete, :clear, :length

    def read(key, lifetime=300)
      value = server.read(key)
      if value.nil? && block_given?
        value = yield
        write(key, value, lifetime)
      end
      value
    end

    def write(key, value, lifetime=300)
      @write_queue ||= Queue.new
      @write_thread ||= Thread.new do
        Thread.current.priority = -1
        loop do
          unless @write_queue.empty?
            info = @write_queue.pop
            server.write(info[0], info[1], info[2])
          end
          sleep 0.5
        end
      end

      @write_queue << [key, value, lifetime]
    end

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

      if server_running?
        if @server
          begin
            @server.ok? if @server
          rescue DRb::DRbConnError => ex
            puts "FAIL! #{ex}"
            @server = nil
          end
        end

        if @server.nil?
          begin
            @server = DRbObject.new_with_uri(uri)
            @server.ok?
          rescue DRb::DRbConnError => ex
            puts "FAIL! #{ex}"
            @server = nil
          end
        end
      end

      return @server if @server

      start_server

      while @server.nil?
        begin
          sleep 0.1
          @server = DRbObject.new_with_uri(uri)
          @server.ok?
        rescue DRb::DRbConnError => ex
        end
      end

      DRb.start_service
      @server
    end

    def pid_file
      "/tmp/coin-pid-63f95cb5-0bae-4f66-88ec-596dfbac9244"
    end

    def pid
      File.read(Coin.pid_file) if File.exist?(Coin.pid_file)
    end

    def server_running?
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
      true
    end

  end
end
