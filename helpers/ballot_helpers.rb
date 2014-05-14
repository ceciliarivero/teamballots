module BallotHelpers
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

  def calculate_result(choices)
    results = {}

    choices.each do |choice|
      rating = 0.0

      voters = choice.votes.size.to_i

      choice.votes.each do |vote|
        choice_title = Choice[vote.choice_id].title
        results[choice_title] = rating

        if !results[choice_title].nil?
          rating = rating + vote.rating.to_i

          results[choice_title] = (rating / voters).round(2)
        else
          results[choice_title] = (vote.rating.to_i / voters).round(2)
        end
      end
    end

    return results
  end
end
