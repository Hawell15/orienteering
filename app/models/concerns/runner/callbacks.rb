module Runner::Callbacks
  extend ActiveSupport::Concern

  included do
    before_save :add_checksum
    before_save :check_dob
  end

  private

  def add_checksum
    self.checksum = get_checksum
  end

  def check_dob
    self.dob = "01-01-0000".to_date if dob.to_date == "01-01-2025".to_date
  end
end
