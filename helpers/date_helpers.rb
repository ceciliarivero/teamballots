module DateHelpers
  def cal_to_unix(date)
    date = date[6..9] + "-" + date[3..4] + "-" + date[0..1] + "T" + date[11..15]
    return Time.iso8601((date + ":00").sub(' UTC','').sub(/ /,'T')).to_i
  end

  def unix_to_cal(date)
    return Time.at(date.to_i).strftime("%d-%m-%Y %H:%M %Z")
  end

  def cal_utc(date)
    return Time.at(date.to_i).utc.strftime("%d-%m-%Y %H:%M %Z")
  end

  def valid_date?(date)
    return date =~ /^(3[01]|[12][0-9]|0[1-9])-(1[0-2]|0[1-9])-[0-9]{4} (0[0-9]|1[0-9]|2[0-3]):(0[0-9]|1[0-9]|2[0-9]|3[0-9]|4[0-9]|5[0-9])( [A-Z]{1,5})?$/
  end
end
