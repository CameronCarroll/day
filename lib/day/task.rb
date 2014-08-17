# DayRB Task Class
#
# Has essentially only one function, which is to perform valid_today? checks.
# But maybe we'll just keep it and give it more responsibility later.
#
# MIT License; See LICENSE file; Cameron Carroll 2014

class Task

  attr_reader :name, :valid_days, :description, :time_estimate, :fulfillment

  def initialize(name, description, valid_days, time_estimate, fulfillment)
    @name = name
    @valid_days = valid_days
    @description = description
    @time_estimate = time_estimate
    @fulfillment = fulfillment
  end

  # Determine whether the task is valid today.
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