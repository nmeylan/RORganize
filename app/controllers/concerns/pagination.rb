module Pagination
  def set_pagination
    set_current_page
    set_per_page
  end

  def sort_direction
    @sessions[:direction] = if params[:direction] then
                              params[:direction]
                            else
                              @sessions[:direction] ? @sessions[:direction] : 'desc'
                            end
  end

  def sort_column(default_column = nil)
    @sessions[:sort] = if params[:sort] then
                         params[:sort]
                       else
                         @sessions[:sort] ? @sessions[:sort] : default_column
                       end
  end

  def order(default_column)
    sort_column(default_column) + ' ' + sort_direction
  end

  def set_per_page
    @sessions[:per_page] = if params[:per_page] then
                             params[:per_page]
                           else
                             @sessions[:per_page] ? @sessions[:per_page] : 25
                           end
  end

  def set_current_page
    @sessions[:current_page] = params[:page]
  end
end