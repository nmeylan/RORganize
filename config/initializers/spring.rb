if defined?(Spring)
  Spring.after_fork do
    load "#{Rails.root.to_s}/config/initializers/in_memory_db.rb"
  end
end