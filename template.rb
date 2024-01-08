run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "devise"
    gem "autoprefixer-rails"
    gem "font-awesome-sass", "~> 6.1"
    gem "cloudinary"
    gem "pundit"
    gem "rails_admin", "3.0"
    gem "sidekiq", "< 7"
    gem "sidekiq-failures", "~> 1.0"
    gem 'redis-namespace'
    gem 'redis-rails'
    gem 'faker'
    gem 'pagy'
    gem 'friendly_id'
    gem 'acts-as-taggable-on'
    gem 'stripe'
    gem "pg_search"
    gem "geocoder"
    gem "view_component"
    gem 'wicked'
    gem 'rails-i18n', '~> 7.0.0'
    gem 'devise-i18n'
  RUBY
end

inject_into_file "Gemfile", after: 'gem "debug", platforms: %i[ mri mingw x64_mingw ]' do
  "\n  gem \"dotenv-rails\""
end

# Assets
########################################
run "rm -rf app/assets/stylesheets"
run "rm -rf vendor"
run "curl -L https://github.com/lewagon/rails-stylesheets/archive/master.zip > stylesheets.zip"
run "unzip stylesheets.zip -d app/assets && rm -f stylesheets.zip && rm -f app/assets/rails-stylesheets-master/README.md"
run "mv app/assets/rails-stylesheets-master app/assets/stylesheets"

# Layout
########################################
gsub_file(
  "app/views/layouts/application.html.erb",
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
)

# Flashes
########################################
file "app/views/shared/_flashes.html.erb", <<~HTML
  <% if notice %>
  <div class="fixed bottom-24 md:bottom-10 left-1/2 transform -translate-x-1/2 z-50 flex items-center justify-between p-2 leading-normal border border-black" role="alert">
      <p><%= notice %></p>
  
      <svg onclick="return this.parentNode.remove();"
          class="inline w-4 h-4 fill-current ml-2 hover:opacity-80 cursor-pointer" xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 512 512">
          <path
              d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256s256-114.6 256-256S397.4 0 256 0zM256 464c-114.7 0-208-93.31-208-208S141.3 48 256 48s208 93.31 208 208S370.7 464 256 464zM359.5 133.7c-10.11-8.578-25.28-7.297-33.83 2.828L256 218.8L186.3 136.5C177.8 126.4 162.6 125.1 152.5 133.7C142.4 142.2 141.1 157.4 149.7 167.5L224.6 256l-74.88 88.5c-8.562 10.11-7.297 25.27 2.828 33.83C157 382.1 162.5 384 167.1 384c6.812 0 13.59-2.891 18.34-8.5L256 293.2l69.67 82.34C330.4 381.1 337.2 384 344 384c5.469 0 10.98-1.859 15.48-5.672c10.12-8.562 11.39-23.72 2.828-33.83L287.4 256l74.88-88.5C370.9 157.4 369.6 142.2 359.5 133.7z" />
      </svg>
  </div>
  <% end %>
  <% if alert %>
  <div class="fixed bottom-24 md:bottom-10 left-1/2 transform -translate-x-1/2 z-50 flex items-center justify-between p-2 leading-normal border border-black"
      role="alert">
      <svg class="w-5 h-5 inline mr-3" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd"
              d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
              clip-rule="evenodd"></path>
      </svg>
      <div>
          <%= alert %>
      </div>
  </div>
  <% end %>
HTML

