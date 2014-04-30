module UserRemovedLog
  def self.create(user)
    message = "Voter closed account:<br><br>
    Voter name: " + user.name + "<br>
    Voter username: " + user.username + "<br>
    Voter email: " + user.email

    log_comment = {}

    user.ballots.each do |ballot|
        log_comment["date"] = Time.new.to_i
        log_comment["user_id"] = user.id
        log_comment["ballot_id"] = ballot.id
        log_comment["added_by"] = user.name
        log_comment["message"] = message

        Comment.create(log_comment)
    end
  end
end
