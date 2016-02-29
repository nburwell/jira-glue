module Comm
  class Client
    
    def initialize
      @send_pipe = "/tmp/glue.server.recv"
      @recv_pipe = "/tmp/glue.server.send"

      `mkfifo #{@send_pipe}` unless File.exists?(@send_pipe)
      `mkfifo #{@recv_pipe}` unless File.exists?(@recv_pipe)
    end

    def send(data)
      log "Sent #{data} to pipe #{@send_pipe}"
      send_message(data)
    end
    
    private
    
    def log(message)
      puts message
    end

    def send_message(data)
      output = open(@send_pipe, "w+") # the w+ means we don't block
      output.puts data
      output.flush
      output.close

      receive_response  
    end

    def receive_response
      response = open(@recv_pipe, "r")

      while line = response.gets
        puts "Response: '#{line.strip}'"
      end

      response.close
    end
  end
end