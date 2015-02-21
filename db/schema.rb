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

ActiveRecord::Schema.define(version: 20150221150311) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dictionaries", force: :cascade do |t|
    t.integer  "user_id",                                          null: false
    t.string   "name",                                             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "word_column_label",        default: "Word",        null: false
    t.string   "translation_column_label", default: "Translation", null: false
    t.integer  "exclude_test_types",       default: [],                         array: true
    t.integer  "select_option_from",       default: 3
    t.integer  "select_option_to",         default: 5
    t.integer  "exclude_test_method_ids",  default: [],            null: false, array: true
    t.integer  "missing_letters_from",     default: 1
    t.integer  "missing_letters_to",       default: 2
  end

  add_index "dictionaries", ["user_id"], name: "index_dictionaries_on_user_id", using: :btree

  create_table "tests", force: :cascade do |t|
    t.integer  "word_id",                     null: false
    t.integer  "dictionary_id",               null: false
    t.string   "question",                    null: false
    t.string   "correct_answer",              null: false
    t.string   "options",                                  array: true
    t.string   "given_answer"
    t.boolean  "correct"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "question_method"
    t.string   "answer_method"
    t.integer  "test_method_id",  default: 0, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_dictionary_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "words", force: :cascade do |t|
    t.string   "word",                      null: false
    t.string   "translation"
    t.string   "pronunciation"
    t.integer  "dictionary_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "word_class"
    t.string   "properties",                             array: true
    t.string   "variant",                                array: true
    t.integer  "root_id"
    t.integer  "correct",       default: 0, null: false
    t.integer  "incorrect",     default: 0, null: false
  end

  add_foreign_key "dictionaries", "users"
  add_foreign_key "words", "dictionaries"
end
