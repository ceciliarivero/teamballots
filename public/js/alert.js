var closeAccount = document.getElementById('close_account');

if (closeAccount) {
  closeAccount.onclick = function () {
    return confirm("Are you sure you want to close your account?");
  };
}