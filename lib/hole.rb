# Mouth의 sucker의 영감을 받아 고친 sucker
# MOuth : https://github.com/cypriss/mouth
require 'em-mongo'
require 'eventmachine'

module Blackhole
  class HoleConnection < EM::Connection
    attr_accessor :hole
  
    def receive_data(data)
      Blackhole.logger.debug "UDP packet: '#{data}'"
      # store to memory
      hole.store!(data)
    end
  end
  
  class Hole
    # Host/Port to suck UDP packets on
    attr_accessor :host
    attr_accessor :port

    # Actual EM::Mongo connection
    attr_accessor :mongo
    
    # Info to connect to mongo
    attr_accessor :mongo_db_name
    attr_accessor :mongo_hostports
    
    # Stats
    attr_accessor :udp_packets_received
    attr_accessor :mongo_flushes
    
    # Received Log
    attr_accessor :logs
    # sender info
    attr_accessor :info


    def initialize(options = {})
    
      self.host = options[:host] || "localhost"
      self.port = options[:port] || 8889
      self.mongo_db_name = options[:mongo_db_name] || "stepper"
      hostports = options[:mongo_hostports] || [["localhost", EM::Mongo::DEFAULT_PORT]]
      self.mongo_hostports = hostports.collect do |hp|
        if hp.is_a?(String)
          host, port = hp.split(":")
          [host, port || EM::Mongo::DEFAULT_PORT]
        else
          hp
        end
      end
      
      self.udp_packets_received = 0
      self.mongo_flushes = 0
      self.logs = []
      self.info = []
    end
   
    def tug!
      EM.run do
        # Connect to mongo now
        self.mongo

        EM.open_datagram_socket host, port, HoleConnection do |conn|
          conn.hole = self
        end
        
        EM.add_periodic_timer(5) do
          #Blackhole.logger.info "Stepping: #{self.stepping.inspect}"
          #self.flush!
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
        self.info << packet
        packet[:date] = date
        packet[:log] = log
        packet[:time] = Time.now.to_i
        self.logs << packet
      end

      self.udp_packets_received += 1
    end
    
    def drain!

      # make two collections 
      # one for the logs
      # and the other for the collection dd
      # "mycollection:step_id": {
      #   t:  23423433,
      #   ms: 6,
      #   cs: 1
      # }
      #몽고에 저장하는 도중에 들어오는 녀석들 때문에..
      temp_logs = self.logs.clone
      self.logs = []
      temp_info = self.info.clone
      self.info = []
      temp_info.uniq!
      
      if temp_info.size > 0
        collection_name = Blackhole.mongo_collection_name("info") 
        temp_info.each do |info|
          info_tmp = {}
          info_tmp[:host] = info[:hostname].to_s
          info_tmp[:file] = info[:file].to_s
          info_tmp[:port] = self.port
          self.mongo.collection(collection_name).update(info_tmp, info_tmp, { upsert: true })
        end
      end

      if temp_logs.size > 0
        # sanitize collection name
        collection_name = Blackhole.mongo_collection_name(self.port) 

        self.mongo.collection(collection_name).insert(temp_logs)
        
        self.logs.delete_if { |log| temp_logs.include?(log) }
      end

      Blackhole.logger.info "Saved Steps : #{temp_steps.inspect}" 

      self.mongo_flushes += 1
    end
    
    def mongo
      @mongo ||= begin
        if self.mongo_hostports.length == 1
          EM::Mongo::Connection.new(*self.mongo_hostports.first).db(self.mongo_db_name)
        else
          raise "Ability to connect to a replica set not implemented."
        end
      end
    end
    
    def set_procline!
      $0 = "blackhole [#{self.port}] [UDP Recv: #{self.udp_packets_received}] [Mongo saves: #{self.mongo_flushes}]"
    end
    
  end # class Hole
end # module
