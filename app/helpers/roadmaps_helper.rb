# Author: Nicolas Meylan
# Date: 2 févr. 2013
# Encoding: UTF-8
# File: roadmaps_helper.rb
module RoadmapsHelper
  require 'nokogiri'
  require 'open-uri'
  def gantt_hash(hash)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.projects {
        hash.each do |version, issues|
          if version.start_date
            xml.project(:id => version.id, :name => version.name, :startdate => version.start_date.strftime('%Y,%m,%d')){
              issues.each do |issue|
                task_builder(xml,issue,issues)
              end
            }
          end
        end
      }
    end
    return builder.to_xml.gsub(/\n/, '').gsub(/\"/,"'").gsub(/>\s*/, '>')
  end

  def task_builder(xml,issue,issues)
    if issue.start_date
      xml.task(:id => issue.id){
        xml.name issue.subject
        xml.est issue.start_date.strftime('%Y,%m,%d')
        xml.duration issue.due_date ? (issue.due_date - issue.start_date).to_i * 8 : ''
        xml.percentcompleted issue.done
        if !issue.parent.nil? && issue.parent.due_date < issue.start_date
          xml.predecessortasks issue.predecessor_id
        else
          xml.predecessortasks{}
        end
        xml.childtasks{
          issue.children.each do |child|
            if child.start_date && child.start_date <= issue.due_date
              issues.delete(child)
              task_builder(xml,child,issues)
            end
          end
        }

      }
    end
  end
end