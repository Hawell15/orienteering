json.extract! relay_result, :id, :place, :team, :time, :category_id, :group_id, :date, :results, :created_at, :updated_at
json.url relay_result_url(relay_result, format: :json)
