# Reward calculation
## Task
A company is planning a way to reward customers for inviting their friends. They're planning a reward
system that will give a customer points for each confirmed invitation they played a part into. The definition
of a confirmed invitation is one where an invited person accepts their contract. Inviters also should be
rewarded when someone they have invited invites more people.

The inviter gets (1/2)^k points for each confirmed invitation, where k is the level of the invitation: level 0
(people directly invited) yields 1 point, level 1 (people invited by someone invited by the original customer)
gives 1/2 points, level 2 invitations (people invited by someone on level 1) awards 1/4 points and so on.
Only the first invitation counts: multiple invites sent to the same person don't produce any further points,
even if they come from different inviters and only the first invitation counts.

## How to use
Instruction assumes that you have installed __Ruby 2.3.1__ and you cloned this repository onto your machine.

First you need to run the server. Navigate to the repo folder in console.
``` bash
gem install bundler
bundle install
ruby app.rb
```
After that just navigate to http://localhost:4567/

For your convenience a set of two sample data files is included in `/samples`

## How to run tests
Assuming that you have successfully ran the server you can run test using the following
``` bash
ruby tests.rb
```

## About the solution
This solution uses Sinatra framework to serve HTTP. Algorithm-wise this solution parses events and constructs them into the tree of users, stored in `Hash`.

The algorithm supports loading events in batches with the following limitations:

- Batches __must not intersect__ each other in terms of time
- Batch that is loaded later __must represent__ the later moment in time

To find out about data format that is used, refer to files in `/samples` directory.
