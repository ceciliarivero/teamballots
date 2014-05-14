Encoding.default_external = "UTF-8"

require "cuba"
require "cuba/contrib"
require "malone"
require "mote"
require "nobi"
require "ohm"
require "ohm/contrib"
require "ost"
require "rack/protection"
require "scrivener"
require "shield"

APP_SECRET = ENV.fetch("APP_SECRET")
MALONE_URL = ENV.fetch("MALONE_URL")
OPENREDIS_URL = ENV.fetch("OPENREDIS_URL")
RESET_URL = ENV.fetch("RESET_URL")
NOBI_SECRET = ENV.fetch("NOBI_SECRET")

ROOT = File.expand_path("../", __FILE__)

Cuba.plugin Cuba::Mote
Cuba.plugin Cuba::TextHelpers
Cuba.plugin Shield::Helpers

Ohm.redis = Redic.new(OPENREDIS_URL)
Ost.connect(url: OPENREDIS_URL)
Malone.connect(url: MALONE_URL, tls: false, domain: "teamballots.com")

Dir["./models/**/*.rb"].each  { |rb| require rb }
Dir["./routes/**/*.rb"].each  { |rb| require rb }
Dir["./helpers/**/*.rb"].each { |rb| require rb }
Dir["./filters/**/*.rb"].each { |rb| require rb }
Dir["./lib/**/*.rb"].each     { |rb| require rb }
Dir["./services/**/*.rb"].each     { |rb| require rb }

Cuba.plugin UserHelpers
Cuba.plugin BallotHelpers

Cuba.use Rack::Session::Cookie,
  key: "team_ballots",
  secret: APP_SECRET

Cuba.use Rack::Protection, except: :http_origin
Cuba.use Rack::Protection::RemoteReferrer

Cuba.use Rack::Static,
  urls: %w[/js /css /img],
  root: File.expand_path("./public", __dir__)

Cuba.define do
  persist_session!

  on root do
    on authenticated(User) do
      res.redirect "/dashboard"
    end

    on default do
      render("home", title: "Home")
    end
  end

  on "about" do
    render("about", title: "About Team Ballots")
  end

  on "contact" do
    run Contacts
  end

  on authenticated(User) do
    run Users
  end

  on default do
    run Guests
  end
end
