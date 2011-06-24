class LogEntry
  attr_accessor :method, :url, :protocol
  attr_accessor :action, :backend
  attr_accessor :response_protocol, :status_code, :status_message, :length
  attr_accessor :request, :response
  attr_accessor :t_open, :t_req, :t_end, :dh, :dp, :da
  attr_accessor :misc

  def initialize
    null_scalar_ivars
    @request = {}
    @response = {}
    @misc = []
  end

  def clear!
    null_scalar_ivars
    @request.clear
    @response.clear
    @misc.clear
  end

  def request=(header)
    name, value = header.split(/: /)

    @request[name] ||= []
    @request[name] << value
  end

  def response=(header)
    name, value = header.split(/: /)

    @response[name] ||= []
    @response[name] << value
  end

  def sessionopen(value)
  end

  def reqstart(value)
  end

  def reqend(value)
    # 426584589 1308649464.096332073 1308649464.096544981 0.000611067 0.000089884 0.000123024
    ignore, xid, t_req, t_end, dh, dp, da = */(\d+) ([0-9.]+) ([0-9.]+) ([0-9.]+) ([0-9.]+) ([0-9.]+)/.match(value)
    @t_req = t_req.to_f
    @t_end = t_end.to_f
    @dh = dh.to_f
    @dp = dp.to_f
    @da = da.to_f
    @t_open = @t_req - @dh
  end

  def inspect
    "#<#{self.class.name} #{method} #{url} #{protocol}\n" +
      "  request=#{request.inspect}\n" +
      "  response=#{response.inspect}\n" +
      "  misc=#{misc.inspect}>\n"
  end

private
  def null_scalar_ivars
    @method = nil
    @url = nil
    @protocol = nil
    @action = nil
    @backend = nil
    @response_protocol = nil
    @status_code = nil
    @status_message = nil
    @length = nil
    @t_open = nil
    @t_req = nil
    @t_end = nil
    @dh = nil
    @dp = nil
    @da = nil
  end
end
