var closeAccount = document.getElementById('close_account');
var deleteGroupVoter = document.getElementById('delete_group_voter');
var removeGroup = document.getElementById('remove_group');
var removeChoice = document.getElementById('remove_choice');
var removeVoter = document.getElementById('remove_voter');

if (closeAccount) {
  closeAccount.onclick = function () {
    return confirm("Are you sure you want to close your account?");
  };
}

if (deleteGroupVoter) {
  deleteGroupVoter.onclick = function () {
    return confirm("Are you sure you want to remove this voter from the group?");
  };
}

if (removeGroup) {
  removeGroup.onclick = function () {
    return confirm("Are you sure you want to remove this group?");
  };
}

if (removeChoice) {
  removeChoice.onclick = function () {
    return confirm("Are you sure you want to remove this choice?");
  };
}

if (removeVoter) {
  removeVoter.onclick = function () {
    return confirm("Are you sure you want to remove yourself from the ballot?");
  };
}
