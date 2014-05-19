class Guests < Cuba
  define do
    on get, root do
      res.redirect "/"
    end

    on "signup" do
      on post, param("user") do |params|

        signup = Signup.new(params)

        on signup.valid? do
          params.delete("password_confirmation")
          params["status"] = "tbc"

          user = User.create(params)

          signer = Nobi::TimestampSigner.new(NOBI_SECRET)
          signed = signer.sign(String(user.id))

          link = RESET_URL + "/activate/%s" % signed
          text = Mailer.render("activate", { user: user, link: link })

          Malone.deliver(
            from: "info@teamballots.com",
            to: user.email,
            subject: "[Team Ballots] Account activation",
            text: text)

          res.redirect "/signup/?activate=true", 303
        end

        on default do
          render("signup", title: "Sign up",
            user: params, signup: signup)
        end
      end

      on param("activate") do
        session[:success] = "Check your e-mail and follow the instructions to activate your account."
        res.redirect "/"
      end

      on default do
        render("signup", title: "Sign up",
          user: {}, signup: Signup.new({}))
      end
    end

    on "activate/:signature" do |signature|
      user = Otp.unsign(signature, 7200)

      on user do
        on user.status != "confirmed" do
          user.update(status: "confirmed")

          authenticate(user)

          session[:success] = "You have successfully activated your account and logged in!"

          Ost[:welcome].push(user.id)
          Ost[:new_user].push(user.id)

          res.redirect "/dashboard", 303
        end

        on default do
          session[:error] = "You have already activated your account, you can login now"
          res.redirect "/"
        end
      end

      on get, root do
        session[:error] = "Invalid or expired URL. Please contact us so we can send you a new activation link"
        res.redirect("/contact")
      end

      on(default) { not_found! }
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

          user = User[session["User"]]

          on user.status == "tbc" do
            logout(User)

            session[:error] = "You need to confirm your account first."
            res.redirect "/"
          end

          on default do
            session[:success] = "You have successfully logged in!"
            res.redirect "/dashboard"
          end
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

    on "forgot-password" do
      on post do
        user = User.fetch(req[:email])

        on user do
          nobi = Nobi::TimestampSigner.new(NOBI_SECRET)
          signature = nobi.sign(String(user.id))

          link = RESET_URL + "/otp/%s" % signature
          text = Mailer.render("password_reset", { user: user, link: link })

          Malone.deliver(
            from: "info@teamballots.com",
            to: user.email,
            subject: "[Team Ballots] Password recovery",
            text: text)

          res.redirect "/login/?recovery=true", 303
        end

        on default do
          session[:error] = "Can't find a user with that e-mail."
          res.redirect("/forgot-password", 303)
        end
      end

      on get, root do
        render("forgot-password",
          title: "Password recovery")
      end

      on default do
        not_found!
      end
    end

    on "otp/:signature" do |signature|
      user = Otp.unsign(signature, 7200)

      on user do
        on post, param("user") do |params|
          reset = PasswordRecovery.new(params)

          on reset.valid? do
            user.update(password: reset.password)

            authenticate(user)

            session[:success] = "You have successfully changed
            your password and logged in!"

            Ost[:password_changed].push(user.id)

            res.redirect "/", 303
          end

          on default do
            render("otp", title: "Password recovery",
              user: user, signature: signature,
              reset: reset)
          end
        end

        on default do
          render("otp", title: "Password recovery",
            user: user, signature: signature)
        end
      end

      on get, root do
        session[:error] = "Invalid or expired URL. Please try again!"
        res.redirect("/forgot-password")
      end

      on(default) { not_found! }
    end

    on default do
      not_found!
    end
  end
end
