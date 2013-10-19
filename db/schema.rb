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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130921185511) do

  create_table "attachments", :force => true do |t|
    t.integer  "object_id"
    t.string   "name"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "object_type"
  end

  add_index "attachments", ["object_id"], :name => "index_attachments_on_object_id"

  create_table "categories", :force => true do |t|
    t.integer "project_id"
    t.string  "name"
  end

  add_index "categories", ["project_id"], :name => "index_categories_on_project_id"

  create_table "changelogs", :force => true do |t|
    t.integer "version_id"
    t.integer "project_id"
    t.integer "enumeration_id"
    t.text    "description",    :limit => 16777215
  end

  create_table "checklist_items", :force => true do |t|
    t.integer "enumeration_id"
    t.integer "issue_id"
    t.integer "position"
    t.string  "name",           :limit => 50
  end

  add_index "checklist_items", ["enumeration_id"], :name => "index_checklist_items_on_enumeration_id"
  add_index "checklist_items", ["issue_id"], :name => "index_checklist_items_on_issue_id"

  create_table "documents", :force => true do |t|
    t.string   "name"
    t.text     "description", :limit => 16777215
    t.integer  "version_id"
    t.integer  "category_id"
    t.integer  "project_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "documents", ["category_id"], :name => "index_documents_on_category_id"
  add_index "documents", ["project_id"], :name => "index_documents_on_project_id"
  add_index "documents", ["version_id"], :name => "index_documents_on_version_id"

  create_table "enabled_modules", :force => true do |t|
    t.string  "name",       :limit => 128
    t.string  "action"
    t.string  "controller"
    t.integer "project_id"
  end

  add_index "enabled_modules", ["project_id"], :name => "index_enabled_modules_on_project_id"

  create_table "enumerations", :force => true do |t|
    t.string  "opt",      :limit => 4
    t.string  "name"
    t.integer "position"
  end

  create_table "issues", :force => true do |t|
    t.string   "subject"
    t.text     "description",           :limit => 16777215
    t.datetime "created_at",                                                                              :null => false
    t.datetime "updated_at",                                                                              :null => false
    t.date     "due_date"
    t.integer  "done"
    t.integer  "author_id"
    t.integer  "assigned_to_id"
    t.integer  "project_id"
    t.integer  "tracker_id"
    t.integer  "status_id"
    t.integer  "version_id"
    t.integer  "category_id"
    t.decimal  "estimated_time",                            :precision => 10, :scale => 1
    t.date     "start_date"
    t.integer  "predecessor_id"
    t.integer  "checklist_items_count",                                                    :default => 0
    t.integer  "attachments_count",                                                        :default => 0
  end

  add_index "issues", ["assigned_to_id"], :name => "index_issues_on_assigned_to_id"
  add_index "issues", ["author_id"], :name => "index_issues_on_author_id"
  add_index "issues", ["category_id"], :name => "index_issues_on_category_id"
  add_index "issues", ["predecessor_id"], :name => "index_issues_on_predecessor_id"
  add_index "issues", ["project_id"], :name => "index_issues_on_project_id"
  add_index "issues", ["tracker_id"], :name => "index_issues_on_tracker_id"
  add_index "issues", ["version_id"], :name => "index_issues_on_version_id"

  create_table "issues_statuses", :force => true do |t|
    t.boolean "is_closed"
    t.integer "default_done_ratio"
    t.integer "enumeration_id"
  end

  add_index "issues_statuses", ["enumeration_id"], :name => "index_issues_statuses_on_enumeration_id"

  create_table "issues_statuses_roles", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "issues_status_id"
  end

  add_index "issues_statuses_roles", ["issues_status_id"], :name => "index_issues_statuses_roles_on_issues_status_id"
  add_index "issues_statuses_roles", ["role_id"], :name => "index_issues_statuses_roles_on_role_id"

  create_table "issues_steps", :id => false, :force => true do |t|
    t.integer "issue_id"
    t.integer "step_id"
  end

  add_index "issues_steps", ["issue_id"], :name => "index_issues_steps_on_issue_id"
  add_index "issues_steps", ["step_id"], :name => "index_issues_steps_on_step_id"

  create_table "journal_details", :force => true do |t|
    t.integer "journal_id"
    t.string  "property",     :limit => 30
    t.string  "property_key", :limit => 30
    t.string  "old_value"
    t.string  "value"
  end

  create_table "journals", :force => true do |t|
    t.string   "journalized_type",       :limit => 30
    t.text     "notes",                  :limit => 16777215
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "journalized_id"
    t.integer  "user_id"
    t.string   "action_type"
    t.integer  "project_id"
    t.string   "journalized_identifier", :limit => 128
  end

  add_index "journals", ["project_id"], :name => "index_journals_on_project_id"
  add_index "journals", ["user_id"], :name => "index_journals_on_user_id"

  create_table "members", :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.integer "role_id"
    t.boolean "is_project_starred", :default => false
    t.integer "project_position"
  end

  add_index "members", ["project_id"], :name => "index_members_on_project_id"
  add_index "members", ["role_id"], :name => "index_members_on_role_id"
  add_index "members", ["user_id"], :name => "index_members_on_user_id"

  create_table "permissions", :force => true do |t|
    t.string  "name"
    t.string  "action"
    t.string  "controller"
    t.boolean "is_locked"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  add_index "permissions_roles", ["permission_id"], :name => "index_permissions_roles_on_permission_id"
  add_index "permissions_roles", ["role_id"], :name => "index_permissions_roles_on_role_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description",       :limit => 16777215
    t.string   "identifier",        :limit => 20
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.integer  "created_by"
    t.boolean  "is_archived",                           :default => false
    t.string   "slug"
    t.integer  "members_count",                         :default => 0
    t.integer  "issues_count",                          :default => 0
    t.integer  "attachments_count",                     :default => 0
  end

  add_index "projects", ["slug"], :name => "index_projects_on_slug"

  create_table "projects_trackers", :id => false, :force => true do |t|
    t.integer "tracker_id"
    t.integer "project_id"
  end

  add_index "projects_trackers", ["project_id"], :name => "index_projects_trackers_on_project_id"
  add_index "projects_trackers", ["tracker_id"], :name => "index_projects_trackers_on_tracker_id"

  create_table "queries", :force => true do |t|
    t.integer "author_id"
    t.integer "project_id"
    t.boolean "is_for_all"
    t.boolean "is_public"
    t.string  "name",             :limit => 50
    t.text    "description",      :limit => 16777215
    t.text    "stringify_params", :limit => 16777215
    t.text    "stringify_query",  :limit => 16777215
    t.string  "object_type"
    t.string  "slug"
  end

  add_index "queries", ["author_id"], :name => "index_queries_on_author_id"
  add_index "queries", ["project_id"], :name => "index_queries_on_project_id"
  add_index "queries", ["slug"], :name => "index_queries_on_slug"

  create_table "roles", :force => true do |t|
    t.string  "name"
    t.integer "position"
  end

  create_table "scenarios", :force => true do |t|
    t.string   "name"
    t.text     "description", :limit => 16777215
    t.integer  "actor_id"
    t.integer  "version_id"
    t.integer  "project_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "scenarios", ["actor_id"], :name => "index_scenarios_on_actor_id"
  add_index "scenarios", ["project_id"], :name => "index_scenarios_on_project_id"
  add_index "scenarios", ["version_id"], :name => "index_scenarios_on_version_id"

  create_table "steps", :force => true do |t|
    t.string  "name"
    t.integer "scenario_id"
  end

  add_index "steps", ["scenario_id"], :name => "index_steps_on_scenario_id"

  create_table "tasks", :force => true do |t|
    t.integer  "enumeration_id"
    t.integer  "project_id"
    t.integer  "issue_id"
    t.string   "name"
    t.text     "description",    :limit => 16777215
    t.integer  "position"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "tasks_todo_lists", :id => false, :force => true do |t|
    t.integer "todo_lists_id"
    t.integer "tasks_id"
  end

  create_table "time_entries", :force => true do |t|
    t.integer "user_id"
    t.integer "issue_id"
    t.integer "project_id"
    t.date    "spent_on"
    t.float   "spent_time"
    t.text    "comment"
  end

  create_table "todo_lists", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "name"
    t.text     "description", :limit => 16777215
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "trackers", :force => true do |t|
    t.boolean "is_in_chlog"
    t.boolean "is_in_roadmap"
    t.string  "name"
    t.integer "position"
  end

  create_table "users", :force => true do |t|
    t.string   "name",                   :limit => 50
    t.string   "login",                  :limit => 50
    t.boolean  "admin"
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "slug"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug"

  create_table "versions", :force => true do |t|
    t.string  "name"
    t.date    "target_date"
    t.text    "description", :limit => 16777215
    t.integer "position"
    t.date    "start_date"
    t.integer "project_id"
  end

  create_table "wiki_pages", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "author_id"
    t.integer  "wiki_id"
    t.integer  "position"
    t.string   "title"
    t.text     "content",    :limit => 16777215
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "slug"
  end

  add_index "wiki_pages", ["author_id"], :name => "index_wiki_pages_on_author_id"
  add_index "wiki_pages", ["parent_id"], :name => "index_wiki_pages_on_parent_id"
  add_index "wiki_pages", ["slug"], :name => "index_wiki_pages_on_slug"
  add_index "wiki_pages", ["wiki_id"], :name => "index_wiki_pages_on_wiki_id"

  create_table "wikis", :force => true do |t|
    t.integer "home_page_id"
    t.integer "project_id"
  end

  add_index "wikis", ["home_page_id"], :name => "index_wikis_on_home_page_id"
  add_index "wikis", ["project_id"], :name => "index_wikis_on_project_id"

end
