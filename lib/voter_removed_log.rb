module VoterRemovedLog
  def self.create(user, ballot, voter)
    message = "Voter self-removed:<br><br>
    Voter name: " + voter.name + "<br>
    Voter username: " + voter.username + "<br>
    Voter email: " + voter.email

    log_comment = {}

    log_comment["date"] = Time.new.to_i
    log_comment["user_id"] = user.id
    log_comment["ballot_id"] = ballot.id
    log_comment["added_by"] = user.name
    log_comment["message"] = message

    Comment.create(log_comment)
  end
end
