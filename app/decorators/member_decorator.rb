class MemberDecorator < ApplicationDecorator
  delegate_all

  def role_selection(roles)
    if User.current.allowed_to?('change_role', 'Members', context[:project])
      h.select_tag('roles_'+member.id.to_s, h.options_from_collection_for_select(roles, 'id', 'name', member.role ? member.role.id.to_s : ''),
                 {:class => 'chzn-select cbb-medium', :include_blank => true, 'data-link' => h.change_role_members_path(context[:project].slug, member.id)})
    else
      member.role.name
    end
  end

  def delete_link
    super(h.t(:link_delete), h.member_path(context[:project].slug, model.id), context[:project])
  end
end
