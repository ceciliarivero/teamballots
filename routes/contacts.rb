class Contacts < Cuba
  define do
    on post, param("contact") do |params|
      mail = Contact.new(params)

      if mail.valid?
        session[:success] = "Thanks for your message!"

        json = JSON.dump(email: params["email"],
          body: params["body"])

        Ost[:contact].push(json)

        res.redirect "/"
      else
        session[:error] = "All fields are required and must be valid"
        render("contact", title: "Contact us",
          contact: params)
      end
    end

    on default do
      render("contact", title: "Contact",
        contact: {})
    end
  end
end
