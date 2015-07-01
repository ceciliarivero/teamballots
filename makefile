.PHONY: test

gems:
	which gs  || gem install gs
	which dep || gem install dep
	which shotgun || gem install shotgun
	gs init

install:
	dep install

server:
	env $$(cat env.sh) shotgun -o 0.0.0.0

console:
	env $$(cat env.sh) irb -r ./app

test:
	env $$(cat env.sh) cutest -r ./test/helper.rb test/**/*.rb

db:
	ruby seed.rb

workers-start:
	env $$(cat env.sh) ost start -d contact
	env $$(cat env.sh) ost start -d comment_made
	env $$(cat env.sh) ost start -d new_user
	env $$(cat env.sh) ost start -d password_changed
	env $$(cat env.sh) ost start -d send_invitation
	env $$(cat env.sh) ost start -d user_deleted
	env $$(cat env.sh) ost start -d voter_added
	env $$(cat env.sh) ost start -d welcome

workers-stop:
	kill $$(cat workers/contact.pid)
	kill $$(cat workers/comment_made.pid)
	kill $$(cat workers/new_user.pid)
	kill $$(cat workers/password_changed.pid)
	kill $$(cat workers/send_invitation.pid)
	kill $$(cat workers/user_deleted.pid)
	kill $$(cat workers/voter_added.pid)
	kill $$(cat workers/welcome.pid)
