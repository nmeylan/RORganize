# Author: Nicolas Meylan
# Date: 06.01.15
# Encoding: UTF-8
# File: code_coverage.rb

require 'coveralls'

class CodeCoverage
  GROUP_HASH = {
      "Controller" => %w(app/controllers lib/rorganize/rich_controller),
      "Decorators" => "app/decorators",
      "Helpers" => %w(app/helpers lib/rorganize/helpers),
      "Models" => %w(app/models lib/rorganize/models),
      "QueryObjects" => "app/query_objects",
      "ViewObjects" => "app/view_objects",
      "Managers" => "lib/rorganize/managers",
      "Filters" => "lib/rorganize/filters"
  }
  EXCLUDED_FILES = %w()

  def self.start
    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
        SimpleCov::Formatter::HTMLFormatter,
        Coveralls::SimpleCov::Formatter
    ]
    SimpleCov.start 'rails' do
      add_filter '/spec/'
      add_filter '/db/'
      add_filter '/lib/tasks/'
      add_filter '/vendor/'
      add_filter '/config/'
      add_filter '/app/mailers/'


      GROUP_HASH.each do |group_name, dir|
        if dir.is_a?(Array)
          g_name = group_name.eql?("Controller") ? "Controllers" : group_name
          add_group(g_name, &->(source_file) { source_file.filename.include?(group_name.downcase) })
        else
          add_group group_name, dir
        end
      end

      add_group 'Libraries', &->(source_file) { File.dirname(source_file.filename).end_with?('lib/rorganize') }
    end

    force_coverage_on_all_files if ENV['FORCE_COVERAGE']
  end

  def self.force_coverage_on_all_files
    base_result = {}
    GROUP_HASH.each_value do |dir|
      if dir.is_a?(Array)
        dir.each do |d|
          base_result_for_source(base_result, d)
        end
      else
        base_result_for_source(base_result, dir)
      end
    end
    append_base_result_hash(Dir['lib/rorganize/*.rb'], base_result)
  end

  def self.base_result_for_source(base_result, dir)
    all_files = Dir["#{dir}/**/*.rb"]
    append_base_result_hash(all_files, base_result)
  end

  def self.append_base_result_hash(all_files, base_result)
    all_files.each do |file|
      absolute = File::expand_path(file)
      lines = File.readlines(absolute, :encoding => 'UTF-8')
      base_result[absolute] = lines.map do |l|
        l.strip!
        l.empty? || l =~ /^else$/ || l =~ /^end$/ || l[0] == '#' ? nil : 0
      end
    end

    SimpleCov.at_exit do
      merged = SimpleCov::Result.new(Coverage.result).original_result.merge_resultset(base_result)
      result = SimpleCov::Result.new(merged)
      result.format!
    end
  end
end