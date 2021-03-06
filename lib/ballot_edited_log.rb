module BallotEditedLog
  def self.create(user, ballot, params = {})
    message = "Ballot was edited:"

    if ballot.title != params["title"]
      message += "<br><br><br>Previous Ballot title: " + ballot.title + "<br><br>
      Current Ballot title: " + params["title"]
    end

    if ballot.description != params["description"]
      message += "<br><br><br>Previous Ballot description:<br>" + ballot.description + "<br><br>
      Current Ballot description: " + params["description"]
    end

    if ballot.end_choices_date.to_i != params["end_choices_date"]
      message += "<br><br><br>Previous start of voting term: " +
      Time.at(ballot.end_choices_date.to_i).utc.strftime("%d-%m-%Y %H:%M %Z") + "<br><br>
      Current start of voting term: " +
      Time.at(params["end_choices_date"].to_i).utc.strftime("%d-%m-%Y %H:%M %Z")
    end

    if ballot.end_date.to_i != params["end_date"]
      message += "<br><br><br>Previous Ballot closing date: " +
      Time.at(ballot.end_date.to_i).utc.strftime("%d-%m-%Y %H:%M %Z") + "<br><br>
      Current Ballot closing date: " +
      Time.at(params["end_date"].to_i).utc.strftime("%d-%m-%Y %H:%M %Z")
    end

    log_comment = {}

    log_comment["date"] = Time.new.to_i
    log_comment["user_id"] = user.id
    log_comment["ballot_id"] = ballot.id
    log_comment["added_by"] = user.name
    log_comment["message"] = message

    Comment.create(log_comment)
  end
end
