json.extract! entry, :id, :date, :runner_id, :category_id, :result_id, :status, :created_at, :updated_at
json.url entry_url(entry, format: :json)
