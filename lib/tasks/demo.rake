namespace :demo do
  desc "Create demo inventories for the walkthrough"
  task seed: :environment do
    DemoData.seed!
  end
end
