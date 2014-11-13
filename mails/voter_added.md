Dear {{ name }},

You have been added to the following ballot:

{{ ballot_title }}

% if !ballot_description.empty?
Description:
{{ ballot_description }}

% end
Ballot closing date: {{ end_date }}

Go to https://www.teamballots.com/ballot/{{ ballot_id }} to participate of the ballot.

Best regards,

Team Ballots

https://www.teamballots.com
https://twitter.com/teamballots
https://github.com/ceciliarivero/teamballots
