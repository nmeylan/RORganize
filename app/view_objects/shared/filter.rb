class Filter
  attr_accessor :content

  def initialize(project)
    @project = project
    @content = build_filter
  end

  def build_json_form(form_hash)
    form_hash.each { |_, v| v.tr('"', "'").gsub(/\n/, '') }
    form_hash.to_json
  end


  def build_hash_for_radio(content_hash, attribute_name, choices = %w(all equal different))
    build_hash_for('radio', attribute_name, choices, content_hash)
  end

  def build_hash_for_radio_date(content_hash, attribute_name)
    build_hash_for('radio', attribute_name,  %w(all equal superior inferior today), content_hash)
  end

  def build_hash_for(input_type, attribute_name, choices, content_hash)
    content_hash["hash_for_#{input_type}"][attribute_name] = choices
  end

  def build_hash_for_select(content_hash, attribute_name, choices)
    build_hash_for('select', attribute_name, choices, content_hash)
  end

  def build_filter
    raise ''
  end
end
