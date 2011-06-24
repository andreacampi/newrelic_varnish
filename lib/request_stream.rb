require 'em/varnish_log/connection'
require 'em/buffered_channel'
require 'log_entry'
require 'processor'

class RequestStream
  def initialize(options = {})
    self.class.send(:include, Processor::get(options[:processor]))

    @channel = EM::BufferedChannel.new
    @callbacks = []
    @entries = {}

    listen
  end

  def onrequest(&block)
    @callbacks << block
  end

private

  def listen
    EM::VarnishLog::Connection.start(@channel)

    @channel.subscribe do |msg|
      process_message(msg)
    end
  end

  def setup_entry(fd)
    if @entries[fd]
      @entries[fd].clear!
    else
      @entries[fd] = LogEntry.new
    end
  end

  def entry_for(fd)
    if @entries[fd]
      yield @entries[fd]
    else
      puts "warning: no entry for #{fd}"
    end
  end
end
