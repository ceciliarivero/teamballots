require_relative "../app"

Ost[:welcome].each do |id|
  user = User[id]
  text = Mailer.render("welcome", { user: user })

  Malone.deliver(
    from: "info@teamballots.com",
    to: user.email,
    subject: "[Team Ballots] Welcome!",
    text: text)
end
