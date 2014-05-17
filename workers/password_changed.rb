require_relative "../app"

begin
  Ost[:password_changed].each do |id|
    user = User[id]
    text = Mailer.render("password_changed", { user: user })

    Malone.deliver(
      from: "info@teamballots.com",
      to: user.email,
      subject: "[Team Ballots] Password change confirmation",
      text: text)
  end
rescue Net::SMTPAuthenticationError
  Ost[:password_changed_failures_log].push(sprintf("MALONE_URL: %s, id: %s", MALONE_URL.inspect, id))
end
