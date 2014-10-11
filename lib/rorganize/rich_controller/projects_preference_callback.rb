module Rorganize
  module RichController
    module ProjectsPreferenceCallback

      def save_star_project
        members = @user.members
        member = members.detect { |member| member.project.slug.eql?(params[:project_id]) }
        project = Project.find_by_slug(params[:project_id])
        if member.nil? && project.is_public
          member = star_public_project(project)
        end
        member.is_project_starred = !member.is_project_starred
        member.save
        message = "#{t(:text_project)} #{member.project.name} #{member.is_project_starred ? t(:successful_starred) : t(:successful_unstarred)}"
        return member, message
      end

      def star_public_project(project)
        non_member_role = Role.find_by_name('Non member')
        Member.create({project_id: project.id, user_id: User.current.id, role_id: non_member_role.id})
      end

      def update_project_position
        members = @user.members.includes(:project)
        project_ids = params[:ids]
        public_project_position_change(members, project_ids)
        members.each do |member|
          member.project_position = project_ids.index(member.project.slug)
          member.save
        end
      end

      def public_project_position_change(members, project_ids)
        member_project_slug = members.map { |member| member.project.slug }
        diff = project_ids - member_project_slug
        if diff.any?
          non_member_projects = Project.where(slug: diff)
          non_member_role = Role.find_by_name('Non member')
          create_non_member(members, non_member_projects, non_member_role)
        end
      end

      def create_non_member(members, non_member_projects, non_member_role)
        non_member_projects.each do |project|
          members << Member.create({project_id: project.id, user_id: User.current.id, role_id: non_member_role.id}) if project.is_public
        end
      end
    end
  end
end
