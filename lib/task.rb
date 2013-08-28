class Task

  attr_reader :name, :valid_days, :time_commitment, :fulfillment, :day_fulfillment

  def initialize(name, valid_days, time_commitment, fulfillment, day_fulfillment)
    @name = name
    @valid_days = valid_days
    @time_commitment = time_commitment
    @fulfillment = fulfillment
    if day_fulfillment
      @day_fulfillment = day_fulfillment[1]
    end
  end

  def valid_today?
    if @valid_days
      today = Time.new.wday #0 is sunday, 6 saturday

      weekday_key = case today
      when 0 then :sunday
      when 1 then :monday
      when 2 then :tuesday
      when 3 then :wednesday
      when 4 then :thursday
      when 5 then :friday
      when 6 then :saturday
      end

      if (@valid_days.include?(weekday_key) || @valid_days.empty?)
        return true
      else
        return false
      end 
    else
      return true # valid everyday
    end
  end
end