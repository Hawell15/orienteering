FactoryBot.define do
  factory :entry do
    date { "2024-02-07" }
    runner { nil }
    category { nil }
    result { nil }
    status { "MyString" }
  end
end
