module ApplicationHelper
  def admin_user?
    return false unless current_user

    current_user.admin
  end

  def club_admin?(_club = 0)
    return false
  end

   def all_countries
    ISO3166::Country.translations('ro').values
  end
end
