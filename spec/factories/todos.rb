FactoryBot.define do
  factory :todo do
    sequence(:title) { |n| "#{n} #{Faker::Book.unique.title}" }
    description { Faker::Hacker.say_something_smart }
    status { ::Todo::PENDING }
  end

  trait :in_progress do
    status { ::Todo::IN_PROGRESS }
  end

  trait :done do
    status { ::Todo::DONE }
  end
end
