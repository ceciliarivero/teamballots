class Guests < Cuba
  define do
    on get, root do
      res.redirect "/"
    end

    on "signup" do
      on post, param("user") do |params|

        user = UserCreator.create(params)

        on user do
          authenticate(user)

          session[:success] = "You have successfully signed up!"

          # Ost[:welcome].push(user.id)

          res.redirect "/dashboard"
        end

        on default do
          render("signup", title: "Sign up",
            user: params, signup: signup)
        end
      end

      on default do
        render("signup", title: "Sign up",
          user: {}, signup: Signup.new({}))
      end
    end

    on "login" do
      on post, param("user") do |params|
        user = params["email"]
        pass = params["password"]
        remember = params["remember"]

        if login(User, user, pass)
          if remember
            remember(3600)
          end

          session[:success] = "You have successfully logged in!"
          res.redirect "/dashboard"
        else
          session[:error] = "Invalid email/password combination"

          render("login", title: "Login", user: user)
        end
      end

      on param("recovery") do
        session[:success] = "Check your e-mail and follow the instructions."
        res.redirect "/login"
      end

      on get, root do
        render("login", title: "Login", user: "")
      end

      on default do
        not_found!
      end
    end

    # on "forgot-password" do
    #   on get do
    #     render("forgot-password",
    #       title: "Password recovery")
    #   end

    #   on post do
    #     user = User.fetch(req[:email])

    #     on user do
    #       nobi = Nobi::TimestampSigner.new(NOBI_SECRET)
    #       signature = nobi.sign(String(user.id))

    #       Malone.deliver(
    #         from: "info@teamballots.com",
    #         to: user.email,
    #         subject: "[Team Ballots] Password recovery",
    #         html: "To reset your password, please copy and paste this link into your browser's URL address bar: " +
    #         RESET_URL + "/otp/%s" % signature)

    #       res.redirect "/login/?recovery=true", 303
    #     end

    #     on default do
    #       session[:error] = "Can't find a user with that e-mail."
    #       res.redirect("/forgot-password", 303)
    #     end
    #   end
    # end

    # on "otp/:signature" do |signature|
    #   user = Otp.unsign(signature, 7200)

    #   on user do
    #     on post, param("user") do |params|
    #       reset = PasswordRecovery.new(params)

    #       on reset.valid? do
    #         user.update(password: reset.password)

    #         authenticate(user)

    #         session[:success] = "You have successfully changed
    #         your password and logged in!"

    #         # Ost[:password_changed].push(user.id)

    #         res.redirect "/", 303
    #       end

    #       on default do
    #         render("otp", title: "Password recovery",
    #           user: user, signature: signature,
    #           reset: reset)
    #       end
    #     end

    #     on default do
    #       render("otp", title: "Password recovery",
    #         user: user, signature: signature)
    #     end
    #   end

    #   on get, root do
    #     session[:error] = "Invalid or expired URL. Please try again!"
    #     res.redirect("/forgot-password")
    #   end

    #   on(default) { not_found! }
    # end

    # on "password/:signature" do |signature|
    #   user = Otp.unsign(signature, 604800)

    #   on user do
    #     on post, param("user") do |params|
    #       reset = PasswordRecovery.new(params)

    #       on reset.valid? do
    #         user.update(password: reset.password)

    #         authenticate(user)

    #         session[:success] = "You have successfully changed
    #         your password and logged in!"

    #         # Ost[:password_changed].push(user.id)

    #         res.redirect "/", 303
    #       end

    #       on default do
    #         render("first_time_login", title: "First time login",
    #           user: user, signature: signature, reset: reset)
    #       end
    #     end

    #     on default do
    #       render("first_time_login", title: "First time login",
    #         user: user, signature: signature)
    #     end
    #   end

    #   on get, root do
    #     session[:error] = "This URL has expired. Send a mail to info@teamballots.com and we'll send you a new one right away!"
    #     res.redirect "/password"
    #   end

    #   on default do
    #     not_found!
    #   end
    # end

    on default do
      not_found!
    end
  end
end
