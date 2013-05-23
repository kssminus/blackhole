# Mouth의 sucker의 영감을 받아 고친 sucker
# MOuth : https://github.com/cypriss/mouth
require 'eventmachine'

module Blackhole
  class HoleConnection < EM::Connection
    attr_accessor :hole
  
    def receive_data(data)
      Blackhole.logger.debug "UDP packet: '#{data.to_s.force_encoding('cp949')}'"
      # store to memory
      hole.store!(data)
    end
  end
  
  class Hole
    # Host/Port to suck UDP packets on
    attr_accessor :host
    attr_accessor :port

    # Stats
    attr_accessor :udp_packets_received

    # Received Log
    attr_accessor :logs


    def initialize(options = {})
    
      self.host = options[:host] || "localhost"
      self.port = options[:port] || 8889
      
      self.udp_packets_received = 0
      self.logs = []
    end
   
    def tug!
      EM.run do

        EM.open_datagram_socket host, port, HoleConnection do |conn|
          conn.hole = self
        end
        
        EM.add_periodic_timer(5) do
          self.drain!
          self.set_procline!
        end

        EM.next_tick do
          Blackhole.logger.info "Blackhost started to tug logs..."
          self.set_procline!
        end
      end
    end
    
    def store!(data)
      if /(?<seq>^<\d+>)(?<date>.{15})\s(?<hostname>[\w-]+)\s(?<filename>[^:]+):\s(?<log>.+)/ =~ data
        packet = {}
        packet[:hostname] = hostname
        packet[:filename] = filename
        packet[:date] = date
        packet[:log] = log
        packet[:time] = Time.now.to_i
        #Blackhole.logger.info data
        self.logs << packet
      end

      self.udp_packets_received += 1
    end
    
    def drain!

      temp_logs = self.logs.clone
      self.logs = []
      
      temp_logs.each do |log|
        #Blackhole.logger.info "#{log}" 
      end
    end
    
    def set_procline!
      $0 = "blackhole [#{self.port}] [UDP Recv: #{self.udp_packets_received}]"
    end
    
  end # class Hole
end # module
