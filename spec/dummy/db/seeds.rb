def create_users
  3.times do |x|
    user = User.find_or_initialize_by(name: "Some User #{x}")
    user.save
  end
end

create_users