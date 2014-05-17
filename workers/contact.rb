require_relative "../app"

begin
  Ost[:contact].each do |json|
    hash = JSON.load(json)

    email = hash["email"]
    body = hash["body"]

    text = Mailer.render("contact",
      email: email, body: body)

    Malone.deliver(
      from: "info@teamballots.com",
      to: "info@teamballots.com",
      subject: "[Team Ballots] Message received!",
      text: text)
  end
rescue Net::SMTPAuthenticationError
  Ost[:contact_failures_log].push(sprintf("MALONE_URL: %s, json: %s", MALONE_URL.inspect, json))
end
