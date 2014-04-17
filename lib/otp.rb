module Otp
  def self.unsign(signature, max_age)
    nobi = Nobi::TimestampSigner.new(NOBI_SECRET)

    begin
      user_id = nobi.unsign(signature, max_age: max_age)
      User[user_id]
    rescue Nobi::BadData
    end
  end
end