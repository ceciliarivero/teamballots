require_relative "../app"

Ost[:password_changed].each do |id|
  user = User[id]
  text = Mailer.render("password_changed", { user: user })

  Malone.deliver(
    from: "info@teamballots.com",
    to: user.email,
    subject: "[Team Ballots] Password change confirmation",
    text: text)
end
