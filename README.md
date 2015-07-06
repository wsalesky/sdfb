## TO PUSH TO HEROKU
1. Following these instructions, download the Heroku toolbelt so you can run from the command line
2. In the command line, run heroku login
3. Login with the SixDegreesFrancisBacon@gmail.com account (information on the Account Info google doc)
4. From the sdfb directory on your machine, run heroku git:remote -a sixdegfrancisbacon
5. Make sure all local changes are working
6. Commit and push the changes to Katarina's sdfb repo
7. Run git push heroku master
8. If making changes to js or css, run rake assets:precompile, then commit and push again before running git push heroku master

## POPULATING HEROKU
To run any script for heroku you need to add "heroku run" before "rake". For example, to migrate run "heroku run rake db:migrate" in the command line.
If populating the entire database you can run the file herokupop.sh which will run all the scripts.

## USING THE HEROKU SANDBOX
1. Switch to the sandbox repository. From the sdfb directory on your machine, run heroku git:remote -a sdfb2
2. Follow "To Push to Heroku" section steps 5-8


## Code to restart localhost server if there is an error
kill -9 $(lsof -i tcp:3000 -t)

## Brakeman runs checks against the app to identify security flaws
to use run the command 'brakeman' in the Terminal

## Status
Had to roll back populate changes because there 
is more logic in the models than I thought.
 
Currently, the nodes and relationships are 
individually read from the tsv 
files, then fields are added, one by one 
they are inserted into Postgres. Each record is 
then passed through to the rails controllers 
where it performs around 250,000 queries each of 
which result in K update operations to the text 
field that contains "rel_sum". This text field 
contains aggregated Ids of all of the nodes that 
each person has references to in the 
relationships table to. The array of node ids is
serialized to a single string and each person is 
then updated with the field "rel_sum".Every time 
a person is queried, the field is parsed and 
serialized back into an array, changed, and then 
converted back into a string and stored.


## Alternatively, I think the query below runs in O(n), 
I'm also not sompletely sure the way above converges.
```sql
 SELECT t1.person1_index AS pid, 
   ARRAY(( 
    SELECT t2.person2_index 
    FROM relationships t2 
    WHERE t2.person1_index = t1.person1_index
   )) AS rels 
FROM relationships t1 
GROUP BY t1.person1_index;
```
And if we must store this field, 
this runs almost as fast.
```sql
UPDATE people AS p SET rel_sum = t3.rels FROM (
    SELECT t1.person1_index as pid, 
    ARRAY(( 
       SELECT t2.person2_index 
       FROM relationships t2 
       WHERE t2.person1_index = t1.person1_index
    )) AS rels 
    FROM relationships t1 
    GROUP BY t1.person1_index
 ) t3 WHERE p.id = t3.pid;
```

## To set up rails:
```
Follow this tutorial: http://rubyonrails.org/download/
And install the Postgres database at: http://postgresapp.com/
First time: To run the files cloned from Github and populate the database write the commands for the first time:
install software plugins specific to the app:
bundle install
```

## To prepare database by creating/clearing it:

```
rake db:drop (if database is already created)
rake db:create
rake db:migrate
rake routes 
```

## To populate everything:

```
populate.sh
```


## To populate this file run the following commands in order:

