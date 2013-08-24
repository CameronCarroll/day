class Task

  attr_reader :name, :valid_days, :time_commitment, :fulfillment

  def initialize(name, valid_days, time_commitment, fulfillment)
    @name = name
    @valid_days = valid_days
    @time_commitment = time_commitment
    @fulfillment = fulfillment
  end

  def valid_today?
    if @valid_days
      today = Time.new.wday #0 is sunday, 6 saturday

      weekday_short = case today
      when 0 then 'su'
      when 1 then 'm'
      when 2 then 'tu'
      when 3 then 'w'
      when 4 then 'th'
      when 5 then 'f'
      when 6 then 'sa'
      end

      weekday_long = case today
      when 0 then 'sun'
      when 1 then 'mon'
      when 2 then 'tue'
      when 3 then 'wed'
      when 4 then 'thu'
      when 5 then 'fri'
      when 6 then 'sat'
      end


      if @valid_days.include?(today) || @valid_days.include?(weekday_short)
        return true
      elsif (@valid_days.include?(weekday_long) || @valid_days.empty?)
        return true
      else
        return false
      end 
    else
      return true # valid everyday
    end
  end
end