module ApplicationHelper
  def admin_user?
    return false unless current_user

    current_user.admin
  end

  def club_admin?(_club = 0)
    return false
  end
end
