module Processor
  module HostsAndPrefixes
    def process_message(msg)
      case msg[:tag]
      when :reqstart
        setup_entry(msg[:fd])

      when :hit
        entry_for(msg[:fd]) do |entry|
          entry.action = :hit
          entry.newrelic_keys[:name] = "hit"
        end

      when :rxurl
        segments = msg[:data].split("/")
        entry_for(msg[:fd]) do |entry|
          # XXX dirty hack
          entry.newrelic_keys[:prefix] = segments.length > 1 ? segments[1] : ""
        end

      when :rxheader
        if msg[:data] =~ /^Host: (.+)$/
          entry_for(msg[:fd]) do |entry|
            entry.newrelic_keys[:class_name] = [$1, entry.newrelic_keys.delete(:prefix)].join("/")
          end
        end

      when :reqend
        entry_for(msg[:fd]) do |entry|
          entry.reqend(msg[:data])
          # XXX find out the correct action
          entry.newrelic_keys[:name] ||= "miss"

          @callbacks.each { |c| c.call(entry) }
        end

      else
        nil
      end
    end
  end
end
