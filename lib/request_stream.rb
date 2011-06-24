require 'em/varnish_log/connection'
require 'em/buffered_channel'
require 'log_entry'

class RequestStream
  def initialize
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
      case msg[:tag]
      when :reqstart
        setup_entry(msg[:fd])

      when :hit
        entry_for(msg[:fd]) do |entry|
          entry.action = :hit
        end

      when :backend
        entry_for(msg[:fd]) do |entry|
          entry.action  = :backend
          msg[:str] =~ /^\d+ (\S+) \S+$/
          entry.backend = $1
        end

      when :reqend
        entry_for(msg[:fd]) do |entry|
          entry.reqend(msg[:data])

          @callbacks.each { |c| c.call(entry) }
        end
      end
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
