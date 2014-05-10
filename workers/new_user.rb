require_relative "../app"

Ost[:new_user].each do |id|
  user = User[id]
  text = Mailer.render("new_user", { user: user })

  Malone.deliver(
    from: "info@teamballots.com",
    to: "info@teamballots.com",
    subject: "[Team Ballots] New user",
    text: text)
end
