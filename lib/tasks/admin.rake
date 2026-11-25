namespace :admin do
  # Render's free plan has no console, so the first admin is given rights on every start.
  # Works for an account created before ADMIN_EMAIL was set, too.
  desc "Make the user with ADMIN_EMAIL an admin"
  task promote: :environment do
    email = ENV["ADMIN_EMAIL"].to_s.strip.downcase

    if email.present?
      count = User.where("LOWER(email) = ?", email).update_all(admin: true)
      puts "admin:promote #{email} -> #{count} user(s)"
    else
      puts "admin:promote skipped: ADMIN_EMAIL is empty"
    end

    Rake::Task["demo:seed"].invoke if Rake::Task.task_defined?("demo:seed")
  end
end
