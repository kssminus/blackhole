require 'fileutils'
require 'logger'
require 'hole'
require 'blackhole'

module Blackhole
  class Runner
    
    attr_accessor :log_file
    attr_accessor :pid_file
    attr_accessor :logger
    attr_accessor :verbosity    # 0: Only errors/warnings 1: informational 2: debug/all incomding UDP packets
    attr_accessor :options
    
    def initialize(opts={})
      self.log_file = opts[:log_file]
      self.pid_file = opts[:pid_file]
      self.verbosity = opts[:verbosity]
      self.options = opts
    end
    
    def run!
      kill! if self.options[:kill]
      
      puts "Starting Blackhole..."
      
      daemonize!
      save_pid!
      setup_logging!      

      # Start the reactor!
      hole = Blackhole::Hole.new(self.options)
      hole.tug!
    end
    
    def kill!
      if @pid_file
        pid = File.read(@pid_file)
        #logger.warn "Sending #{kill_command} to #{pid.to_i}"
        Process.kill(:INT, pid.to_i)
      else
        #logger.warn "No pid_file specified"
      end
    ensure
      exit(0)
    end
    
    def daemonize!
      # Fork and continue in forked process
      # Also calls setsid
      # Also redirects all output to /dev/null
      Process.daemon(true)
       
      # Reset umask
      File.umask(0000)
      
      # Set the procline
      $0 = "Blackhole [initializing]"
    end
    
    def save_pid!
      if @pid_file
        pid = Process.pid
        FileUtils.mkdir_p(File.dirname(@pid_file))
        File.open(@pid_file, 'w') { |f| f.write(pid) }
      end
    end
    
    def setup_logging!
      if @log_file
        STDERR.reopen(@log_file, 'a')
        # Open a logger
        self.logger = Logger.new(@log_file)
        self.logger.level = case self.verbosity
        when 0
          Logger::WARN
        when 1
          Logger::INFO
        else
          Logger::DEBUG
        end
        Blackhole.logger = self.logger
        
        self.logger.info "Blackhole Initialized..."
      end
    end
    
  end # class Runner
end # module
