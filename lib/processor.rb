module Processor
  extend self

  def get(name)
    Processor.const_get(name.capitalize)
  end
end

Dir[File.join(File.dirname(__FILE__), "processor", "*.rb")].each { |f| require f }