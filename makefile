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
	env $$(cat env.sh) cutest test/**/*.rb

db:
	ruby seed.rb

workers-start:
	env $$(cat env.sh) ost -d welcome
	env $$(cat env.sh) ost -d password_changed
	env $$(cat env.sh) ost -d user_deleted
	env $$(cat env.sh) ost -d voter_added

workers-stop:
	kill $$(cat workers/welcome.pid)
	kill $$(cat workers/password_changed.pid)
	kill $$(cat workers/user_deleted.pid)
	kill $$(cat workers/voter_added.pid)
