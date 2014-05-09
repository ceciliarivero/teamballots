module Mailer
  extend Mote::Helpers

  def self.render(template, params = {})
    mote("#{ROOT}/mails/%s.md" % template, params)
  end
end
