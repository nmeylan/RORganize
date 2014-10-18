# Author: Nicolas Meylan
# Date: 18.10.14
# Encoding: UTF-8
# File: project_item_filter_part.rb

require 'shared/filter'
class ProjectItemFilterPart < Filter
  def updated_at_filter(content_hash)
    build_hash_for_radio_date(content_hash, 'updated')
  end

  def created_at_filter(content_hash)
    build_hash_for_radio_date(content_hash, 'created')
  end

  def version_filter(content_hash)
    version_options = @project.versions.collect { |version| [version.name, version.id] }
    version_options << %w(Unplanned NULL)
    build_hash_for_radio(content_hash, 'version')
    build_hash_for_select(content_hash, 'version', version_options)
  end

  def category_filter(content_hash)
    category_options = @project.categories.collect { |category| [category.name, category.id] }
    build_hash_for_select(content_hash, 'category', category_options)
    build_hash_for_radio(content_hash, 'category')
  end
end