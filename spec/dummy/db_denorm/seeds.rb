def create_users
  3.times {|x| User.where(name: "Some User #{x}").first_or_create! }
end

create_users