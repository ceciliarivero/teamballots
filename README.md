Team Ballots
------------

The voting app for small groups.

[https://www.teamballots.com/] (https://www.teamballots.com/)

About
-----
Sometimes, small or medium-size organizations, like book clubs or owners associations, find themselves voting on issues and end up having a very long email exchange between the members of the group to decide on something.

Team Ballots is here to help!

With Team Ballots, users will be able to create ballots and include voters into ballots. Voters will be able to add choices, make comments, vote (and change their votes until the closing date) and, at the end, they all see the final results.

Team Ballots uses a Cardinal voting system called Range or Score Voting. That means that all the choices of a ballot will need to be scored by the voters (from 0 to 10, being 10 the best score). The final results of every ballot will be a ranking including all the choices, the first one being the winner, with the highest score.

If the ballot has only one choice (i.e., "Do you want to have a meeting on Sunday afternoon? Yes or No."), then the result of the ballot would be a "Yes" if the final score was 5.00 or more, and "No" if it was 4.99 or less. Regardless of whether the result is a "Yes" or a "No", the final score will be shown as well.

Also, users will be able to create Voters groups. That way, a user will easily add voters from groups to specific ballots, instead of adding voters one by one.

Installation
------------
Clone this repository, then create a `env.sh` file in the project folder.

*example*:

``` ruby
# cat env.sh
APP_SECRET=your_app_secret_here
MALONE_URL=smtp://username:password@smtp.gmail.com:587
NEW_RELIC_LICENSE_KEY=your_new_relic_license_key
NEWRELIC_AGENT_ENABLED=true
NOBI_SECRET=your_nobi_secret_here
OPENREDIS_URL=redis://127.0.0.1:6379/
RACK_ENV=production
RESET_URL=http://localhost:9393
```
In terminal run:

    $ make gems
    $ make install

Finally, to run the server:

    $ make server

Now, you can go to localhost:9393 in your browser and see the app running.

Enjoy! :-)

Tools used in Team Ballots
--------------------------
- [Cuba:] (http://cuba.is/) Microframework built in Ruby.
- [Cutest] (https://github.com/djanowski/cutest) for testing.
- [Malone:] (https://github.com/cyx/malone) for mailing.
- [Mote:] (https://github.com/soveran/mote) Minimum Operational Template.
- [Nobi:] (https://github.com/cyx/nobi) for creating a password reset link and account activations.
- [Ohm:] (http://soveran.github.io/ohm/) Library that allows to store objects in Redis.
- [Ost:] (https://github.com/soveran/ost) for workers.
- [Rack-protection:] (https://github.com/rkh/rack-protection) Protects against typical web attacks.
- [Redis:] (http://www.redis.io) Open source database.
- [Scrivener:] (https://github.com/soveran/scrivener) Validation frontend for models.
- [Shield:] (https://github.com/soveran/shield) Authentication library.
