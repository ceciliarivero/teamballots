require "cuba/test"
require_relative "../../app"

prepare do
  User.create({ email: "foo@mail.com", password: "12345678" })
end

scope do
  test "redirect to /ballot/:id after login" do
    get "/ballot/1"

    follow_redirect!

    assert_equal "/login", last_request.env['PATH_INFO']

    post "/login", { user: { email: "foo@mail.com", password: "12345678" } }

    follow_redirect!

    assert_equal "/ballot/1", last_request.env['PATH_INFO']
  end
end
