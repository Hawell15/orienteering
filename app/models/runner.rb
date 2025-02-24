class Runner < ApplicationRecord
  belongs_to :club
  belongs_to :category
  belongs_to :best_category, class_name: 'Category'
  has_many :results, dependent: :destroy
  has_many :entries, dependent: :destroy

  accepts_nested_attributes_for :results

  # include Runner::Searchable
  # include Runner::Sortable
  # include Runner::Checksum
  include RunnerMatching
  # include Runner::Processing
  # include Runner::NameConversion
  # include Runner::Callbacks

  def self.add_runner(params, skip_matching = false)
    params = params.with_indifferent_access
    params['runner_name'] = convert_from_russian(params['runner_name'])
    params['surname']     = convert_from_russian(params['surname'])

    runner = matching_runner(params).first
    runner ||= get_runner_by_matching(params) unless skip_matching
    params['id'] ||= (Runner.last&.id || 0) + 1
    runner ||= Runner.create!(params.except('category_id', 'date'))

    if params['category_id'] && params['category_id'].to_i < runner.category_id.to_i
      ResultAndEntryProcessor.new({ runner_id: runner.id, group_id: 1, category_id: params['category_id'], date: params['date'].as_json }).add_result
    end
    runner
  end

  def junior_runner?
    Time.now.year - dob.year < 18
  end
end
