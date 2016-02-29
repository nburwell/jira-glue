module Comm
  class Server
    
    def initialize
      # pipe_reader.rb
      @recv_pipe = "/tmp/glue.server.recv"
      @send_pipe = "/tmp/glue.server.send"

      `mkfifo #{@recv_pipe}` unless File.exists?(@recv_pipe)
      `mkfifo #{@send_pipe}` unless File.exists?(@send_pipe)
    end
    
    def start &block
      message = open(@recv_pipe, "r+")
      puts "Waiting for messages..."

      while line = message.gets
      
        clean_line = line.strip
        
        if clean_line == "exit"
          puts "Exiting..."
          break
        end
        
        yield clean_line
      end

      message.close

      puts "Exiting... [Done]"
    end
    
    def send(data)
      output = open(@send_pipe, "w+") # the w+ means we don't block
      output.puts data
      output.flush
      output.close
      puts "Sent #{data} to pipe #{@send_pipe}"
    end
  end
end
