namespace :admin do
  # Render's free plan has no console, so the first admin is given rights on every start.
  # Works for an account created before ADMIN_EMAIL was set, too.
  desc "Make the user with ADMIN_EMAIL an admin"
  task promote: :environment do
    email = ENV["ADMIN_EMAIL"].to_s.strip.downcase
    next if email.empty?

    count = User.where("LOWER(email) = ?", email).update_all(admin: true)
    puts "admin:promote #{email} -> #{count} user(s)"
  end
end
