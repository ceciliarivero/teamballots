module Activation
  def self.unsign(signature)
    nobi = Nobi::Signer.new(NOBI_SECRET)

    begin
      user_id = nobi.unsign(signature)
      User[user_id]
    rescue Nobi::BadData
    end
  end
end