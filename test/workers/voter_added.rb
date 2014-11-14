require 'cuba/test'
require 'malone/test'
require_relative '../../app'

scope do
  test 'send email to voters after added' do
    time = Time.now.to_i
    user = User.create(email: 'user@example.com', password: 'secret',
      status: 'confirmed', name: 'owner', username: 'owner')
    voter = User.create(email: 'voter@example.com', password: 'secret',
      status: 'confirmed', name: 'voter', username: 'voter')
    ballot = Ballot.create(user_id: user.id, created_by: 'foo', title: 'test',
      description: 'foo', end_choices_date: time + 14400, start_date: time,
      end_date: time + 28800)

    user.ballots.add(ballot)
    ballot.voters.add(user)

    post '/login', user: { email: user.email, password: 'secret' }

    post "/ballot/#{ballot.id}/voters/add", voter: { email: voter.email }

    Thread.new do
      require_relative '../../workers/voter_added.rb'
    end

    sleep 1

    ballot_ref = "Go to https://www.teamballots.com/ballot/#{ballot.id}"
    assert Malone.deliveries.first.text.include?(ballot_ref)
  end
end
