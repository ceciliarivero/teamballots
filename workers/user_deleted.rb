require_relative "../app"

begin
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
rescue Net::SMTPAuthenticationError
  Ost[:user_deleted_failures_log].push(sprintf("MALONE_URL: %s, id: %s", MALONE_URL.inspect, id))
end
