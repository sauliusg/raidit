# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'
require 'timecop'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

Before do
  Repository.reset!
  Repository.configure(
    "User"        => InMemory::UserRepo.new,
    "Guild"       => InMemory::GuildRepo.new,
    "Character"   => InMemory::CharacterRepo.new,
    "Raid"        => InMemory::RaidRepo.new,
    "Signup"      => InMemory::SignupRepo.new,
    "Permission"  => InMemory::PermissionRepo.new
  )

  Repository.for(User).save(
    jason = User.new(:login => "jason", :password => "password")
  )

  Repository.for(User).save(
    User.new(:login => "raider", :password => "password")
  )

  Repository.for(Guild).save(
    exiled = Guild.new(:name => "Exiled")
  )

  Repository.for(Permission).save(
    Permission.new(:user => jason, :guild => exiled,
                    :permissions => Permission::RAID_LEADER)
  )
end
