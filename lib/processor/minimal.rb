module Processor
  module Minimal
    def process_message(msg)
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
          msg[:data] =~ /^\d+ (\S+) \S+$/
          entry.backend = $1
        end

      when :reqend
        entry_for(msg[:fd]) do |entry|
          entry.reqend(msg[:data])
          entry.newrelic_keys = {:class_name => entry.action.to_s, :name => entry.backend.to_s}

          @callbacks.each { |c| c.call(entry) }
        end

      else
        nil
      end
    end
  end
end
