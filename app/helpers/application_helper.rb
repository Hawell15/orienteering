module ApplicationHelper
  def admin_user?
    return false unless current_user

    current_user.admin
  end
end
