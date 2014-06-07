setup do
  new_ballot = NewBallot.new(title: 'ruby rocks',
                             created_by: 'john',
                             end_choices_date: Time.new.to_i+3600,
                             end_date: Time.new.to_i+7200)

  new_choice = NewChoice.new(title: 'ruby rocks', added_by: 'john')

  new_comment = NewComment.new(message: 'ruby rocks', added_by: 'john')

  assert new_ballot.valid?
  assert new_choice.valid?
  assert new_comment.valid?

  ballot = Ballot.create(new_ballot.attributes)
  assert_equal 'john', ballot.created_by

  choice = Choice.create(new_choice.attributes)
  assert_equal 'john', choice.added_by

  comment = Comment.create(new_comment.attributes)
  assert_equal 'john', comment.added_by
  [ballot, choice, comment]
end

test do |ballot, choice, comment|
  OwnershipRenamer.execute('john', 'martin')
  ballot.load!
  choice.load!
  comment.load!

  assert_equal 'martin', ballot.created_by
  assert_equal 'martin', choice.added_by
  assert_equal 'martin', comment.added_by
end
