class MemberDecorator < ApplicationDecorator
  delegate_all

  # Render a select for roles if user has the permissions to change members roles. Else render the role name.
  # @param [Array] roles an array with all roles.
  def role_selection(roles)
    if User.current.allowed_to?('change_role', 'Members', context[:project])
      h.select_tag('roles_'+member.id.to_s, h.options_from_collection_for_select(roles, 'id', 'name', member.role ? member.role.id.to_s : ''),
                   {:class => 'chzn-select cbb-medium', :include_blank => true, 'data-link' => h.change_role_members_path(context[:project].slug, member.id)})
    else
      member.role.name
    end
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    super(h.t(:link_delete), h.member_path(context[:project].slug, model.id), context[:project])
  end
end
