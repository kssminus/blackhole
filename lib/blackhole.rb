module Blackhole
  class << self
    attr_accessor :logger
    
    # Mongo connection
    attr_accessor :mongo
    
    # Info to connect to mongo
    attr_accessor :mongo_db_name
    attr_accessor :mongo_hostports

    # Returns a mongo connection (NOT an em-mongo connection)
    def mongo
      @mongo ||= begin
        require 'mongo'   # require mongo here, as opposed to the top, because we don't want mongo included in the reactor (use em-mongo for that)
        
        hostports = self.mongo_hostports || [["localhost", Mongo::Connection::DEFAULT_PORT]]
        self.mongo_hostports = hostports.collect do |hp|
          if hp.is_a?(String)
            host, port = hp.split(":")
            [host, port || Mongo::Connection::DEFAULT_PORT]
          else
            hp
          end
        end
        
        if self.mongo_hostports.length == 1
          hostport = self.mongo_hostports.first
          Mongo::Connection.new(hostport[0], hostport[1], :pool_size => 5, :pool_timeout => 20).db(self.mongo_db_name || "blackhole")
        else
          raise "repls set con not impl"
        end
      end
    end
    
    def collection(collection_name)
      @collections ||= {}
      @collections[collection_name] ||= begin
        c = mongo.collection(collection_name)
        c.ensure_index([["t", 1]], {:background => true, :unique => true})
        c.ensure_index([["host", 1]], {:background => true, :unique => true})
        c
      end
    end
    
    def mongo_collection_name(namespace)
      "blackhole_#{namespace}"
    end
    
    def collection_for(namespace)
      collection(mongo_collection_name(namespace))
    end
  end
end
