# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171126132946) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "group_assignments", force: :cascade do |t|
    t.integer  "created_by"
    t.integer  "group_id"
    t.integer  "person_id"
    t.integer  "start_year"
    t.integer  "end_year"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.boolean  "is_approved",                 default: false
    t.boolean  "is_active",                   default: true
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "start_date_type", limit: 255
    t.string   "end_date_type",   limit: 255
    t.text     "citation"
  end

  add_index "group_assignments", ["approved_by"], name: "index_group_assignments_on_approved_by", using: :btree
  add_index "group_assignments", ["created_by"], name: "index_group_assignments_on_created_by", using: :btree
  add_index "group_assignments", ["group_id"], name: "index_group_assignments_on_group_id", using: :btree
  add_index "group_assignments", ["person_id"], name: "index_group_assignments_on_person_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.integer  "created_by"
    t.string   "name",            limit: 255
    t.text     "description"
    t.text     "justification"
    t.integer  "start_year"
    t.integer  "end_year"
    t.string   "approved_by",     limit: 255
    t.string   "approved_on",     limit: 255
    t.boolean  "is_approved",                 default: false
    t.boolean  "is_active",                   default: true
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "start_date_type", limit: 255
    t.string   "end_date_type",   limit: 255
    t.text     "citation"
  end

  add_index "groups", ["approved_by"], name: "index_groups_on_approved_by", using: :btree
  add_index "groups", ["created_by"], name: "index_groups_on_created_by", using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "first_name",              limit: 255
    t.string   "last_name",               limit: 255
    t.integer  "created_by"
    t.text     "historical_significance"
    t.string   "prefix",                  limit: 255
    t.string   "suffix",                  limit: 255
    t.string   "title",                   limit: 255
    t.string   "birth_year_type",         limit: 255
    t.string   "birth_year",              limit: 255
    t.string   "death_year_type",         limit: 255
    t.string   "death_year",              limit: 255
    t.string   "gender",                  limit: 255
    t.text     "justification"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.integer  "odnb_id"
    t.boolean  "is_approved",                         default: false
    t.boolean  "is_active",                           default: true
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "display_name",            limit: 255
    t.text     "search_names_all"
    t.text     "citation"
    t.text     "aliases"
  end

  add_index "people", ["approved_by"], name: "index_people_on_approved_by", using: :btree
  add_index "people", ["created_by"], name: "index_people_on_created_by", using: :btree

  create_table "rel_cat_assigns", force: :cascade do |t|
    t.integer  "relationship_category_id"
    t.integer  "relationship_type_id"
    t.integer  "created_by"
    t.string   "approved_by",              limit: 255
    t.string   "approved_on",              limit: 255
    t.boolean  "is_approved",                          default: false
    t.boolean  "is_active",                            default: true
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.text     "citation"
  end

  add_index "rel_cat_assigns", ["approved_by"], name: "index_rel_cat_assigns_on_approved_by", using: :btree
  add_index "rel_cat_assigns", ["created_by"], name: "index_rel_cat_assigns_on_created_by", using: :btree
  add_index "rel_cat_assigns", ["relationship_category_id"], name: "index_rel_cat_assigns_on_relationship_category_id", using: :btree
  add_index "rel_cat_assigns", ["relationship_type_id"], name: "index_rel_cat_assigns_on_relationship_type_id", using: :btree

  create_table "relationship_categories", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.boolean  "is_approved",             default: false
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.integer  "created_by"
    t.boolean  "is_active",               default: true
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "citation"
  end

  add_index "relationship_categories", ["approved_by"], name: "index_relationship_categories_on_approved_by", using: :btree
  add_index "relationship_categories", ["created_by"], name: "index_relationship_categories_on_created_by", using: :btree

  create_table "relationship_types", force: :cascade do |t|
    t.integer  "relationship_type_inverse"
    t.string   "name",                      limit: 255
    t.text     "description"
    t.boolean  "is_active",                             default: true
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.boolean  "is_approved",                           default: false
    t.integer  "created_by"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.text     "citation"
  end

  add_index "relationship_types", ["approved_by"], name: "index_relationship_types_on_approved_by", using: :btree
  add_index "relationship_types", ["created_by"], name: "index_relationship_types_on_created_by", using: :btree
  add_index "relationship_types", ["relationship_type_inverse"], name: "index_relationship_types_on_relationship_type_inverse", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.integer  "original_certainty"
    t.integer  "person1_index"
    t.integer  "person2_index"
    t.integer  "created_by"
    t.integer  "max_certainty"
    t.integer  "start_year"
    t.integer  "end_year"
    t.text     "justification"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.boolean  "is_approved",                    default: false
    t.boolean  "is_active",                      default: true
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "start_date_type",    limit: 255
    t.string   "end_date_type",      limit: 255
    t.text     "citation"
    t.boolean  "altered",                        default: false
  end

  add_index "relationships", ["approved_by"], name: "index_relationships_on_approved_by", using: :btree
  add_index "relationships", ["created_by"], name: "index_relationships_on_created_by", using: :btree
  add_index "relationships", ["person1_index"], name: "index_relationships_on_person1_index", using: :btree
  add_index "relationships", ["person2_index"], name: "index_relationships_on_person2_index", using: :btree

  create_table "user_rel_contribs", force: :cascade do |t|
    t.integer  "relationship_id"
    t.integer  "created_by"
    t.integer  "certainty"
    t.text     "citation"
    t.integer  "relationship_type_id"
    t.integer  "start_year"
    t.integer  "end_year"
    t.integer  "approved_by"
    t.date     "approved_on"
    t.boolean  "is_approved",                      default: true
    t.boolean  "is_active",                        default: true
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "start_date_type",      limit: 255
    t.string   "end_date_type",        limit: 255
  end

  add_index "user_rel_contribs", ["approved_by"], name: "index_user_rel_contribs_on_approved_by", using: :btree
  add_index "user_rel_contribs", ["created_by"], name: "index_user_rel_contribs_on_created_by", using: :btree
  add_index "user_rel_contribs", ["relationship_id"], name: "index_user_rel_contribs_on_relationship_id", using: :btree
  add_index "user_rel_contribs", ["relationship_type_id"], name: "index_user_rel_contribs_on_relationship_type_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.text     "about_description"
    t.string   "affiliation",            limit: 255
    t.string   "email",                  limit: 255
    t.string   "first_name",             limit: 255
    t.boolean  "is_active",                          default: true
    t.string   "last_name",              limit: 255
    t.string   "user_type",                          default: "Standard"
    t.string   "prefix",                 limit: 255
    t.string   "orcid",                  limit: 255
    t.integer  "created_by"
    t.string   "username",               limit: 255
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "auth_token",             limit: 255
    t.string   "password_digest",        limit: 255
    t.string   "password_reset_sent_at", limit: 255
    t.string   "password_reset_token",   limit: 255
    t.boolean  "is_public",                          default: false
  end

  add_index "users", ["created_by"], name: "index_users_on_created_by", using: :btree

end
