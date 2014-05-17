require_relative "../app"

begin
  Ost[:voter_added].each do |json|
    hash = JSON.load(json)

    email = hash["email"]
    name = hash["name"]
    ballot_title = hash["ballot_title"]
    ballot_description = hash["ballot_description"]
    end_date = hash["end_date"]

    text = Mailer.render("voter_added", {
      name: name,
      ballot_title: ballot_title,
      ballot_description: ballot_description,
      end_date: end_date })

    Malone.deliver(
      from: "info@teamballots.com",
      to: email,
      subject: "[Team Ballots] You have been added to a ballot",
      text: text)
  end
rescue Net::SMTPAuthenticationError
  Ost[:voter_added_failures_log].push(sprintf("MALONE_URL: %s, json: %s", MALONE_URL.inspect, json))
end
