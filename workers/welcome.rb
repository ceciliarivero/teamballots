require_relative "../app"

begin
  Ost[:welcome].each do |id|
    user = User[id]
    text = Mailer.render("welcome", { user: user })

    Malone.deliver(
      from: "info@teamballots.com",
      to: user.email,
      subject: "[Team Ballots] Welcome!",
      text: text)
  end
rescue Net::SMTPAuthenticationError
  Ost[:welcome_failures_log].push(sprintf("MALONE_URL: %s, id: %s", MALONE_URL.inspect, id))
end
