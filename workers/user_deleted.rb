require_relative "../app"

Ost[:user_deleted].each do |id|
  user = User[id]
  text = Mailer.render("user_deleted", { user: user })

  Malone.deliver(
    from: "info@teamballots.com",
    to: "info@teamballots.com",
    subject: "[Team Ballots] User deleted",
    text: text)

  user.delete
end
