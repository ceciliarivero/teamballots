var closeAccount = document.getElementById('close_account');

if (closeAccount) {
  closeAccount.onclick = function () {
    return confirm("Are you sure you want to close your account?");
  };
}

function remove_group_voter(id) {
  var voter = document.getElementById('group_voter_' + id);
  return confirm("Are you sure you want to remove this voter from the group?");
};

function remove_group(id) {
  var group = document.getElementById('group_' + id);
  return confirm("Are you sure you want to remove this group?");
};

function remove_choice(id) {
  var choice = document.getElementById('choice_' + id);
  return confirm("Are you sure you want to remove this choice?");
};

function remove_voter(id) {
  var voter = document.getElementById('voter_' + id);
  return confirm("Are you sure you want to remove yourself from the ballot?");
};
