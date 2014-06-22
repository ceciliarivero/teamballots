module ChoiceEditedLog
  def self.create(user, ballot, choice, params = {})
    message = "Choice '" + choice.title + "' was edited:"

    if choice.title != params["title"]
      message += "<br><br><br>Previous Choice title: " + choice.title + "<br><br>
      Current Choice title: " + params["title"]
    end

    if !choice.comment.empty? && choice.comment != params["comment"]
      message += "<br><br>Previous Choice comment: " + choice.comment + "<br><br>
      Current Choice comment: " + params["comment"]
    elsif choice.comment.empty? && !params["comment"].empty?
      message += "<br><br>Previous Choice comment: <i>(none)</i><br><br>
      Current Choice comment: " + params["comment"]
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
