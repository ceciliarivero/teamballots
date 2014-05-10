require_relative "../app"

Ost[:send_invitation].each do |json|
  hash = JSON.load(json)

  from_user = hash["from_user"]
  email = hash["email"]
  body = hash["body"]

  text = Mailer.render("send_invitation", { body: body })

  Malone.deliver(
    from: "info@teamballots.com",
    to: email,
    subject: "[Team Ballots] #{from_user} invites you to join as a voter",
    text: text)
end
