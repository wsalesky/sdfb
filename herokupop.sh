heroku run rake db:populate_people --app sdfb2
heroku run rake db:populate_groups --app sdfb2
heroku run rake db:populate_people_genders --app sdfb2
heroku run rake db:populate_group_cats --app sdfb2
heroku run rake db:populate_rel_cats --app sdfb2
heroku run rake db:populate_rel_types --app sdfb2
heroku run rake db:populate_rel_cat_assigns --app sdfb2
heroku run rake db:populate_group_cat_assigns --app sdfb2
heroku run rake db:populate_rels_2_20000 --app sdfb2
heroku run rake db:populate_rels_20001_40000 --app sdfb2
heroku run rake db:populate_rels_40001_60000 --app sdfb2
# heroku run rake db:populate_rels_60001_80000 --app sdfb2
# heroku run rake db:populate_rels_80001_100000 --app sdfb2
# heroku run rake db:populate_rels_100001_120000 --app sdfb2
# heroku run rake db:populate_rels_120001_140000 --app sdfb2
# heroku run rake db:populate_rels_140001_160000 --app sdfb2
# heroku run rake db:populate_rels_160001_170542 --app sdfb2
heroku run rake db:populate_user_rel_contribs_samples --app sdfb2
heroku run rake db:populate_people_search_names_all --app sdfb2