```
rake db:populate_people
rake db:populate_groups
rake db:populate_people_genders
rake db:populate_group_cats
rake db:populate_rel_cats
rake db:populate_rel_types
rake db:populate_rel_cat_assigns
rake db:populate_group_cat_assigns
rake db:populate_people_display_names
rake db:populate_people_search_names_all
rake db:populate_rels_2_20000
rake db:populate_rels_20001_40000
rake db:populate_rels_40001_60000
rake db:populate_rels_60001_80000
rake db:populate_rels_80001_100000
rake db:populate_rels_100001_120000
rake db:populate_rels_120001_140000
rake db:populate_rels_140001_160000
rake db:populate_rels_160001_170542
rake db:populate_user_rel_contribs_samples
# Populate start and end dates (only need to do this if you originally populated relationships before May 1, 2015)
rake db:populate_rel_start_end_date_100000001_100010000
rake db:populate_rel_start_end_date_100010001_100020000
rake db:populate_rel_start_end_date_100020001_100030000
rake db:populate_rel_start_end_date_100030001_100040000
rake db:populate_rel_start_end_date_100040001_100050000
rake db:populate_rel_start_end_date_100050001_100060000
rake db:populate_rel_start_end_date_100060001_100070000
rake db:populate_rel_start_end_date_100070001_100080000
rake db:populate_rel_start_end_date_100080001_100090000
rake db:populate_rel_start_end_date_100090001_100100000
rake db:populate_rel_start_end_date_100100001_100110000
rake db:populate_rel_start_end_date_100110001_100120000
rake db:populate_rel_start_end_date_100120001_100130000
rake db:populate_rel_start_end_date_100130001_100140000
rake db:populate_rel_start_end_date_100140001_100150000
rake db:populate_rel_start_end_date_100150001_100160000
rake db:populate_rel_start_end_date_100160001_100170000
rake db:populate_rel_start_end_date_100170001_100180000

## Populate the first met records. You don't have to do this if you populated the relationships or start and end dates after July 6th
rake db:populate_rel_met_record_100000001_100010000
rake db:populate_rel_met_record_100010001_100020000
rake db:populate_rel_met_record_100020001_100030000
rake db:populate_rel_met_record_100030001_100040000
rake db:populate_rel_met_record_100040001_100050000
rake db:populate_rel_met_record_100050001_100060000
rake db:populate_rel_met_record_100060001_100070000
rake db:populate_rel_met_record_100070001_100080000
rake db:populate_rel_met_record_100080001_100090000
rake db:populate_rel_met_record_100090001_100100000
rake db:populate_rel_met_record_100100001_100110000
rake db:populate_rel_met_record_100110001_100120000
rake db:populate_rel_met_record_100120001_100130000
rake db:populate_rel_met_record_100130001_100140000
rake db:populate_rel_met_record_100140001_100150000
rake db:populate_rel_met_record_100150001_100160000
rake db:populate_rel_met_record_100160001_100170000
rake db:populate_rel_met_record_100170001_100180000

## IMPORTANT NOTES ON POPULATING:
1. You must only run the following if updating people populated prior to March 12, 2015
    rake db:populate_rel_sum
2. To populate the first time, you must comment out the following before populating (then comment back in after you are done):
    In app>models>person.rb, "validates_presence_of :display_name"

## To run the server locally:

```
Start Postgres
type "rails s" without the quotes into the terminal
navigate to http://localhost:3000/
end this process by sending "Ctrl-C" in terminal
```

Most Recent Brakeman 6-16-15:
+SUMMARY+

+-------------------+--------+
| Scanned/Reported  | Total  |
+-------------------+--------+
| Controllers       | 19     |
| Models            | 16     |
| Templates         | 177    |
| Errors            | 2      |
| Security Warnings | 15 (1) |
+-------------------+--------+

+----------------------------+-------+
| Warning Type               | Total |
+----------------------------+-------+
| Cross-Site Request Forgery | 1     |
| Mass Assignment            | 12    |
| SQL Injection              | 1     |
| Session Setting            | 1     |
+----------------------------+-------+
+Errors+
+----------------------------------------------------------------------------->>
| Error                                                                       >>
+----------------------------------------------------------------------------->>
| /Users/katarinashaw/Documents/sdfb/app/views/password_resets/edit.html.erb:3>>
| /Users/katarinashaw/Documents/sdfb/app/views/relationships/all_rels_for_pers>>
+----------------------------------------------------------------------------->>


+SECURITY WARNINGS+

+------------+--------+------------------+-----------------+------------------>>
| Confidence | Class  | Method           | Warning Type    | Message          >>
+------------+--------+------------------+-----------------+------------------>>
| High       |        |                  | Session Setting | Session secret sh>>
| Medium     | Person | first_degree_for | SQL Injection   | Possible SQL inje>>
+------------+--------+------------------+-----------------+------------------>>



Controller Warnings:

+------------+-----------------------+----------------------------+----------->>
| Confidence | Controller            | Warning Type               | Message   >>
+------------+-----------------------+----------------------------+----------->>
| Medium     | ApplicationController | Cross-Site Request Forgery | protect_fr>>
+------------+-----------------------+----------------------------+----------->>



Model Warnings:

+------------+-------------------+-----------------+-------------------------->>
| Confidence | Model             | Warning Type    | Message                  >>
+------------+-------------------+-----------------+-------------------------->>
| Weak       | Flag              | Mass Assignment | Potentially dangerous att>>
| Weak       | GroupAssignment   | Mass Assignment | Potentially dangerous att>>
| Weak       | GroupAssignment   | Mass Assignment | Potentially dangerous att>>
| Weak       | GroupCatAssign    | Mass Assignment | Potentially dangerous att>>
| Weak       | GroupCatAssign    | Mass Assignment | Potentially dangerous att>>
| Weak       | Person            | Mass Assignment | Potentially dangerous att>>
| Weak       | RelCatAssign      | Mass Assignment | Potentially dangerous att>>
| Weak       | RelCatAssign      | Mass Assignment | Potentially dangerous att>>
| Weak       | UserGroupContrib  | Mass Assignment | Potentially dangerous att>>
| Weak       | UserPersonContrib | Mass Assignment | Potentially dangerous att>>
| Weak       | UserRelContrib    | Mass Assignment | Potentially dangerous att>>
| Weak       | UserRelContrib    | Mass Assignment | Potentially dangerous att>>
+------------+-------------------+-----------------+-------------------------->>

CMU-912690:sdfb katarinashaw$ 

