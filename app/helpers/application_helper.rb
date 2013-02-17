module ApplicationHelper
#  require 'Date'
  def sidebar_content?
    content_for?(:sidebar)
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html.erb", :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def render_403
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/403.html.erb", :status => :forbidden }
      format.xml  { head :forbidden }
      format.any  { head :forbidden }
    end
  end

  def date_valid?(date, format="%Y-%m-%d" )
    if date.eql?('') || date.nil?
      return true
    end
    begin
      Date.strptime(date,format)
      return true
    rescue
      return false
    end
  end
  #Here are define basic action into hash
  def find_action(action)
    basic_actions = {"update" => "edit", "create" => "new"}
    if basic_actions.keys.include?(action)
      return basic_actions[action]
    else
      return action
    end
  end

  def check_permission
    unless current_user.allowed_to?(find_action(params[:action]),params[:controller],@project)
      render_403
    end
  end

  def error_messages(object)
    if object.any?
      error_explanation = ""
      errors = ""
      error_explanation += "<script type='text/javascript'>"
      errors += "<ul>"
      object.each do |error|
        errors += "<li>"+error+"</li>"
      end
      errors += "</ul>"
      error_explanation += "error_explanation(\""+errors+"\");"
      error_explanation += "</script>"
      object.clear
      return error_explanation.to_s
    end
  end
  #Return updated attributes
  def updated_attributes(object, parameter)
    #{attribute_name => [old_value, new_value],...}
    attr_updated = Hash.new{|k,v| v = []}

    attributes_names = object.attributes.keys
    #For each attributes compare differences between old object and new parameters
    attributes_names.each do |name|
      if !object[name].to_s.eql?(parameter[name].to_s) && !parameter[name].nil?
        attr_updated[name] = [object[name], parameter[name]]
      end
    end
    return attr_updated
  end

  def journal_creation_on_delete(object, value, property,property_key = nil)
    property_key ||= property.downcase
    journal = Journal.create(:user_id => current_user.id,
      :journalized_id => object.id,
      :journalized_type => object.class.to_s,
      :created_at => Time.now.to_formatted_s(:db),
      :notes => '')
    JournalDetail.create(:journal_id => journal.id,
      :property => property,
      :property_key => property_key,
      :old_value => value,
      :value => 'Deleted')
  end
  def decimal_zero_removing(decimal)
    removed_zero = decimal.gsub(/^*[.][0]$/,'')
    return removed_zero ? removed_zero : decimal
  end

  def textile_to_html(text)
    t = RedCloth.new <<EOD
#{text}
EOD
    return t.to_html
  end

  def set_toolbar(id)
    javascript_tag(
      "jQuery(document).ready(function() {
        jQuery('##{id}').markItUp(mySettings);
      });")
  end

  def sortable(column, title = nil, default_action = nil)
    default_action ||= 'index'
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction, :action => default_action}, {:class => css_class, :remote => true}
  end

  #generic journal detail insertion
  def journal_insertion(updated_attributes, journal, journalized_property)
    updated_attrs = updated_attributes
    updated_attrs.each do |attribute, old_new_value|
      old_value = old_new_value[0]
      new_value = old_new_value[1]
      JournalDetail.create(:journal_id => journal.id,
        :property => journalized_property[attribute],
        :property_key => attribute,
        :old_value => old_value,
        :value => new_value)
    end
  end

  #generic journal renderer
  def history_render(journals)
    history_str = ""
    #    puts journals.inspect
    journals.each do |journal|
      if journal.details.any? || (!journal.notes.eql?("") && !journal.nil?)
        history_str += "<h3>#{t(:label_updated)} #{distance_of_time_in_words(journal.created_at,Time.now)} #{t(:label_ago)}, #{t(:label_by)} #{journal.user.name }</h3>"
        history_str += "<ul>"
        journal.details.each do |detail|
          if detail.old_value && (detail.value.nil? || detail.value.eql?(''))
            history_str += "<li><b>#{detail.property}</b> <b>#{detail.old_value.to_s}</b> #{t(:text_deleted)}</li>"
          elsif detail.old_value && detail.value
            history_str += "<li><b>#{detail.property}</b> #{t(:text_changed)} #{t(:text_from)} <b>#{detail.old_value.to_s}</b> #{t(:text_to)} <b>#{detail.value.to_s}</b></li>"
          else
            history_str += "<li><b>#{detail.property}</b> #{t(:text_set_at)} <b>#{detail.value.to_s}</b></li>"
          end
        end
        history_str += "</ul>"
        history_str += "<div class='box'> #{textile_to_html(journal.notes)}</div>" unless journal.notes.eql?('')
        history_str += "<br/><hr /><br/>" unless journal.eql?(journals.last)
      end
    end
    return history_str
  end

  def add_attachments_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :attachments, :partial => 'attachments', :object => Attachment.new
    end
  end

  def sort_hash_by_keys(hash, order)
    h = {}
    if order.eql?("desc")
      sorted_keys = hash.keys.sort{|x,y| y <=> x}
    else
      sorted_keys = hash.keys.sort{|x,y| x <=> y}
    end
    sorted_keys.each do |sorted_key|
      h[sorted_key] = hash[sorted_key]
    end
    return h
  end
  #  def act_as_admin?
  #    return session["act_as"].eql?("Admin")
  #  end
end
