json.extract! runner, :id, :runner_name, :surname, :dob, :club_id, :gender, :wre_id, :best_category_id, :category_id, :category_valid, :sprint_wre_rang, :forest_wre_rang, :sprint_wre_place, :forest_wre_place, :checksum, :created_at, :updated_at, :license
json.url runner_url(runner, format: :json)
