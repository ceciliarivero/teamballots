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
              OwnershipRenamer.execute(user.name, params["name"])
            end

            user.update(params)

            if !params["password"].nil?
              Ost[:password_changed].push(user.id)
            end

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
      UserRemovedLog.create(user)

      logout(User)
      session[:success] = "You have successfully deleted your account"

      Ost[:user_deleted].push(user.id)

      res.redirect "/"
    end

    on "group/new" do
      on post, param("group") do |params|

        new_group = NewGroup.new(params)

        on new_group.valid? do
          params["user_id"] = user.id

          group = Group.create(params)

          user.groups.add(group)

          session[:success] = "You have successfully created a new group!"
          res.redirect "/group/#{group.id}"
        end

        on default do
          render("group/new",
            title: "Create new group", group: new_group)
        end
      end

      on get, root do
        render("group/new",
          title: "Create new group")
      end

      on default do
        not_found!
      end
    end

    on "group/:id/voters/add" do |id|
      group = user.groups[id]

      on group do
        on post, param("voter") do |params|
          voter = NewVoter.new(params)

          on voter.valid? do
            new_voter = User.with(:email, voter.email)

            on new_voter && new_voter.email == user.email do
              session[:error] = "You are already a voter! No need to include yourself in the group. :-)"
              render("group/info",
                title: "Group", group: group, new_voter: voter)
            end

            on new_voter && group.voters.include?(new_voter) do
              session[:error] = "Voter already added"
              render("group/info",
                title: "Group", group: group, new_voter: voter)
            end

            on new_voter && new_voter.status == "confirmed" do
              group.voters.add(new_voter)

              session[:success] = "Voter successfully added!"
              res.redirect "/group/#{id}"
            end

            on new_voter && new_voter.status == "tbc" do
              session[:error] = "This user didn't activate the account yet"
              res.redirect "/group/#{id}"
            end

            on default do
              session[:error] = "The email you entered is not registered in Team Ballots"

              message = NewMessage.new(email: voter.email)

              render("group/invite",
                title: "Invite", group: group, message: message)
            end
          end

          on default do
            render("group/info",
              title: "Group", group: group, new_voter: voter)
          end
        end

        on get, root do
          render("group/info",
            title: "Group", group: group, new_voter: NewVoter.new({}))
        end
      end

      on default do
        not_found!
      end
    end

    on "group/:group_id/voters/:voter_id/remove" do |group_id, voter_id|
      group = user.groups[group_id]
      voter = User[voter_id]

      on group && voter do
        on get do
          group.voters.delete(voter)

          session[:success] = "Voter successfully removed"
          res.redirect "/group/#{group_id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "group/:id/remove" do |id|
      group = user.groups[id]

      on group do
        on get do
          user.groups.delete(group)
          group.delete

          session[:success] = "Group successfully removed"
          res.redirect "/dashboard"
        end
      end

      on default do
        not_found!
      end
    end

    on "group/:id/invite" do |id|
      group = user.groups[id]

      on group do
        on post, param("message") do |params|

          message = NewMessage.new(params)

          on message.valid? do

            json = JSON.dump(
              from_user: user.name,
              email: message.email,
              body: message.body)

            Ost[:send_invitation].push(json)

            session[:success] = "You have successfully send an invitation!"
            res.redirect "/group/#{id}"
          end

          on default do
            render("group/invite",
              title: "Invite", group: group, message: message)
          end
        end
      end

      on default do
        not_found!
      end
    end

    on "group/:id" do |id|
      group = user.groups[id]

      on group do
        on get, root do
          render("group/info",
            title: "Group", group: group, new_voter: NewVoter.new({}))
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/new" do
      on post, param("ballot") do |params|
        params["start_date"] = Time.new.to_i

        if params["end_choices_date"] != ""
          params["end_choices_date"] = cal_to_unix(params["end_choices_date"])
        else
          params["end_choices_date"] = nil
        end

        if params["end_date"] != ""
          params["end_date"] = cal_to_unix(params["end_date"])
        else
          params["end_date"] = nil
        end

        new_ballot = NewBallot.new(params)

        on new_ballot.valid? do
          params["user_id"] = user.id
          params["created_by"] = user.name

          ballot = Ballot.create(params)

          user.ballots.add(ballot)
          ballot.voters.add(user)

          session[:success] = "You have successfully posted a new ballot!"
          res.redirect "/dashboard"
        end

        on default do
          if new_ballot.end_choices_date != nil
            new_ballot.end_choices_date = unix_to_cal(new_ballot.end_choices_date)
          else
            new_ballot.end_choices_date = ""
          end

          if new_ballot.end_date != nil
            new_ballot.end_date = unix_to_cal(new_ballot.end_date)
          else
            new_ballot.end_date = ""
          end

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
        if ballot.status == "Active" && ballot.user_id == user.id
          on post do
            on req.post?, param("ballot") do |params|

              if valid_date?(params["end_choices_date"]) && valid_date?(params["end_date"])
                if params["end_choices_date"] != ""
                  params["end_choices_date"] = cal_to_unix(params["end_choices_date"])
                else
                  params["end_choices_date"] = unix_to_cal(ballot.end_choices_date)
                end

                if params["end_date"] != ""
                  params["end_date"] = cal_to_unix(params["end_date"])
                else
                  params["end_date"] = unix_to_cal(ballot.end_date)
                end

                edit = NewBallot.new(params)

                edit.start_date = Time.new.to_i

                on edit.valid? do

                  if ballot.title != params["title"] ||
                    ballot.description != params["description"] ||
                    ballot.end_choices_date.to_i != params["end_choices_date"] ||
                    ballot.end_date.to_i != params["end_date"]

                    BallotEditedLog.create(user, ballot, params)
                  end

                  ballot.update(params)

                  session[:success] = "Ballot successfully edited!"
                  res.redirect "/ballot/#{id}"
                end

                on default do
                  ballot.end_choices_date = unix_to_cal(ballot.end_choices_date)
                  ballot.end_date = unix_to_cal(ballot.end_date)

                  render("ballot/edit",
                    title: "Edit ballot", ballot: ballot, edit: edit)
                end
              else
                session[:error] = "Invalid date format"
                res.redirect "/ballot/#{id}/edit"
              end
            end

            on default do
              ballot.end_choices_date = unix_to_cal(ballot.end_choices_date)
              ballot.end_date = unix_to_cal(ballot.end_date)

              render("ballot/edit",
                title: "Edit ballot", ballot: ballot, edit: NewBallot.new({}))
            end
          end

          on get, root do
            ballot.end_choices_date = unix_to_cal(ballot.end_choices_date)
            ballot.end_date = unix_to_cal(ballot.end_date)

            render("ballot/edit",
              title: "Edit ballot", ballot: ballot)
          end
        elsif ballot.status == "Active" && ballot.user_id != user.id
          session[:error] = "Ballot can be edited only by #{ballot.created_by}"
          res.redirect "/ballot/#{id}"
        else
          session[:error] = "Ballot cannot be edited anymore"
          res.redirect "/ballot/#{id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/choices/add" do |id|
      ballot = user.ballots[id]

      on ballot do
        if ballot.status == "Active"
          on post, param("choice") do |params|
            params["date"] = Time.new.to_i
            params["added_by"] = user.name

            choice = NewChoice.new(params)

            on choice.valid? do
              params["user_id"] = user.id
              params["ballot_id"] = ballot.id

              choice_added = Choice.create(params)

              ChoiceAddedLog.create(user, ballot, choice_added)

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
          session[:error] = "Ballot cannot be edited anymore"
          res.redirect "/ballot/#{id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:ballot_id/choices/:choice_id/edit" do |ballot_id, choice_id|
      ballot = user.ballots[ballot_id]
      choice = ballot.choices.ids.include?(choice_id) if ballot

      on ballot && choice do
        choice = Choice[choice_id]

        if ballot.status == "Active"
          on post do
            on req.post?, param("choice") do |params|
              params["date"] = Time.new.to_i
              params["added_by"] = user.name

              edit = NewChoice.new(params)

              on edit.valid? do
                choice.comment = "" if choice.comment == nil

                if choice.title != params["title"] || choice.comment != params["comment"]
                  ChoiceEditedLog.create(user, ballot, choice, params)
                end

                choice.update(params)

                session[:success] = "You have successfully edited a choice!"
                res.redirect "/ballot/#{ballot_id}/choices"
              end

              on default do
                render("ballot/edit_choice",
                  title: "Edit choice", ballot: ballot, choice: choice, edit: edit)
              end
            end
          end

          on get, root do
            render("ballot/edit_choice",
              title: "Edit choice", ballot: ballot, choice: choice)
          end
        else
          session[:error] = "Ballot cannot be edited anymore"
          res.redirect "/ballot/#{ballot_id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:ballot_id/choices/:choice_id/remove" do |ballot_id, choice_id|
      ballot = user.ballots[ballot_id]
      choice = ballot.choices.ids.include?(choice_id)

      on ballot && choice do
        if ballot.status == "Active"
          choice = ballot.choices[choice_id]

          on get do
            on choice.user_id != user.id do
              session[:error] = "You can only remove choices added by you"
              res.redirect "/ballot/#{ballot_id}/choices"
            end

            on default do

              ChoiceRemovedLog.create(user, ballot, choice)

              choice.delete

              session[:success] = "Choice successfully removed"
              res.redirect "/ballot/#{ballot_id}/choices"
            end
          end

        else
          session[:error] = "Ballot cannot be edited anymore"
          res.redirect "/ballot/#{ballot_id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballots/closed" do
      closed_ballots = []

      user.ballots.each do |ballot|
        if ballot.status == "Closed"
          closed_ballots << ballot
        end
      end

      on !closed_ballots.empty? do
        on get, root do
          render("ballot/closed_ballots",
            title: "Closed ballots", closed_ballots: closed_ballots)
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
      voter = User[voter_id]

      on ballot && voter do
        on get do
          on voter != user do
            session[:error] = "You can't remove other users, just yourself."
            res.redirect "/ballot/#{ballot_id}/voters"
          end

          on voter == user && ballot.voters.size == 1  do

            ballot.delete

            session[:success] = "You have removed yourself and deleted the ballot (as you were the only one voter)."
            res.redirect "/dashboard"
          end

          on default do

            VoterRemovedLog.create(user, ballot, voter)

            ballot.voters.delete(voter)
            voter.ballots.delete(ballot)

            session[:success] = "You have removed yourself from the ballot."
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

      on ballot && ballot.user_id != user.id do
        session[:error] = "Voters can be added only by #{ballot.created_by}"
        res.redirect "/ballot/#{id}"
      end

      on ballot do
        if ballot.status != "Closed"
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

              on new_voter && new_voter.status == "confirmed" do
                ballot.voters.add(new_voter)
                new_voter.ballots.add(ballot)

                VoterAddedLog.create(user, ballot, new_voter)

                json = JSON.dump(
                  email: new_voter.email,
                  name: new_voter.name,
                  ballot_title: ballot.title,
                  ballot_description: ballot.description,
                  end_date: cal_utc(ballot.end_date))

                Ost[:voter_added].push(json)

                session[:success] = "Voter successfully added!"
                res.redirect "/ballot/#{id}/voters"
              end

              on new_voter && new_voter.status == "tbc" do
                session[:error] = "This user didn't activate the account yet"
                res.redirect "/ballot/#{id}"
              end

              on default do
                session[:error] = "The email you entered is not registered in Team Ballots"

                message = NewMessage.new(email: voter.email)

                render("ballot/invite",
                  title: "Invite", ballot: ballot, message: message)
              end
            end

            on default do
              render("ballot/add_voter",
                title: "Add voter", ballot: ballot, voter: voter)
            end
          end

          on post, param("voters") do |params|
            if params["group"] != ""
              group = user.groups.include?(Group[params["group"]])
            end

            on group do
              group = Group[params["group"]]

              voters = group.voters

              voters.each do |voter|
                if !ballot.voters.include?(voter)
                  VoterAddedLog.create(user, ballot, voter)
                end

                ballot.voters.add(voter)
                voter.ballots.add(ballot)

                json = JSON.dump(
                  email: voter.email,
                  name: voter.name,
                  ballot_title: ballot.title,
                  ballot_description: ballot.description,
                  end_date: cal_utc(ballot.end_date))

                Ost[:voter_added].push(json)
              end

              session[:success] = "Voters group successfully added!"
              res.redirect "/ballot/#{id}/voters"
            end

            on default do
              session[:error] = "The voters group selected was not valid"
              res.redirect "/ballot/#{id}/voters/add"
            end
          end

          on get, root do
            render("ballot/add_voter",
              title: "Add voter", ballot: ballot, voter: NewVoter.new({}))
          end
        else
          session[:error] = "Ballot cannot be edited anymore"
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

    on "ballot/:id/add_comment" do |id|
      ballot = user.ballots[id]

      on ballot do
        if ballot.status != "Closed"
          on post, param("comment") do |params|
            params["date"] = Time.new.to_i
            params["added_by"] = user.name

            comment = NewComment.new(params)
            puts comment.attributes

            on comment.valid? do
              params["user_id"] = user.id
              params["ballot_id"] = ballot.id

              Comment.create(params)

              ballot.voters.each do |voter|
                if voter.id != user.id
                  json = JSON.dump(
                    email: voter.email,
                    name: voter.name,
                    comment_by: user.name,
                    ballot_title: ballot.title,
                    ballot_id: ballot.id)

                  Ost[:comment_made].push(json)
                end
              end

              session[:success] = "You have successfully added a comment!"
              res.redirect "/ballot/#{id}"
            end

            on default do
              render("ballot/info",
                title: "Add comment", ballot: ballot, comment: comment)
            end
          end
        else
          session[:error] = "Comments cannot be added anymore. Ballot is closed."
          res.redirect "/ballot/#{id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/vote" do |id|
      ballot = user.ballots[id]

      on ballot do
        choices_voted = []

        ballot.choices.each do |choice|
          choice_voted = choice.votes.find(user_id: user.id)

          if !choice_voted.empty?
            choices_voted << choice.id
          end
        end


        if ballot.status == "Voting only"
          on post, param("vote") do |votes|

            valid_votes = []

            votes.each do |rating|

              params = {}
              params["rating"] = rating[1].to_i # if it's converted into integer, when choosing "--" it validates because it takes it as "0"

              vote = NewVote.new(params)

              if vote.valid?
                if choices_voted.include?(rating[0])
                  choice = Choice[rating[0]]

                  vote_to_update = Vote[choice.votes.find(user_id: user.id).ids[0]]

                  updated = vote_to_update.update(params)

                  valid_votes << updated
                else
                  params["date"] = Time.new.to_i
                  params["choice_id"] = rating[0]
                  params["user_id"] = user.id

                  new_vote = Vote.create(params)

                  valid_votes << new_vote
                end
              else
                session[:error] = "The vote wasn't valid. Please try again."
                res.redirect "/ballot/#{id}"
              end
            end

            on valid_votes.size == votes.size do

              UserVotedLog.create(user, ballot)

              session[:success] = "You have successfully voted!"
              res.redirect "/ballot/#{id}"
            end

            on default do
              session[:error] = "Vote wasn't valid. Please try again."
              res.redirect "/ballot/#{id}"
            end
          end

          on get, root do
            render("ballot/update_vote",
              title: "Vote", ballot: ballot, voter: NewVote.new({}))
          end
        elsif ballot.status == "Active"
          session[:error] = "Voting starts on #{cal_utc(ballot.end_choices_date)}"
          res.redirect "/ballot/#{id}"
        else
          session[:error] = "Ballot is closed."
          res.redirect "/ballot/#{id}"
        end
      end

      on default do
        not_found!
      end
    end

    on "ballot/:id/invite" do |id|
      ballot = user.ballots[id]

      on ballot do
        if ballot.status != "Closed"
          on post, param("message") do |params|

            message = NewMessage.new(params)

            on message.valid? do

              json = JSON.dump(
                from_user: user.name,
                email: message.email,
                body: message.body)

              Ost[:send_invitation].push(json)

              session[:success] = "You have successfully send an invitation!"
              res.redirect "/ballot/#{id}/voters/add"
            end

            on default do
              render("ballot/invite",
                title: "Invite", ballot: ballot, message: message)
            end
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
