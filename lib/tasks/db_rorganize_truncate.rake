# Author: Nicolas Meylan
# Date: 02.09.14
# Encoding: UTF-8
# File: db_safe_drop.rb

namespace :db do
  desc 'truncate all tables from db except users and their avatars.'
  task :rorganize_truncate => :environment do
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.tables.each do |table|
        except = ['users', 'attachments', 'permissions', 'roles', 'trackers', 'permissions_roles', 'issues_statuses', 'enumerations', 'issues_statuses_roles', 'schema_migrations']
        if except.include? table
          if table.eql?('attachments')
            Attachment.delete_all("attachable_type <> 'User'")
          end
        else
          ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
        end
      end
    end
  end
end