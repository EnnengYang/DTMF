The dataset was collected by Paolo Massa in a 5-week crawl (November/December 2003) from the Epinions.com Web site.

The dataset contains

* 49,290 users who rated a total of
* 139,738 different items at least once, writing
* 664,824 reviews and
* 487,181 issued trust statements.
Users and Items are represented by anonimized numeric identifiers.

** ratings_data.txt.bz2 (2.5 Megabytes): it contains the ratings given by users to items.

Every line has the following format:

user_id item_id rating_value
For example,

23 387 5
represents the fact "user 23 has rated item 387 as 5"

Ranges:

user_id is in [1,49290]
item_id is in [1,139738]
rating_value is in [1,5]

** trust_data.txt.bz2 (1.7 Megabytes): it contains the trust statements issued by users.

Every line has the following format:

source_user_id target_user_id trust_statement_value
For example, the line

22605 18420 1
represents the fact "user 22605 has expressed a positive trust statement on user 18420"

Ranges:

source_user_id and target_user_id are in [1,49290]
trust_statement_value is always 1 (since in the dataset there are only positive trust statements and not negative ones (distrust)).
Note: there are no distrust statements in the dataset (block list) but only trust statements (web of trust), because the block list is kept private and not shown on the site.
