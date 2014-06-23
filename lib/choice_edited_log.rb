module ChoiceEditedLog
  def self.create(user, ballot, choice, params = {})
    message = "<b>Choice '" + choice.title + "' was edited:</b>"

    if choice.title != params["title"]
      message += "<br><br><b>Previous Choice title:</b> " + choice.title + "<br><br>
      <b>Current Choice title:</b> " + params["title"]
    end

    if !choice.comment.empty? && choice.comment != params["comment"]
      message += "<br><br><b>Previous Choice comment:</b><br>" + choice.comment + "<br><br>
      <b>Current Choice comment:</b><br>" + params["comment"]
    elsif choice.comment.empty? && !params["comment"].empty?
      message += "<br><br><b>Previous Choice comment:</b> (none)<br><br>
      <b>Current Choice comment:</b><br>" + params["comment"]
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
