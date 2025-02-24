module Runner::Checksum
  extend ActiveSupport::Concern

  def self.get_checksum(runner_name, surname, dob, gender)
    Digest::SHA2.hexdigest("#{runner_name}-#{surname}-#{dob.to_date.year}-#{gender}")
  end

  def get_checksum
    self.class.get_checksum(runner_name, surname, dob, gender)
  end
end
