def create_users
  6.times {|x| User.where(name: "Different User #{x}").first_or_create! }
end

create_users
