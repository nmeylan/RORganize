/**
 * User: nmeylan
 * Date: 20.06.15
 * Time: 10:30
 */

// This fix the chosen width when select is hidden.
AbstractChosen.prototype.container_width = function() {
  if (this.options.width != null) {
    return this.options.width;
  } else {
    var calculatedWidth = this.form_field.offsetWidth;
    // Fix for zero width on hidden inputs.
    if (0 == calculatedWidth) {
      var clone = this.form_field_jq.clone();
      clone.appendTo(this.form_field_jq);
      clone.css({display: "block"});
      if (clone.css("width").indexOf("%") != -1) {
        calculatedWidth = clone.css("width");
        clone.remove();
        return calculatedWidth;
      } else {
        calculatedWidth = clone.outerWidth();
        clone.remove();
      }
    }
    return "" + calculatedWidth + "px";
  }
};