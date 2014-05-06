module BallotHelpers
  def cal_to_unix(date)
    date = date[6..9] + "-" + date[3..4] + "-" + date[0..1] + "T" + date[11..15]
    return Time.iso8601((date + ":00").sub(' UTC','').sub(/ /,'T')).to_i
  end

  def unix_to_cal(date)
    return Time.at(date.to_i).utc.strftime("%d-%m-%Y %H:%M %Z")
  end
end
