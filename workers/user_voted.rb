require_relative "../app"

Ost[:user_voted].each do |json|
  hash = JSON.load(json)

  email = hash["email"]
  name = hash["name"]
  vote_by = hash["vote_by"]
  ballot_title = hash["ballot_title"]

  text = Mailer.render("user_voted", {
    name: name,
    vote_by: vote_by,
    ballot_title: ballot_title })

  Malone.deliver(
    from: "info@teamballots.com",
    to: email,
    subject: "[Team Ballots] Vote notification",
    text: text)
end
