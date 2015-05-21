module HasTaskList
  def self.included(base)
    p "aaaa"
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_task_list?
      true
    end
  end
end