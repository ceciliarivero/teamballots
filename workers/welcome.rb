require_relative "../app"

Ost[:welcome].each do |id|
  user = User[id]
  text_welcome = Mailer.render("welcome", { user: user })
  text_new_user = Mailer.render("new_user", { user: user })

  Malone.deliver(
    from: "info@teamballots.com",
    to: user.email,
    subject: "[Team Ballots] Welcome!",
    text: text_welcome)

  Malone.deliver(
    from: "info@teamballots.com",
    to: "info@teamballots.com",
    subject: "[Team Ballots] New user",
    text: text_new_user)
end
