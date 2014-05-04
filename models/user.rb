class User < Ohm::Model
  include Shield::Model
  include Ohm::Callbacks

  attribute :name
  attribute :username
  attribute :email
  attribute :crypted_password
  attribute :gravatar
  attribute :status

  index :status

  unique :username
  unique :email

  def self.fetch(identifier)
    with(:email, identifier) || with(:username, identifier)
  end

  def before_delete
    # The following loop needs to be changed, to not iterate through ALL the groups
    Group.all.each do |group|
      group.voters.delete(self)
    end

    ballots.each do |ballot|
      ballot.voters.delete(self)
    end

    groups.each(&:delete)

    super
  end

  set :groups, :Group
  set :ballots, :Ballot
end
