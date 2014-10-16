# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: filter_helper.rb
module Rorganize
  module Helpers
    module CustomTagHelper
      # Build a header for the given title.
      # @param [String] title.
      def box_header_tag(title, css_class = 'header')
        content_tag :div, class: css_class do
          if block_given?
            safe_concat content_tag :div, yield, class: 'right actions'
          end
          safe_concat content_tag(:h2, title)
        end
      end

      # Build a button that display an info to the user when he click on it.
      # @param [String] info : text info.
      # @param [hash] options : html_options.
      def info_tag(info, options = {})
        default_options = {class: 'octicon octicon-info', title: info}
        content_tag :span, nil, default_options.merge(options)
      end

      # Build a 32x32 glyph render.
      # @param [String] body : content.
      # @param [String] names : glyph names.
      def mega_glyph(body, *names)
        generic_glyph(body, 'mega', *names)
      end

      # Build a 24x24 glyph render.
      # @param [String] body : content.
      # @param [String] names : glyph names.
      def medium_glyph(body, *names)
        generic_glyph(body, 'medium', *names)
      end

      # Build a 16x16 glyph render.
      # @param [String] body : content.
      # @param [String] names : glyph names.
      def glyph(body, *names)
        generic_glyph(body, '', *names)
      end

      def generic_glyph(body, type, *names)
        type += '-' unless type.blank?
        content_tag(:span, nil, class: names.map { |name| "octicon-#{name.to_s.tr('_', '-')}" }.push("#{type}octicon")) + body
      end

      # Build a 16x16 glyph render, if condition is true else return raw content.
      # @param [String] body : content.
      # @param [Boolean] bool : the condition.
      # @param [String] names : glyph names.
      def conditional_glyph(body, bool, *names)
        if bool
          glyph(body, *names)
        else
          body
        end
      end

      # Build a dynamic progress bar for a given percentage.
      # @param [Numeric] percent : percentage of progression.
      # @param [String] css_class : extra css_class.
      def progress_bar_tag(percent, css_class = nil)
        css_class ||= ''
        css_class += ' progress-bar'
        content_tag :span, class: css_class do
          safe_concat content_tag :span, '&nbsp'.html_safe, {class: 'progress', style: "width:#{percent}%"}
          safe_concat content_tag :span, "#{percent}%", {class: 'percent'}
        end
      end

      def mini_progress_bar_tag(percent, css_class = nil)
        css_class ||= ''
        css_class += ' progress-bar mini-progress-bar'
        content_tag :span, {class: css_class} do
          safe_concat content_tag :span, '&nbsp'.html_safe, {class: 'progress', style: "width:#{percent}%"}
        end
      end

      # @param [Fixnum] count : number to display.
      # @return [String] build a <span> do display a number with the "count" css class.
      def sidebar_count_tag(count)
        content_tag :span, count, class: 'count'
      end

      # @param [Form] form : the form in which the field will be placed.
      # @param [Symbol] field : the name of the field.
      # @return [String] build a color picker text field. Behaviour is bind on page load (JS).
      def color_field_tag(form, field)
        form.text_field field, autocomplete: 'off', maxlength: 7, class: 'color-editor-field'
      end

      def concat_span_tag(content, options = {})
        safe_concat content_tag :span, content, options
      end

      # @return [String] : div that clear left and right.
      def clear_both
        content_tag :div, nil, {class: 'clear-both'}
      end

      # @param [String] text : to display when there are no data to display
      # @return [String] : div block containing text.
      # @param [String] glyph : glyph name to display.
      # @param [Boolean] large : large display or not?
      def no_data(text = nil, glyph = nil, large = false)
        content_tag :div, class: "no-data #{large ? 'large' : '' }" do
          if glyph
            safe_concat (glyph('', glyph))
          end
          safe_concat content_tag :h3, text ? text : t(:text_no_data)
        end
      end
    end
  end
end