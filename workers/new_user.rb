require_relative "../app"

begin
  Ost[:new_user].each do |id|
    user = User[id]
    text = Mailer.render("new_user", { user: user })

    Malone.deliver(
      from: "info@teamballots.com",
      to: "info@teamballots.com",
      subject: "[Team Ballots] New user",
      text: text)
  end
rescue Net::SMTPAuthenticationError
  Ost[:new_user_failures_log].push(sprintf("MALONE_URL: %s, id: %s", MALONE_URL.inspect, id))
end
