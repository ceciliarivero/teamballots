class Users < Cuba
  define do
    user = current_user

    on "dashboard" do
      on get, root do
        render("user/dashboard", title: "Dashboard")
      end

      on(default) { not_found! }
    end

    on "edit" do
      on post, param("user") do |params|
        params.delete("password") if params["password"].empty?

        edit = EditUser.new(params)

        on edit.valid? do
          params.delete("password_confirmation")

          on user.email != edit.email && User.with(:email, edit.email) do
            session[:error] = "This e-mail is already registered"
            render("user/edit", title: "Edit profile",
              edit: edit, user: user)
          end

          on user.username != edit.username && User.with(:username, edit.username) do
            session[:error] = "This username is already taken"
            render("user/edit", title: "Edit profile",
              edit: edit, user: user)
          end

          on default do
            if user.name != params["name"]
              ballots = Ballot.find(created_by: user.name)
              choices = Choice.find(added_by: user.name)

              ballots.each do |ballot|
                ballot.update(created_by: params["name"])
              end

              choices.each do |choice|
                choice.update(added_by: params["name"])
              end
            end

            user.update(params)

            # if !params["password"].nil?
            #   Ost[:password_changed].push(user.id)
            # end

            session[:success] = "Your account was successfully updated!"
            res.redirect "/dashboard"
          end
        end

        on default do
          render("user/edit",
            title: "Edit profile", edit: edit, user: user)
        end
      end

      on default do
        edit = EditUser.new({})

        render("user/edit",
          title: "Edit profile", edit: edit, user: user)
      end
    end

    on "logout" do
      logout(User)
      session[:success] = "You have successfully logged out!"
      res.redirect "/"
    end

    on "delete" do
      user.delete

      logout(User)
      session[:success] = "You have successfully deleted your account"

      # Ost[:deleted_user].push(user.id)

      res.redirect "/"
    end

    on "ballot/new" do
      on post, param("ballot") do |params|
        params["start_date"] = Time.new.to_i

        if params["end_choices_date"] != ""
          params["end_choices_date"] = Time.iso8601(((params["end_choices_date"] + ":00").sub("T"," ")).sub(/ /,'T')).to_i
        else
          params["end_choices_date"] = nil
        end

        if params["end_date"] != ""
          params["end_date"] = Time.iso8601(((params["end_date"] + ":00").sub("T"," ")).sub(/ /,'T')).to_i
        else
          params["end_date"] = nil
        end

        params["status"] = "active"

        new_ballot = NewBallot.new(params)

        on new_ballot.valid? do
          params["user_id"] = user.id
          params["created_by"] = user.name

          ballot = Ballot.create(params)

          user.ballots.add(ballot)
          ballot.voters.add(user)

          # Ost[:new_ballot].push(ballot.id)

          session[:success] = "You have successfully posted a new ballot!"
          res.redirect "/dashboard"
        end

        on default do
          render("ballot/new",
            title: "Create new ballot", ballot: new_ballot)
        end
      end

      on get, root do
        new_ballot = NewBallot.new({})

        render("ballot/new",
          title: "Create new ballot", ballot: new_ballot,
          end_choices_date: nil, end_date: nil)
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/edit" do |id|
      ballot = user.ballots[id]

      on ballot do
        if ballot.status? == "active"
          on post do
            on req.post?, param("ballot") do |params|
              if params["end_choices_date"] != ""
                params["end_choices_date"] = Time.iso8601(((params["end_choices_date"] + ":00").sub("T"," ")).sub(/ /,'T')).to_i
              else
                params["end_choices_date"] = nil
              end

              if params["end_date"] != ""
                params["end_date"] = Time.iso8601(((params["end_date"] + ":00").sub("T"," ")).sub(/ /,'T')).to_i
              else
                params["end_date"] = nil
              end

              edit = NewBallot.new(params)

              on edit.valid? do
                ballot.update(params)

                session[:success] = "Ballot successfully edited!"
                res.redirect "/ballot/#{id}"
              end

              on default do
                ballot.end_choices_date = Time.at(ballot.end_choices_date.to_i).strftime("%Y-%m-%eT%H:%M")
                ballot.end_date = Time.at(ballot.end_date.to_i).strftime("%Y-%m-%eT%H:%M")

                render("ballot/edit",
                  title: "Edit ballot", ballot: ballot, edit: edit)
              end
            end

            on default do
              ballot.end_choices_date = Time.at(ballot.end_choices_date.to_i).strftime("%Y-%m-%eT%H:%M")
              ballot.end_date = Time.at(ballot.end_date.to_i).strftime("%Y-%m-%eT%H:%M")

              render("ballot/edit",
                title: "Edit ballot", ballot: ballot, edit: NewBallot.new({}))
            end
          end

          on get, root do
            ballot.end_choices_date = Time.at(ballot.end_choices_date.to_i).strftime("%Y-%m-%eT%H:%M")
            ballot.end_date = Time.at(ballot.end_date.to_i).strftime("%Y-%m-%eT%H:%M")

            render("ballot/edit",
              title: "Edit ballot", ballot: ballot)
          end
        else
          session[:error] = "Ballot cannot be edited. We're in Voting Only period now."
          res.redirect "/ballot/#{id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/remove" do |id|
      ballot = user.ballots[id]

      on ballot do
        on get do
          ballot.delete

          # Ost[:removed_ballot].push(id)

          session[:success] = "Ballot successfully removed"
          res.redirect "/dashboard"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/choices/add" do |id|
      ballot = user.ballots[id]

      on ballot do
        if ballot.status? == "active"
          on post, param("choice") do |params|
            params["date"] = Time.new.to_i

            choice = NewChoice.new(params)

            on choice.valid? do
              params["user_id"] = user.id
              params["ballot_id"] = ballot.id
              params["added_by"] = user.name

              Choice.create(params)

              session[:success] = "You have successfully added a choice!"
              res.redirect "/ballot/#{id}/choices"
            end

            on default do
              render("ballot/add_choice",
                title: "Add choice", ballot: ballot, choice: choice)
            end
          end

          on get, root do
            render("ballot/add_choice",
              title: "Add choice", ballot: ballot, choice: NewChoice.new({}))
          end
        else
          session[:error] = "Choices cannot be added anymore. We're in Voting Only period now."
          res.redirect "/ballot/#{id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:ballot_id/choices/:choice_id/remove" do |ballot_id, choice_id|
      ballot = user.ballots[ballot_id]

      on ballot do
        if ballot.status? == "active"
          choice = ballot.choices[choice_id]

          on get do
            on choice.user_id != user.id do
              session[:error] = "You can only remove choices added by you"
              res.redirect "/ballot/#{ballot_id}/choices"
            end

            on default do
              choice.delete

              # Ost[:removed_choice].push(id)

              session[:success] = "Choice successfully removed"
              res.redirect "/ballot/#{ballot_id}/choices"
            end
          end

        else
          session[:error] = "Choices cannot be removed. We're in Voting Only period now."
          res.redirect "/ballot/#{ballot_id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/choices" do |id|
      ballot = user.ballots[id]

      on ballot do
        on get, root do
          render("ballot/choices",
            title: "Choices", ballot: ballot, choice: NewChoice.new({}))
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:ballot_id/voters/:voter_id/remove" do |ballot_id, voter_id|
      ballot = user.ballots[ballot_id]

      on ballot do
        voter = User[voter_id]

        on get do
          on voter != user do
            session[:error] = "You can't remove other users, just yourself."
            res.redirect "/ballot/#{ballot_id}/voters"
          end

          on voter == user && ballot.voters.size == 1  do
            session[:error] = "You can't remove yourself if you're the only one voter."
            res.redirect "/ballot/#{ballot_id}/voters"
          end

          on default do
            ballot.voters.delete(voter)
            voter.ballots.delete(ballot)

            # Ost[:removed_ballot].push(id)

            session[:success] = "Voter successfully removed"
            res.redirect "/dashboard"
          end
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/voters/add" do |id|
      ballot = user.ballots[id]

      on ballot do
        if ballot.status? == "active"
          on post, param("voter") do |params|
            voter = NewVoter.new(params)

            on voter.valid? do
              new_voter = User.with(:email, voter.email)

              on new_voter && new_voter.email == user.email do
                session[:error] = "You are already a voter! :-)"
                render("ballot/add_voter",
                  title: "Add voter", ballot: ballot, voter: voter)
              end

              on new_voter && ballot.voters.include?(new_voter) do
                session[:error] = "Voter already added"
                render("ballot/add_voter",
                  title: "Add voter", ballot: ballot, voter: voter)
              end

              on new_voter do
                ballot.voters.add(new_voter)
                new_voter.ballots.add(ballot)

                session[:success] = "Voter successfully added!"
                res.redirect "/ballot/#{id}/voters"
              end

              on default do
                session[:error] = "E-mail is not registered"
                render("ballot/add_voter",
                  title: "Add voter", ballot: ballot, voter: voter)
              end
            end

            on default do
              render("ballot/add_voter",
                title: "Add voter", ballot: ballot, voter: voter)
            end
          end

          on get, root do
            render("ballot/add_voter",
              title: "Add voter", ballot: ballot, voter: NewVoter.new({}))
          end
        else
          session[:error] = "Voters cannot be added. We're in Voting Only period now."
          res.redirect "/ballot/#{id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/voters" do |id|
      ballot = user.ballots[id]

      on ballot do
        on get, root do
          render("ballot/voters",
            title: "Voters", ballot: ballot, voter: NewVoter.new({}))
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/vote" do |id|
      ballot = user.ballots[id]

      on ballot do
        if ballot.status? != "closed"
          on post, param("vote") do |votes|
            valid_votes = []

            votes.each do |rating|
              params = {}
              params["rating"] = rating[1]

              vote = NewVote.new(params)

              if vote.valid?
                params["date"] = Time.new.to_i
                params["choice_id"] = rating[0]
                params["user_id"] = user.id

                new_vote = Vote.create(params)

                valid_votes << new_vote
              end
            end

            on valid_votes.size == votes.size do
              session[:success] = "You have successfully voted!"
              res.redirect "/ballot/#{id}"
            end

            on default do
              session[:error] = "Vote wasn't valid. Please try again."
              res.redirect "/ballot/#{id}"
            end
          end

          on get, root do
            render("ballot/vote",
              title: "Vote", ballot: ballot, voter: NewVote.new({}))
          end
        else
          session[:error] = "Ballot is closed."
          res.redirect "/ballot/#{id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id" do |id|
      ballot = user.ballots[id]

      on ballot do
        on get, root do
          render("ballot/info",
            title: ballot.title, ballot: ballot)
        end
      end

      on default do
        not_found!
      end
    end

    on default do
      not_found!
    end
  end
end