file "app/views/shared/_navbar.html.erb", <<~HTML
  <nav class="h-14 w-full sticky top-0 z-10 text-stone-800 p-4 lg:px-8">
    <div class="flex grid grid-cols-4 items-center">
        <div onclick="openNav()" class="cursor-pointer">
            <i class="fa-solid fa-xl fa-bars"></i>
        </div>
        <%= link_to root_path, class:"col-span-2 block cursor-pointaer text-sm lg:text-lg text-center font-bold" do %>
            <h2>TEMPLATE</h2>
        <% end %>
        <div class="flex justify-end items-center font-semibold">
            <%= link_to "FR", root_path(locale: :fr), class:"block px-2 py-1" %>
            <%= link_to "EN", root_path(locale: :en),class:"block px-2 py-1" %>
        </div>
    </div>
    <div onclick="exitNav()" id="sideBar"
            class="fixed top-14 left-0 w-full h-0 overflow-y-hidden duration-500 z-50">
            <div id="sideNav" class="fixed top-14 left-0 w-full h-0 overflow-y-hidden duration-500 font-light z-50" style="background: url('<%= asset_path('background.jpg') %>'); background-repeat: repeat; background-size: 300px 300px;">
                <div class="w-full flex flex-col divide-y pt-2">
                    <%= link_to t(".home"), root_path, class:"hover:bg-stone-900 text-center hover:text-white duration-700" %>
                    <% if user_signed_in? %>
                    <%= link_to t(".signout"), destroy_user_session_path, data: {turbo_method: :delete}, class:"hover:bg-stone-900 text-center hover:text-white duration-700" %>
                    <% else %>
                    <%= link_to t(".signin"), new_user_session_path, class:"hover:bg-stone-900 text-center hover:text-white duration-700" %>
                    <% end %>
                </div>
            </div>
        </div>
</nav>
<script>
    function openNav() {
        document.getElementById("sideBar").classList.toggle("h-full");
        document.getElementById("sideNav").classList.toggle("h-64");
    }

    function exitNav() {
        document.getElementById("sideBar").classList.toggle("h-full");
        document.getElementById("sideNav").classList.toggle("h-64");
    }
</script>
HTML

inject_into_file "app/views/layouts/application.html.erb", after: "<body>" do
  <<~HTML
    <%= render "shared/navbar" %>
    <%= render "shared/flashes" %>
  HTML
end

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

########################################
# After bundle
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rails_command "db:drop db:create db:migrate"
  generate(:controller, "pages", "home", "--skip-routes", "--no-test-framework")

  # Routes
  ########################################
  route 'root to: "pages#home"'

  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT
    # Ignore .env file containing credentials.
    .env*

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  # Devise install + user
  ########################################
  generate("devise:install")
  generate("active_storage:install")
  generate("devise", "User")
  generate("geocoder:config")
  generate("pundit:install")

  # Application controller
  ########################################
  run "rm app/controllers/application_controller.rb"
  file "app/controllers/application_controller.rb", <<~RUBY
    class ApplicationController < ActionController::Base
      before_action :authenticate_user!
    end
  RUBY

  # migrate + devise views
  ########################################
  rails_command "db:migrate"
  generate("devise:views")
  gsub_file(
    "app/views/devise/registrations/new.html.erb",
    "<%= simple_form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>",
    "<%= simple_form_for(resource, as: resource_name, url: registration_path(resource_name), data: { turbo: :false }) do |f| %>"
  )
  gsub_file(
    "app/views/devise/sessions/new.html.erb",
    "<%= simple_form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>",
    "<%= simple_form_for(resource, as: resource_name, url: session_path(resource_name), data: { turbo: :false }) do |f| %>"
  )
  link_to = <<~HTML
    <p>Unhappy? <%= link_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete %></p>
  HTML
  button_to = <<~HTML
    <div class="d-flex align-items-center">
      <div>Unhappy?</div>
      <%= button_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete, class: "btn btn-link" %>
    </div>
  HTML
  gsub_file("app/views/devise/registrations/edit.html.erb", link_to, button_to)

  # Pages Controller
  ########################################
  run "rm app/controllers/pages_controller.rb"
  file "app/controllers/pages_controller.rb", <<~RUBY
    class PagesController < ApplicationController
      skip_before_action :authenticate_user!, only: [ :home ]

      def home
      end
    end
  RUBY

  # Environments
  ########################################
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: "development"
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: "production"

  # Heroku
  ########################################
  run "bundle lock --add-platform x86_64-linux"

  # Dotenv
  ########################################
  run "touch '.env'"

  # Rubocop
  ########################################
  run "curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml"

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit'"
end
