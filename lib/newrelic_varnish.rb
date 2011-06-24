require 'eventmachine'
require 'newrelic_rpm'
require File.expand_path('request_stream', File.dirname(__FILE__))

module NewRelic::Agent
  def trace_execution_scoped(metric_names, options={})
    return yield if trace_disabled?(options)
    set_if_nil(options, :metric)
    set_if_nil(options, :deduct_call_time_from_parent)
    first_name, metric_stats = get_metric_stats(metric_names, options)
    # puts "from t_req=#{$ENTRY.t_req} to t_end=#{$ENTRY.t_end}"
    start_time, expected_scope = trace_execution_scoped_header(first_name, options, Thread.current[:entry].t_req)
    begin
      yield
    ensure
      trace_execution_scoped_footer(start_time, first_name, metric_stats, expected_scope, options[:force], Thread.current[:entry].t_end)
    end
  end

  def trace_execution_duration(metric_names, start_time, duration, options={})
    return yield if trace_disabled?(options)
    set_if_nil(options, :metric)
    set_if_nil(options, :deduct_call_time_from_parent)
    first_name, metric_stats = get_metric_stats(metric_names, options)
    start_time, expected_scope = trace_execution_scoped_header(first_name, options, start_time)
    # puts " from #{start_time} to #{start_time + duration}"
    trace_execution_scoped_footer(start_time, first_name, metric_stats, expected_scope, options[:force], start_time + duration)
  end
end

class NewRelicLogger
  include NewRelic::Agent::MethodTracer
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def log(entry)
    Thread.current[:entry] = entry

    keys = {:category => :uri, :force => true, :request => entry}
    keys.merge!(entry.newrelic_keys)

    perform_action_with_newrelic_trace(keys) do
      NewRelic::Agent.trace_execution_duration "Custom/Varnish/Process", entry.t_req, entry.dp, :force => true
      NewRelic::Agent.trace_execution_duration "Custom/Varnish/Deliver", entry.t_req + entry.dp, entry.da, :force => true
    end

    Thread.current[:entry] = nil
  end
end

if EM.kqueue?
  puts "kqueue #{EM.kqueue} => true"
  EM.kqueue = true
end

NewRelic::Agent.manual_start

count = 0
t = nil

EM.run do
  logger = NewRelicLogger.new

  stream = RequestStream.new(:processor => 'Minimal')
  stream.onrequest do |data|
    t = Time.now if count == 0

    logger.log(data)

    count += 1
    if (count % 1000) == 0
      puts "received #{count} requests in #{(Time.now - t).to_s} seconds"
      t = Time.now
    end
  end
end
