FactoryBot.define do
  factory :user do
    email { 'test@test.test' }
    password { 'testtestest' }
    # line below is needed only if you use devise :confirmable
  end
end