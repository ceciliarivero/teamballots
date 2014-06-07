module OwnershipRenamer
  def self.execute(old_name, new_name)
    return false if old_name == new_name

    Ballot.find(created_by: old_name).each do |ballot|
      ballot.update(created_by: new_name)
    end

    Choice.find(added_by: old_name).each do |choice|
      choice.update(added_by: new_name)
    end

    Comment.find(added_by: old_name).each do |comment|
      comment.update(added_by: new_name)
    end
  end
end
