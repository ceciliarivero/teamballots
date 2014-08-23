require "cuba/test"
require "malone/test"
require_relative "../../app"

scope do
  test "send email to voters after comment" do
    time = Time.now.to_i
    user = User.create({ email: 'user@example.com', password: 'secret',
      status: 'confirmed', name: 'owner' })
    voter = User.create({ email: 'voter@example.com', password: 'secret',
      status: 'confirmed', name: 'voter' })
    ballot = Ballot.create({ user_id: user.id, created_by: 'foo', title: 'test',
      description: 'foo', end_choices_date: time + 14400, start_date: time,
      end_date: time + 28800 })

    user.ballots.add(ballot)
    voter.ballots.add(ballot)
    ballot.voters.add(user)
    ballot.voters.add(voter)

    post "/login", { user: { email: voter.email, password: 'secret' } }

    get "/ballot/#{ballot.id}"

    post "/ballot/#{ballot.id}/add_comment",
      { comment: { message: 'fooo' } }

    Thread.new do
      require_relative '../../workers/comment_made.rb'
    end

    sleep 1

    assert_equal 1, Malone.deliveries.size
  end
end
