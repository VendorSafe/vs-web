# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/application-options.md

# Application Options

The following configuration options are available for your Bullet Train application. For local development, you can set these values in `config/application.yml`. For hosting providers that we provide first-party support for, you can consult [Render's documentation](https://render.com/docs/environment-variables) and [Heroku's documentation](https://devcenter.heroku.com/articles/config-vars) for how to set these values.

| Option | Purpose | Example Value <sup><a href="#footnote-1">1</a></sup> | Helper Methods |
| --- | --- | --- | --- |
| `BASE_URL` | Specify the full URL where the application is hosted | `https://app.yourproduct.com` | |
| `HIDE_THINGS` | [Hide the "Creative Concept" demo model and "Tangible Thing" template model](/docs/super-scaffolding.md) | `true` | `scaffolding_things_disabled?` |
| `STRIPE_CLIENT_ID` | [Enable the example OAuth2 integration with Stripe Connect](/docs/oauth.md) | `ca_DBOenflO97IalW31IEvpvSKGHjOWhGzJ` | `stripe_enabled?` |
| `CLOUDINARY_URL` | Enable Cloudinary-powered image uploads, including profile photos | `cloudinary://9149...:3HSd...@hfytqhfzj` | `cloudinary_enabled?` |
| `INVITATION_KEYS` | [Restrict new sign-ups](/docs/authentication.md) | `89dshwxja, a9y29ihs1` | `invitation_keys` `invitation_only?` |
| `FONTAWESOME_NPM_AUTH_TOKEN` | [Enable Font Awesome Pro](/docs/font-awesome-pro.md) | `5DC62AA7-5741-4C45-874B-EA9CAA4EE085` | `font_awesome?` |
| `OPENAI_ACCESS_TOKEN` | Enable OpenAI-powered UX improvements | `sk-Tnko8PI15i6du03KkxVExTz3lbkFJV...` | `openai_enabled?` |
| `REDOCLY_ORGANIZATION_ID` | Enable Redocly-powered API documentation | `your-organization-name` | |
| `REDOCLY_API_KEY` | Enable Redocly-powered API documentation |`orgsk_lfyrXAAym8nbSrar9b8wvTN+...`| |
| `DISABLE_DEVELOPER_MENU` | Disable the `developer` tab in the navigation bar | `true` | disable_developer_menu? |

<sup><a name="footnote-1"></a>1</sup> Any credentials listed here aren't real, but we wanted you to know what each looks like so you can recognize the correct value from each provider.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/authentication.md

# Authentication
Bullet Train uses [Devise](https://github.com/heartcombo/devise) for authentication and we've done the work of making the related views look pretty and well-integrated with the look-and-feel of the application template.

## Customizing Controllers
Bullet Train registers its own slightly customized registration and session controllers for Devise. If you want to customize them further, you can simply eject those controllers from the framework and override them locally, like so:

```
bin/resolve RegistrationsController --eject --open
bin/resolve SessionsController --eject --open
```

## Customizing Views
You can customize Devise views using the same workflow you would use to customize any other Bullet Train views.

## Invite-Only Mode and Disabling Registration
If you would like to stop users from signing up for your application without an invitation code or without an invitation to an existing team, set `INVITATION_KEYS` to one or more comma-delimited values in `config/application.yml` (or however you configure your environment values in production.) Once invitation keys are configured, you can invite people to sign up with one of your keys at the following URL:

```
https://example.com/invitation?key=ONE_OF_YOUR_KEYS
```

If you want to disable new registrations completely, put an unguessable value into `INVITATION_KEYS` and keep it secret.

Note that in both of these scenarios that existing users will still be able to invite new collaborators to their teams and those collaborators will have the option of creating a new account, but no users in the application will be allowed to create a new team without an invitation code and following the above URL.

## Enabling Two-Factor Authentication (2FA)
Two-factor authentication is enabled by default in Bullet Train, but you must have Rails built-in encrypted secrets and Active Record Encryption configured.

To do this, first run:

```
bin/secrets
```

That will generate some credentails files for you.

Then you'll need to set encryption keys, either in those newly generated credentials files, or you can do it via environment variables.

Generate some keys by running:

```
bin/rails db:encryption:init
```

That will output something like this:

```
active_record_encryption:
  primary_key: NLngkt...
  deterministic_key: edpu...
  key_derivation_salt: Bfwy...
```

Then to add them to your `development` credentials file run:

```
bin/rails credentials:edit --environment development
```

That will decrypt `config/credentials/development.yml.enc` and open it in your editor. Paste in the block of keys you generated in the previous step, save, and close the file.

If you'd rather set them via environment variables you could add something like this to `config/application.rb`:

```
config.active_record.encryption.primary_key = ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY']
config.active_record.encryption.deterministic_key = ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY']
config.active_record.encryption.key_derivation_salt = ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']
```

And then populate those ENV variables by whatever means you use. (Maybe setting them in `.env` or possibly exporting them directly.)

After you have things working in development you'll need to follow the same process for your production environment, and any others.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/action-models.md

# Action Models

Action Models make it easy to scaffold and implement user-facing custom actions in your Bullet Train application and API in a RESTful way. Action Models are perfect for situations where you want one or more of the following:

 - Bulk actions for a model where users can select one or more objects as targets.
 - Long-running background tasks where you want to keep users updated on their progress in the UI or notify them after completion.
 - Actions that have one or more configuration options available.
 - Tasks that can be configured now but scheduled to take place later.
 - Actions where you want to keep an in-app record of when it happened and who initiated the action.
 - Tasks that one team member can initiate, but a team member with elevated privileges has to approve.

Examples of real-world features that can be easily implemented using Action Models include:

 - A project manager can archive multiple projects at once.
 - A customer service agent can refund multiple payments at once and provide a reason.
 - A user can see progress updates while their 100,000 row CSV file is imported.
 - A marketing manager can publish a blog post now or schedule it for publication tomorrow at 9 AM.
 - A contributor can propose a content template change that will be applied after review and approval.

Importantly, Action Models aren't a special new layer in your application or a special section of your code base. Instead, they're just regular models, with corresponding scaffolded views and controllers, that exist alongside the rest of your domain model. They leverage Bullet Train's existing strengths around domain modeling and code generation with Super Scaffolding.

They're also super simple and very DRY. Consider the following example, assuming the process of archiving each project is very complicated and takes a lot of time:

```ruby
class Projects::ArchiveAction < ApplicationRecord
  include Actions::TargetsMany
  include Actions::ProcessesAsync
  include Actions::HasProgress
  include Actions::CleansUp

  belongs_to :team

  def valid_targets
    team.projects
  end

  def perform_on_target(project)
    project.archive
  end
end
```

## Installation

### 1. Purchase Bullet Train Pro

First, [purchase Bullet Train Pro](https://buy.stripe.com/aEU7vc4dBfHtfO89AV). Once you've completed this process, you'll be issued a private token for the Bullet Train Pro package server. The process is currently completed manually, so you may have to wait a little to receive your keys.

### 2. Install the Package

Then you can specify the Ruby gem in your `Gemfile`:

```ruby
source "https://YOUR_TOKEN_HERE@gem.fury.io/bullettrain" do
  gem "bullet_train-action_models"
end
```

Don't forget to run `bundle install` and `rails restart`.

## Super Scaffolding Commands

You can get detailed information about using Super Scaffolding to generate different types of Action Models like so:

```
rails generate super_scaffold:action_models:targets_many
rails generate super_scaffold:action_models:targets_one
rails generate super_scaffold:action_models:targets_one_parent
rails generate super_scaffold:action_models:performs_import
rails generate super_scaffold:action_models:performs_export
```

## Basic Example

### 1. Generate and scaffold an example `Project` model.

```
rails generate super_scaffold Project Team name:text_field
```

### 2. Generate and scaffold an archive action for projects.

```
rails generate super_scaffold:action_models:targets_many Archive Project Team
```

### 3. Implement the action logic.

Open `app/models/projects/archive_action.rb` and update the implementation of this method:

```ruby
def perform_on_target(project)
  project.archive
end
```

You're done!

## Additional Examples

### Add configuration options to an action.

Because Action Models are just regular models, you can add new fields to them with Super Scaffolding the same as any other model. This is an incredible strength, because it means the configuration options for your Action Models can leverage the entire suite of form field types available in Bullet Train, and maintaining the presentation of those options to users is like maintaining any other model form in your application.

For example:

```
# side quest: update the generated migration with `default: false` on the new boolean field.
rails g super_scaffold:crud_field Projects::ArchiveAction notify_users:boolean
```

Now users will be prompted with that option when they perform this action, and you can update your logic to take action based on it, or at least pass on the information to another method that takes action based on it:

```ruby
def perform_on_target(project)
  project.archive(send_notification: notify_users)
end
```

## Action Types

Action Models can be generated in five flavors:

 - `rails g super_scaffold:action_models:targets_many`
 - `rails g super_scaffold:action_models:targets_one`
 - `rails g super_scaffold:action_models:targets_one_parent`
 - `rails g super_scaffold:action_models:performs_import`
 - `rails g super_scaffold:action_models:performs_export`

### Targets Many

Action Models that _can_ target many objects are by far the most common, but it's important to understand that they're not only presented to users as bulk actions. Instead, by default, they're presented to users as an action available for each individual object, but they're also presented as a bulk action when users have selected multiple objects.

"Targets many" actions live at the same level in the domain model (and belong to the same parent) as the model they target. (If this doesn't make immediate sense, just consider that it would be impossible for instances of these actions to live under multiple targets at the same time.)

### Targets One

Sometimes you have an action that will only ever target one object at a time. In this case, they're generated a little differently and live under (and belong to) the model they target.

When deciding between "targets many" and "targets one", our recommendation is that you only use "targets one" for actions that you know for certain could never make sense targeting more than one object at the same time. For example, if you're creating a send action for an email that includes configuration options and scheduling details, you may be reasonably confident that you never need users to be able to schedule two different emails at the same time with the same settings. That would be a good candidate for a "targets one" action.

### Targets One Parent

This type of action is available for things like custom/complex importers that don't necessarily target specific existing objects by ID, but instead create many new or affect many existing objects under a specific parent based on the configuration of the action (like an attached CSV file.) These objects don't "target many" per se, but they live at the same level (and belong to the same parent) as the models they end up creating or affecting.

### Performs Import

This action is useful for allowing users to upload a CSV representing a list of models that they'd like to have created in the system. It handles mapping columns in the CSV to attributes on the model you're creating.

### Performs Export

This action will allow users to export a CSV from a list of models in the application.

## Frequently Asked Questions

### Do Action Models have to be persisted to the database?

No. Action Models extend from `ApplicationRecord` by default, but if you're not using features that depend on persistence to the database, you can make them `include ActiveModel::API` instead. That said, it's probably not worth the trouble. As an alternative, consider just including `Actions::CleansUp` in your action to ensure it removes itself from the database after completion.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/i18n.md

# Translations and Internationalization

Bullet Train and views generated by Super Scaffolding are localized by default, meaning all of the human-readable text in your application has been extracted into a YAML configuration file in `config/locales/en` and can be translated into any language you would like to target.

We override the native I18n translation method to automatically include the current team name or other objects depending on the string. For example, here's a description of a membership which you can find on a membership's show page:

```
The following are the details for David’s Membership on Your Team.
```

The view can be found here in the `bullet_train` gem:<br/>[bullet_train-core/bullet_train/app/views/account/memberships/show.html.erb](https://github.com/bullet-train-co/bullet_train-core/blob/fab77efab57126c083e0041f97c0e716560a2ffe/bullet_train/app/views/account/memberships/show.html.erb#L16)<br/>
<br/>
Looking at the view, you can see we are only passing a key to the translation method for I18n to process:

```erb
<%= t('.description') %>
```

However, looking at the [locale itself](https://github.com/bullet-train-co/bullet_train-core/blob/fab77efab57126c083e0041f97c0e716560a2ffe/bullet_train/config/locales/en/memberships.en.yml#L82), you can see that the string takes two variables, `memberships_possessive` and `team_name`, to complete the string:
```yaml
description: The following are the details for %{memberships_possessive} Membership on %{team_name}.
```

Usually, you would pass the variable as a keyword argument:
```ruby
t('.description', memberships_possessive: memberships_possessive, team_name: current_team.name)
```

However, in Bullet Train, we override the original translation method to include variable names like this automatically in our locales. Check out the [locale helper](https://github.com/bullet-train-co/bullet_train-core/blob/main/bullet_train/app/helpers/account/locale_helper.rb) to get a closer look at how we handle strings for internationalization. For example, the two variables above are generated by the method `model_locales` in the locale helper.

You can find more information in the [indirection documentation](indirection) about using `bin/resolve` and logs to pinpoint where your locales are coming from.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/permissions.md

# Roles, Permissions, Abilities, and Authorization

## CanCanCan
Bullet Train leans heavily on [CanCanCan](https://github.com/CanCanCommunity/cancancan) for implementing authorization and permissions. (We’re also proud sponsors of its ongoing maintenance.) The original CanCan library by Ryan Bates was, in our opinion, a masterpiece and a software engineering marvel that has stood the test of time. It's truly a diamond among Ruby Gems. If you're not already familiar with CanCanCan, you should [read its documentation](https://github.com/CanCanCommunity/cancancan) to get familiar with its features and DSL.

## Bullet Train Roles
Over many years of successfully implementing applications with CanCanCan, it became apparent to us that a supplemental level of abstraction could help streamline and simplify the definition of many common permissions, especially in large applications. We've since extracted this functionality into [a standalone Ruby Gem](https://github.com/bullet-train-co/bullet_train-core/tree/main/bullet_train-roles) and moved the documentation that used to be here into [the README for that project](https://github.com/bullet-train-co/bullet_train-core/tree/main/bullet_train-roles). Should you encounter situations where this abstraction doesn't meet your specific needs, you can always implement the permissions you need using standard CanCanCan directives in `app/models/ability.rb`.

## Additional Notes

### Caching
Because abilities are being evaluated on basically every request, it made sense to introduce a thin layer of caching to help speed things up. When evaluating permissions, we store a cache of the result in the `ability_cache` attribute of the `User`. By default, making changes to a model that includes the `Roles::Support` concern will invalidate that user's cache.

### Naming and Labeling
What we call a `Role` in the domain model is referred to as “Special Privileges” in the user-facing application. You can rename this to whatever you like in `config/locales/en/roles.en.yml`.

## A Note About Pundit
There’s nothing stopping you from utilizing Pundit in a Bullet Train project for specific hard-to-implement cases in your permissions model, but you wouldn’t want to try and replace CanCanCan with it. We do too much automatically with CanCanCan for that to be recommended. That said, in those situations where there is a permission that needs to be implemented that isn’t easily implemented with CanCanCan, consider just writing vanilla Ruby code for that purpose.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/namespacing.md

# Namespacing in Bullet Train

## The `Account` Namespace for Controllers and Views
Bullet Train comes preconfigured with an `Account` namespace for controllers and views. This is the place where Super Scaffolding will, by default, put new resource views and controllers. The intention here is to ensure that in systems that have both authenticated resource workflows and public-facing resources, those two different facets of the application are served by separate resource views and controllers. (By default, public-facing resources would be in the `Public` namespace.)

## Alternative Authenticated Namespaces
In Bullet Train applications with [multiple team types](/docs/teams.md), you may find it helpful to introduce additional controller and view namespaces to represent and organize user interfaces and experiences for certain team types that vary substantially from the `Account` namespace default. In Super Scaffolding, you can specify a namespace other than `Account` with the `--namespace` option, for example:

```
rails generate super_scaffold Event Team name:text_field --namespace=customers
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/stylesheets.md

# Style Sheets
Bullet Train's stock UI theme, called “Light”, is built to use `tailwindcss` extensively, where most of the styling is defined within the `.html.erb` theme partials.

As such, there are two ways to update the styling of your app: either by modifying theme partials, or by adding your own custom CSS.

## Modify Theme Partials

Since `tailwindcss` is used, most style changes are done by ejecting theme partials into your app's `app/views` directory, and modifying the Tailwind classes within the `.html.erb` templates.

You can eject only the theme files you wish to override or you can eject the whole UI theme for customization. You can find more information in the [indirection documentation](indirection) about using `bin/resolve` to find the theme partials to eject. Or see the [themes documentation](themes) for details on using the "Light" UI theme as a starting point for creating your own.

## Add custom CSS 

To add your own custom CSS, add to the `app/assets/stylesheets/application.css` file found in your app. In this file, you'll be able to use Tailwind `@apply` directives and add `@import` statements to include the CSS from third-party `npm` packages.

For further modifications to the theme's style sheet (for example, to change the order in which base Tailwind stylesheets are included), you can eject the theme's css by using the command `rake bullet_train:themes:light:eject_css`.

# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/api.md

# REST API
We believe every SaaS application should have an API and [webhooks](/docs/webhooks/outgoing.md) available to users, so Bullet Train aims to help automate the creation of a production-grade REST API using Rails-native tooling and provides a forward-thinking strategy for its long-term maintenance.

## Background
Vanilla Rails scaffolding actually provides simple API functionality out-of-the-box: You can append `.json` to the URL of any scaffold and it will render a JSON representation instead of an HTML view. This functionality continues to work in Bullet Train, but our API implementation also builds on this simple baseline using the same tools with additional organization and some new patterns. 

## Goals

### Zero-Effort API
As with vanilla Rails scaffolding, Super Scaffolding automatically generates your API as you scaffold new models, and unlike vanilla Rails scaffolding, it will automatically keep it up-to-date as you scaffold additional attributes onto your models.

### Versioning by Default
By separating out and versioning API controllers, views, routes, and tests, Bullet Train provides [a methodology and tooling](/docs/api/versioning.md) to help ensure that once users have built against your API, changes in the structure of your domain model and API don't unexpectedly break existing integrations. You can [read more about API versioning](/docs/api/versioning.md).

### Standard Rails Tooling
APIs are built using standard Rails tools like `ActiveController::API`, [Strong Parameters](https://api.rubyonrails.org/classes/ActionController/StrongParameters.html), `config/routes.rb`, and [Jbuilder](https://github.com/rails/jbuilder). Maintaining API endpoints doesn't require special knowledge and feels like regular Rails development.

### Outsourced Authentication
In the same way we've adopted [Devise](https://github.com/heartcombo/devise) for best-of-breed and battle-tested authentication on the browser side, we've adopted [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) for best-of-breed and battle-tested authentication on the API side.

### DRY Authorization Logic
Because our API endpoints are standard Rails controllers, they're able to leverage the exact same [permissions definitions and authorization logic](/docs/permissions) as our account controllers.

## Structure
Where vanilla Rails uses a single controller in `app/controllers` for both in-browser and API requests, Bullet Train splits these into two separate controllers, one in `app/controllers/account` and another in `app/controllers/api/v1`, although a lot of logic is shared between the two.

API endpoints are defined in three parts:

1. Routes are defined in `config/routes/api/v1.rb`.
2. Controllers are defined in the `app/controllers/api/v1` directory.
3. Jbuilder views are defined in the `app/views/api/v1` directory.

## "API First" and Supporting Account Controllers
As previously mentioned, there is a lot of shared logic between account and API controllers. Importantly, there are a couple of responsbilities that are implemented "API first" in API controllers and then utilized by account controllers.

### Strong Parameters
The primary definition of Strong Parameters for a given resource is defined in the most recent version of the API controller and included from there by the account controller. In account controllers, where you might expect to see a Strong Parameters definition, you'll see the following instead:

```ruby
include strong_parameters_from_api
```

> This may feel counter-intuitive to some developers and you might wonder why we don't flip this around and have the primary definition in the account controller and have the API controller delegate to it. The answer is a pragmatic one: creating and maintaining the defintion of Strong Paramters in the API controller means it gets automatically frozen in time should you ever need to [bump your API version number](/docs/api/versioning.md). We probably _could_ accomplish this if things were the other way around, but it wouldn't happen automatically.

If by chance there are additional attributes that should be permitted or specific logic that needs to be run as part of the account controller (or inversely, only in the API controller), you can specify that in the controller like so:

```ruby
def permitted_fields
  [:some_specific_attribute]
end

def permitted_arrays
  {some_collection: []}
end

def process_params(strong_params)
  assign_checkboxes(strong_params, :some_checkboxes)
  strong_params
end
```

### Delegating `.json` View Rendering on Account Controllers

In Bullet Train, when you append `.json` to an account URL, the account controller doesn't actually have any `.json.jbuilder` templates in its view directory within `app/views/account`. Instead, by default the controller is configured to delegate the JSON rendering to the corresponding Jbuilder templates in the most recent version of the API, like so:

```ruby
# GET /account/projects/:id or /account/projects/:id.json
def show
  delegate_json_to_api
end
```

## Usage Example
First, provision a platform application in the section titled "Your Applications" in the "Developers" menu of the application. When you create a new platform application, an access token that doesn't automatically expire will be automatically provisioned along with it. You can then use the access token to hit the API, as seen in the following Ruby-based example:

```ruby
require 'net/http'
require 'uri'

# Configure an API client.
client = Net::HTTP.new('localhost', 3000)

headers = {
  "Content-Type" => "application/json",
  "Authorization" => "Bearer GfNLkDmzOTqAacR1Kqv0VJo7ft2TT-S_p8C6zPDBFhg"
}

# Fetch the team details.
response = client.get("/api/v1/teams/1", headers)

# Parse response.
team = JSON.parse(response.body)

# Update team name.
team["name"] = "Updated Team Name"

# Push the update to the API.
# Note that the team attributes are nested under a `team` key in the JSON body.
response = client.patch("/api/v1/teams/1", {team: team}.to_json, headers)
```

## Advanced Topics
 - [API Versioning](/docs/api/versioning.md)

## A Note About Other Serializers and API Frameworks
In early versions of Bullet Train we made the decision to adopt a specific serialization library, [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers), and in subsequent versions we went as far as to adopt an entire third-party framework ([Grape](https://github.com/ruby-grape/grape)) and a third-party API specification ([JSON:API](https://jsonapi.org)). We now consider it out-of-scope to try and make such decisions on behalf of developers. Support for them in Bullet Train applications and in Super Scaffolding could be created by third-parties.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/application-hash.md

## `ApplicationHash`
[Webhooks::Outgoing::EventType](https://github.com/bullet-train-co/bullet_train-core/blob/main/bullet_train-outgoing_webhooks/app/models/webhooks/outgoing/event_type.rb) inherits a class called [ApplicationHash](https://github.com/bullet-train-co/bullet_train/blob/main/app/models/application_hash.rb) which includes helpful methods from [ActiveHash](https://github.com/active-hash/active_hash).

ActiveHash itself is a simple base class that allows you to use a Ruby hash as a readonly datasource for an ActiveRecord-like model.

For webhooks in Bullet Train, this means that we can handle `Webhooks::Outgoing::EventType` similar to an ActiveRecord model even though it doesn't have a table in the database like models usually do, making it easier to order and utilize data like this in the context of a Rails application.

```
> rails c
irb(main):001:0> Scaffolding::AbsolutelyAbstract::CreativeConcept.all.class
=> Scaffolding::AbsolutelyAbstract::CreativeConcept::ActiveRecord_Relation
irb(main):002:0> Webhooks::Outgoing::EventType.all.class
=> ActiveHash::Relation

# An example from the EndpointSupport module
def event_types
  event_type_ids.map { |id| Webhooks::Outgoing::EventType.find(id) }
end
```

Now that we can use `Webhooks::Outgoing::EventType` like an ActiveRecord model, we can use methods like `find`, as well as declare associations like `belongs_to` for any models that inherit `ApplicationHash`.

Also, because the event types are declared in a [YAML file](https://github.com/bullet-train-co/bullet_train/blob/main/config/models/webhooks/outgoing/event_types.yml), all you have to do is add attributes there to add changes to your ApplicationHash data.

Refer to the Active Hash [repository](https://github.com/active-hash/active_hash) for more details.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/heroku.md

# Deploying to Heroku

When you're ready to deploy to Heroku, it's highly recommended you use this button:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=http://github.com/bullet-train-co/bullet_train)

This button leverages the configuration found in `app.json`, including sensible demo-ready defaults for dyno formation, third-party services, buildpack configuration, etc.

The resources provisioned will cost about **$22/month**.

**Please note:** The resources provisioned via `app.json` are intended to be used for quickly launching your brand new app so that you can demo it easily. When you're ready to go into production you'll want to make some changes to these resources. See the section at the bottom of this page.

## What's Included?

### Required Add-Ons

We've included the "entry-level" service tier across the board for:

 - [Heroku Postgres](https://elements.heroku.com/addons/heroku-postgresql)
 - [Heroku Redis](https://elements.heroku.com/addons/heroku-redis) to support Sidekiq and Action Cable.
 - [Memcachier](https://elements.heroku.com/addons/memcachier) to support Rails Cache.
 - [Cloudinary](https://cloudinary.com) to support off-server image uploads and ImageMagick processing.
 - [Heroku Scheduler](https://elements.heroku.com/addons/scheduler) for cron jobs.
 - [Rails Autoscale](https://railsautoscale.com) for best-of-breed reactive performance monitoring.
 - [Honeybadger](https://www.honeybadger.io) for error tracking.
 - [Expedited Security](https://expeditedsecurity.com)'s [Real Email](https://elements.heroku.com/addons/realemail) to reduce accounts created with fake and unreachable emails, which will subsequently hurt your email deliverability.

## Additional Required Steps

Even after using the above button, there are a few steps that need to be performed manually using the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli):

### 1. Add Heroku as a Remote in Your Local Repository

```
heroku git:remote -a YOUR_HEROKU_APP_NAME
```

After this, you'll be able to deploy updates to your app like so:

```
git push heroku main
```

### 2. Improve Boot Time

You can cut your application boot time in half by enabling the following Heroku Labs feature. See [this blog post](https://dev.to/dbackeus/cut-your-rails-boot-times-on-heroku-in-half-with-a-single-command-514d) for more details.

```
heroku labs:enable build-in-app-dir
```

### 3. Adding Your Actual Domain

The most common use case for Bullet Train applications is to be hosted at some appropriate subdomain (e.g. `app.YOURDOMAIN.COM`) while a marketing site is hosted with a completely different service at the apex domain (e.g. just `YOURDOMAIN.COM`) or `www.YOURDOMAIN.COM`. To accomplish this, do the following in your shell:

```
heroku domains:add app.YOURDOMAIN.COM
```

The output for this command will say something like:

```
Configure your app's DNS provider to point to the DNS Target SOMETHING-SOMETHING-XXX.herokudns.com.
```

On most DNS providers this means going into the DNS records for `YOURDOMAIN.COM` and adding a *CNAME* record for the `app` subdomain with a value of `SOMETHING-SOMETHING-XXX.herokudns.com` (except using the actual value provided by the Heroku CLI) and whatever TTL refresh rate you desire. I always set this as low as possible at first to make it easier to fix any mistakes I've made.

After you've added that record, you need to update the following environment settings on the Heroku app:

```
heroku config:set BASE_URL=https://app.YOURDOMAIN.COM
heroku config:set MARKETING_SITE_URL=https://YOURDOMAIN.COM
```

You'll also need to enable Heroku's Automated Certificate Management to have them handle provisioning and renewing your Let's Encrypt SSL certificates:

```
heroku certs:auto:enable
heroku certs:auto
```

You should be done now and your app should be available at `https://app.YOURDOMAIN.COM/account` and any hits to `https://app.YOURDOMAIN.COM` (e.g. when users sign out, etc.) will be redirected to your marketing site.

### 4. Configure CORS on Your S3 Bucket

Before you can upload to your freshly provisioned S3 bucket, you need to run (on Heroku) a rake task we've created for you to set the appropriate CORS settings.

```
heroku run rake aws:set_cors
```

Note: If you change `ENV["BASE_URL"]`, you need to re-run this task.

## Getting ready for production

When you're ready to launch your app in production you probably don't want to use the entry-level resources that we provision via `app.json`


### 1. Use standard dynos instead of basic

To update your `web` and `worker` processes to use `standard-1` dynos instead of `basic`:

```
heroku ps:type web=standard-1x
heroku ps:type worker=standard-1x
```

### 2. Upgrade your database

Pick the plan that matches the features you need: https://elements.heroku.com/addons/heroku-postgresql

Then follow the instructions here: https://devcenter.heroku.com/articles/updating-heroku-postgres-databases

### 3. Upgrade your redis instance

Pick the plan that matches the features you need: https://elements.heroku.com/addons/heroku-redis

Then follow the instructions here: https://devcenter.heroku.com/articles/heroku-redis-version-upgrade

### 4. Upgrade any other resources

Use `heroku addons` to see which addons you currently have installed. Double check the features that are included with your current plan and make sure they're sufficient for your needs in production.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/desktop.md

# Distributing as a Desktop Application

Bullet Train is fine-tuned to run well within an Electron container and the easiest way to generate code-signed, Electron-powered application bundles for Windows, macOS, and Linux is the commercial tool provided by our friends at [ToDesktop](https://www.todesktop.com).

## Developing Desktop Experiences Locally

To test your application's desktop experience during development, you can simply [download and install Bullet Train's own prebuilt desktop application](https://dl.todesktop.com/210204wqi0hp3xe). This example application (built by ToDesktop) points to `http://localhost:3000`, so after spinning up `rails s`, you can launch this application to tweak and tune your desktop experience in real time.

This same bundle is available for the following platforms:

 - [Windows](https://dl.todesktop.com/210204wqi0hp3xe/windows/nsis/x64)
 - [macOS](https://dl.todesktop.com/210204wqi0hp3xe/mac/dmg/x64)
 - [Linux](https://dl.todesktop.com/210204wqi0hp3xe/linux/appImage/x64)


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/oauth.md

# OAuth Providers
Bullet Train includes [Omniauth](https://github.com/omniauth/omniauth) by default which enables [Super Scaffolding](/docs/super-scaffolding) to easily add [any of the third-party OAuth providers in its community-maintained list of strategies](https://github.com/omniauth/omniauth/wiki/List-of-Strategies) for user-level authentication and team-level integrations via API and incoming webhooks.

For specific instructions on adding new OAuth providers, run the following on your shell:

```
rails generate super_scaffold:oauth_provider
```

## Stripe Connect Example
Similar to the "Tangible Things" template for [Super Scaffolding CRUD workflows](/docs/super-scaffolding.md), Bullet Train includes a Stripe Connect integration by default and this example also serves as a template for Super Scaffolding to implement other providers you might want to add.

## Dealing with Last Mile Issues

You should be able to add many third-party OAuth providers with Super Scaffolding without any manual effort. However, there are sometimes quirks from provider to provider, so if you need to dig in to get things working on a specific provider, here are the files you'll probably be looking for:

### Core Functionality
 - `config.omniauth` in `config/initializers/devise.rb`
   - Third-party OAuth providers are registered at the top of this file.
 - `app/controllers/account/oauth/omniauth_callbacks_controller.rb`
   - This controller contains all the logic that executes when a user returns back to your application after working their way through the third-party OAuth provider's workflow.
 - `omniauth_callbacks` in `config/routes.rb`
   - This file just registers the above controller with Devise.
 - `app/views/devise/shared/_oauth.html.erb`
   - This partial includes all the buttons for presentation on the sign in and sign up pages.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/seeds.md

# Database Seeds

Bullet Train introduces a new, slightly different expectation for Rails seed data: **It should be possible to run `rake db:seed` multiple times without creating duplicate data.**

## The Rails Default

This is different than the Rails default, [as evidenced by the Rails example](https://guides.rubyonrails.org/v6.1.1/active_record_migrations.html#migrations-and-seed-data) which uses `Product.create`:

```ruby
5.times do |i|
  Product.create(name: "Product ##{i}", description: "A product.")
end
```

## Bullet Train Example

In Bullet Train applications, you would implement that same `db/seeds.rb` logic like so:

```ruby
5.times do |i|
  Product.find_or_create_by(name: "Product ##{i}") do |product|
    # this only happens if on a `create`.
    production.description = "A product."
  end
end
```

## Why?
We do this so Bullet Train applications can re-use the logic in `db/seeds.rb` for three purposes:

1. Set up new local development environments.
2. Ensure the test suite has the same configuration for features whose configuration is backed by Active Record (e.g. [outgoing webhooks](/docs/webhooks/outgoing.md)).
3. Ensure any updates to the baseline configuration that have been tested both locally and in CI are the exact same updates being executed in production upon deploy.

This makes `db/seeds.rb` a single source of truth for this sort of baseline data, instead of having this concern spread and sometimes duplicated across `db/seeds.rb`, `db/migrations/*`, and `test/fixtures`.

## Seeds for Different Environments
In some cases, you may have core seed data like roles that needs to exist in every environment, but you also have development data to populate in your non-production environments. Bullet Train makes this easy by supporting per-environment seed files in the `db/seeds` folder like `db/seeds/test.rb` and `db/seeds/development.rb`.

Then in `db/seeds.rb`, you can load all of the shared core seed data at the beginning of `db/seeds.rb` and then load the environment-specific seeds only when you've specified one of those environments.

```ruby
load "#{Rails.root}/db/seeds/development.rb" if Rails.env.development?
load "#{Rails.root}/db/seeds/test.rb" if Rails.env.test?
```

## Feedback
We're always very hesitant to stray from Rails defaults, so it must be said that our commitment to this approach isn't set in stone. It's worked very well for us in a number of applications, so we've standardized on it, but the approach is certainly open to discussion.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/javascript.md

# JavaScript
Bullet Train leans into the use of [Stimulus](https://stimulus.hotwired.dev) for custom JavaScript. If you haven't read it previously, [the original introductory blog post for Stimulus from 2018](https://medium.com/signal-v-noise/stimulus-1-0-a-modest-javascript-framework-for-the-html-you-already-have-f04307009130) was groundbreaking in its time, and we still consider it required reading for understanding the philosophy of JavaScript in Bullet Train.

## Writing Custom JavaScript
The happy path for writing new custom JavaScript is to [write it as a Stimulus controller](https://stimulus.hotwired.dev/handbook/building-something-real) in `app/javascript/controllers` and invoke it by augmenting the HTML in your views. If you name the file `*_controller.js`, it will be automatically picked up and compiled as part of your application's JavaScript bundle.

## npm Packages
npm packages are managed by [Yarn](https://yarnpkg.com) and any required importing can be done in `app/javascript/application.js`.

## Compilation
Bullet Train uses [esbuild](https://esbuild.github.io) to compile all local JavaScript and npm package dependencies. If you haven't used esbuild before, it's blazing fast compared to older options like Webpack. Honestly, it makes JavaScript development and deployment in complex applications a joy again, in a way it hasn't been for years.

In development, the esbuild process that compiles JavaScript is defined as `yarn build` in `package.json`. This script also has an entry in `Procfile.dev`, so it runs automatically when you start your application with `bin/dev`, and when run in this context, it watches the filesystem and automatically recompiles anytime JavaScript files change on disk.

The resulting JavaScript bundle is output to the `app/assets/builds` directory where it is picked up by the traditional Rails asset pipeline. This directory is listed in `.gitignore`, so the compiled bundles are never committed to the repository.

## React, Vue.js, etc.
We're not against the use of front-end JavaScript frameworks in the specific contexts where they're the best tool for the job, but we solidly subscribe to the "heavy machinery" philosophy put forward in [that original Stimulus blog post](https://medium.com/signal-v-noise/stimulus-1-0-a-modest-javascript-framework-for-the-html-you-already-have-f04307009130), and have no interest in actually supporting them.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/font-awesome-pro.md

# Font Awesome Pro

By default, Bullet Train ships with both [Themify Icons](https://themify.me/themify-icons) and [Font Awesome Pro's Light icons](https://fontawesome.com/icons?d=gallery&s=light) preconfigured for each menu item. However, Font Awesome Pro is a [paid product](https://fontawesome.com/plans), so by default Bullet Train falls back to showing the Themify icons.

In our experience, there is no better resource than Font Awesome Pro for finding the perfect icon for every model when you're using Super Scaffolding, so we encourage you to make the investment. Once you configure Font Awesome Pro in your environment, its icons will take precedence over the Themify Icons that were provided as a fallback.

## Configuring Font Awesome Pro

### 1. Set Authentication Token Environment Variable

Once you buy a license for Font Awesome Pro, set `FONTAWESOME_NPM_AUTH_TOKEN` in your shell environment to be equal to your key as presented [on their instructions page](https://fontawesome.com/how-to-use/on-the-web/setup/using-package-managers). Unfortunately, it's not enough to simply set `FONTAWESOME_NPM_AUTH_TOKEN` in `config/application.yml` like you might be thinking, because that value won't be picked up when you run `yarn install`.

#### If you're using **Bash**:
- Add `export FONTAWESOME_NPM_AUTH_TOKEN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` in `~/.bashrc`.
- Restart your terminal.

#### If you're using **zsh**:
- Add `export FONTAWESOME_NPM_AUTH_TOKEN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` in `~/.zshrc`.
- Restart your terminal.

If you're configuring this in another type of shell, please let us know what the steps are [in a new GitHub issue](https://github.com/bullet-train-co/bullet_train/issues/new) and we'll add them here for others.

### 2. Add `.npmrc` Configuration

Create a `.npmrc` file in the root of your project if you don't already have one, and add the following to it:

```
@fortawesome:registry=https://npm.fontawesome.com/
//npm.fontawesome.com/:_authToken=${FONTAWESOME_NPM_AUTH_TOKEN}
```

This will pull the environment variable in, but also be compatible with the way we need to supply this value when deploying to Heroku.

### 3. Add Font Awesome Pro npm Package

Once you've got your Font Awesome Pro authentication token configured, you can run:

```
yarn add @fortawesome/fontawesome-pro
```

No, that's not a typo. [That's the name of their company.](https://fortawesome.com) If you receive an error at this point, be sure you restarted your terminal, and reach out for help!

### 4. Add Font Awesome Pro to the Asset Pipeline

In `app/javascript/application.js`, below `require("@icon/themify-icons/themify-icons.css")`, add:

```js
require("@fortawesome/fontawesome-pro/css/all.css")
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/modeling.md

# Domain Modeling in Bullet Train

Domain modeling is one of the most important activities in software development. With [Super Scaffolding](/docs/super-scaffolding.md), it's also one of the highest leverage activities in Bullet Train development.

## What is a "Domain Model"?

In software application development, your domain model is the object-oriented representation (or "abstraction") of the problem space you're solving problems for. In Rails, the classes that represent your domain model live in `app/models`.

## What is "Domain Modeling"?

"Domain modeling" refers to the process by which you decide which entities to introduce into your application's domain model, how those models relate to each other, and which attributes belong on which models.

Because in Rails most of your models will typically be backed by tables in a database, the process of domain modeling substantially overlaps with "database design". This is especially true in systems like Rails that implement their domain model with the Active Record pattern, because your table structure and object-oriented models are pretty much mapped one-to-one[<sup>*</sup>](https://en.wikipedia.org/wiki/Object–relational_impedance_mismatch).

## The Importance of Domain Modeling

### Usability

Generally speaking, the better your domain model is mapped to the real-world problem space, the more likely it is to map to your own users conceptual model of the problem space in their own head. Since the structure of your domain model ends up having such a large influence on the default structure and navigation of your application UI, getting the domain model "right" is the first step in creating an application that is easy for users to understand and use.

### Extendability

Feature requests come from the real world, and specifically from the parts of reality your application doesn't already solve for. The better your existing domain model captures the existing real-world problem space you've tried to solve problems for, the easier it will be for your application to add new models for features that solve the new problems your users are actually experiencing in real life. Inversely, if you take the wrong shortcuts when representing the problem space, it will be difficult to find the right place to add new features in a way that makes sense to your users.

## Important Bullet Train Concepts

### The "Parent Model"

The idea of a "parent model" is different than [a "parent class" in an object-oriented sense](https://en.wikipedia.org/wiki/Inheritance_\(object-oriented_programming\)). When we say "parent model", we're referring to the model that another model primarily belongs to. For example, a `Task` might primarily belong to a `Project`. Although this type of hierarchy isn't an entirely natural concept in object-oriented programming itself, (where our UML diagrams have many types of relationships flying in different directions,) it's actually a very natural concept in the navigation structure of software, which is why breadcrumbs are such a popular tool for navigation. It's also a concept that is very natural in traditional Rails development, expressed in the definition of nested RESTful routes for resources.

## Philosophies

### Take your time and get it right.

Because Super Scaffolding makes it so easy to bring your domain model to life, you don't have to rush into that implementation phase of writing code. Instead, you can take your sweet time thinking through your proposed domain model and mentally running it through the different scenarios and use cases it needs to solve for. If you get aspects of your domain model wrong, it can be really hard to fix later.

### More minds are better.

Subject your proposed domain model to review from other developers or potential users and invite their thoughts.

### Tear it down to get it right.

In traditional Rails development, it can be so much work to bring your domain model to life in views and controllers that if you afterward realize you missed something or got something wrong structurally, it can be tempting not to fix it or refactor it. Because Super Scaffolding eliminates so much of the busy work of bringing your domain model to life in the initial implementation phase, you don't have to worry so much about tearing down your scaffolds, reworking the domain model, and running through the scaffolding process again.

### Focus on the structure and namespacing. Don't worry about every attribute.

One of the unique features of Super Scaffolding is that it allows you to scaffold additional attributes with `rails generate super_scaffold:field` after the initial scaffolding of a model with `rails generate super_scaffold`. That means that you don't have to worry about figuring out every single attribute that might exist on a model before running Super Scaffolding. Instead, the really important piece is:

1. Naming the model.
2. Determining which parent model it primarily belongs to.
3. Determining whether the model should be [in a topic namespace](https://blog.bullettrain.co/rails-model-namespacing/).

### Start with CRUD, then polish.

Even if you know there's an attribute or model that you're going to want to polish up the user experience for, still start with the scaffolding. This ensures that any model or attribute is also represented in your REST API and you have feature parity between your web-based experience and what developers can integrate with and automate.

### Pluralize preemptively.

> Before you write any code — ask if you could ever possibly want multiple kinds of the thing you are coding. If yes, just do it. Now, not later.

— [Shawn Wang](https://twitter.com/swyx)

> I've done this refactoring a million times. I'll be like, I thought there would only ever be one subscription team, user plan, name, address, and it always ends up being like, "Oh, actually there's more." I almost never go the other way. What if you just paid the upfront cost of thinking "This is just always a collection"?

— [Ben Orenstein](https://twitter.com/r00k)

[I believe this is one of the most important articles in software development in the last ten years.](https://www.swyx.io/preemptive-pluralization/) However, with great domain modeling power comes great UX responsibility, which we'll touch on later.

## A Systematic Approach

### 1. Write `rails generate super_scaffold` commands in a scratch file.

See the [Super Scaffolding documentation](/docs/super-scaffolding.md) for more specific guidance. Leave plenty of comments in your scratch file describing anything that isn't obvious and providing examples of values that might populate attributes.

### 2. Review with other developers.

Push up a pull request with your scratch file and invite review from other developers. They might bring up scenarios and use cases you didn't think of, better ways of representing something, or generate questions that don't have an obvious answer and require feedback from a subject matter expert.

### 3. Review with non-developer stakeholders.

Engage with product owners or potential users and talk through each part of the domain model in your scratch file without showing it to them or getting too technical. Just talk through which entities you chose to represent, which attributes and options are available. Talk through the features those models and attributes allow you to provide and which use cases you think you've covered.

In these discussions, you're looking for inspiration of additional nouns, verbs, and use cases you may not have considered in your initial modeling. Even if you choose not to incorporate certain ideas or feature requests immediately, you're at least taking into consideration whether they would fit nicely into the mental model you have represented in your domain model.

### 4. Run the commands.

Be sure to commit your results at this point. This helps isolate the computer generated code from the work you'll do in the next step (which you may want to have someone review.)

### 5. Polish the UI.

By default, Bullet Train produces a very CRUD-y user experience. The intention has always been that the productivity gains provided by Super Scaffolding should be reinvested into the steps that come before and after. Spend more time domain modeling, and then spend more time polishing up the resulting UX.

This is especially true in situations where you've chosen to pluralize preemptively. Ask yourself: Does every user need this option in the plural? If not, should we try to simplify the conceptual model by representing it as a "has one" until they opt-in to complexity? Doing this allows you to have the best of both worlds: Simplicity for those who can fit within it, and advanced functionality that users can opt into.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/upgrades.md

# Upgrading Your Bullet Train Application

<div class="rounded-md border bg-amber-100 border-amber-200 py-4 px-5 mb-3 not-prose">
  <h3 class="text-sm text-amber-800 font-light mb-2">
    Note: These upgrade steps have recently changed.
  </h3>
  <p class="text-sm text-amber-800 font-light mb-2">
    These instructions assume that you're doing a stepwise upgrade on an app that's already on version <code>1.4.0</code> or later.
  </p>
  <p class="text-sm text-amber-800 font-light">
    <a href="/docs/upgrades/options">Learn about other upgrade options.</a>
  </p>
</div>

## The Stepwise Upgrade Method

This method will ensure that the version of the Bullet Train gems that your app uses will stay in sync with the application framework provided by the starter repo.
If you've ever upgraded a Rails app from version to version this process should feel fairly similar.

## Pulling Updates from the Starter Repository

There are times when you'll want to update Bullet Train gems and pull updates from the starter repository into your local application.
Thankfully, `git merge` provides us with the perfect tool for just that. You can simply merge the upstream Bullet Train repository into
your local repository. If you haven’t tinkered with the starter repository defaults at all, then this should happen with no meaningful
conflicts at all. Simply run your automated tests (including the comprehensive integration tests Bullet Train ships with) to make sure
everything is still working as it was before.

If you _have_ modified some starter repository defaults _and_ we also happened to update that same logic upstream, then pulling the most
recent version of the starter repository should cause a merge conflict in Git. This is actually great, because Git will then give you the
opportunity to compare our upstream changes with your local customizations and allow you to resolve them in a way that makes sense for
your application.

⚠️ If you have ejected files or a new custom theme, there is a possibility that those ejected files need to be updated although no merge conflicts arose from `git merge`. You will need to compare your ejected views with the original views in [bullet_train-core](https://github.com/bullet-train-co/bullet_train-core) to ensure everything is working properly. Please refer to the documentation on [indirection](indirection) to find out more about ejected views.

### 1. Decide which version you want to upgrade to

For the purposes of these instructions we'll assume that you're on version `1.4.0` and are going to upgrade to version `1.4.1`.

[Be sure to check our Notable Versions list to see if there's anything tricky about the version you're moving to.](/docs/upgrades/notable-versions)

### 2. Make sure you're working with a clean local copy.

```
git status
```

If you've got uncommitted or untracked files, you can clean them up with the following.

```
# ⚠️ This will destroy any uncommitted or untracked changes and files you have locally.
git checkout .
git clean -d -f
```

### 3. Fetch the latest and greatest from the Bullet Train repository.

```
git fetch bullet-train
git fetch --tags bullet-train
```

### 4. Create a new "upgrade" branch off of your main branch.

It can be handy to include the version number that you're moving to in the branch name.

```
git checkout main
git checkout -b updating-bullet-train-1.4.1
```

### 5. Merge in the newest stuff from Bullet Train and resolve any merge conflicts.

Each version of the starter repo is tagged, so you can merge in the tag from the upstream repo.

```
git merge v1.4.1
```

It's quite possible you'll get some merge conflicts at this point. No big deal! Just go through and
resolve them like you would if you were integrating code from another developer on your team. We tend
to comment our code heavily, but if you have any questions about the code you're trying to understand,
let us know on [Discord!](https://discord.gg/bullettrain)

One of the files that's likely to have conflicts, and which can be the most frustrating to resolve is
`Gemfile.lock`. You can try to sort it out by hand, or you can checkout a clean copy and then let bundler
generate a new one that matches what you need:

```
git checkout HEAD -- Gemfile.lock
bundle install
```

If you choose to sort out `Gemfile.lock` by hand it's a good idea to run `bundle install` just to make
sure that your `Gemfile.lock` agrees with the new state of `Gemfile`.

Once you've resolved all the conflicts go ahead and commit the changes.

```
git diff
git add -A
git commit -m "Upgrading Bullet Train to v1.4.1."
```

### 6. Run Tests.

```
rails test
rails test:system
```

### 7. Merge into `main` and delete the branch.

```
git checkout main
git merge updating-bullet-train-1.4.1
git push origin main
git branch -d updating-bullet-train-1.4.1
```

Alternatively, if you're using GitHub, you can push the `updating-bullet-train-1.4.1` branch up and create a
PR from it and let your CI integration do its thing and then merge in the PR and delete the branch there.
(That's what we typically do.)


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/testing.md

# Automated Test Suite
All of Bullet Train’s core functionality is verifiable using the provided test suite. This foundation of headless browser integration tests took a ton of time to write, but they can give you the confidence and peace of mind that you haven't broken any key functionality in your application before a deploy.

You can run the test suite with the following commands in your shell:

```
rails test
rails test:system
```

## Fixing Broken Tests

### 1. Run Chrome in Non-Headless Mode

When debugging tests, it's important to be able to see what Capybara is seeing. You can disable the headless browser mode by prefixing `rails test` like so:

```shell
MAGIC_TEST=1 rails test
```

When you run the test suite with `MAGIC_TEST` set in your environment like this, the browser will appear on your screen after the first Capybara test starts. (This may not be the first test that runs.) Be careful not to interact with the window when it appears, as sometimes your interactions can cause the test to fail needlessly.

### 2. Insert `binding.pry`.

Open the failing test file and insert `binding.pry` right before the action or assertion that is causing the test to fail. After doing that, when you run the test, it will actually stop and open a debugging console while the browser is still open to the appropriate page where the test is beginning to fail. You can use this console and the open browser to try and figure out why the test is failing. When you're done, hit <kbd>Control</kbd> + <kbd>D</kbd> to exit the debugger and continue letting the test run.

## Super Scaffolding Test Suite
In addition to the standard application test suite, there is a separate test available that doesn't run by default that you can run in CI to ensure you haven't accidentally broken the full function of Super Scaffolding in your application. Before the test runs, there is a setup script that runs a number of Super Scaffolding commands, so you should never run the test in anything but a clean working copy that can be reset when you're done.

You can run the setup script and test like so:

```
test/bin/setup-super-scaffolding-system-test
rails test test/system/super_scaffolding_test.rb
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/getting-started.md

# Getting Started

## Starting a New Project

Whether you want to build a new application with Bullet Train or contribute to Bullet Train itself, you should start by following the instructions on [the starter repository](https://github.com/bullet-train-co/bullet_train).

## Basic Techniques

If you're using Bullet Train for the first time, begin by learning these five important techniques:

1. Use `rails generate super_scaffold` to scaffold a new model:

    ```
    rails generate super_scaffold Project Team name:text_field
    ```

    In this example, `Team` refers to the immediate parent of the `Project` resource. For more details, just run `rails generate super_scaffold` or [read the documentation](/docs/super-scaffolding.md).

2. Use `rails generate super_scaffold:field` to add a new field to a model you've already scaffolded:

    ```
    rails generate super_scaffold:field Project description:trix_editor
    ```

    These first two points about Super Scaffolding are just the tip of the iceberg, so be sure to circle around and [read the full documentation](/docs/super-scaffolding.md).

3. Figure out which ERB views are powering something you see in the UI by:

    - Right clicking the element.
    - Selecting "Inspect Element".
    - Looking for the `<!-- BEGIN ... -->` comment above the element you've selected.

4. Figure out the full I18n translation key of any string on the page by adding `?show_locales=true` to the URL.

5. Use `bin/resolve` to figure out where framework or theme things are coming from and eject them if you need to customize something locally:

    ```
    bin/resolve Users::Base
    bin/resolve en.account.teams.show.header --open
    bin/resolve shared/box --open --eject
    ```

    Also, for inputs that can't be provided on the shell, there's an interactive mode where you can paste them:

    ```
    bin/resolve --interactive --eject --open
    ```

    And then paste any input, e.g.:

    ```
    <!-- BEGIN /Users/andrewculver/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/bullet_train-themes-light-1.0.10/app/views/themes/light/commentary/_box.html.erb -->
    ```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/tunneling.md

# HTTP Tunneling with ngrok

Before your application can take advantage of features that depend on incoming webhooks, you'll need to setup an HTTP tunnel using a service like [ngrok](https://ngrok.com).

## Use a Paid Plan

You should specifically sign up for a paid account. Although ngrok offers a free plan, their $8/year or $10/month [paid plan](https://ngrok.com/pricing) will allow you to reserve a custom subdomain for reuse each time you spin up your tunnel. This is a critical productivity improvement, because in practice you'll end up configuring your tunnel URL in a bunch of different places like `config/application.yml` but also in external systems like when you [configure payment providers to deliver webhooks to you](/docs/billing/stripe.md).

## Usage

Once you have ngrok installed, you can start your tunnel like so, replacing `YOUR-SUBDOMAIN` with whatever subdomain you reserved in your ngrok account:

```
ngrok http --domain=YOUR-SUBDOMAIN 3000
```

## Updating Your Configuration

Before your Rails application will accept connections on your tunnel hostname, you need to update `config/application.yml` with:

```yaml
BASE_URL: https://YOUR-SUBDOMAIN.ngrok.io
```

You'll also need to restart your Rails server:

```
rails restart
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/field-partials.md

# Field Partials
Bullet Train includes a collection of view partials that are intended to [DRY-up](https://en.wikipedia.org/wiki/Don't_repeat_yourself) as much redundant presentation logic as possible for different types of form fields without taking on a third-party dependency like Formtastic.

## Responsibilities
These form field partials standardize and centralize the following behavior across all form fields that use them:

 - Apply theme styling and classes.
 - Display any error messages for a specific field inline under the field itself.
 - Display a stylized asterisk next to the label of fields that are known to be required.
 - Any labels, placeholder values, and help text are defined in a standardized way in the model's localization Yaml file.
 - For fields presenting a static list of options (e.g. a list of buttons or a select field) the options can be defined in the localization Yaml file.

It's a simple set of responsibilities, but putting them all together in one place cleans up a lot of form view code. One of the most compelling features of this "field partials" approach is that they're just HTML in ERB templates using standard Rails form field helpers within the standard Rails `form_with` method. That means there are no "last mile" issues if you need to customize the markup being generated. There's no library to fork or classes to override.

## The Complete Package
Each field partial can optionally include whichever of the following are required to fully support it:

 - **Controller assignment helper** to be used alongside Strong Parameters to convert whatever is submitted in the form to the appropriate ActiveRecord attribute value.
 - **Turbo-compatible JavaScript invocation** of any third-party library that helps support the field partial.
 - **Theme-compatible styling** to ensure any third-party libraries "fit in".
 - **Capybara testing helper** to ensure it's easy to inject values into a field partial in headless browser tests.

## Basic Usage
The form field partials are designed to be a 1:1 match for [the native Rails form field helpers](https://guides.rubyonrails.org/form_helpers.html) developers are already used to using. For example, consider the following basic Rails form field helper invocation:

```erb
<%= form.text_field :text_field_value, autofocus: true %>
```

Using the field partials, the same field would be implemented as follows:

```erb
<%= render 'shared/fields/text_field', form: form, method: :text_field_value, options: {autofocus: true} %>
```

At first blush it might look like a more verbose invocation, but that doesn't take into account that the first vanilla Rails example doesn't handle the field label or any other related functionality.

Breaking down the invocation:

 - `text_field` matches the name of the native Rails form field helper we want to invoke.
 - The `form` option passes a reference to the form object the field will exist within.
 - The `method` option specifies which attribute of the model the field represents, in the same way as the first parameter of the basic Rails `text_field` helper.
 - The `options` option is basically a passthrough, allowing you to specify options which will be passed directly to the underlying Rails form field helper.

The 1:1 relationship between these field partials and their underlying Rails form helpers is an important design decision. For example, the way `options` is passed through to native Rails form field helpers means that experienced Rails developers will still be able to leverage what they remember about using Rails, while those of us who don't readily remember all the various options of those helpers can make use of [the standard Rails documentation](https://guides.rubyonrails.org/form_helpers.html) and the great wealth of Rails code examples available online and still take advantage of these field partials. That means the amount of documentation we need to maintain for these field partials is strictly for those features that are in addition to what Rails provides by default.

Individual field partials might have additional options available based on the underlying Rails form field helper. Links to the documentation for individual form field partials are listed at the end of this page.

## `options` vs. `html_options`

Most of the native form helpers use `options` to define html attributes like so:

```ruby
def text_field(object, method, options = {})
  ...
end
```

However, the `super_select` partial uses `html_options` to define them. This is the same as the native Rails [select form helper](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select). Each field partial has its own set of arguments that can be passed to it depending on the underlying form helper, so please refer to the [field partial options](/docs/field-partials/options.md) documentation for more details.

## `options` vs. `other_options`

Because Bullet Train field partials have more responsibilities than the underlying Rails form field helpers, there are also additional options for things like hiding labels, displaying specific error messages, and more. For these options, we pass them separately as `other_options`. This keeps them separate from the options in `options` that will be passed directly to the underlying Rails form field helper.

For example, to suppress a label on any field, we can use the `hide_label` option like so:

```erb
<%= render 'shared/fields/text_field', form: form, method: :text_field_value, other_options: {hide_label: true} %>
```

Please refer to the [field partial options](/docs/field-partials/options.md) documentation for more details.

### Globally-Available `other_options` Options

| Key | Value Type | Description |
| --- | --- | --- |
| `help` | string | Display a specific help string. |
| `error` | string | Display a specific error string. |
| `hide_label` | boolean | Hide the field label. |
| `required` | boolean | Display an asterisk by the field label to indicate the field is required. |

## `required`: through presence validation vs. `options: {required: true}` vs. `other_options:{required: true}`

By default, where there's a presence validation on the model attribute, we add an asterisk to indicate the field is required. For fields without a presence validation, you have options to pass the `:required` detail:

1. `other_options: {required: true}` adds the asterisk to the field manually.
2. `options: {required: true}` adds asterisk but also triggers client-side validation via the [`required`](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/required) attribute.

Since client-side validations vary from browser to browser, we recommend relying on server-side validation for most forms, and thus mostly using `other_options[:required]`.

## Reducing Repetition
When you're including multiple fields, you can DRY up redundant settings (e.g. `form: form`) like so:

```erb
<% with_field_settings form: form do %>
  <%= render 'shared/fields/text_field', method: :text_field_value, options: {autofocus: true} %>
  <%= render 'shared/fields/buttons', method: :button_value %>
  <%= render 'shared/fields/image', method: :cloudinary_image_value %>
<% end %>
```

## Field partials that integrate with third-party service providers
 - `image` makes it trivial to upload photos and videos to [Cloudinary](https://cloudinary.com) and store their resulting Cloudinary ID as an attribute of the model backing the form. To enable this field partial, sign up for Cloudinary and copy the "Cloudinary URL" they provide you with into your `config/application.yml` as `CLOUDINARY_URL`. If you use our [Heroku app.json](https://github.com/bullet-train-co/bullet_train/blob/main/app.json) to provision your production environment, this will happen in that environment automatically.

## Yaml Configuration
The localization Yaml file (where you configure label and option values for a field) is automatically generated when you run Super Scaffolding for a model. If you haven't done this yet, the localization Yaml file for `Scaffolding::CompletelyConcrete::TangibleThing` serves as a good example. Under `en.scaffolding/completely_concrete/tangible_things.fields` you'll see definitions like this:

```yaml
text_field_value:
  name: &text_field_value Text Field Value
  label: *text_field_value
  heading: *text_field_value
  api_title: *text_field_value
  api_description: *text_field_value
```

This might look redundant at first glance, as you can see that by default the same label ("Text Field Value") is being used for both the form field label (`label`) and the heading (`heading`) of the show view and table view, and in API `api_title` and `api_descriptions` are used for documentation purposes. It's also used when the field is referred to in a validation error message. However, having these three values defined separately gives us the flexibility of defining much more user-friendly labels in the context of a form field. In my own applications, I'll frequently configure these form field labels to be much more verbose questions (in an attempt to improve the UX), but still use the shorter label as a column header on the table view and the show view:

```yaml
text_field_value:
  name: &text_field_value Text Field Value
  label: "What should the value of this text field be?"
  heading: *text_field_value
  api_title: *text_field_value
  api_description: *text_field_value
```

You can also configure some placeholder text (displayed in the field when in an empty state) or some inline help text (to be presented to users under the form field) like so:

```yaml
text_field_value:
  name: &text_field_value Text Field Value
  label: "What should the value of this text field be?"
  heading: *text_field_value
  api_title: *text_field_value
  api_description: *text_field_value
  placeholder: "Type your response here"
  help: "The value can be anything you want it to be!"
```

Certain form field partials like `buttons` and `super_select` can also have their selectable options configured in this Yaml file. See their respective documentation for details, as usage varies slightly.

## Available Field Partials

| Field Partial                                            | Data Type                 | Multiple Values? | Assignment Helpers      | JavaScript Library                                                                | Description                                                                                                                                              |
|----------------------------------------------------------|---------------------------|------------------|-------------------------|-----------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`address_field`](/docs/field-partials/address-field.md) | `Address`                 |                  |                         |                                                                                   | Adds a block of address fields. On change, its country super-select auto-updates the state/province/region super-select and postal/zip code field label. |
| `boolean`                                                | `boolean`                 |                  | `assign_boolean`        |                                                                                   |                                                                                                                                                          |
| [`buttons`](/docs/field-partials/buttons.md)             | `string`                  | Optionally       | `assign_checkboxes`     |                                                                                   |                                                                                                                                                          |
| `image`                                                  | `string` or `attachment`* |                  |                         |                                                                                   |                                                                                                                                                          |
| `color_picker`                                           | `string`                  |                  |                         | [pickr](https://simonwep.github.io/pickr/)                                        |                                                                                                                                                          |
| `date_and_time_field`                                    | `datetime`                |                  |                         | [Date Range Picker](https://www.daterangepicker.com)                              |                                                                                                                                                          |
| `date_field`                                             | `date`                    |                  |                         | [Date Range Picker](https://www.daterangepicker.com)                              |                                                                                                                                                          |
| `email_field`                                            | `string`                  |                  |                         |                                                                                   |                                                                                                                                                          |
| `emoji_field`                                            | `string`                  |                  |                         | [Emoji Mart](https://missiveapp.com/open/emoji-mart) | A front-end library which allows users to browse and select emojis with ease. |                                                                                                       |
| [`file_field`](/docs/field-partials/file-field.md)       | `attachment`              |                  |                         | [Active Storage](https://edgeguides.rubyonrails.org/active_storage_overview.html) |                                                                                                                                                          |
| `options`                                                | `string`                  | Optionally       | `assign_checkboxes`     |                                                                                   |                                                                                                                                                          |
| `password_field`                                         | `string`                  |                  |                         |                                                                                   |                                                                                                                                                          |
| `phone_field`                                            | `string`                  |                  |                         | [International Telephone Input](https://intl-tel-input.com)                       | Ensures telephone numbers are in a format that can be used by providers like Twilio.                                                                     |
| [`super_select`](/docs/field-partials/super-select.md)   | `string`                  | Optionally       | `assign_select_options` | [Select2](https://select2.org)                                                    | Provides powerful option search, AJAX search, and multi-select functionality.                                                                            |
| `text_area`                                              | `text`                    |                  |                         |                                                                                   |                                                                                                                                                          |
| `text_field`                                             | `string`                  |                  |                         |                                                                                   |                                                                                                                                                          |
| `number_field`                                           | `integer`                 |                  |                         |                                                                                   |                                                                                                                                                          |
| `trix_editor`                                            | `text`                    |                  |                         | [Trix](https://github.com/basecamp/trix)                                          | Basic HTML-powered formatting features and support for at-mentions amongst team members.                                                                 |

* The data type for `image` fields will vary based on whether you're using Cloudinary or ActiveStorage.
For Cloudinary you should use `string`, and for ActiveStorage you should use `attachment`.

## A Note On Data Types
When creating a `multiple` option attribute, Bullet Train generates these values as a `jsonb`.
```
rails generate super_scaffold Project Team multiple_buttons:buttons{multiple}
```

This will run the following rails command.
```
rails generate model Project team:references multiple_buttons:jsonb
```
## Formating `date` and `date_and_time`
After Super Scaffolding a `date` or `date_and_time` field, you can pass a format for the object like so:

```
<%= render 'shared/attributes/date', attribute: date_object, format: :short %>
```

Please refer to the [Ruby on Rails documentation](https://guides.rubyonrails.org/i18n.html#adding-date-time-formats) for more information.

## Dynamic Forms and Dependent Fields

To dynamically update your forms on field changes, Bullet Train introduces two new concepts:

1. Dependent Fields Pattern
2. Dependent Fields Frame

These concepts are currently used by the `address_field` to dynamically update the _State / Province / Region_ field on _Country_ change, as well as the label for the _Postal Code_ field.

[Read more about Dynamic Forms and Dependent Fields](/docs/field-partials/dynamic-forms-dependent-fields.md)

## Additional Field Partials Documentation
 - [`address_field`](/docs/field-partials/address-field.md)
 - [`buttons`](/docs/field-partials/buttons.md)
 - [`super_select`](/docs/field-partials/super-select.md)
 - [`file_field`](/docs/field-partials/file-field.md)
 - [`date_field` and `date_and_time_field`](/docs/field-partials/date-related-fields.md)


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/zapier.md

# Integrating with Zapier
Bullet Train provides out-of-the-box support for Zapier. New Bullet Train projects include a preconfigured Zapier CLI project that is ready to `zapier deploy`.

## Background
Zapier was designed to take advantage of an application's existing [REST API](/docs/api.md), [outgoing webhook capabilities](/docs/webhooks/outgoing.md), and OAuth2 authorization workflows. Thankfully for us, Bullet Train provides the first two and pre-configures Doorkeeper to provide the latter. We also have a smooth OAuth2 connection workflow that accounts for the mismatch between user-based OAuth2 and team-based multitenancy.

## Prerequisites
 - You must be developing in an environment with [tunneling enabled](/docs/tunneling.md).

## Getting Started in Development
First, install the Zapier CLI tooling and deploy:

```
cd zapier
yarn install
zapier login
zapier register
zapier push
```

Once the application is registered in your account, you can re-run seeds in your development environment and it will create a `Platform::Application` record for Zapier:

```
cd ..
rake db:seed
```

When you do this for the first time, it will output some credentials for you to go back and configure for the Zapier application, like so:

```
cd zapier
zapier env:set 1.0.0 \
  BASE_URL=https://andrewculver.ngrok.io \
  CLIENT_ID=... \
  CLIENT_SECRET=...
cd ..
```

You're done and can now test creating Zaps that react to example objects being created or create example objects based on other triggers.

## Deploying in Production
We haven't figured out a good suggested process for breaking out development and production versions of the Zapier application yet, but we'll update this section when we have.

## Future Plans
 - Extend Super Scaffolding to automatically add new resources to the Zapier CLI project. For now you have to extend the Zapier CLI definitions manually.



# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/index.md

# Bullet Train Developer Documentation

> Some of the open-source Bullet Train packages are considered pre-release, so please pardon the dust while we work to complete the documentation for certain topics.

## Introduction
 - [What is Bullet Train?](https://bullettrain.co) <i class="ti ti-new-window ml-2"></i>
 - [Getting Started](/docs/getting-started.md)
 - [Upgrades](/docs/upgrades.md)

## General Topics
 - [Domain Modeling](/docs/modeling.md)
 - [Dealing with Indirection](/docs/indirection.md)
 - [Overriding the Framework](/docs/overriding.md)
 - [Tunneling](/docs/tunneling.md)
 - [JavaScript](/docs/javascript.md)
 - [Style Sheets](/docs/stylesheets.md)
 - [Internationalization](/docs/i18n.md)

## Developer Tools
 - [Super Scaffolding](/docs/super-scaffolding.md)
 - [Action Models](/docs/action-models.md)
 - [Database Seeds](/docs/seeds.md)
 - [Test Suite](/docs/testing.md)
 - [Magic Test: Point-and-Click Test Writing](https://github.com/bullet-train-co/magic_test) <i class="ti ti-new-window ml-2"></i>
 - [Application Options](/docs/application-options.md)

## Accounts & Teams
 - [Authentication](/docs/authentication.md)
 - [Teams](/docs/teams.md)
 - [Roles & Permissions](/docs/permissions.md)
 - [Onboarding](/docs/onboarding.md)
 - [Namespacing](/docs/namespacing.md)

## User Interface
 - [Field Partials](/docs/field-partials.md)
 - [Theme Engine](/docs/themes.md)
 - [Nice Partials](https://github.com/bullet-train-co/nice_partials) <i class="ti ti-new-window ml-2"></i>
 - [Showcase](https://github.com/bullet-train-co/showcase) <i class="ti ti-new-window ml-2"></i>

## Billing
 - [Stripe](/docs/billing/stripe.md)
 - [Usage Limits](/docs/billing/usage.md)

## Integration
 - [REST API](/docs/api.md)
 - [Zapier](/docs/zapier.md)
 - [OAuth Providers](/docs/oauth.md)
 - [Outgoing Webhooks](/docs/webhooks/outgoing.md)
 - [Incoming Webhooks](/docs/webhooks/incoming.md)

## Add-Ons
 - [Font Awesome Pro](/docs/font-awesome-pro.md)

## Deployment
 - [Heroku](/docs/heroku.md)
 - [Desktop Applications](/docs/desktop.md)

<hr>

Overwhelmed? [YOLO](https://github.com/bullet-train-co/bullet_train#readme).


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/themes.md

# Themes

Bullet Train has a theme subsystem designed to allow you the flexibility to either extend or completely replace the stock “Light” UI theme.
To reduce duplication of code across themes, Bullet Train implements the following three packages:
1. `bullet_train-themes`
2. `bullet_train-themes-tailwind_css`
3. `bullet_train-themes-light`

This is where all of Bullet Train's standard views are contained.

## Adding a New Theme (ejecting standard views)

If you want to add a new theme, you can use the following command. For example, let's make a new theme called "foo":
```
> rake bullet_train:themes:light:eject[foo]
```

This will copy all of the standard views from `bullet_train-themes-light` to `app/views/themes/` and configure your application to use the new theme.

After running this command, you will see that a few other files are edited to use this new theme. Whenever switching a theme, you will need to make the same changes to make sure your application is running with the theme of your choice.

You can also pass an annotated path to a view after running `bin/resolve --interactive` to eject individual views to your application.

## Theme Component Usage

To use a theme component, simply include it from "within" `shared` like so:

```erb
<%= render 'shared/fields/text_field', method: :text_field_value %>
```

We say "within" because while a `shared` view partial directory does exist, the referenced `shared/fields/_text_field.html.erb` doesn't actually exist within it. Instead, the theme engine picks up on `shared` and then works its way through the theme directories to find the appropriate match.

### Dealing with Indirection

This small piece of indirection buys us an incredible amount of power in building and extending themes, but as with any indirection, it could potentially come at the cost of developer experience. That's why Bullet Train includes additional tools for smoothing over this experience. Be sure to read the section on [dealing with indirection](./indirection.md).

## Restoring Theme Configuration

Your application will automatically be configured to use your new theme whenever you run the eject command. You can run the below command to re-install the standard light theme.
```
> rake bullet_train:themes:light:install
```

## Additional Guidance and Principles

### Should you extend or replace?

For most development projects, the likely best path for customizing the UI is to extend “Light” or another complete Bullet Train theme. It’s difficult to convey how many hours have gone into making the Bullet Train themes complete and coherent from end to end. Every type of field partial, all the third-party libraries, all the responsiveness scenarios, etc. It has taken many hours of expert time.

Extending an existing theme is like retaining an option on shipping. By extending a theme that is already complete, you allow yourself to say “enough is enough” at a certain point and just living with some inherited defaults in exchange for shipping your product sooner. You can always do more UI work later, but it doesn’t look unpolished now!

On the other hand, if you decide to try to build a theme from the ground up, you risk getting to that same point, but not being able to stop because there are bits around the edges that don’t feel polished and cohesive.

### Don’t reference theme component partials directly, even within the same theme!

#### ❌ Don’t do this, even in theme partials:

```erb
<%= render "themes/light/box" do |p| %>
  ...
<% end %>
```

#### ✅ Instead, always do this:

```erb
<%= render "shared/box" do |p| %>
  ...
<% end %>
```

This allows the theme engine to resolve which theme in the inheritance chain will include the `box` partial. For example:

 - It might come from the “Light” theme today, but if you switch to the “Bold” theme later, it’ll start pulling it from there.
 - If you start extending “Light”, you can override its `box` implementation and your application will pick up the new customized version from your theme automatically.
 - If (hypothetically) `box` becomes generalized and moves into the parent “Tailwind CSS” theme, your application would pick it up from the appropriate place.

### Let your designer name their theme.

You're going to have to call your theme something and there are practical reasons to not call it something generic. If you're pursuing a heavily customized design, consider allowing the designer or designers who are creating the look-and-feel of your application to name their own masterpiece. Giving it a distinct name will really help differentiate things when you're ready to start introducing additional facets to your application or a totally new look-and-feel down the road.

## Additional Themes Documentation

* [Installing Bullet Train Themes on Other Rails Projects](/docs/themes/on-other-rails-projects.md)
* [Installing Bullet Train Themes on Jumpstart Pro Projects](/docs/themes/on-jumpstart-pro-projects.md)

# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/super-scaffolding.md

# Code Generation with Super Scaffolding

Super Scaffolding is Bullet Train’s code generation engine. Its goal is to allow you to produce production-ready CRUD interfaces for your models while barely lifting a finger, and it handles a lot of other grunt-work as well.

Here’s a list of what Super Scaffolding takes care of for you each time you add a model to your application:

 - It generates a basic CRUD controller and accompanying views.
 - It generates a Yaml locale file for the views’ translatable strings.
 - It generates type-specific form fields for each attribute of the model.
 - It generates an API controller and an accompanying entry in the application’s API docs.
 - It generates a serializer that’s used by the API and when dispatching webhooks.
 - It adds the appropriate permissions for multitenancy in CanCanCan’s configuration file.
 - It adds the model’s table view to the show view of its parent.
 - It adds the model to the application’s navigation (if applicable).
 - It generates breadcrumbs for use in the application’s layout.
 - It generates the appropriate routes for the CRUD controllers and API endpoints.

When adding just one model, Super Scaffolding generates ~30 different files on your behalf.

## Living Templates

Bullet Train's Super Scaffolding engine is a unique approach to code generation, based on template files that are functional code instead of obscure DSLs that are difficult to customize and maintain. Super Scaffolding automates the most repetitive and mundane aspects of building out your application's basic structure. Furthermore, it does this without leaning on the magic of libraries that force too high a level of abstraction. Instead, it generates standard Rails code that is both ready for prime time, but is also easy to customize and modify.

## Prerequisites

Before getting started with Super Scaffolding, we recommend reading about [the philosophy of domain modeling in Bullet Train](/docs/modeling.md).

## Usage

The Super Scaffolding shell script provides its own documentation. If you're curious about specific scaffolders or parameters, you can run the following in your shell:

```
rails generate super_scaffold
```

## Available Scaffolding Types

| `rails generate` Command | Scaffolding Type |
|--------------------------|------------------|
| `rails generate super_scaffold` | Basic CRUD scaffolder |
| `rails generate super_scaffold:field` | Adds a field to an existing model |
| `rails generate super_scaffold:incoming_webhook` | Scaffolds an incoming webhook |
| `rails generate super_scaffold:join_model` | Scaffolds a join model (must have two existing models to join before scaffolding) |
| `rails generate super_scaffold:oauth_provider` | Scaffolds logic to use OAuth2 with the provider of your choice |

The following commands are for use specifically with [Action Models](action-models).

| `rails generate` Command | Scaffolding Type |
|--------------------------|------------------|
| `rails generate super_scaffold:action_models:targets_many` | Generates an action that targets many records |
| `rails generate super_scaffold:action_models:targets_one` | Generates an action that targets one record |
| `rails generate super_scaffold:action_models:targets_one_parent` | Generates an action that targets the parent of the specified model |

## Examples

### 1. Basic CRUD Scaffolding

Let's implement the following feature:

> An organization has many projects.

First, run the scaffolder:
```
rails generate super_scaffold Project Team name:text_field
rake db:migrate
```

In the above example, `team` represents the model that a `Project` primarily belongs to. Also, `text_field` was selected from [the list of available field partials](/docs/field-partials.md). We'll show examples with `trix_editor` and `super_select` later.

Super Scaffolding automatically generates models for you. However, if you want to split this process, you can pass the `--skip-migration-generation` to the command.

For example, generate the model with the standard Rails generator:
```
rails g model Project team:references name:string
```

⚠️ Don't run migrations right away. It would be fine in this case, but sometimes the subsequent Super Scaffolding step actually updates the migration as part of its magic.

Then you can run the scaffolder with the flag:
```
rails generate super_scaffold Project Team name:text_field --skip-migration-generation
```

### 2. Nested CRUD Scaffolding

Building on that example, let's implement the following feature:

```
A project has many goals.
```

First, run the scaffolder:

```
rails generate super_scaffold Goal Project,Team description:text_field
rake db:migrate
```

You can see in the example above how we've specified `Project,Team`, because we want to specify the entire chain of ownership back to the `Team`. This allows Super Scaffolding to automatically generate the required permissions. Take note that this generates a foreign key for `Project` and not for `Team`.

### 3. Adding New Fields with `field`

One of Bullet Train's most valuable features is the ability to add new fields to existing scaffolded models. When you add new fields with the `field` scaffolder, you don't have to remember to add that same attribute to table views, show views, translation files, API endpoints, serializers, tests, documentation, etc.

Building on the earlier example, consider the following new requirement:

> In addition to a name, a project can have a description.

Use the `field` scaffolder to add it throughout the application:

```
rails generate super_scaffold:field Project description:trix_editor
rake db:migrate
```

As you can see, when we're using `field`, we don't need to supply the chain of ownership back to `Team`.

If you want to scaffold a new field to use for read-only purposes, add the following option to omit the field from the form and all other files that apply:
```
rails generate super_scaffold:field Project description:trix_editor{readonly}
```

Again, if you would like to automatically generate the migration on your own, pass the `--skip-migration-generation` flag:
```
rails generate super_scaffold:field Project description:trix_editor --skip-migration-generation
```

### 4. Adding Option Fields with Fixed, Translatable Options

Continuing with the earlier example, let's address the following new requirement:

> Users can specify the current project status.

We have multiple [field partials](/docs/field-partials.md) that we could use for this purpose, including `buttons`, `options`, or `super_select`.

In this example, let's add a status attribute and present it as buttons:

```
rails generate super_scaffold:field Project status:buttons
```

By default, Super Scaffolding configures the buttons as "One", "Two", and "Three", but in this example you can edit those options in the `fields` section of `config/locales/en/projects.en.yml`. For example, you could specify the following options:

```yaml
planned: Planned
started: Started
completed: Completed
```

If you want new `Project` models to be set to `planned` by default, you can add that to the migration file that was generated before running it, like so:

```ruby
add_column :projects, :status, :string, default: "planned"
```

### 5. Scaffolding `belongs_to` Associations, Team Member Assignments

Continuing with the example, consider the following requirement:

> A project has one specific project lead.

Although you might think this calls for a reference to `User`, we've learned the hard way that it's typically much better to assign resources on a `Team` to a `Membership` on the team instead. For one, this allows you to assign resources to new team members that haven't accepted their invitation yet (and don't necessarily have a `User` record yet.)

We can accomplish this like so:

```
rails generate super_scaffold:field Project lead_id:super_select{class_name=Membership}
rake db:migrate
```

There are three important things to point out here:

1. The scaffolder automatically adds a foreign key for `lead` to `Project`.
2. When adding this foreign key the `references` column is generated under the name `lead`, but when we're specifying the _field_ we want to scaffold, we specify it as `lead_id`, because that's the name of the attribute on the form, in strong parameters, etc.
3. We have to specify the model name with the `class_name` option so that Super Scaffolding can fully work it's magic. We can't reflect on the association, because at this point the association isn't properly defined yet. With this information, Super Scaffolding can handle that step for you.

Finally, Super Scaffolding will prompt you to edit `app/models/project.rb` and implement the required logic in the `valid_leads` method. This is a template method that will be used to both populate the select field on the `Project` form, but also enforce some important security concerns in this multi-tenant system. In this case, you can define it as:

```ruby
def valid_leads
  team.memberships.current_and_invited
end
```

(The `current_and_invited` scope just filters out people that have already been removed from the team.)

### 6. Scaffolding Has-Many-Through Associations with `join_model`

Finally, working from the same example, imagine the following requirement:

> A project can be labeled with one or more project-specific tags.

We can accomplish this with a new model, a new join model, and a `super_select` field.

First, let's create the tag model:

```
rails generate super_scaffold Projects::Tag Team name:text_field
```

Note that project tags are specifically defined at the `Team` level. The same tag can be applied to multiple `Project` models.

Now, let's create a join model for the has-many-through association.

We're not going to scaffold this model with the typical `rails generate super_scaffold` scaffolder, but some preparation is needed before we can use it with the `field` scaffolder, so we need to do the following:

```
rails generate super_scaffold:join_model Projects::AppliedTag project_id{class_name=Project} tag_id{class_name=Projects::Tag}
```

All we're doing here is specifying the name of the join model, and the two attributes and class names of the models it joins. Note again that we specify the `_id` suffix on both of the attributes.

Now that the join model has been prepared, we can use the `field` scaffolder to create the multi-select field:

```
rails generate super_scaffold:field Project tag_ids:super_select{class_name=Projects::Tag}
rake db:migrate
```

Just note that the suffix of the field is `_ids` plural, and this is an attribute provided by Rails to interact with the `has_many :tags, through: :applied_tags` association.

The `field` step will ask you to define the logic for the `valid_tags` method in `app/models/project.rb`. You can define it like so:

```ruby
def valid_tags
  team.projects_tags
end
```

Honestly, it's crazy that we got to the point where we can handle this particular use case automatically. It seems simple, but there is so much going on to make this feature work.

### 7. Scaffolding image upload attributes

Bullet Train comes with two different ways to handle image uploads.

* Cloudinary - This option allows your app deployment to be simpler because you don't need to ship any image manipulation libraries. But it does introduce a dependence on a 3rd party service.
* ActiveStorage - This option doesn't include reliance on a 3rd party service, but you do have to include image manipulation libararies in your deployment process.

#### Scaffolding images with Cloudinary

When you scaffold your model a `string` is generated where Cloudinary can store a reference to the image.

Make sure you have the `CLOUDINARY_URL` environment variable to use Cloudinary for your images.

For instance to scaffold a `Project` model with a `logo` image upload.
Use `image` as a field type for super scaffolding:

```
rails generate super_scaffold Project Team name:text_field logo:image
rake db:migrate
```

Under the hood, Bullet Train will generate your model with the following command:
```
rails generate super_scaffold Project Team name:text_field
rake db:migrate
```

#### Scaffolding images with ActiveStorage

When you scaffold your model we generate an `attachment` type attribute.

For instance to scaffold a `Project` model with a `logo` image upload.
Use `image` as a field type for super scaffolding:

```
rails generate super_scaffold Project Team name:text_field logo:image
rake db:migrate
```

Under the hood, Bullet Train will generate your model with the following command:
```
rails generate super_scaffold Project Team name:text_field
rake db:migrate
```

## Additional Notes

### `TangibleThing` and `CreativeConcept`

In order to properly facilitate this type of code generation, Bullet Train includes two models in the `Scaffolding` namespace as a parent and child model:

1. `Scaffolding::AbsolutelyAbstract::CreativeConcept`
2. `Scaffolding::CompletelyConcrete::TangibleThing`

Their peculiar naming is what's required to ensure that their corresponding view and controller templates can serve as the basis for any combination of different model naming or [namespacing](https://blog.bullettrain.co/rails-model-namespacing/) that you may need to employ in your own application. There are [a ton of different potential combinations of parent and child namespaces](https://blog.bullettrain.co/nested-namespaced-rails-routing-examples/), and these two class names provide us with the fidelity we need when transforming the templates to represent any of these scenarios.

Only the files associated with `Scaffolding::CompletelyConcrete::TangibleThing` actually serve as scaffolding templates, so we also take advantage of `Scaffolding::AbsolutelyAbstract::CreativeConcept` to demonstrate other available Bullet Train features. For example, we use it to demonstrate how to implement resource-level collaborators.

### Hiding Scaffolding Templates

You won't want your end users seeing the Super Scaffolding templates in your environment, so you can disable their presentation by setting `HIDE_THINGS` in your environment. For example, you can add the following to `config/application.yml`:

```yaml
HIDE_THINGS: true
```

## Advanced Examples
 - [Super Scaffolding Options](/docs/super-scaffolding/options.md)
 - [Super Scaffolding with Delegated Types](/docs/super-scaffolding/delegated-types.md)
 - [Super Scaffolding with the `--sortable` option](/docs/super-scaffolding/sortable.md)


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/overriding.md

# Overriding Framework Defaults

Most of Bullet Train's functionality is distributed via Ruby gems, not the starter template. We provide the `bin/resolve` tool to help developers figure out which Ruby gem packages are providing which classes, modules, views, and translations, and its usage is covered in the [Dealing With Indirection](/docs/indirection.md) section of the documentation.

However, sometimes you will need to do more than just understand where something is coming from and how it works in the framework. In some situations, you'll specifically want to change or override the default framework behavior. The primary workflow for doing this is much the same as the `bin/resolve` workflow for dealing with indirection in the first place, however, instead of just using `--open` to inspect the source of the framework-provided file, you can add `--eject` to have that file copied into the local repository. From there, it will act as a replacement for the framework-provided file, and you can modify the behavior as needed.

## The Important Role of Active Support Concerns in Bullet Train Customization

When it comes to object-oriented classes, wholesale copying framework files into your local repository just to be able to modify their behavior or extend them would quickly be untenable, as your app would no longer see upstream updates that would otherwise be incorporated into your application via `bundle update`.

For this reason, common points of extension like framework-provided models and controllers actually exist as a kind of "stub" in the local repository, but include their base functionality from framework-provided concerns, like so:

```ruby
class User < ApplicationRecord
  include Users::Base

  # ...
end
```

In this case, for most customizations or extensions you would want to make, you don't need to eject `Users::Base` into your local repository. Instead, you can simply re-define methods from that concern in your local `User` model after the inclusion of the concern.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/onboarding.md

# Onboarding
Bullet Train provides an easy to understand and modifiable structure for defining required onboarding steps and forms. This system makes it easy for users to complete required steps before seeing your application's full account interface. The code for this feature is well documented in the code with comments, so rather than duplicating that document here, we'll simply direct you to the relevant files.

## Included Onboarding Steps

### Collect User Details

The included "user details" onboarding step is intended to collect any fields that are required for a user account to be "complete" while not requiring those fields to be collected on the initial sign up form. This is a deliberate UX decision to try and increase conversions on the initial form.

### Collect User Email

The "user email" onboarding step is specifically used in situations where a user signs up with an OAuth provider that either doesn't supply their email address to the application or doesn't have a verified email address for the user. In this situation, we want to have an email address on their account, so we prompt them for it.

## Relevant Files

Each of the following files exist within their own respective Bullet Train packages. Make sure you navigate to the correct package when searching for the following files.

### Controllers
 - `ensure_onboarding_is_complete` in `bullet_train/app/controllers/account/application_controller.rb`
 - `bullet_train-core/bullet_train/app/controllers/account/onboarding/user_details_controller.rb`
 - `bullet_train-core/bullet_train/app/controllers/account/onboarding/user_email_controller.rb`

### Views
 - `bullet_train-core/bullet_train/app/views/account/onboarding/user_details/edit.html.erb`
 - `bullet_train-core/bullet_train/app/views/account/onboarding/user_email/edit.html.erb`

### Models
 - `user#details_provided?` in `bullet_train/app/models/concerns/users/base.rb`

### Routes
 - `namespace :onboarding` in `bullet_train-core/bullet_train/config/routes.rb` and `bullet_train/config/routes.rb`

## Adding Additional Steps
Although you can implement onboarding steps from scratch, we always just copy and paste one of the existing steps as a starting point, like so:

1. Copy, rename, and modify all of the existing onboarding controllers.
2. Copy, rename, and modify the corresponding `edit.html.erb` view.
3. Copy and rename the route entry in `bullet_train-core/bullet_train/config/routes.rb`.
4. Add the appropriate gating logic in `ensure_onboarding_is_complete` in `bullet_train/app/controllers/account/application_controller.rb`

Onboarding steps aren't limited to targeting `User` models. It's possible to add onboarding steps to help flesh out team `Membership` records or `Team` records as well. You can use this pattern for setting up any sort of required data for either the user or the team.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/trademark.md

# Trademark Information

"Bullet Train" is a registered trademark of Bullet Train, Inc.

We love and encourage contributions to the Bullet Train ecosystem. That's our dream!

It's also important when you're building packages or presenting offerings in the Bullet Train ecosystem, they're not named in such a way that anyone could confuse your package or offering as being officially maintained or sanctioned by the Bullet Train team.

Here are some examples of names we would not typically object to:

 - "Super Widget __for Bullet Train__"
 - "MySQL Starter Kit __for Bullet Train__"
 - "__BT__ Starter Kit with MySQL"
 - "__BT__ Pro Tools"

Here are some examples that would require explicit permission:

 - "Bullet Train Super Widget"
 - "Bullet Train MySQL Starter Kit"
 - "Bullet Train Application Template with MySQL"
 - "Bullet Train Pro Tools"
 - "Bullet Train Conference"
 - "Bullet Train Podcast"

If you've got an idea and aren't sure about the name, message Andrew Culver privately [on Discord](https://discord.gg/bullettrain) or [via Twitter DM](https://twitter.com/andrewculver). If you know anything about trademarks, you know we're required to enforce our policies, so thank you for understanding! 🙏


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/teams.md

# Teams

Please read the article providing [an overview of organizational teams in Bullet Train](https://blog.bullettrain.co/teams-should-be-an-mvp-feature/). This article doesn't just explain how `Team`, `Membership`, `Invitation` and `Role` relate and function in Bullet Train, but it also explains how to properly think about resource ownership even in complex scenarios. Furthermore, it touches on ways in which Bullet Train's organizational structure has been successfully extended in more complicated systems.

Rather than simply duplicating the content of that blog article here, we'll focus on keeping that article up-to-date so it can benefit not only incoming Bullet Train developers, but also the broader developer ecosystem.

## Related Topics
 - [Permissions](/docs/permissions.md)


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/indirection.md

# Dealing with Indirection

## The Problem with Indirection

In software development, indirection is everywhere and takes many forms.

For example, in vanilla Rails development, you introduce a type of indirection when you extract a button label out of a view file and use the `t` helper to render the string from a translation YAML file. In the future, when another developer goes to update the button label, they will first open the view, they'll see `t(".submit")` and then have to reason a little bit about which translation file they need to open up in order to update that label.

Our goal in Bullet Train is to improve developer experience, not reduce it, so it was important that along with any instances of indirection we were introducing, we also included new tooling to ensure it was never a burden to developers. Thankfully, in practice we found that some of this new tooling improves even layers of indirection that have always been with us in Rails development.

## Figuring Out Class Locations

Most of Bullet Train's functionality is distributed via Ruby gems, not the starter template. As a result, the power of fuzzy searching in your IDE is more limited. For example, `app/controllers/account/users_controller.rb` includes its base functionality from a concern called `Account::Users::ControllerBase`. If you try to fuzzy search for it, you'll quickly find the module isn't included in your application repository. However, you can quickly figure out which Ruby gem is providing that concern and inspect it's source by running:

```
bin/resolve Account::Users::ControllerBase --open
```

If you need to modify behavior in these framework-provided classes or modules, see the documentation for [Overriding Framework Defaults](/docs/overriding.md).

## Solving Indirection in Views

### Resolving Partial Paths with `bin/resolve`

Even in vanilla Rails development, when you're looking at a view file, the path you see passed to a `render` call isn't the actual file name of the partial that will be rendered. This is even more true in Bullet Train where certain partial paths are [magically served from theme gems](/docs/themes.md).

`bin/resolve` makes it easy to figure out where a partial is being served from:

```
bin/resolve shared/box
```

### Exposing Rendered Views with Annotated Views

If you're looking at a rendered view in the browser, it can be hard to know which file to open in order to make a change. To help, Bullet Train enables `config.action_view.annotate_rendered_view_with_filenames` by default, so you can right click on any element you see, select "Inspect Element", and you'll see comments in the HTML source telling you which file is powering a particular portion of the view, like this:

```
<!-- BEGIN /Users/andrewculver/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/bullet_train-themes-light-1.0.10/app/views/themes/light/workflow/_box.html.erb -->
```

If you want to customize files like this that you find annotated in your browser, you can use the `--interactive` flag to eject the file to your main application, or simply open it in your code editor.

```
> bin/resolve --interactive

OK, paste what you've got for us and hit <Return>!

<!-- BEGIN /Users/andrewculver/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/bullet_train-themes-light-1.0.10/app/views/themes/light/workflow/_box.html.erb -->

Absolute path:
  /Users/andrewculver/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/bullet_train-themes-light-1.0.10/app/views/themes/light/workflow/_box.html.erb

Package name:
  bullet_train-themes-light-1.0.10


Would you like to eject the file into the local project? (y/n)
n

Would you like to open `/Users/andrewculver/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/bullet_train-themes-light-1.0.10/app/views/themes/light/workflow/_box.html.erb`? (y/n)
y
```

You may also want to consider using `bin/hack`, which will clone the Bullet Train core packages to `local/bullet_train-core` within your main application's root directory. Running this command will also automatically link the packages to your main application and open bullet_train-core in the code editor for you, so you can start using the cloned repository and make changes to your main application right away.

To revert back to using the original gems, run `bin/hack --reset`. You can link up to your local packages at any time with `bin/hack --link`.

Note that in the example above, the view in question isn't actually coming from the application repository. Instead, it's being included from the `bullet_train-themes-light` package. For further instructions on how to customize it, see [Overriding Framework Defaults](/docs/overriding.md).

### Drilling Down on Translation Keys

Even in vanilla Rails applications, extracting strings from view files into I18n translation YAML files introduces a layer of indirection. Bullet Train tries to improve the resulting DX with a couple of tools that make it easier to figure out where a translation you see in your browser is coming from.

#### Show Translation Keys in the Browser with `?show_locales=true`

You can see the full translation key of any string on the page by adding `?show_locales=true` to the URL.

#### Log Translation Keys to the Console with `?log_locales=true`

You can also log all the translation keys for anything being rendered to the console by adding `?log_locales=true` to the request URL. This can make it easier to copy and paste translation keys for strings that are rendered in non-selectable UI elements.

#### Eject all Translations to your Application

Run `rake bullet_train:themes[eject]` to put all of Bullet Train's core locales into your repository. Then you can sift through the files to keep the ones you want to customize, and remove the ones you don't need.

#### Resolving Translation Keys with `bin/resolve`

Once you have the full I18n translation key, you can use `bin/resolve` to figure out which package and file it's coming from. At that point, if you need to customize it, you can also use the `--eject` option to copy the framework for customization in your local application:

```
bin/resolve en.account.onboarding.user_details.edit.header --eject --open
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/super-scaffolding/delegated-types.md

# Super Scaffolding with Delegated Types

## Introduction
In this guide, we’ll cover how to use Super Scaffolding to build views and controllers around models leveraging delegated types. As a prerequisite, you should read the [native Rails documentation for delegated types](https://edgeapi.rubyonrails.org/classes/ActiveRecord/DelegatedType.html). The examples in that documentation only deal with using delegated types at the Active Record level, but they lay a foundation that we won’t be repeating here.

## Terminology
For the purposes of our discussion here, and building on the Rails example, we’ll call their `Entry` model the **“Abstract Parent”** and the `Message` and `Comment` models the **“Concrete Children”**.

## One of Multiple Approaches
It’s worth noting there are at least two different approaches you can take for implementing views and controllers around models using delegated types:

1. Centralize views and controllers around the Abstract Parent (e.g. `Account::EntriesController`).
2. Create separate views and controllers for each Concrete Child (e.g. `Account::MessagesController`, `Account::CommentsController`, etc.)

**In this guide, we’ll be covering the first approach.** This might not seem like an obvious choice for the `Message` and `Comment` examples we’re drawing on from the Rails documentation (it's not), but it is a very natural fit for other common use cases like:

 - “I’d like to add a field to this form and there are many kinds of fields.”
 - “I’d like to add a section to this page and there are many kinds of sections.”

It’s not to say you can’t do it the other way described above, but this approach has specific benefits:

1. It’s a lot less code. We only have to use Super Scaffolding for the Abstract Parent. It's the only model with views and controllers generated. For the Concrete Children, the only files required are the models, tests, and migrations generated by `rails g model` and some locale Yaml files for each Concrete Child.
2. Controller permissions can be enforced the same way they always are, by checking the relationship between the Abstract Parent (e.g. `Entry`) and `Team`. All permissions are defined in `app/models/ability.rb` for `Entry` only, instead of each Concrete Child.

## Steps

### 1. Generate Rails Models

Drawing on the [canonical Rails example](https://edgeapi.rubyonrails.org/classes/ActiveRecord/DelegatedType.html), we begin by using Rails' native model generators:

```
rails g model Entry team:references entryable:references{polymorphic}:index
rails g model Message subject:string
rails g model Comment content:text
```

Note that in this specific approach we don't need a `team:references` on `Message` and `Comment`. That's because in this approach there are no controllers specific to `Message` and `Comment`, so all permissions are being enforced by checking the ownership of `Entry`. (That's not to say it would be wrong to add them for other reasons, we're just keeping it as simple as possible here.)

### 2. Super Scaffolding for `Entry`

```
rails generate super_scaffold Entry Team entryable_type:buttons --skip-migration-generation
```

We use `entryable_type:buttons` because we're going to allow people to choose which type of `Entry` they're creating with a list of buttons. This isn't the only option available to us, but it's the easiest to implement for now.

### 3. Defining Button Options

Super Scaffolding will have generated some initial button options for us already in `config/locales/en/entries.en.yml`. We'll want to update the attribute `name`, field `label` (which is shown on the form) and the available options to reflect the available Concrete Children like so:

```yaml
fields: &fields
  entryable_type:
    name: &entryable_type Entry Type
    label: What type of entry would you like to create?
    heading: *entryable_type
    options:
      "Message": Message
      "Comment": Comment
```

We will add this block below in the next step on our `new.html.erb` page so you don't have to worry about it now, but with the options above in place, our buttons partial will now allow your users to select either a `Message` or a `Comment` before creating the `Entry` itself:

```erb
<% with_field_settings form: form do %>
  <%= render 'shared/fields/buttons', method: :entryable_type, html_options: {autofocus: true} %>
  <%# 🚅 super scaffolding will insert new fields above this line. %>
<% end %>
```

This will produce the following HTML:

```html
<div>
  <label class="btn-toggle" data-controller="fields--button-toggle">
    <input data-fields--button-toggle-target="shadowField" type="radio" value="Message" name="entry[entryable_type]" id="entry_entryable_type_message">
    <button type="button" class="button-alternative mb-1.5 mr-1" data-action="fields--button-toggle#clickShadowField">
      Message
    </button>
  </label>
  <label class="btn-toggle" data-controller="fields--button-toggle">
    <input data-fields--button-toggle-target="shadowField" type="radio" value="Comment" name="entry[entryable_type]" id="entry_entryable_type_comment">
    <button type="button" class="button-alternative mb-1.5 mr-1" data-action="fields--button-toggle#clickShadowField">
      Comment
    </button>
  </label>
</div>
```


### 4. Add Our First Step to `new.html.erb`

By default, `app/views/account/entries/new.html.erb` has this reference to the shared `_form.html.erb`:

```erb
<%= render 'form', entry: @entry %>
```

However, in this workflow we actually need two steps:

1. Ask the user what type of `Entry` they're creating.
2. Show the user the `Entry` form with the appropriate fields for the type of entry they're creating.

The first of these two forms is actually not shared between `new.html.erb` and `edit.html.erb`, so we'll copy the contents of `_form.html.erb` into `new.html.erb` as a starting point, like so:

```erb
<% if @entry.entryable_type %>
  <%= render 'form', entry: @entry %>
<% else %>
  <%= form_with model: @entry, url: [:new, :account, @team, :entry], method: :get, local: true, class: 'form' do |form| %>
    <%= render 'account/shared/forms/errors', form: form %>
    <% with_field_settings form: form do %>
      <%= render 'shared/fields/buttons', method: :entryable_type, html_options: {autofocus: true} %>
    <% end %>
    <div class="buttons">
      <%= form.submit t('.buttons.next'), class: "button" %>
      <%= link_to t('global.buttons.cancel'), [:account, @team, :entries], class: "button-secondary" %>
    </div>
  <% end %>
<% end %>
```

Here's a summary of the updates required when copying `_form.html.erb` into `new.html.erb`:

1. Add the `if @entry.entryable_type` branch logic, maintaining the existing reference to `_form.html.erb`.
2. Add `@` to the `entry` references throughout. `@entry` is an instance variable in this view, not passed in as a local.
3. Update the form submission `url` and `method` as seen above.
4. Remove the Super Scaffolding hooks. Any additional fields that we add to `Entry` would be on the actual `_form.html.erb`, not this step.
5. Simplify button logic because the form is always for a new object.

### 5. Update Locales

We need to add a locale entry for the "Next Step" button in `config/locales/en/entries.en.yml`. This goes under the `buttons: &buttons` entry that is already present, like so:

```yaml
buttons: &buttons
  next: Next Step
```

Also, sadly, the original locale file wasn't expecting any buttons in `new.html.erb` directly, so we need to include buttons on the `new` page in the same file, below `form: *form`, like so:

```yaml
new:
  # ...
  form: *form
  buttons: *buttons
```

### 6. Add Appropriate Validations in `entry.rb`

In `app/models/entry.rb`, we want to replace the default validation of `entryable_type` like so:

```ruby
ENTRYABLE_TYPES = I18n.t('entries.fields.entryable_type.options').keys.map(&:to_s)

validates :entryable_type, inclusion: {
  in: ENTRYABLE_TYPES, allow_blank: false, message: I18n.t('errors.messages.empty')
}
```

This makes the locale file, where we define the options to present to the user, the single source of truth for what the valid options are.

<small>TODO We should look into whether reflecting on the definition of the delegated types is possible.</small>

Also, to make it easy to check the state of this validation, we'll add `entryable_type_valid?` as well:

```ruby
def entryable_type_valid?
  ENTRYABLE_TYPES.include?(entryable_type)
end
```

I don't like this method. If you can think of a way to get rid of it or write it better, please let us know!

### 7. Accept Nested Attributes in `entry.rb` and `entries_controller.rb`

In preparation for the second step, we need to configure `Entry` to accept [nested attributes](https://edgeapi.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html). We do this in three parts:

In `app/models/entry.rb`, like so:

```ruby
accepts_nested_attributes_for :entryable
```

Also in `app/models/entry.rb`, [Rails will be expecting us](https://stackoverflow.com/questions/45295202/cannot-build-nested-polymorphic-associations-are-you-trying-to-build-a-polymor) to define the following method on the model:

```ruby
def build_entryable(params = {})
  raise 'invalid entryable type' unless entryable_type_valid?
  self.entryable = entryable_type.constantize.new(params)
end
```

Finally, in the [strong parameters](https://edgeguides.rubyonrails.org/action_controller_overview.html#strong-parameters) of `app/controllers/account/entries_controller.rb`, _directly below_ this line:

```ruby
# 🚅 super scaffolding will insert new arrays above this line.
```

And still within the `permit` parameters, add:

```ruby
entryable_attributes: [
  :id,

  # Message attributes:
  :subject,

  # Comment attributes:
  :content,
],
```

<small>(Eagle-eyed developers will note an edge case here where you would need to take additional steps if you had two Concrete Children classes that shared the same attribute name and you only wanted submitting form data for that attribute to be permissible for one of the classes. That situation should be exceedingly rare, and you can always write a little additional code here to deal with it.)</small>

### 8. Populate `@entry.entryable` in `entries_controller.rb`

Before we can present the second step to users, we need to react to the user's input from the first step and initialize either a `Message` or `Comment` object and associate `@entry` with it. We do this in the `new` action of `app/controllers/account/entries_controller.rb` and we can also use the `build_entryable` method we created earlier for this purpose, like so:

```ruby
def new
  if @entry.entryable_type_valid?
    @entry.build_entryable
  elsif params[:commit]
    @entry.valid?
  end
end
```

### 9. Add the Concrete Children Fields to the Second Step in `_form.html.erb`

Since we're now prompting for the entry type on the first step, we can remove the following from the second step in `app/views/account/entries/_form.html.erb`:

```erb
<%= render 'shared/fields/buttons', method: :entryable_type, html_options: {autofocus: true} %>
```

But we need to keep track of which entry type they selected, so we replace it with:

```erb
<%= form.hidden_field :entryable_type %>
```

Also, below that (and below the Super Scaffolding hook), we want to add the `Message` and `Comment` fields as [nested forms](https://guides.rubyonrails.org/form_helpers.html#nested-forms) like so:

```erb
<%= form.fields_for :entryable, entry.entryable do |entryable_form| %>
  <%= entryable_form.hidden_field :id %>
  <% with_field_settings form: entryable_form do %>
    <% case entryable_form.object %>
    <% when Message %>
      <%= render 'shared/fields/text_field', method: :subject %>
    <% when Comment %>
      <%= render 'shared/fields/trix_editor', method: :content %>
    <% end %>
  <% end %>
<% end %>
```

We add this _below_ the Super Scaffolding hook because we want any additional fields being added to `Entry` directly to appear in the form _above_ the nested form fields.

### 10. Add Attributes of the Concrete Children to `show.html.erb`

Add the following in `app/views/account/entries/show.html.erb` under the Super Scaffolding hook shown in the example code below:

```erb
<%# 🚅 super scaffolding will insert new fields above this line. %>

<% with_attribute_settings object: @entry.entryable, strategy: :label do %>
  <% case @entry.entryable %>
  <% when Message %>
    <%= render 'shared/attributes/text', attribute: :subject %>
  <% when Comment %>
    <%= render 'shared/attributes/html', attribute: :content %>
  <% end %>
<% end %>
```

This will ensure the various different attributes of the Concrete Children are properly presented. However, the `label` strategy for these attribute partials depend on the locales for the individual Concrete Children being defined, so we need to create those files now, as well:

`config/locales/en/messages.en.yml`:

```yaml
en:
  messages: &messages
    fields:
      subject:
        _: &subject Subject
        label: *subject
        heading: *subject
  account:
    messages: *messages
  activerecord:
    attributes:
      message:
        subject: *subject
```

`config/locales/en/comments.en.yml`:

```yaml
en:
  comments: &comments
    fields:
      content:
        _: &content Content
        label: *content
        heading: *content
  account:
    comments: *comments
  activerecord:
    attributes:
      comment:
        content: *content
```

### 11. Actually Use Delegated Types?

So everything should now be working as expected, and here's the crazy thing: **We haven't even used the delegated types feature yet.** That was part of the beauty of delegated types when it was released in Rails 6.1: It was really just a formalization of an approach that folks had already been doing in Rails for years.

<center>
<br>
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Really loving the PR for Rails 6.1&#39;s Delegated Types. From the application developer level, very little of it feels &quot;new&quot;. Instead, the experience reads very similar to what many of us were already doing with the existing tools, but even smoother! <a href="https://t.co/6UkxXNCvaa">https://t.co/6UkxXNCvaa</a></p>&mdash; Andrew Culver (@andrewculver) <a href="https://twitter.com/andrewculver/status/1338189146213543951?ref_src=twsrc%5Etfw">December 13, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
<br>
</center>

To now incorporate delegated types as put forward in the original documentation, we want to remove this line in `app/models/entry.rb`:

```ruby
belongs_to :entryable, polymorphic: true
```

And replace it with:

```ruby
delegated_type :entryable, types: %w[ Message Comment ]
```

We also want to follow the other steps seen there, such as defining an `Entryable` concern in `app/models/concerns/entryable.rb`, like so:

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

And including the `Entryable` concern in both `app/models/message.rb` and `app/models/comment.rb` like so:

```ruby
include Entryable
```

## Conclusion

That's it! You're done! As mentioned at the beginning, this is only one of the ways to approach building views and controllers around your models with delegated types, but it's a common one, and for the situations where it is the right fit, it requires a lot less code and is a lot more [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) than scaffolding views and controllers around each individual delegated type class.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/super-scaffolding/options.md

# Super Scaffolding Options

There are different flags you can pass to the Super Scaffolding command which gives you more flexibility over creating your model. Add the flag of your choice to **the end** of the command for the option to take effect.
```
rails generate super_scaffold Project Team description:text_field --sortable
```

Most of these include skipping particular functionalities, so take a look at what's available here and pass the flag that applies to your use-case.

| Option | Description |
|--------|-------------|
| `--sortable` | [Details here](/docs/super-scaffolding/sortable.md) |
| `--namespace=customers` | [Details here](/docs/namespacing.md) |
| `--sidebar="ti-world"` | Pass the Themify icon or Font Awesome icon of your choice to automatically add it to the navbar* |
| `--only-index` | Only scaffold the index view for a model"` |
| `--skip-views` | |
| `--skip-form` | |
| `--skip-locales` | |
| `--skip-api` | |
| `--skip-model` | |
| `--skip-controller` | |
| `--skip-routes` | |

*This option is only available for top-level models, which are models that are direct children of the `Team` model.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/super-scaffolding/sortable.md

# Super Scaffolding with the `--sortable` option

When issuing a `rails generate super_scaffold` command, you can pass the `--sortable` option like this:

```
# E.g. Pages belong to a Site and are sortable via drag-and-drop:
rails generate super_scaffold Page Site,Team name:text_field path:text_area --sortable
```

The `--sortable` option:

1. Wraps the table's body in a `sortable` Stimulus controller, providing drag-and-drop re-ordering;
2. Adds a `reorder` action to your resource via `include SortableActions`, triggered automatically on re-order;
3. Adds a `sort_order` attribute to your model to store the ordering;
4. Adds a `default_scope` which orders by `sort_order` and auto increments `sort_order` on create via `include Sortable` on the model.

## Disabling Saving on Re-order

By default, a call to save the new `sort_order` is triggered automatically on re-order.

### To disable auto-saving

Add the  `data-sortable-save-on-reorder-value="false"` param on the `sortable` root element:

```html
<tbody data-controller="sortable"
  data-sortable-save-on-reorder-value="false"
  ...
>
```

### To manually fire the save action via a button

Since the button won't be part of the `sortable` root element's descendants (all its direct descendants are sortable by default), you'll need to wrap both the `sortable` element and the save button in a new Stimulus controlled ancestor element.

```js
/* sortable-wrapper_controller.js */
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "sortable" ]
  
  saveSortOrder() {
    if (!this.hasSortableTarget) { return }
    this.sortableTarget.dispatchEvent(new CustomEvent("save-sort-order"))
  }
}
```

On the button, add a `data-action`

```html
<button data-action="sortable-wrapper#saveSortOrder">Save Sort Order</button>
```

And on the `sortable` element, catch the `save-sort-order` event and define it as the `sortable` target for the `sortable-wrapper` controller:

```html
<tbody data-controller="sortable"
  data-sortable-save-on-reorder-value="false"
  data-action="save-sort-order->sortable#saveSortOrder"
  data-sortable-wrapper-target="sortable"
  ...
>
```

## Events

Under the hood, the `sortable` Stimulus controller uses the [dragula](https://github.com/bevacqua/dragula) library.

All of the events that `dragula` defines are re-dispatched as native DOM events. The native DOM event name is prefixed with `sortable:`

| dragula event name  | DOM event name       |
|---------------------|----------------------|
| drag                | sortable:drag        |
| dragend             | sortable:dragend     |
| drop                | sortable:drop        |
| cancel              | sortable:cancel      |
| remove              | sortable:remove      |
| shadow              | sortable:shadow      |
| over                | sortable:over        |
| out                 | sortable:out         |
| cloned              | sortable:cloned      |

The original event's listener arguments are passed to the native DOM event as a simple numbered Array under `event.detail.args`. See [dragula's list of events](https://github.com/bevacqua/dragula#drakeon-events) for the listener arguments.

### Example: Asking for Confirmation on the `drop` Event

Let's say we'd like to ask the user to confirm before saving the new sort order:

> Are you sure you want to place DROPPED ITEM before SIBLING ITEM?

```js
/* confirm-reorder_controller.js */
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "sortable" ]
  
  requestConfirmation(event) {
    const [el, target, source, sibling] = event.detail?.args
    
    // sibling will be undefined if dropped in last position, taking a shortcut here
    const areYouSure = `Are you sure you want to place ${el.dataset.name} before ${sibling.dataset.name}?`
    
    // let's suppose each <tr> in sortable has a data-name attribute
    if (confirm(areYouSure)) {
      this.sortableTarget.dispatchEvent(new CustomEvent('save-sort-order'))
    } else {
      this.revertToOriginalOrder()
    }
  }
  
  prepareForRevertOnCancel(event) {
    // we're assuming we can swap out the HTML safely
    this.originalSortableHTML = this.sortableTarget.innerHTML
  }
  
  revertToOriginalOrder() {
    if (this.originalSortableHTML === undefined) { return }
    this.sortableTarget.innerHTML = this.originalSortableHTML
    this.originalSortableHTML = undefined
  }
}
```

And on the `sortable` element, catch the `sortable:drop`, `sortable:drag` (for catching when dragging starts) and `save-sort-order` events. Also define it as the `sortable` target for the `confirm-reorder` controller:

```html
<tbody data-controller="sortable"
  data-sortable-save-on-reorder-value="false"
  data-action="sortable:drop->confirm-reorder#requestConfirmation sortable:drag->confirm-reorder#prepareForRevertOnCancel save-sort-order->sortable#saveSortOrder"
  data-confirm-reorder-target="sortable"
  ...
>
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/field-partials/buttons.md

# Examples for the `buttons` Field Partial

## Define Available Buttons via Localization Yaml

If you invoke the field partial in `app/views/account/some_class_name/_form.html.erb` like so:

```erb
<%= render 'shared/fields/buttons', form: form, method: :enabled %>
```

You can define the available buttons in `config/locales/en/some_class_name.en.yml` like so:

```yaml
en:
  some_class_name:
    fields:
      enabled:
        name: &enabled Enabled
        label: Should this item be enabled?
        heading: Enabled?
        options:
          yes: "Yes, this item should be enabled."
          no: "No, this item should be disabled."
```

## Generate Buttons Programmatically

You can generate the available buttons using a collection of database objects by passing the `button_field_options` option like so:

```erb
<%= render 'shared/fields/buttons', form: form, method: :category_id,
  button_field_options: Category.all.map { |category| [category.id, category.label_string] } %>
```

## Allow Multiple Button Selections

You can allow multiple buttons to be selected using the `multiple` option, like so:

```erb
<%= render 'shared/fields/buttons', form: form, method: :category_ids,
  button_field_options: Category.all.map { |category| [category.id, category.label_string] }, options: {multiple: true} %>
```

## Dynamically Updating Form Fields

If you'd like to:

* modify other fields based on the value of your `buttons` field, or
* modify your `buttons` field based on the value of other fields

See [Dynamic Forms and Dependent Fields](/docs/field-partials/dynamic-forms-dependent-fields.md).


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/field-partials/file-field.md

# Examples and setup for the `file_field` Field Partial

## Active Storage

`file_field` is designed to be used with [Active Storage](https://edgeguides.rubyonrails.org/active_storage_overview.html). You will need to confgure Active Storage for your application before using this field partial. You can find instructions for doing so in the [Rails Guides](https://edgeguides.rubyonrails.org/active_storage_overview.html#setup).

In addition, Bullet Train has integrated the direct-uploads feature of Active Storage. For this to work, you need to have CORS configured for your storage endpoint. You can find instructions for doing so in the [Rails Guides](https://edgeguides.rubyonrails.org/active_storage_overview.html#cross-origin-resource-sharing-cors-configuration).

## Example

The following steps illustrate how to add a `document` file attachment to a `Post` model.

Add the following to `app/models/post.rb`:

```ruby
has_one_attached :document
```

Note, no database migration is required as ActiveStorage uses its own tables to store the attachments.

Run the following command to generate the scaffolding for the `document` field on the `Post` model:

```bash
rails generate super_scaffold:field Post document:file_field
```

## Multiple Attachment Example

The following steps illustrate how to add multiple `document` file attachments to a `Post` model.

Add the following to `app/models/post.rb`:

```ruby
has_many_attached :documents
```

Note, no database migration is required as ActiveStorage uses its own tables to store the attachments.

Run the following command to generate the scaffolding for the `documents` field on the `Post` model:

```bash
rails generate super_scaffold:field Post documents:file_field{multiple}
```

## Generating a Model & Super Scaffold Example

If you're starting fresh, and don't have an existing model you can do something like this:

```
rails generate super_scaffold Project Team name:text_field specification:file_field documents:file_field{multiple}
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/field-partials/dynamic-forms-dependent-fields.md

# Dynamic Forms and Dependent Fields

Bullet Train introduces two new concepts to make your Hotwire-powered forms update dynamically on field changes.

1. Dependent Fields Pattern
2. Dependent Fields Frame

## Dependent Fields Pattern

Let's say we have a `super_select` for a "Where have you heard from us?" field. And we'll have a `text_field` for "Other", `disabled` by default.

```erb
<%= render 'shared/fields/super_select',
    method: :heard_from,
    options: {include_blank: true}, 
    other_options: {search: true}
%>
<%= render 'shared/fields/text_field',
    method: :heard_from_other,
    options: {disabled: true}
%>
```

Our goal: if `other` is selected, enable the "Other" field.

We'll wire the `super_select` field with the `dependable` Stimulus controller. We'll also tie both fields using the `dependable-dependents-selector-value`. In this case, the `id` of the the `heard_from_other` field.

```erb
<%= render 'shared/fields/super_select',
    method: :heard_from,
    options: {include_blank: true}, 
    other_options: {search: true},
    wrapper_options: {
      data: {
        'controller': "dependable",
        'action': '$change->dependable#updateDependents',
        'dependable-dependents-selector-value': "##{form.field_id(:heard_from_other)}"
      }
    }
%>
<%= render 'shared/fields/text_field',
    method: :heard_from_other,
    id: form.field_id(:heard_from_other),
    options: {disabled: true}
%>
```

On `$change` ([See `super_select` dispatched events](/docs/field-partials/super-select#events)), a custom `dependable:updated` event will be dispatched to all elements matching the `dependable-dependents-selector-value`. This gives us flexibility: disparate form fields don't need to be wrapped with a common Stimulus controlled-wrapper. This approach is favored over Stimulus `outlets` because here we're not coupling the functionality of the `dependable` and `dependent` fields. We're just dispatching Custom Events and using CSS selectors, preferably good old `form.field_id`'s.

To let our `:heard_from_other` field handle the `dependable:updated` event, we'll assume we have created a custom  `field-availability` Stimulus controller, with a `#toggle` method, looking for the `expected` value on the incoming event `target` element, in this case the `dependable` field.

```erb
<%= render 'shared/fields/text_field',
    method: :heard_from_other,
    id: form.field_id(:heard_from_other),
    options: {
      disabled: true,
      data: {
        controller: "field-availability",
        action: "dependable:updated->field-availability#toggle",
        field_availability_expected_value: "other"
      }
    }
%>
```

Note: `field-availability` here is not implemented in Bullet Train. It serves as an example.

Next, we'll find a way to only serve the `:heard_from_other` field to the user if "other" is selected, this time by using server-side conditionals in a `turbo_frame`.

## Dependent Fields Frame

What if you'd instead want to:

* Not rely on a custom Stimulus controller to control the `disabled` state of the "Other" field
* Show/hide multiple dependent fields based on the value of the `dependable` field.
* Update more than the field itself, but also the value of its `label`. As an example, the [`address_field`](/docs/field-partials/address-field.md) partial shows an empty "State / Province / Region" sub-field by default, and on changing the `:country_id` field to the United States, changes the whole `:region_id` to "State or Territory" as its label and with all US States and territories as its choices.

For these situations, Bullet Train has a `dependent_fields_frame` partial that's made to listen to `dependable:updated` events by default.

```erb
# update the super-select `dependable-dependents-selector-value` to "##{form.field_id(:heard_from, :dependent_fields)}" to match

<%= render "shared/fields/dependent_fields_frame", 
  id: form.field_id(:heard_from, :dependent_fields),
  form: form,
  dependable_fields: [:heard_from] do %>

  <% if form.object&.heard_from == "other" %>
    <%# no need for a custom `id` or the `disabled` attribute %>
    <%= render 'shared/fields/text_field', method: :heard_from_other %>
  <% end %>

  <%# include additional fields if "other" is selected %>
<% end %>
```

This `dependent_fields_frame` serves two purposes:

1. Handle the `dependable:updated` event, so that the frame can...
2. Re-fetch the current form URL (it could be for a `#new` or a `#edit`, it works in both situations) with a GET request (not a submit) that contains the `heard_from` value as a `query_string` param. It then ensures that our `form.object.heard_from` value gets populated with the value found in the `query_string` param automatically, with **no changes needed to the resource controller**. That's all handled by the `dependent_fields_frame` partial by reading its `dependable_fields` param.

With this functionality, the contents of the underlying `turbo_frame` will be populated with the updated fields.

---

Now let's say we want to come back to the `disabled` use case above, while using the `dependent_fields_frame` approach.

We'll move the conditional on the `disabled` property. And we'll also let the `dependent_fields_frame` underlying controller handle disabling the field automatically when the `turbo_frame` awaits updates.

```erb
<%= render "shared/fields/dependent_fields_frame", 
  id: form.field_id(:heard_from, :dependent_fields),
  form: form,
  dependable_fields: [:heard_from] do |dependent_fields_controller_name| %>

  <%= render 'shared/fields/text_field',
    method: :heard_from_other,
    options: {
      disabled: form.object&.heard_from != "other",
      data: {"#{dependent_fields_controller_name}-target": "field"}
    }
  %>
<% end %>
```

To learn more about its inner functionality, search the `bullet-train-core` repo for `dependable_controller.js`,  `dependent_fields_frame_controller.js` and `_dependent_fields_frame.html.erb`. You can also see an implementation by looking at the `_address_field.html.erb` partial.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/field-partials/date-related-fields.md

# Customizing `date_field` and `date_and_time_field` Field Partials

You can customize the format in which your `Date` and `DateTime` fields appear by passing the `format` option to your render calls. You can also use `date_format` and `time_format` to accomplish the same thing.

```erb
<%# For Date objects %>
<%= render 'shared/attributes/date', attribute: :date_test, format: "%m/%d" %>
<%= render 'shared/attributes/date', attribute: :date_test, date_format: "%m/%d" %>

<%# For DateTime objects %>
<%= render 'shared/attributes/date_and_time', attribute: :date_time_test, format: "%m/%d %I %p" %>
<%= render 'shared/attributes/date_and_time', attribute: :date_time_test, date_format: "%m/%d", time_format: "%I %p" %>
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/field-partials/address-field.md

# Examples for the `address_field` Field Partial

The address field partial adds a block of fields to your form. It creates and stores an instance of the `Address` model and associates it to your record.

## Sub-Fields Included in the Partial

| Field Label               | Name          | Data Type               | Notes                                                                                                                                                                                                                |
|---------------------------|---------------|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Country                   | `country_id`  | `Addresses::Country`    | For country values, see `config/address/countries.json` in bullet_train-core/bullet_train.                                                                                                                           |
| Address                   | `address_one` | `string`                |                                                                                                                                                                                                                      |
| Address (cont'd)          | `address_two` | `string`                |                                                                                                                                                                                                                      |
| City                      | `city`        | `string`                |                                                                                                                                                                                                                      |
| State / Province / Region | `region_id`   | `Addresses::Region`     | Depending on the country selected, the label will change (e.g. Prefecture for Japan, Province or Territory for Canada). For all region values, see `config/addresses/states.json` in bullet_train-core/bullet_train. |
| Postal code               | `postal_code` | `string`                | Depending on the country selected, the label will change (e.g. Zip code for the United States).                                                                                                                      |

If you'd like to add or remove fields, you'll need to update your own version of the `Address` model and eject and modify the `shared/fields/address_field` partial.

## Dynamically Updating `region_id` and `postal_code` Fields and Labels

The `address_field` partial implements Bullet Train's [Dependent Fields Pattern](/docs/field-partials/dynamic-forms-dependent-fields.md) to automatically update the `region_id` and `postal_code` fields and their labels based on the value of the selected `country_id`.

## Customizing the Address Output

By default, `show` screens get a multi-line output and `index` table columns get a one-line format (use the `one_line: true` param).

To customize this output, eject the `shared/attributes/address` partial.

See the [Showcase preview](https://github.com/bullet-train-co/showcase)<i class="ti ti-new-window ml-2"></i> for the example output.

# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/field-partials/options.md

# Field Partial Options
Most field partials have a native Rails form helper working underneath. To see what options you can pass to a partial, check the API for the form helper you want to edit.

In addition, Bullet Train provides framework-specific options which you can pass as `other_options` to further customize your fields.

## General `other_options` Types
Some partials have specific types of `other_options` available for only that partial. However, the following `other_options` are available for all field partials, and you can pass them to a field partial like this.

```erb
<%= render 'shared/fields/text_field' method: :attribute_name, other_options: {help: "Custom help text"} %>
```

| Key | Description |
|-----|-------------|
| `:help` | Pass a String to display help text |
| `:error` | Pass a String to write a custom error and outline the field in red |
| `:required` | Pass a Boolean to make this field required or not |
| `:label` | Pass a String to display a custom label |
| `:hide_label` | Pass a Boolean to hide the label |
| `:hide_custom_error` | Highlight the erroneous field in red, but hide the error message set in `:error` |
| `:icon` | Add a custom icon as an HTML class (i.e. - `ti ti-tablet`)|

## `other_options` for Specific Field Partials
| Partial Name | Option            | Description
|--------------|-------------------|-----------------| 
| `password_field` | `:show_strength_indicator`* | Shows how strong the password is via a Stimulus controller with the colors red, yellow, and green. |
| `super_select` | Refer to the [super_select documentation](/docs/field-partials/super-select.md) | Super Select fields have different kinds of options which are covered in another page. |


*Currently, you must pass `:show_strength_indicator` to `options`, not `other_options`. This will change in a later version.

## Field Partial Form Helpers

Most of the field partials have a native Rails form helper working underneath. Please use `bin/resolve` if you want to look at the source code for the partial (i.e. - `bin/resolve shared/fields/text_field`).

| Partial Name | Rails Form Helper |
|--------------|-------------------|
| `address_field` | [select](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) |
| `boolean` | [radio_button](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) |
| `buttons` | [radio_button](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) ([check_box](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) when `options[:multiple]` is `true`) |
| `image` | [file_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-file_field) when using ActiveStorage (No Rails form helper is called when using Cloudinary) |
| `color_picker` | [hidden_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-hidden_field) (Currently cannot edit this field) |
| `date_and_time_field` | [text_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-text_field) |
| `date_field` | [text_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-text_field) |
| `email_field` | [email_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-email_field) |
| `emoji_field` | [hidden_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-hidden_field) (Currently cannot edit this field) |
| `options` | [radio_button](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) ([check_box](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) when `options[:multiple]` is `true`) |
| `password_field` | [password_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-password_field) |
| `phone_field` | [text_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-text_field) |
| `super_select` | [select](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) |
| `text_area` | [text_area](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-text_area) |
| `text_field` | [text_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-text_field) |
| `number_field` | [number_field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-number_field) |
| `trix_editor` | [rich_text_editor](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area) |


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/field-partials/super-select.md

Note: before you attempt to manually wire up a `super_select` field, note that Super Scaffolding will automatically do that for your models. See [Super Scaffolding](/docs/super-scaffolding.md), docs, section 5, for an example. And make sure Super Scaffolding doesn't automatically do what you're trying to do.

# Examples for the `super_select` Field Partial

The `super_select` partial provides a wonderful default UI (in contrast to the vanilla browser experience for select boxes, which is horrible) with optional search and multi-select functionality out-of-the-box. It invokes the [Select2][select2] library to provide you these features.

## Define Available Buttons via Localization Yaml

If you invoke the field partial in `app/views/account/some_class_name/_form.html.erb` like so:

<pre><code><%= render 'shared/fields/super_select', form: form, method: :response_behavior %></code></pre>

You can define the available options in `config/locales/en/some_class_name.en.yml` like so:

<pre><code>en:
  some_class_name:
    fields:
      response_behavior:
        name: &response_behavior Response Behavior
        label: When should this object respond to new submissions?
        heading: Responds
        choices:
          immediate: Immediately
          after_10_minutes: After a 10 minute delay
          disabled: Doesn't respond
</code></pre>

## Specify Available Choices Inline

Although it's recommended to define any static list of choices in the localization Yaml file (so your application remains easy to translate into other languages), you can also specify these choices using the `choices` option from the underlying select form field helper:

<pre><code><%= render 'shared/fields/super_select', form: form, method: :response_behavior,
  choices: [['Immediately', 'immediate'],
  ['After a 10 minute delay', 'after_10_minutes'],
  ["Doesn't respond", 'disabled']] %></code></pre>

## Generate Choices Programmatically

You can generate the available buttons using a collection of database objects by passing the `options` option like so:

<pre><code><%= render 'shared/fields/super_select', form: form, method: :category_id,
  choices: Category.all.map { |category| [category.label_string, category.id] } %></code></pre>

## Allowing Multiple Option Selections

Here is an example allowing multiple team members to be assigned to a (hypothetical) `Project` model:

<pre><code><%= render 'shared/fields/super_select', form: form, method: :membership_ids,
  choices: @project.valid_memberships.map { |membership| [membership.name, membership.id] },
  html_options: {multiple: true} %>
</code></pre>

The `html_options` key is just inherited from the underlying Rails select form field helper.

## Allowing Search

Here is the same example, with search enabled:

<pre><code><%= render 'shared/fields/super_select', form: form, method: :membership_ids,
  choices: @project.valid_memberships.map { |membership| [membership.name, membership.id] },
  html_options: {multiple: true}, other_options: {search: true} %>
</code></pre>

## Overriding Browser Time Zone

When using super-select with Time Zone options, passing `use_browser_time_zone:
false` will override the automatic setting of the timezone value from the
browser.


Here is the an example setting the selected value to `@user.time_zone` which
will not be overridden by the browser time zone.

<pre><code><%= render 'shared/fields/super_select', form: f, method: :time_zone,
    choices: time_zone_options_for_select(@user.time_zone, nil, ActiveSupport::TimeZone),
    other_options: {search: true, required: true, use_browser_time_zone: false } %>
</code></pre>

## Accepting New Entries

Here is an example allowing a new option to be entered by the user:

<pre><code><%= render 'shared/fields/super_select', form: form, method: :delay_minutes,
  choices: %w(1 5 10 30).map { |value| [value, value] },
  other_options: {accepts_new: true} %>
</code></pre>

Note: this will set the option `value` (which will be submitted to the server) to the entered text.

To handle the new entry's text on the server, use `ensure_backing_models_on`.

`ensure_backing_models_on` validates an `id:` or multiple `ids:` against a passed Active Record relation, and yields for each missing id so you can create backing models. Like this:

```rb
if strong_params[:category_id]
  strong_params[:category_id] = ensure_backing_models_on(current_team.categories, id: strong_params[:category_id]) do |scope, id|
    scope.find_or_create_by(name: id)
  end
end
```

In case our form had `multiple: true`, we could have used `ids:` instead:

```rb
if strong_params[:category_ids]
  strong_params[:category_ids] = ensure_backing_models_on(current_team.categories, ids: strong_params[:category_ids]) do |scope, id|
    scope.find_or_create_by(name: id)
  end
end
```

Note, if you need to constrain the collection further you could pass any extra scope, e.g. `current_team.categories.not_archived`.


## Events

All events dispatched from the `super_select` partial are [Select2's jQuery events][select2_events] re-dispatched as native DOM events with the following caveats:

1. The native DOM event name is pre-pended with `$`
2. The original jQuery event is passed through under `event.detail.event`

| Select2 event name  | DOM event name       |
|---------------------|----------------------|
| change              | $change              |
| select2:closing     | $select2:closing     |
| select2:close       | $select2:close       |
| select2:opening     | $select2:opening     |
| select2:open        | $select2:open        |
| select2:selecting   | $select2:selecting   |
| select2:select      | $select2:select      |
| select2:unselecting | $select2:unselecting |
| select2:unselect    | $select2:unselect    |
| select2:clearing    | $select2:clearing    |
| select2:clear       | $select2:clear       |

For an example of catching the `$change` event to update a dependent field, look at the [Dynamic Forms and Dependent Fields](/docs/field-partials/dynamic-forms-dependent-fields.md) doc.

[select2]: https://select2.org
[select2_events]: https://select2.org/programmatic-control/events

## Options
Select2 has different options available which you can check [here](https://select2.org/configuration/options-api).

You can pass these options to the super select partial like so:
```erb
<%= render 'shared/fields/super_select', method: :project,
  select2_options: {
    allowClear: true,
    placeholder: 'Your Custom Placeholder'
  }
%>
```

*Passing options like this doesn't allow JS callbacks or functions to be used, so you must extend the Stimulus controller and add options to the `optionsOverride` getter if you want to do so.

## Dynamically Updating Form Fields

If you'd like to:

* modify other fields based on the value of your `super_select`, or
* modify your `super_select` based on the value of other fields

See [Dynamic Forms and Dependent Fields](/docs/field-partials/dynamic-forms-dependent-fields.md).


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/api/versioning.md

# API Versioning
Bullet Train's API layer is designed to help support the need of software developers to evolve their API over time while continuing to maintain support for versions of the API that users have already built against.

## What is API versioning?
By default, Bullet Train will build out a "V1" version of your API. The version number is intended to represent a contract with your users that as long as they're hitting `/api/v1` endpoints, the structure of URLs, requests, and responses won't change in a way that will break the integrations they've created.

If a change to the API would break the established contract, we want to bump the API version number so we can differentiate between developers building against the latest version of the API (e.g. "V2") and developers who wrote code against the earlier version of the API (e.g. "V1"). This allows us the opportunity to ensure that older versions of the API continue to work as previously expected by the earlier developers.

## When should you take advantage of API versioning?
You want to bump API versions as sparingly as possible. Even with all the tooling Bullet Train provides, maintaining backwards compatibility of older API versions comes at an ongoing cost. Generally speaking, you should only bump your API version when a customer is already using an API endpoint and you're making changes to the structure of your domain model that are not strictly additive and will break the established contract.

Importantly, if the changes you're making to your domain model are only additive, you don't need to bump your API version. Users shouldn't care that you're adding new attributes or new endpoints to your API, just as long as the ones they're already using don't change in a way that is breaking for them.

## Background
By default, the following components in your API are created in versioned namespaces:

 - API controllers are in `app/controllers/api/v1` and live in an `Api::V1` module.
 - JSON views are in `app/controllers/api/v1`.
 - Routes are in `config/routes/api/v1.rb`.
 - Tests are in `test/controllers/api/v1` and live in an `Api::V1` module.

> It's also impotant to keep in mind that some dependencies of your API and API tests like models, factories, and permissions are not versioned, but as we'll cover later, this is something our approach helps you work around.

## Bumping Your API Version

⚠️ You must do this _before_ making the breaking changes to your API.

If you're in a situation where you know you need to bump your API version to help lock-in a backward compatible version of your API, you can simply run:

```
rake bullet_train:api:bump_version
```

## What happens when you bump an API version?
When you bump your API version, all of the files and directories that are namespaced with the API version number will be duplicated into a new namespace for the new API version number.

For example, when bumping from "V1" to "V2":

 - A copy of all the API controllers in `app/controllers/api/v1` are copied into `app/controllers/api/v2`.
 - A copy of all the JSON views in `app/views/api/v1` are copied into `app/views/api/v2`.
 - A copy of all the routes in `config/routes/api/v1.rb` are copied into `config/routes/api/v2.rb`.
 - A copy of all the tests in `test/controllers/api/v1` are copied into `test/controllers/api/v2`.

We also bump the value of `BulletTrain::Api.current_version` in `config/initializers/api.rb` so tools like Super Scaffolding know which version of your API to update going forward.

## How does this help?
As a baseline, keeping a wholesale copy of the versioned API components helps lock in their behavior and protect them from change going forward. It's not a silver bullet, since unversioned dependencies (like your model, factories, and permissions) can still affect the behavior of these versioned API components, but even in that case these copied files give us a place where we can implement the logic that helps older versions of the API continue to operate even as unversioned components like our domain model continue changing.

### Versioned API Tests
By versioning our API tests, we lock in a copy of what the assumptions were for older versions of the API. Should unversioned dependencies like our domain model change in ways that break earlier versions of our API, the test suite will let us know and help us figure out when we've implemented the appropriate logic in the older version of the API controller to restore the expected behavior for that version of the API.

## Advanced Topics

### Object-Oriented Inheritance
In order to reduce the surface area of legacy API controllers that you're maintaining, it might make sense in some cases to have an older versioned API controller simply inherit from a newer version or the current version of the same API controller. For example, this might make sense for endpoints that you know didn't have breaking changes across API versions.

### Backporting New Features to Legacy API Versions
Typically we'd recommend you use new feature availability to encourage existing API users to upgrade to the latest version of the API. However, in some situations you may really need to make a newer API feature available to a user who is locked into a legacy version of your API for some other endpoint. This is totally fine if the feature is only additive. For example, if you're just adding a newer API endpoint in a legacy version of the API, you can simply have the new API controller in the legacy version of the API inherit from the API controller in the current version of the API.

### Pruning Unused Legacy API Endpoints
Maintaining legacy endpoints has a very real cost, so you may choose to identify which endpoints aren't being used on legacy versions of your API and prune them from that version entirely. This has the effect of requiring existing API users to keep their API usage up-to-date before expanding the surface area of usage, which may or may not be desirable for you.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/upgrades/yolo-130.md

# Upgrading Your Bullet Train Application to Version `1.3.0` and through the `1.3.x` line

<div class="rounded-md border bg-amber-100 border-amber-200 py-4 px-5 mb-3 not-prose">
  <p class="text-sm text-amber-800 font-light mb-2">
    If you're already on version <code>1.4.0</code> or later you should use
    <a href="/docs/upgrades">The Stepwise Upgrade Method</a>
  </p>
  <p class="text-sm text-amber-800 font-light">
    <a href="/docs/upgrades/options">Learn about other upgrade options.</a>
  </p>
</div>

## Getting to `1.3.0`

### 1. Make sure you're working with a clean local copy.

```
git status
```

If you've got uncommitted or untracked files, you can clean them up with the following.

```
# ⚠️ This will destroy any uncommitted or untracked changes and files you have locally.
git checkout .
git clean -d -f
```

### 2. Fetch the latest and greatest from the Bullet Train repository.

```
git fetch bullet-train
git fetch --tags bullet-train
```

### 3. Create a new "upgrade" branch off of your main branch.

```
git checkout main
git checkout -b updating-bullet-train-v1.3.0
```

### 4. Merge in the newest stuff from Bullet Train and resolve any merge conflicts.

```
git merge v1.3.0
```

It's quite possible you'll get some merge conflicts at this point. No big deal! Just go through and
resolve them like you would if you were integrating code from another developer on your team. We tend
to comment our code heavily, but if you have any questions about the code you're trying to understand,
let us know on Discord!

One of the files that's likely to have conflicts, and which can be the most frustrating to resolve is
`Gemfile.lock`. Unfortunately there are important changes in that file that we'll want to preserve.
Luckily there's a way to do it without having to resolve conflicts manually. We'll handle that in the
next step. For now you can just skip the updates in that file:

```
git checkout HEAD -- Gemfile.lock
```

Once you've resolved all the conflicts go ahead and commit the changes.

```
git diff
git add -A
git commit -m "Upgrading Bullet Train."
```

### 5. Update `Gemfile`

Now we need to handle the situation with `Gemfile.lock` that we side-stepped earlier. you should open
up your `Gemfile` and find this block of gems:

```ruby
# BULLET TRAIN GEMS
# This section is the list of Ruby gems included by default for Bullet Train.


# Core packages.
gem "bullet_train"
gem "bullet_train-super_scaffolding"
gem "bullet_train-api"
gem "bullet_train-outgoing_webhooks"
gem "bullet_train-incoming_webhooks"
gem "bullet_train-themes"
gem "bullet_train-themes-light"
gem "bullet_train-integrations"
gem "bullet_train-integrations-stripe"


# Optional support packages.
gem "bullet_train-sortable"
gem "bullet_train-scope_questions"
gem "bullet_train-obfuscates_id"
```

Replace that entire block with this block:

```ruby
# BULLET TRAIN GEMS
# This section is the list of Ruby gems included by default for Bullet Train.

# We use a constant here so that we can ensure that all of the bullet_train-*
# packages are on the same version.
BULLET_TRAIN_VERSION = "1.3.0"

# Core packages.
gem "bullet_train", BULLET_TRAIN_VERSION
gem "bullet_train-super_scaffolding", BULLET_TRAIN_VERSION
gem "bullet_train-api", BULLET_TRAIN_VERSION
gem "bullet_train-outgoing_webhooks", BULLET_TRAIN_VERSION
gem "bullet_train-incoming_webhooks", BULLET_TRAIN_VERSION
gem "bullet_train-themes", BULLET_TRAIN_VERSION
gem "bullet_train-themes-light", BULLET_TRAIN_VERSION
gem "bullet_train-integrations", BULLET_TRAIN_VERSION
gem "bullet_train-integrations-stripe", BULLET_TRAIN_VERSION

# Optional support packages.
gem "bullet_train-sortable", BULLET_TRAIN_VERSION
gem "bullet_train-scope_questions", BULLET_TRAIN_VERSION
gem "bullet_train-obfuscates_id", BULLET_TRAIN_VERSION

# Core gems that are dependencies of gems listed above. Technically they
# shouldn't need to be listed here, but we list them so that we can keep
# verion numbers in sync.
gem "bullet_train-fields", BULLET_TRAIN_VERSION
gem "bullet_train-has_uuid", BULLET_TRAIN_VERSION
gem "bullet_train-roles", BULLET_TRAIN_VERSION
gem "bullet_train-scope_validator", BULLET_TRAIN_VERSION
gem "bullet_train-super_load_and_authorize_resource", BULLET_TRAIN_VERSION
gem "bullet_train-themes-tailwind_css", BULLET_TRAIN_VERSION
```

(We have to do this since we didn't start explicitly tracking versions until `1.4.0` and
want to make sure that our gem versions match what the starter repo expects.)

Then run `bundle install`

Then go ahead and commit the changes.

```
git diff
git add -A
git commit -m "Upgrading Bullet Train gems."
```

### 6. Update the version of JavaScript packages

You'll need to also update your `package.json` to point to the same Bullet Train version set in your `Gemfile`.

Also note that we're removing the `^` "compatible with version" character. For each version change through `1.3.x` versions, we'll specify the exact version. `v1.4.0` releases (and above) include this change automatically.

So we're changing from:

```json
    "@bullet-train/bullet-train": "^1.3.0",
    "@bullet-train/bullet-train-sortable": "^1.3.0",
    "@bullet-train/fields": "^1.3.0",
```

To this:

```json
    "@bullet-train/bullet-train": "1.3.0",
    "@bullet-train/bullet-train-sortable": "1.3.0",
    "@bullet-train/fields": "1.3.0",
```

### 7. Run Tests.

```
rails test
rails test:system
```

If anything fails, investigate the failures and get things working again, and commit those changes.

### 8. Merge into `main` and delete the branch.

```
git checkout main
git merge updating-bullet-train-v1.3.0
git push origin main
git branch -d updating-bullet-train-v1.3.0
```

Alternatively, if you're using GitHub, you can push the `updating-bullet-train-v1.3.0` branch up and create a PR from it and let your CI integration do it's thing and then merge in the PR and delete the branch there. (That's what we typically do.)


## Stepping to `1.3.x`

Before doing this you should have already followed the instructions above to get to version `1.3.0`.

For purposes of this example we'll assume that you're stepping up from `1.3.0` to `1.3.1`.

[Be sure to check our Notable Versions list to see if there's anything tricky about the version you're moving to.](/docs/upgrades/notable-versions)

### 1. Make sure you're working with a clean local copy.

```
git status
```

If you've got uncommitted or untracked files, you can clean them up with the following.

```
# ⚠️ This will destroy any uncommitted or untracked changes and files you have locally.
git checkout .
git clean -d -f
```

### 2. Fetch the latest and greatest from the Bullet Train repository.

```
git fetch bullet-train
git fetch --tags bullet-train
```

### 3. Create a new "upgrade" branch off of your main branch.

```
git checkout main
git checkout -b updating-bullet-train-v1.3.1
```

### 4. Merge in the newest stuff from Bullet Train and resolve any merge conflicts.

```
git merge v1.3.1
```

It's quite possible you'll get some merge conflicts at this point. No big deal! Just go through and
resolve them like you would if you were integrating code from another developer on your team. We tend
to comment our code heavily, but if you have any questions about the code you're trying to understand,
let us know on Discord!

One of the files that's likely to have conflicts, and which can be the most frustrating to resolve is
`Gemfile.lock`. Unfortunately there are important changes in that file that we'll want to preserve.
Luckily there's a way to do it without having to resolve conflicts manually. We'll handle that in the
next step. For now you can just skip the updates in that file:

```
git checkout HEAD -- Gemfile.lock
```

Once you've resolved all the conflicts go ahead and commit the changes.

```
git diff
git add -A
git commit -m "Upgrading Bullet Train."
```

### 5. Update `Gemfile`

Now we need to handle the situation with `Gemfile.lock` that we side-stepped earlier. you should open
up your `Gemfile` and find this line:

```ruby
BULLET_TRAIN_VERSION = "1.3.0"
```

Update that line with the new version you're moving to:

```ruby
BULLET_TRAIN_VERSION = "1.3.1"
```

(We have to do this since we didn't start explicitly tracking versions until `1.4.0` and
want to make sure that our gem versions match what the starter repo expects.)

Then run `bundle install`

Then go ahead and commit the changes.

```
git diff
git add -A
git commit -m "Upgrading Bullet Train gems."
```

### 5. Update `package.json``

Likewise, we'll need to manually update the version of the `@bullet_train/*` JavaScript packages in
`package.json`, by looking for these lines:

```json
    "@bullet-train/bullet-train": "1.3.0",
    "@bullet-train/bullet-train-sortable": "1.3.0",
    "@bullet-train/fields": "1.3.0",
```

And upgrading the version numbers like this:

```json
    "@bullet-train/bullet-train": "1.3.1",
    "@bullet-train/bullet-train-sortable": "1.3.1",
    "@bullet-train/fields": "1.3.1",
```

(As with the Gemfile, we have to do this since we didn't start explicitly tracking versions until 
`1.4.0` and want to make sure that our gem versions match what the starter repo expects.)

Then run `yarn install`

Then go ahead and commit the changes.

```
git diff
git add -A
git commit -m "Upgrading Bullet Train js packages."
```

### 6. Run Tests.

```
rails test
rails test:system
```

If anything fails, investigate the failures and get things working again, and commit those changes.

### 7. Merge into `main` and delete the branch.

```
git checkout main
git merge updating-bullet-train-v1.3.1
git push origin main
git branch -d updating-bullet-train-v1.3.1
```

Alternatively, if you're using GitHub, you can push the `updating-bullet-train-v1.3.1` branch up and create a PR from it and let your CI integration do its thing and then merge in the PR and delete the branch there. (That's what we typically do.)


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/upgrades/yolo.md

# The YOLO Approach To Upgrading Your Bullet Train Application

<div class="rounded-md border bg-amber-100 border-amber-200 py-4 px-5 mb-3 not-prose">
  <p class="text-sm text-amber-800 font-light mb-2">
    Note: We don't really recommend using this method.
    <a href="/docs/upgrades/options">Learn about other upgrade options.</a>
  </p>
  <p class="text-sm text-amber-800 font-light">
    If you're already on version <code>1.4.0</code> or later you should use
    <a href="/docs/upgrades">The Stepwise Upgrade Method</a>
  </p>
</div>

## Pulling Updates from the Starter Repository

There are times when you'll want to pull updates from the starter repository into your local application. Thankfully, `git merge` provides us with the perfect tool for just that. You can simply merge the upstream Bullet Train repository into your local repository. If you haven’t tinkered with the starter repository defaults at all, then this should happen with no meaningful conflicts at all. Simply run your automated tests (including the comprehensive integration tests Bullet Train ships with) to make sure everything is still working as it was before.

If you _have_ modified some starter repository defaults _and_ we also happened to update that same logic upstream, then pulling the most recent version of the starter repository should cause a merge conflict in Git. This is actually great, because Git will then give you the opportunity to compare our upstream changes with your local customizations and allow you to resolve them in a way that makes sense for your application.

### 1. Make sure you're working with a clean local copy.

```
git status
```

If you've got uncommitted or untracked files, you can clean them up with the following.

```
# ⚠️ This will destroy any uncommitted or untracked changes and files you have locally.
git checkout .
git clean -d -f
```

### 2. Fetch the latest and greatest from the Bullet Train repository.

```
git fetch bullet-train
```

### 3. Create a new "upgrade" branch off of your main branch.

```
git checkout main
git checkout -b updating-bullet-train
```

### 4. Merge in the newest stuff from Bullet Train and resolve any merge conflicts.

```
git merge bullet-train/main
```

It's quite possible you'll get some merge conflicts at this point. No big deal! Just go through and resolve them like you would if you were integrating code from another developer on your team. We tend to comment our code heavily, but if you have any questions about the code you're trying to understand, let us know on Discord!

One of the files that's likely to have conflicts, and which can be the most frustrating to resolve is
`Gemfile.lock`. You can try to sort it out by hand, or you can checkout a clean copy and then let bundler
generate a new one that matches what you need:

```
git checkout HEAD -- Gemfile.lock
bundle install
```

If you choose to sort out `Gemfile.lock` by hand it's a good idea to run `bundle install` just to make
sure that your `Gemfile.lock` agrees with the new state of `Gemfile`.

Once you've resolved all the conflicts go ahead and commit the changes.

```
git diff
git add -A
git commit -m "Upgrading Bullet Train."
```

### 5. Run Tests.

```
rails test
rails test:system
```

### 6. Merge into `main` and delete the branch.

```
git checkout main
git merge updating-bullet-train
git push origin main
git branch -d updating-bullet-train
```

Alternatively, if you're using GitHub, you can push the `updating-bullet-train` branch up and create a PR from it and let your CI integration do it's thing and then merge in the PR and delete the branch there. (That's what we typically do.)


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/upgrades/yolo-140.md

# Upgrading Your Bullet Train Application to Version `1.4.0`

<div class="rounded-md border bg-amber-100 border-amber-200 py-4 px-5 mb-3 not-prose">
  <p class="text-sm text-amber-800 font-light mb-2">
    If you're already on version <code>1.4.0</code> or later you should use
    <a href="/docs/upgrades">The Stepwise Upgrade Method</a>
  </p>
  <p class="text-sm text-amber-800 font-light">
    <a href="/docs/upgrades/options">Learn about other upgrade options.</a>
  </p>
</div>

## Getting to `1.4.0`

[Be sure to check our Notable Versions list to see if there's anything tricky about the version you're moving to.](/docs/upgrades/notable-versions)

### 1. Make sure you're working with a clean local copy.

```
git status
```

If you've got uncommitted or untracked files, you can clean them up with the following.

```
# ⚠️ This will destroy any uncommitted or untracked changes and files you have locally.
git checkout .
git clean -d -f
```

### 2. Fetch the latest and greatest from the Bullet Train repository.

```
git fetch bullet-train
git fetch --tags bullet-train
```

### 3. Create a new "upgrade" branch off of your main branch.

```
git checkout main
git checkout -b updating-bullet-train-v1.4.0
```

### 4. Merge in the newest stuff from Bullet Train and resolve any merge conflicts.

```
git merge v1.4.0
```

It's quite possible you'll get some merge conflicts at this point. No big deal! Just go through and
resolve them like you would if you were integrating code from another developer on your team. We tend
to comment our code heavily, but if you have any questions about the code you're trying to understand,
let us know on Discord!

One of the files that's likely to have conflicts, and which can be the most frustrating to resolve is
`Gemfile.lock`. You can try to sort it out by hand, or you can checkout a clean copy and then let bundler
generate a new one that matches what you need:

```
git checkout HEAD -- Gemfile.lock
bundle install
```

If you choose to sort out `Gemfile.lock` by hand it's a good idea to run `bundle install` just to make
sure that your `Gemfile.lock` agrees with the new state of `Gemfile`.

Once you've resolved all the conflicts go ahead and commit the changes.

```
git diff
git add -A
git commit -m "Upgrading Bullet Train."
```

### 5. Run Tests.

```
rails test
rails test:system
```

If anything fails, investigate the failures and get things working again, and commit those changes.

### 6. Merge into `main` and delete the branch.

```
git checkout main
git merge updating-bullet-train-v1.4.0
git push origin main
git branch -d updating-bullet-train-v1.4.0
```

Alternatively, if you're using GitHub, you can push the `updating-bullet-train-v1.4.0` branch up and create a PR from it and let your CI integration do it's thing and then merge in the PR and delete the branch there. (That's what we typically do.)




# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/upgrades/notable-versions.md

# Notable Versions

## v1.4.11 / v1.5.0

In v1.5.0 we made some fairly big changes to the format of system tests. In order to ease the
transition we shipped a helper in 1.4.11 that you can use to modify your copy of the tests before
you merge in version 1.5.0. Doing this should reduce the chances for merge conflicts.

To use the helper to modify your tests run this in a console (after updating to v1.4.11):

```
bin/updates/system_tests/use_device_test
```

Then you should:

* Run the tests to make sure they still pass
* Commit the updated test files
* Update to v1.5.0

### Dealing with merge conflicts after merging v1.5.0

When you update to 1.5.0 you may have rather large merge conflicts in some system test files,
especially if you've modified those files to accomodate changes to user flows in your own app.

When you're resolving conflicts you'll mostly want to pick your own version of stuff (that is,
the code on the `HEAD` side of the conflict). If you want to avoid manually sorting a conflict
and just preserve your own version of a file you can do something like this:

```
git checkout HEAD -- test/system/the_test_file_in_question.rb
```

### About this change

We've introduced a new `device_test` helper that wraps up some of the implementation
details about running system tests on a variety of devices.

It simplifies the way that we write system tests like this:

```diff
-  @@test_devices.each do |device_name, display_details|
-    test "user can so something on a #{device_name}" do
-      resize_for(display_details)
-      # actual tests here
-    end
-  end
+  device_test "user can do something" do
+    # actual test code
+  end
```

The specific changes are:

* Remove the enclosing @@test_devices.each do block
* Remove one level of indentation from test inside those blocks
* Remove the resize_for(display_details) from tests in those blocks
* Use `device_test` helper to handle running the test on different devices


## v1.3.22

In version 1.3.22 we added an `Address` model. If your app already had an `Address` model you'll
probably want to reject some of the updates made to the starter repo in this version.

TODO: Can we offer more direction here?


## v1.3.0

Version 1.3.0 is when we started explicitly bumping the Bullet Train gems within the starter repo
every time that we release a new version of the `core` gems. Unfortunately, at that time we were
only making changes to Gemfile.lock which kind of hides the dependencies, and is often a source of
merge conflicts that can be hard to sort out.

[See the upgrade guide for getting your app to version 1.3.0](/docs/upgrades/yolo-130)


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/upgrades/options.md

# Options For Upgrading Your Bullet Train Application

## Quick Links

* [The YOLO Method (The original upgrade method)](/docs/upgrades/yolo.md)
* [The Stepwise Method - For `1.4.0` and above](/docs/upgrades)
* [Upgrade from any version to `1.4.0`](/docs/upgrades/yolo-140.md)
* [Upgrade from any version to `1.3.0`](/docs/upgrades/yolo-130.md)
* [Upgrade from `1.3.x` to `1.4.0`](/docs/upgrades/yolo-140.md)
* [Notable versions](/docs/upgrades/notable-versions)


## About the upgrade process

The vast majority of Bullet Train's functionality is distributed via Ruby gems, but those gems depend on certain
hooks and initializers being present in the hosting application. Those hooks and initializers are provided by the
[starter repository](https://github.com/bullet-train-co/bullet_train).

Starting in mid-August of 2023 we began to iterate on how we publish gems and how we ensure that the starter repo
will get the version of the gems that it expects.

Starting with version `1.3.0` we began to explicitly update the starter repo every time that we released new
versions of the Bullet Train gems. Unfortunately, at that time we were only making changes to `Gemfile.lock`
which kind of hides the dependencies, and is often a source of merge conflicts that can be hard to sort out.

Starting with version `1.4.0` we added explicit version numbers for all of the Bullet Train gems to `Gemfile`,
which is less hidden and is not as prone to having merge conflicts as `Gemfile.lock`.

As a result of these changes, there are a few different ways that you might choose to upgrade your application
depending on which version you're currently on.

[Be sure to check our Notable Versions list to see if there's anything tricky about the version you're moving to.](/docs/upgrades/notable-versions)

## How to find your current version

You can easily find your current version by running `bundle show | grep "bullet_train "`.

For example:

```
$ bundle show | grep "bullet_train "
  * bullet_train (1.3.20)
```

This app is on version `1.3.20`

## How to upgrade

Depending on what version you're starting on, and what version you want to get to, you have a few options.

In general your two main options are:

1. Upgrade directly from whatever version you happen to be on all the way to the latest published version.
2. Do a series of stepwise upgrades from the version you're on to the version you want to get to.

### Upgrade directly from any previous version to the latest version (aka The YOLO Method)

This was the original upgrade method that Bullet Train used for many years. It's still a perfectly useable way of
upgrading, though it feels a little... let's call it "uncontrolled" to some people. It can definitely lead to some
hairy merge conflicts if you haven't updated in a long time.

[Read more about The YOLO Method](/docs/upgrades/yolo.md)

### Upgrade from `1.4.0` (or later) to any later version (aka The Standard Stepwise Method)

This is the new standard upgrade method that we recommend. If you've ever upgraded a Rails app from version to version
this process should feel fairly similar.

[Read more about The Stepwise Method](/docs/upgrades)

### Upgrade from any previous verison to version `1.4.0` (a modified YOLO)

If you're on a version prior to `1.4.0` it can be a little tricky to do a stepwise upgrade to get to `1.4.0`. It's not
impossible (see below), but if you're feeling lucky you might start with making an attempt to upgrade your app directly to `1.4.0`.

[Read more about going directly to `1.4.0`](/docs/upgrades/yolo-140.md)

### Upgrade from any previous verison to version `1.3.0` (and through the `1.3.x` line)

Since we weren't tracking version numbers in `Gemfile` (only `Gemfile.lock`) it can be a little tricky to upgrade
directly to `1.3.0`. With a few extra steps in the upgrade process it's (hopefully) not too terrible.

[Read more about going directly to `1.3.0`](/docs/upgrades/yolo-130.md)

### Upgrade from `1.3.x` to version `1.4.0`

Once you make it to the end of the `1.3.x` line you only have one more step to get to the `1.4.0` branch. It's the
same instructions as if you wanted to upgrade to `1.4.0` from any previous version.

[Read more about going from `1.3.x` to `1.4.0`](/docs/upgrades/yolo-140.md)






# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/webhooks/incoming.md

# Incoming Webhooks

Bullet Train makes it trivial to scaffold new endpoints where external systems can send you webhooks and they can be processed asyncronously in a background job. For more information, run:

```
rails generate super_scaffold:incoming_webhooks
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/webhooks/outgoing.md

# Outgoing Webhooks

## Introduction
Webhooks allow for users to be notified via HTTP request when activity takes place on their team in your application. Bullet Train applications include an entire user-facing UI that allows them not only to subscribe to webhooks, but also see a history of their attempted deliveries and debug delivery issues.

## Default Event Types
Bullet Train can deliver webhooks for any model you've added under `Team`. We call the model a webhook is being issued for the "subject". 

An "event type" is a subject plus an action. By default, every model includes `created`, `updated`, and `destroyed` event types. These are easy for us to implement automatically because of [Active Record Callbacks](https://guides.rubyonrails.org/active_record_callbacks.html).

## Custom Event Types
You can make custom event types available for subscription by adding them to `config/models/webhooks/outgoing/event_types.yml`. For example:

```yaml
payment:
  - attempting
  - succeeded
  - failed
```

Once the event type is configured, you can make your code actually issue the webhook like so:

```ruby
payment.generate_webhook(:succeeded)
```

## Delivery
Webhooks are delivered asyncronously in a background job by default. If the resulting HTTP request results in a status code other than those in the 2XX series, it will be considered a failed attempt and delivery will be reattempted a number of times.

## Future Plans
 - Allow users to filter webhooks to be generated by a given parent model. For example, they should be able to subscribe to `post.created`, but only for `Post` objects created within a certain `Project`.
 - Integrate [Hammerstone Refine](https://hammerstone.dev) to allow even greater configurability for filtering webhooks.


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/themes/on-other-rails-projects.md

# Installing Bullet Train Themes on Other Rails Projects

Bullet Train themes can be installed on Vanilla Rails projects.

Our main theme, called `Light`, uses `erb` partials to give you native Rails views with Hotwire-powered components. It's built on `tailwindcss`, uses `postcss` to allow for local CSS overrides and uses `esbuild` for fast javascript compilation and to support javascript-side CSS imports.

In addition to providing a nice set of UI components, you'll get access to [`nice_partials`](https://github.com/bullet-train-co/nice_partials), Bullet Train's own lightweight answer for creating `erb` partials with ad-hoc named content areas, which we think is just the right amount of magic for making `erb`-based components.

Note: we have [special instructions for installing themes on Jumpstart Pro projects](on-jumpstart-pro-projects.md).

**Contents:**

1. Installation Instructions
2. Optional Configurations for switching colors, theme gems
3. Using Locales for fields on new models
4. Partials that require special instructions, exclusions
5. Modifying ejected partials

## 1. Installation Instructions

### Ensure your Rails Project uses `esbuild` and `tailwindcss` with `postcss`

You'll need to make sure your Rails project is set up to use `esbuild`, `tailwindcss` and `postcss`.

The easiest way to see what your project should include is to create a separate project, for reference, generated via this command:

```
rails new rails-new-esbuild-tailwind-postcss --css tailwind --javascript esbuild
```

### Add the theme gem

These instructions assume you're installing the `Light` theme bundled with Bullet Train.

```
bundle add bullet_train-themes-light
```

Or add the following to your `Gemfile`:

```
gem "bullet_train-themes-light"
```

And then run:

```
bundle install
```

### Add `npm` packages

The `Light` theme requires the following npm packages to be installed

```
yarn add @bullet-train/bullet-train @bullet-train/fields autoprefixer @rails/actiontext postcss-extend-rule postcss-import
```

Update your `app/javascript/controllers/index.js` with the following lines:

```js
import { controllerDefinitions as bulletTrainControllers } from "@bullet-train/bullet-train"
import { controllerDefinitions as bulletTrainFieldControllers } from "@bullet-train/fields"

application.load(bulletTrainControllers)
application.load(bulletTrainFieldControllers)
```

### Overwrite tailwind and esbuild config files, add bin stubs from Bullet Train

```
curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train/main/esbuild.config.js" -o esbuild.config.js
curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train/main/postcss.config.js" -o postcss.config.js
curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train/main/tailwind.config.js" -o tailwind.config.js
curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train/main/bin/theme" -o bin/theme
curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train/main/bin/link" -o bin/link
chmod +x bin/theme bin/link

```

### Update `build:css` in `package.json`

In `package.json`, replace the `build` and `build:css` entries under `scripts` with:

```json
"build": "THEME=\"light\" node esbuild.config.js",
"build:css": "bin/link; THEME=\"light\" tailwindcss --postcss --minify -c ./tailwind.config.js -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.tailwind.css"
```
### Update esbuild.config.js

Remove or comment out the following line from `esbuild.config.js`:

```js
"intl-tel-input-utils": path.join(process.cwd(), "app/javascript/intl-tel-input-utils.js"),
```

### Define `current_theme` helper

In your `app/helpers/application_helper.rb`, define:

```
def current_theme
  :light
end
```

### Add `stylesheet_link_tag` to `<head>`

Make sure you have the following three lines in your `<head>`, which should be defined in `app/views/layouts/application.html.erb`:

```erb
<%= stylesheet_link_tag "application", media: "all", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "application.tailwind", media: "all", "data-turbo-track": "reload" %>
<%= javascript_include_tag 'application.light', 'data-turbo-track': 'reload' %>
```

### Import the Theme Style Sheet

To your `application.tailwind.css` file, add the following line:

```css
@import "$ThemeStylesheetsDir/application.css";
```

Also be sure to replace the following lines:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

To the following lines:

```css
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";
```

Unless this is done, `postcss-import` doesn't work correctly.

### Add Themify Icons, jQuery (for now) and trix editor support

Note: jQuery is needed for some of our components, but defining `window.$` won't be required soon. See PR https://github.com/bullet-train-co/bullet_train-core/pull/765

```
yarn add @icon/themify-icons jquery
```

To your `application.js`, add the following line:

```js
import jquery from "jquery"
window.jQuery = jquery
window.$ = jquery

require("@icon/themify-icons/themify-icons.css")

import { trixEditor } from "@bullet-train/fields"
trixEditor()
```

### Add Locale Strings

Add these to your `config/locales/en.yml` under `en:`

```yml
  date:
    formats:
      date_field: "%m/%d/%Y"
      date_and_time_field: "%m/%d/%Y %l:%M %p"
      date_controller: "MM/DD/YYYY"
  time:
    am: AM
    pm: PM
    formats:
      date_field: "%m/%d/%Y"
      date_and_time_field: "%m/%d/%Y %l:%M %p"
      date_controller: "MM/DD/YYYY h:mm A"
  daterangepicker:
    firstDay: 1
    separator: " - "
    applyLabel: "Apply"
    cancelLabel: "Cancel"
    fromLabel: "From"
    toLabel: "To"
    customRangeLabel: "Custom"
    weekLabel: "W"
    daysOfWeek:
    - "Su"
    - "Mo"
    - "Tu"
    - "We"
    - "Th"
    - "Fr"
    - "Sa"
    monthNames:
    - "January"
    - "February"
    - "March"
    - "April"
    - "May"
    - "June"
    - "July"
    - "August"
    - "September"
    - "October"
    - "November"
    - "December"
  date_range_controller:
    today: Today
    yesterday: yesterday
    last7Days: Last 7 Days
    last30Days: Last 30 Days
    thisMonth: This Month
    lastMonth: Last Month
  global:
    buttons:
      other: Other
      cancel: Cancel
    bulk_select:
      all: All
```

## 2. Optional Configurations for switching colors, theme gems

### For Setting the Active Color

```
curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train/main/initializers/theme.rb" -o initializers/theme.rb
```

Add the following classes to your `html` tag for your layout:

```erb
<html class="theme-<%= BulletTrain::Themes::Light.color %> <%= "theme-secondary-#{BulletTrain::Themes::Light.secondary_color}" if BulletTrain::Themes::Light.secondary_color %>"
```

### For Switching Between Installed Themes

If you'd like to create your own theme but would still like to build on top of `:light`, you'll need to have both gems installed and you'll be able to switch the current theme this way.

Change the `current_theme` value in `app/helpers/application_helper.rb`

```
def current_theme
  :super_custom_theme
end
```

To change to use a different theme:

1. Change the value returned by `current_theme` to the new theme name
2. Change the name of the `THEME` env var defined in `build` and `build:css` in `package.json`
3. Change the name of the theme in the `javascript_include_tag` in the `<head>`.

## 3. Using Locales for fields on new models

The theme's field partials work best with locale strings that are defined for the model you're creating.

Example: you've created a Project model. Here we'll create a `projects.en.yml`

1. Run `curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train-core/main/bullet_train-super_scaffolding/config/locales/en/scaffolding/completely_concrete/tangible_things.en.yml" -o config/locales/projects.en.yml`
2. Search and replace `projects.en.yml` for `scaffolding/completely_concrete/tangible_things`, `Tangible Things`, `Tangible Thing`, `tangible_things` and `tangible_thing`. Replace with `projects`, `Projects`, `Project`, `projects` and `project` respectively.
3. Remove strings you won't be using. In particular, look for comments with "skip" or "scaffolding".

Some fields use locale strings to drive their `options`. In the `tangible_things.en.yml` template file, look for `super_select_value`, `multiple_option_values` and others.

You'll notice `&` and `*` symbols prefixing some special keys in the `yml` file. Those are anchors and aliases and they help you reduce repetition in your locale strings.

To learn more about how these locales are generated in Bullet Train, see the documentation on [Bullet Train's Super Scaffolding](/docs/super-scaffolding.md)

## 4. Partials that require special instructions, exclusions

### For using boolean-type fields (options, buttons)

In `ApplicationController`, add this:

```ruby
include Fields::ControllerSupport
```

### For the file_field partial

```ruby
# in the model
has_one_attached :file_field_value
after_validation :remove_file_field_value, if: :file_field_value_removal?
attr_accessor :file_field_value_removal
def file_field_value_removal?
def remove_file_field_value
```

```ruby
# in the controller's strong_params
:file_field_value,
:file_field_value_removal,
```

### For `image`, `active_storage_image`

See [`account/users_helper` in BT core repo](https://github.com/bullet-train-co/bullet_train-core/blob/main/bullet_train/app/helpers/account/users_helper.rb) for implementing `photo_url_for_active_storage_attachment`

## 5. Modifying ejected partials

### For ejecting a theme partial and modifying it

We recommend firing up a Bullet Train project and using its `bin/resolve` (see docs on [Indirection](indirection)) to get a copy of the partial field locally to modify.

# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/themes/on-jumpstart-pro-projects.md

# Installing Bullet Train Themes on Jumpstart Pro Projects

Bullet Train themes can be installed on Jumpstart Pro projects, giving you native `erb` partials and Hotwire-powered UI components.

Like Jumpstart Pro, Bullet Train themes are built using `tailwindcss` and use `esbuild` and `postcss` for JavaScript and style sheets.

To get a quick sense of the UI components, we encourage you to spin up a Bullet Train project and navigate through the screens to create a "Creative Concept" and "Tangible Thing" resources.

In addition to providing a nice set of UI components, you'll get access to [`nice_partials`](https://github.com/bullet-train-co/nice_partials), Bullet Train's own lightweight answer for creating `erb` partials with ad-hoc named content areas, which we think is just the right amount of magic for making `erb`-based components.

Note: we also have [instructions for installing themes on other Rails projects](on-other-rails-projects.md).

**Contents:**

1. Installation Instructions
2. Optional Configurations for switching colors, theme gems
3. Using Locales for fields on new models
4. Partials that require special instructions, exclusions
5. Modifying ejected partials

## 1. Installation Instructions

### Add the theme gem

These instructions assume you're installing the `Light` theme bundled with Bullet Train.

```
bundle add bullet_train-themes-light
```

Or add the following to your `Gemfile`:

```
gem "bullet_train-themes-light"
```

And then run:

```
bundle install
```

### Add `npm` packages

The `Light` theme requires the following npm packages to be installed

```
yarn add @bullet-train/bullet-train @bullet-train/fields autoprefixer @rails/actiontext postcss-extend-rule
```

Update your `app/javascript/controllers/index.js` with the following lines:

```js
import { controllerDefinitions as bulletTrainControllers } from "@bullet-train/bullet-train"
import { controllerDefinitions as bulletTrainFieldControllers } from "@bullet-train/fields"

application.load(bulletTrainControllers)
application.load(bulletTrainFieldControllers)
```

### Add `bin/theme` and `bin/link` bin stubs

```
curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train/main/bin/theme" -o bin/theme
curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train/main/bin/link" -o bin/link
chmod +x bin/theme bin/link
```

### Update `esbuild.config.mjs`

Replace it with these contents.

```js
#!/usr/bin/env node

// Esbuild is configured with 3 modes:
//
// `yarn build` - Build JavaScript and exit
// `yarn build --watch` - Rebuild JavaScript on change
// `yarn build --reload` - Reloads page when views, JavaScript, or stylesheets change. Requires a PORT to listen on. Defaults to 3200 but can be specified with PORT env var
//
// Minify is enabled when "RAILS_ENV=production"
// Sourcemaps are enabled in non-production environments

import * as esbuild from "esbuild"
import path from "path"
import { execSync } from "child_process"
import rails from "esbuild-rails"
import chokidar from "chokidar"
import http from "http"
import { setTimeout } from "timers/promises"

let themeFile = ""
if (process.env.THEME) {
  themeFile = execSync(`bundle exec bin/theme javascript ${process.env.THEME}`).toString().trim()
}

const themeEntrypoints = {}
if (process.env.THEME) {
  themeEntrypoints[`application.${process.env.THEME}`] = themeFile
}

const clients = []
const entryPoints = {
  "application": path.join(process.cwd(), "app/javascript/application.js"),
  "administrate": path.join(process.cwd(), "app/javascript/administrate.js"),
  ...themeEntrypoints,
}
const watchDirectories = [
  "./app/javascript/**/*.js",
  "./app/views/**/*.html.erb",
  "./app/assets/builds/**/*.css", // Wait for cssbundling changes
  "./config/locales/**/*.yml",
]
const config = {
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  bundle: true,
  entryPoints: entryPoints,
  minify: process.env.RAILS_ENV == "production",
  outdir: path.join(process.cwd(), "app/assets/builds"),
  plugins: [rails()],
  sourcemap: process.env.RAILS_ENV != "production",
  define: {
    global: "window"
  },
  loader: {
    ".png": "file",
    ".jpg": "file",
    ".svg": "file",
    ".woff": "file",
    ".woff2": "file",
    ".ttf": "file",
    ".eot": "file",
  }
}

async function buildAndReload() {
  // Foreman & Overmind assign a separate PORT for each process
  const port = parseInt(process.env.PORT || 3200)
  console.log(`Esbuild is listening on port ${port}`)
  const context = await esbuild.context({
    ...config,
    banner: {
      js: ` (() => new EventSource("http://localhost:${port}").onmessage = () => location.reload())();`,
    }
  })

  // Reload uses an HTTP server as an even stream to reload the browser
  http
    .createServer((req, res) => {
      return clients.push(
        res.writeHead(200, {
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
          "Access-Control-Allow-Origin": "*",
          Connection: "keep-alive",
        })
      )
    })
    .listen(port)

  await context.rebuild()
  console.log("[reload] initial build succeeded")

  let ready = false
  chokidar
    .watch(watchDirectories)
    .on("ready", () => {
      console.log("[reload] ready")
      ready = true
    })
    .on("all", async (event, path) => {
      if (ready === false)  return

      if (path.includes("javascript")) {
        try {
          await setTimeout(20)
          await context.rebuild()
          console.log("[reload] build succeeded")
        } catch (error) {
          console.error("[reload] build failed", error)
        }
      }
      clients.forEach((res) => res.write("data: update\n\n"))
      clients.length = 0
    })
}

if (process.argv.includes("--reload")) {
  buildAndReload()
} else if (process.argv.includes("--watch")) {
  let context = await esbuild.context({...config, logLevel: 'info'})
  context.watch()
} else {
  esbuild.build(config)
}
```

### Update `tailwind.config.js`

Replace with these contents, which merge the Bullet Train-specific tailwind configs with those of Jumpstart Pro.

_Note: After this step, you might get an error on build about a missing `process.env.THEME`. Follow with the next step to fix this error._

```js
const path = require('path');
const { execSync } = require("child_process");
const glob  = require('glob').sync

if (!process.env.THEME) {
  throw "tailwind.config.js: missing process.env.THEME"
  process.exit(1)
}
  
const themeConfigFile = execSync(`bundle exec bin/theme tailwind-config ${process.env.THEME}`).toString().trim()
let themeConfig = require(themeConfigFile)

const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

themeConfig.darkMode = 'class'

themeConfig.plugins.push(require('@tailwindcss/aspect-ratio'))

themeConfig.content = [
  ...new Set([
    ...themeConfig.content,
    './app/components/**/*.rb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.erb',
    './app/views/**/*.haml',
    './app/views/**/*.slim',
    './lib/jumpstart/app/views/**/*.erb',
    './lib/jumpstart/app/helpers/**/*.rb'
  ])
]

themeConfig.theme.extend.colors = {
  ...themeConfig.theme.extend.colors,
  primary: colors.blue,
  secondary: colors.emerald,
  tertiary: colors.gray,
  danger: colors.red,
  gray: colors.neutral,
  "code-400": "#fefcf9",
  "code-600": "#3c455b",
}

themeConfig.theme.extend.fontFamily = {
  ...themeConfig.theme.extend.fontFamily,
  sans: ['Inter', ...defaultTheme.fontFamily.sans],
}

module.exports = themeConfig
```

### Update `build:css` in `package.json`

In `package.json`, replace the `build` and `build:css` entries under `scripts` with:

```json
"build": "THEME=\"light\" node esbuild.config.mjs",
"build:css": "bin/link; THEME=\"light\" tailwindcss --postcss --minify -c ./tailwind.config.js -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.tailwind.css",
```

### Define `current_theme` helper

In your `app/helpers/application_helper.rb`, define:

```
def current_theme
  :light
end
```

### Add `stylesheet_link_tag` to `<head>`

Make sure you have the following three lines in your `<head>`, which should be defined in `app/views/layouts/application.html.erb`:

```erb
<%= stylesheet_link_tag "application", media: "all", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "application.tailwind", media: "all", "data-turbo-track": "reload" %>
<%= javascript_include_tag 'application.light', 'data-turbo-track': 'reload' %>
```

### Update `postcss.config.js`

Replace with these contents:

```js
const { execSync } = require("child_process");

const postcssImportConfigFile = execSync(`bundle exec bin/theme postcss-import-config ${process.env.THEME}`).toString().trim()
const postcssImportConfig = require(postcssImportConfigFile)

module.exports = {
  plugins: [
    require('postcss-import')(postcssImportConfig),
    require('postcss-extend-rule'),
    require('tailwindcss/nesting'),
    require('tailwindcss'),
    require('autoprefixer')
  ]
}
```

### Import the Theme Style Sheet

To your `application.tailwind.css` file, add the following line:

```css
@import "$ThemeStylesheetsDir/application.css";
```

### Add Themify Icons, jQuery (for now) and trix editor support

Note: jQuery is needed for some of our components, but defining `window.$` won't be required soon. See PR https://github.com/bullet-train-co/bullet_train-core/pull/765

```
yarn add @icon/themify-icons jquery
```

To your `application.js`, add the following line:

```js
import jquery from "jquery"
window.jQuery = jquery
window.$ = jquery

require("@icon/themify-icons/themify-icons.css")

import { trixEditor } from "@bullet-train/fields"
trixEditor()
```

### Add Locale Strings

Add these to your `config/locales/en.yml` under `en:`

```yml
  date:
    formats:
      date_field: "%m/%d/%Y"
      date_and_time_field: "%m/%d/%Y %l:%M %p"
      date_controller: "MM/DD/YYYY"
  time:
    am: AM
    pm: PM
    formats:
      date_field: "%m/%d/%Y"
      date_and_time_field: "%m/%d/%Y %l:%M %p"
      date_controller: "MM/DD/YYYY h:mm A"
  daterangepicker:
    firstDay: 1
    separator: " - "
    applyLabel: "Apply"
    cancelLabel: "Cancel"
    fromLabel: "From"
    toLabel: "To"
    customRangeLabel: "Custom"
    weekLabel: "W"
    daysOfWeek:
    - "Su"
    - "Mo"
    - "Tu"
    - "We"
    - "Th"
    - "Fr"
    - "Sa"
    monthNames:
    - "January"
    - "February"
    - "March"
    - "April"
    - "May"
    - "June"
    - "July"
    - "August"
    - "September"
    - "October"
    - "November"
    - "December"
  date_range_controller:
    today: Today
    yesterday: yesterday
    last7Days: Last 7 Days
    last30Days: Last 30 Days
    thisMonth: This Month
    lastMonth: Last Month
  global:
    buttons:
      other: Other
      cancel: Cancel
    bulk_select:
      all: All
```

### Disable `display: block` on `label` elements

In `app/assets/stylesheets/components/forms.css`, find the line under `label {`:

```css
@apply block text-sm font-medium leading-5 text-gray-700 mb-1;
```

And remove the `block` token:

```css
@apply text-sm font-medium leading-5 text-gray-700 mb-1;
```

## 2. Optional Configurations for switching colors, theme gems

### For Setting the Active Color

```
curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train/main/initializers/theme.rb" -o initializers/theme.rb
```

Add the following classes to your `html` tag for your layout:

```erb
<html class="theme-<%= BulletTrain::Themes::Light.color %> <%= "theme-secondary-#{BulletTrain::Themes::Light.secondary_color}" if BulletTrain::Themes::Light.secondary_color %>"
```

### For Switching Between Installed Themes

If you'd like to create your own theme but would still like to build on top of `:light`, you'll need to have both gems installed and you'll be able to switch the current theme this way.

Change the `current_theme` value in `app/helpers/application_helper.rb`

```
def current_theme
  :super_custom_theme
end
```

To change to use a different theme:

1. Change the value returned by `current_theme` to the new theme name
2. Change the name of the `THEME` env var defined in `build` and `build:css` in `package.json`
3. Change the name of the theme in the `javascript_include_tag` in the `<head>`.

## 3. Using Locales for fields on new models

The theme's field partials work best with locale strings that are defined for the model you're creating.

Example: you've created a Project model. Here we'll create a `projects.en.yml`

1. Run `curl -L "https://raw.githubusercontent.com/bullet-train-co/bullet_train-core/main/bullet_train-super_scaffolding/config/locales/en/scaffolding/completely_concrete/tangible_things.en.yml" -o config/locales/projects.en.yml`
2. Search and replace `projects.en.yml` for `scaffolding/completely_concrete/tangible_things`, `Tangible Things`, `Tangible Thing`, `tangible_things` and `tangible_thing`. Replace with `projects`, `Projects`, `Project`, `projects` and `project` respectively.
3. Remove strings you won't be using. In particular, look for comments with "skip" or "scaffolding".

Some fields use locale strings to drive their `options`. In the `tangible_things.en.yml` template file, look for `super_select_value`, `multiple_option_values` and others.

You'll notice `&` and `*` symbols prefixing some special keys in the `yml` file. Those are anchors and aliases and they help you reduce repetition in your locale strings.

To learn more about how these locales are generated in Bullet Train, see the documentation on [Bullet Train's Super Scaffolding](/docs/super-scaffolding.md)

## 4. Partials that require special instructions, exclusions

### For using boolean-type fields (options, buttons)

In `ApplicationController`, add this:

```ruby
include Fields::ControllerSupport
```

### For the file_field partial

```ruby
# in the model
has_one_attached :file_field_value
after_validation :remove_file_field_value, if: :file_field_value_removal?
attr_accessor :file_field_value_removal
def file_field_value_removal?
def remove_file_field_value
```

```ruby
# in the controller's strong_params
:file_field_value,
:file_field_value_removal,
```

### For `image`, `active_storage_image`

See [`account/users_helper` in BT core repo](https://github.com/bullet-train-co/bullet_train-core/blob/main/bullet_train/app/helpers/account/users_helper.rb) for implementing `photo_url_for_active_storage_attachment`

## 5. Modifying ejected partials

### For ejecting a theme partial and modifying it

We recommend firing up a Bullet Train project and using its `bin/resolve` (see docs on [Indirection](indirection)) to get a copy of the partial field locally to modify.

# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/billing/usage.md

# Bullet Train Usage Limits

Bullet Train provides a holistic method for defining model-based usage limits in your Rails application.

## Installation

### 1. Purchase Bullet Train Pro

First, [purchase Bullet Train Pro](https://buy.stripe.com/aEU7vc4dBfHtfO89AV). Once you've completed this process, you'll be issued a private token for the Bullet Train Pro package server. The process is currently completed manually, so you may have to wait a little to receive your keys.

### 2. Install the Package

### 2.1. Add the Private Ruby Gems

You'll need to specify both Ruby gems in your `Gemfile`, since we have to specify a private source for both:

```ruby
source "https://YOUR_TOKEN_HERE@gem.fury.io/bullettrain" do
  gem "bullet_train-billing"
  gem "bullet_train-billing-stripe" # Or whichever billing provider you're using.
  gem "bullet_train-billing-usage"
end
```

### 2.2. Bundle Install

```
bundle install
```

### 2.3. Copy Database Migrations

Use the following two commands on your shell to copy the required migrations into your local project:

```
cp `bundle show --paths | grep bullet_train-billing | sort | head -n 1`/db/migrate/* db/migrate
cp `bundle show --paths | grep bullet_train-billing-usage | sort | head -n 1`/db/migrate/* db/migrate
```

Note this is different than how many Rails engines ask you to install migrations. This is intentional, as we want to maintain the original timestamps associated with these migrations.

### 2.4. Run Migrations

```
rake db:migrate
```

### 2.5. Add Model Support

There are two concerns that need to be added to your application models.

The first concern is `Billing::UsageSupport` and it allows tracking of usage of verbs on the models you want to support tracking usage on. It is recommended to add this capability to all models, so you can add this.

```ruby
# app/models/application_record.rb

class ApplicationRecord
  include Billing::UsageSupport
end
```

The second concern is `Billing::Usage::HasTrackers` and it allows any model to hold the usage tracking. This is usually done on the `Team` model.

```ruby
# app/models/team.rb

class Team
  include Billing::Usage::HasTrackers
end
```

## Configuration
Usage limit configuration piggybacks on your [product definitions](/docs/billing/stripe.md) in `config/models/billing/products.yml`. It may help to make reference to the [default product definitions in the Bullet Train starter repository](https://github.com/bullet-train-co/bullet_train/blob/main/config/models/billing/products.yml).

## Basic Usage Limits
All limit definitions are organized by product, then by model, and finally by _verb_. For example, you can define the number of projects a team is allowed to have on a basic plan like so:

```yaml
basic:
  prices:
    # ...
  limits:
    projects:
      have:
        count: 3
        enforcement: hard
        upgradable: true
```

Any verb that your model supports can be used. It is recommended to standardize on using the action as the verb. For example, when creating a new model, use the verb _create_. When deleting a model, use the verb _delete_, and so on.

It's important to note that `have` is a special verb and represents the simple `count` of a given model on a `Team`. All _other_ verbs will be interpreted as [time-based usage limits](#time-based-usage-limits).

### Options
 - `enforcement` can be `hard` or `soft`.
   - When a `hard` limit is hit, the create form will be disabled.
   - When a `soft` limit is hit, users are simply notified, but can continue to surpass the limit.
 - `upgradable` indicates whether or not a user should be prompted to upgrade when they hit this limit.

### Excluding Records from `have` Usage Limits
All models have an overridable `billable` scope that includes all records by default. You can override this scope on any given model to ensure that certain records are filtered out from consideration when calculating usage limits. For example, we do the following on `Membership` to exclude removed team members from contributing to any limitation put on the number of team members, like so:

```ruby
scope :billable, -> { current_and_invited }
```

Another example may be excluding "archived" items within the billable usage count such as:

```ruby
module Archivable
  extend ActiveSupport::Concern

  included do
    scope :billable, -> { where(archived_at: nil) }

    # ...
  end
end
```

## Time-Based Usage Limits

### Configuring Limits
In addition to simple `have` usage limits, you can specify other types of usage limits by defining other verbs. For example, you can limit the number of blog posts that can be published in a 3-day period on the free plan like this:

```yaml
free:
  limits:
    blogs/posts:
      publish:
        count: 1
        duration: 3
        interval: days
        enforcement: hard
```

 - `count` is how many times something can happen.
 - `duration` and `interval` represent the time period we'll track for, e.g. "3 days" in this case.
 - Valid options for `interval` are anything you can append to an integer, e.g. `minutes`, `hours`, `days`, `weeks`, `months`, etc., both plural and singular.

### Tracking Usage
For these custom verbs, it's important to also instrument the application for tracking when these actions have taken place. For example:

```ruby
class Blogs::Post < ApplicationRecord
  # ...

  def publish!
    update(published_at: Time.zone.now)
    track_billing_usage(:published)
  end
end
```

It is important that you use the past tense of the verb when tracking so it is tracked appropriately. If you'd like to increment the usage count by more than one, you can pass a quantity like `count: 5` to this call.

### Cycling Trackers Regularly
We include a Rake task you'll need to run on a regular basis in order to cycle the usage trackers that are created at a `Team` level. By default, you should probably run this every five minutes:

```
rake billing:cycle_usage_trackers
```

## Checking Usage Limits

### Checking Time-Based Limits
To make decisions based on or enforce time-based `hard` limits in your views and controllers, you can use the `current_limits` helper like this:

```ruby
current_limits.can?(:publish, Blogs::Post)
```

(You can also pass quantities like `count: 5` as an option.)

### Checking Basic Limits
For basic `have` limits, forms generated by Super Scaffolding will be automatically disabled when a `hard` limit has been hit. Index views will also alert users to a limit being hit or broken for both `hard` and `soft` limits.

> If your Bullet Train application scaffolding predates this feature, you can reference the newest Tangible Things [index template](https://github.com/bullet-train-co/bullet_train-super_scaffolding/blob/main/app/views/account/scaffolding/completely_concrete/tangible_things/_index.html.erb) and [form template](https://github.com/bullet-train-co/bullet_train-super_scaffolding/blob/main/app/views/account/scaffolding/completely_concrete/tangible_things/_form.html.erb) to see how we're using the `shared/limits/index` and `shared/limits/form` partials to present and enforce usage limits, and copy this usage in your own views.

To make decisions in other views or within controllers, you can use the `#exhausted?` method on the `current_limits` helper to check if any basic `have` limits have been hit or exceeded.

```ruby
# Inspects broken hard limits by default
current_limits.exhausted?(Blogs::Post)

# Or you can specify the `enforcement` level
current_limits.exhausted?(Blogs::Post, :soft)
```

#### Presenting an Error

If you want to present an error or warning to the user based on their usage, there themed alert partials that can be displayed in your views. These partials can be rendered via the path `shared/limits/error` and `shared/limits/warning` respectively.

```erb
<%= render "shared/limits/warning", model: model.class %>

<%= render "shared/limits/error", action: :create, model: model.class, count: 1, cancel_path: cancel_path %>
```

These partials have various local assigns that are used to configure the partial.

* `action` - the `verb` to check the usage on the model for. Defaults to `have`.
* `color` - the `color` value to use for the alert partial. Defaults to `red` for errors and `yellow` for warnings.
* `count` - the number of objects intended to be acted upon. Defaults to 1.
* `model` - the `class` relationship as the model to inspect usage on. Defaults to `form.object.class`.

### Changing Products
The default list of products that the limits are based off of are the products available from your Billing products, which is most likely a list of subscription plans from Stripe.

You can change this default behavior by creating your own billing limiter and overriding the `current_products` method. This method should return a list of products that all respond to a `limits` message. The rest of the behavior is encapsulated in the `Billing::Limiter::Base` concern.

```ruby
# app/models/billing/email_limiter.rb

class Billing::EmailLimiter
  include Billing::Limiter::Base

  def current_products
    products = Billing::Product.data

    EmailService.retrieve_product_tiers.map do |tier|
      add_product_limit(tier, products)
    end
  end
end
```


# /Users/sarda/Projects/vendorsafe-archives/vs-app/core/bullet_train/docs/billing/stripe.md

# Bullet Train Billing for Stripe

When you're ready to start billing customers for the product you've created with Bullet Train, you can take advantage of our streamlined, commercial billing package that includes a traditional SaaS pricing page powered by Yaml configuration for products and prices.

We also provide a Stripe-specific adapter package with support for auto-configuring those products and prices in your Stripe account. It also takes advantage of completely modern Stripe workflows, like allowing customers to purchase your product with Stripe Checkout and later manage their subscription using Stripe Billing's customer portal. It also automatically handles incoming Stripe webhooks as well, to keep subscription state in your application up-to-date with activity that has happened on Stripe's platform.

## 1. Purchase Bullet Train Billing for Stripe

First, [purchase Bullet Train Billing for Stripe](https://buy.stripe.com/28o8zg4dBbrd59u7sM). Once you've completed this process, you'll be issued a private token for the Bullet Train Pro package server. (This process is currently completed manually, so please be patient.)

## 2. Install the Package

### 2.1. Add the Private Ruby Gems

You'll need to specify both Ruby gems in your `Gemfile`, since we have to specify a private source for both:

```ruby
source "https://YOUR_TOKEN_HERE@gem.fury.io/bullettrain" do
  gem "bullet_train-billing"
  gem "bullet_train-billing-stripe"
end
```

### 2.2. Bundle Install

```
bundle install
```

### 2.3. Copy Database Migrations

Use the following two commands on your shell to copy the required migrations into your local project:

```
cp `bundle show --paths | grep bullet_train-billing | sort | head -n 1`/db/migrate/* db/migrate
cp `bundle show --paths | grep bullet_train-billing-stripe | sort | head -n 1`/db/migrate/* db/migrate
```

Note this is different than how many Rails engines ask you to install migrations. This is intentional, as we want to maintain the original timestamps associated with these migrations.

<aside><small>TODO Let's create a `rake bullet_train:billing:stripe:install` task.</small></aside>

### 2.4. Run Migrations

```
rake db:migrate
```

## 3. Configure Your Products

Bullet Train defines subscription plans and pricing options in `config/models/billing/products.yml` and defines the translatable elements of these plans in `config/locales/en/billing/products.en.yml`. We recommend just getting started with these plans to ensure your setup is working before customizing the attributes of these plans.

## 4. Configure Stripe

### 4.1. Create API Keys with Stripe

 - Create a Stripe account if you don't already have one.
 - Visit [https://dashboard.stripe.com/test/apikeys](https://dashboard.stripe.com/test/apikeys).
 - Create a new secret key.

**Note:** By default we're linking to the "test mode" page for API keys so you can get up and running in development. When you're ready to deploy to production, you'll have to repeat this step and toggle the "test mode" option off to provision real API keys for live payments.

### 4.2. Configure Stripe API Keys Locally

Edit `config/application.yml` and add your new Stripe secret key to the file:

```yaml
STRIPE_SECRET_KEY: sk_0CJw2Iu5wwIKXUDdqphrt2zFZyOCH
```

### 4.3. Populate Stripe with Locally Configured Products

Before you can use Stripe Checkout or Stripe Billing's customer portal, your locally configured products will have to be created on Stripe as well. To accomplish this, you can have all locally defined products automatically created on Stripe via API by running the following:

```
rake billing:stripe:populate_products_in_stripe
```

### 4.4. Add Additional Environment Variables

The script in the previous step will output some additional environment variables you need to copy into `config/application.yml`.


## 5. Wire Up Webhooks

Basic subscription creation will work without receiving and processing Stripe's webhooks. However, advanced payment workflows like SCA payments and customer portal cancelations and plan changes require receiving webhooks and processing them.

### 5.1. Ensure HTTP Tunneling is Enabled

Although Stripe provides free tooling for receiving webhooks in your local environment, the officially supported mechanism for doing so in Bullet Train is using [HTTP Tunneling with ngrok](/docs/tunneling.md). This is because we provide support for many types of webhooks across different platforms and packages, so we already need to have ngrok in play.

Ensure you've completed the steps from [HTTP Tunneling with ngrok](/docs/tunneling.md), including updating `BASE_URL` in `config/application.yml` and restarting your Rails server.

### 5.2. Enable Stripe Webhooks

 - Visit [https://dashboard.stripe.com/test/webhooks/create](https://dashboard.stripe.com/test/webhooks/create).
 - Use the default "add an endpoint" form.
 - Set "endpoint URL" to `https://YOUR-SUBDOMAIN.ngrok.io/webhooks/incoming/stripe_webhooks`.
 - Under "select events to listen to" choose "select all events" and click "add events".
 - Finalize the creation of the endpoint by clicking "add endpoint".

### 5.3. Configure Stripe Webhooks Signing Secret

After creating the webhook endpoint, click "reveal" under the heading "signing secret". Copy the `whsec_...` value into your `config/application.yml` like so:

```yaml
STRIPE_WEBHOOKS_ENDPOINT_SECRET: whsec_vchvkw3hrLK7SmUiEenExipUcsCgahf9
```

### 5.4. Test Sample Webhook Delivery

 - Restart your Rails server with `rails restart`.
 - Trigger a test webhook just to ensure it's resulting in an HTTP status code of 201.

## 6. Test Creating a Subscription

Bullet Train comes preconfigured with a "freemium" plan, so new and existing accounts will continue to work as normal. A new "billing" menu item will appear and you can test subscription creation by clicking "upgrade" and selecting one of the two plans presented.

You should be in "test mode" on Stripe, so when prompted for a credit card number, you can enter `4242 4242 4242 4242`.

## 7. Configure Stripe Billing's Customer Portal

  - Visit [https://dashboard.stripe.com/test/settings/billing/portal](https://dashboard.stripe.com/test/settings/billing/portal).
  - Complete all required fields.
  - Be sure to add all of your actively available plans under "products".

This "products" list is what Stripe will display to users as upgrade and downgrade options in the customer portal. You shouldn't list any products here that aren't properly configured in your Rails app, otherwise the resulting webhook will fail to process. If you want to stop offering a plan, you should remove it from this list as well.

## 8. Finalize Webhooks Testing by Managing a Subscription

In the same account where you created your first test subscription, go into the "billing" menu and click "manage" on that subscription. This will take you to the Stripe Billing customer portal.

Once you're in the customer portal, you should test upgrading, downgrading, and canceling your subscription and clicking "⬅ Return to {Your Application Name}" in between each step to ensure that each change you're making is properly reflected in your Bullet Train application. This will let you know that webhooks are being properly delivered and processed and all the products in both systems are properly mapped in both directions.

## 9. Rinse and Repeat Configuration Steps for Production

As mentioned earlier, all of the links we provided for configuration steps on Stripe were linked to the "test mode" on your Stripe account. When you're ready to launch payments in production, you will need to:

 - Complete all configuration steps again in the live version of your Stripe account. You can do this by following all the links in the steps above and toggling the "test mode" switch to visit the live mode version of each page.
 - After creating a live API key, configure `STRIPE_SECRET_KEY` in your production environment.
 - Run `STRIPE_SECRET_KEY=... rake billing:stripe:populate_products_in_stripe` (where `...` is your live secret key) in order to create live versions of your products and prices.
 - Copy the environment variables output by that rake task into your production environment.
 - Configure a live version of your webhooks endpoint for the production environment by following the same steps as before, but replacing the ngrok host with your production host in the endpoint URL.
 - After creating the live webhooks endpoint, configure the corresponding signing secret as the `STRIPE_WEBHOOKS_ENDPOINT_SECRET` enviornment variable in your production environment.

## 10. You should be done!

[Let us know on Discord](http://discord.gg/bullettrain) if any part of this guide was not clear or could be improved!

# BulletTrain::Api
API capabilities for apps built with Bullet Train framework.

## Quick Start

### Installation

Add this to your Gemfile:

    gem "bullet_train-api"

Then, run `bundle` or install it manually using `gem install bullet_train-api`.

## Contents

- [API](#api)
  - [Accessing](#accessing)
  - [Versioning](#versioning)
  - [Views](#views)
- [Documentation](#documentation)
  - [Index file](#index-file)
  - [Automatic Components](#automatic-components)
  - [Manually Extending Component Schemas](#manually-extending-component-schemas)
  - [Automatic Paths](#automatic-paths)
  - [External Markdown files](#external-markdown-files)
  - [Examples](#examples)
  - [Example IDs](#example-ids)
  - [Associations](#associations)
  - [Localization](#localization)
- [Rake Tasks](#rake-tasks)
  - [Bump version](#bump-version)
  - [Export OpenAPI document in file](#export-openapi-document-in-file)
  - [Push OpenAPI document to Redocly](#push-openapi-document-to-redocly)
  - [Create separate translations for API](#create-separate-translations-for-api)
- [Contributing](#contributing)
- [License](#license)
- [Sponsor](#open-source-development-sponsored-by)

### API

BulletTrain::Api defines basic REST actions for every model generated with super-scaffolding.

#### Accessing

BulletTrain::Api uses Bearer token as a default authentication method with the help of [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) gem.
It uses the idea that in order to access the API, there should be a Platform Application object, which can have access to different parts of the application.
In Bullet Train, each Team may have several Platform Applications (created in Developers > API menu). When a Platform Application is created,
it automatically generates an Bearer Token needed to access the API, controlled by this Platform Application.

#### Versioning

Versions are being set automatically based on the location of the controller.

Current version can also be checked with
````ruby
BulletTrain::Api.current_version
````

#### Views
All API response templates are located in `app/views/api/<version>/` and are written using standard jbuilder syntax.

### Documentation

This gem automatically generates OpenAPI 3.1 compatible documentation at:

    /api/v1/openapi.yaml


#### Index File

    app/views/api/v1/open_api/index.yaml.erb

The index file is the central point for the API documentation. This consists of a number of sections,
some that get pulled in and bundled at build time.

The file is in YAML format, but includes erb code which generates additional YAML with the help of [`jbuilder-schema`](https://github.com/bullet-train-co/jbuilder-schema) gem.

#### Automatic Components

There are several helper methods available in Index file.
One of them is `automatic_components_for`, which generates two schemas of a model, Attributes and Parameters, based on it's Jbuilder show file.
Parameters are used in requests and Attributes are used in responses.

For example this code:
````yaml
components:
  schemas:
    <%= automatic_components_for User %>
````
looks for the file `app/views/api/v1/users/_user.json.jbuilder`.
Let's say it has this contents:
````ruby
json.extract! user,
  :id,
  :email,
  :name
````
then the produced component will be:
````yaml
components:
  schemas:
    UserAttributes:
      type: object
      title: Users
      description: Users
      required:
      - id
      - email
      properties:
        id:
          type: integer
          description: Team ID
        email:
          type: string
          description: Email Address
        name:
          type:
          - string
          - 'null'
          description: Name
      example:
        id: 42
        email: generic-user-1@example.com
        name: Example Name
    UserParameters:
      type: object
      title: Users
      description: Users
      required:
      - email
      properties:
        email:
          type: string
          description: Email Address
        name:
          type:
          - string
          - 'null'
          description: Name
      example:
        email: generic-user-1@example.com
        name: Example First Name
````
As you can see, it automatically sets required fields based on presence validators of the model,
field types based on the value found in Jbuilder file, descriptions and examples.
More on how it works and how you can customize the output in [`jbuilder-schema`](https://github.com/bullet-train-co/jbuilder-schema) documentation.

#### Manually Extending Component Schemas

While `automatic_components_for` automatically adds parameters and attributes from your application, sometimes it is
necessary to manually specify parameters and attributes in addition to the automatic ones, due to custom code in
your app.

`automatic_components_for` allows to you add or remove parameters and attributes. You can also specify that
parameters that are only available for create or update methods.

##### Adding or Removing Specific Attributes for a Component

To add or remove specific attributes for a component:

    automatic_components_for User,
      parameters: {
        add: {
          tag_ids: {
            type: :array,
            items: {type: :integer},
            description: "Array of Tag IDs for the User."
          }
        }
      },
      attributes: {
        remove: [:email, :time_zone],
        add: {
          url: {
            type: :string,
            description: "The URL of the User's image."
          }
        }
      }

##### Specifying Parameters for Create or Update Methods

To specify parameters that only exist for the create or update methods, use the following format:

    automatic_components_for Enrollment,
      parameters: {
        create: {
          add: {
            user_id: {
              type: :integer,
              description: "ID of the User who enrolled.",
              example: 42
            }
          }
        },
        update: {
          remove: [:time_zone]
        }
      }

#### Automatic Paths

Method `automatic_paths_for` generates basic REST paths. It accepts model as it's argument.
To generate paths for nested models, pass parent model as a second argument. It also accepts `except` as a third argument,
where you can list actions which paths you don't want to be generated.

If the methods defined in the `automatic_paths_for` for the endpoints support
a write action (i.e. create or update), then doc generation uses the `strong_parameters`
defined in the corresponding controller to generate the Parameters section in the schema.

If your endpoint accepts different parameters for the create and update actions, if you define `<model>_update_params` in the
corresponding controller to define the update parameters, these will be used to generate the Parameter for the
update method in the schema.

Automatic paths are generated for basic REST actions. You can customize those paths or add your own by creating a
file at `app/views/api/<version>/open_api/<Model.underscore.plural>/_paths.yaml.erb`. For REST paths there's no need to
duplicate all the schema, you can specify only what differs from auto-generated code.

#### External Markdown files

External text files with Markdown markup can be added with `external_doc` method.
It assumes that the file with `.md` extension can be found in `app/views/api/<version>/open_api/docs`.
You can also use `description_for` method with a model, then there should be file `app/views/api/<version>/open_api/docs/<Model.name.underscore>_description.md`

This allows including external markdown files in OpenAPI schema like in this example:

````yaml
openapi: 3.1.0
info:
  ...
  description: <%= external_doc "info_description" %>
  ...
tags:
  - name: Team
    description: <%= description_for Team %>
  - name: Addresses::Country
    description: <%= description_for Addresses::Country %>
  ...
````
supposing the following files exist:
````
app/views/api/v1/open_api/docs/info_description.md
app/views/api/v1/open_api/docs/team_description.md
app/views/api/v1/open_api/docs/addresses/country_description.md
````

#### Examples

In order to generate example requests and responses for the documentation in the
`automatic_components_for` calls, the bullet_train-api gem contains `ExampleBot`
which uses FactoryBot to build an in-memory representation of the model,
then generates the relevant OpenAPI schema for that model.

ExampleBot will attempt to create an instance of the given model called `<model>_example`.
For namespaced models, `<plural_namespaces>_<model>_example`

For example, for the Order model, use `order_example` factory.

For Orders::Invoices::LineItem, use `orders_invoices_line_item_example` factory.

When writing the factory, the example factory should usually inherit from the existing factory,
but in some cases (usually if the existing factory uses callbacks or creates associations
that you may not want), you may wish to not inherit from the existing one.

##### Example IDs

Since we only want to use in-memory instances, we need to ensure that all examples
have an `id` specified, along with `created_at` and `updated_at`, otherwise they
will show as `null` in the examples.

You may wish to use `sequence` for the id in the examples, but you need to be careful
not to create circular references (see Associations section below)

##### Associations

You need to be careful when specifying associated examples since it is easy to get
into a recursive loop (see Example IDs section above). Also, ensure that you only
create associations using `FactoryBot.example()` and not `create`, otherwise it will
create records in your database.

#### Localization

The documentation requires that `"#{model.name.underscore.pluralize}.label"` localisation value is defined,
which will be used to set model title and description.

### Rake Tasks

#### Bump version

Bump the current version of application's API:

    rake bullet_train:api:bump_version

#### Export OpenAPI document in file

Export the OpenAPI schema for the application to `tmp/openapi` directory:

    rake bullet_train:api:export_openapi_schema

#### Push OpenAPI document to Redocly

Needs `REDOCLY_ORGANIZATION_ID` and `REDOCLY_API_KEY` to be set:

    rake bullet_train:api:push_to_redocly

#### Create separate translations for API

Starting in 1.6.28, Bullet Train Scaffolding generates separate translations for API documentation: `api_title` and `api_description`.
This rake task will add those translations for the existing fields, based on their `heading` value:

    rake bullet_train:api:create_translations

It only needs to be run once after upgrade.

## Contributing

Contributions are welcome! Report bugs and submit pull requests on [GitHub](https://github.com/bullet-train-co/bullet_train-core/tree/main/bullet_train-api).

## License

This gem is open source under the [MIT License](https://opensource.org/licenses/MIT).

## Open-source development sponsored by:

<a href="https://www.clickfunnels.com"><img src="https://images.clickfunnel.com/uploads/digital_asset/file/176632/clickfunnels-dark-logo.svg" width="575" /></a>
# BulletTrain::Fields
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-fields"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-fields
```

## Contributing
See [`RELEASE.md` in bullet_train-base](https://github.com/bullet-train-co/bullet_train-base/blob/main/RELEASE.md) for instructions on local development and for publishing both the gem and the npm package.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::HasUuid
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-has_uuid"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-has_uuid
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::IncomingWebhooks
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-incoming_webhooks"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-incoming_webhooks
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::Integrations
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-integrations"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-integrations
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::Integrations::Stripe
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-integrations-stripe"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-integrations-stripe
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::ObfuscatesId
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-obfuscates_id"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-obfuscates_id
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::OutgoingWebhooks
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-outgoing_webhooks"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-outgoing_webhooks
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# Bullet Train Roles

Bullet Train Roles provides a Yaml-based configuration layer on top of [CanCanCan](https://github.com/CanCanCommunity/cancancan). You can use this configuration file to simplify the definition of many common permissions, while still implementing more complicated permissions in CanCanCan's traditional `app/model/ability.rb`.

Additionally, Bullet Train Roles makes it trivial to assign the same roles and associated permissions at different levels in your application. For example, you can assign someone administrative privileges at a team level, or only at a project level.

Bullet Train Roles was created by [Andrew Culver](http://twitter.com/andrewculver) and [Adam Pallozzi](https://twitter.com/adampallozzi).

## Example Domain Model

For the sake of this document, we're going to assume the following example modeling around users and teams:

- A `User` belongs to a `Team` via a `Membership`.
- A `User` only has one `Membership` per team.
- A `Membership` can have zero, one, or many `Role`s assigned.
- A `Membership` without a `Role` is just a default team member.

You don't have to name your models the same thing in order to use this Ruby Gem, but it does depend on having a similar structure.

> If you're interested in reading more about how and why Bullet Train implements this structure, you can [read about it on our blog](https://blog.bullettrain.co/teams-should-be-an-mvp-feature/).

## Installation

Add these lines to your application's Gemfile:

```ruby
gem "active_hash", github: "bullet-train-co/active_hash"
gem "bullet_train-roles"
```

> We have to link to a specific downstream version of ActiveHash temporarily while working to merge certain fixes and updates upstream.

And then execute the following in your shell:

```
bundle install
```

Finally, run the installation generator:

```
rails generate bullet_train:roles:install
```

The installer defaults to installing a configuration for `Membership` and `Team`, but it will prompt you so you can specify different models if they differ in your application.

The installer will:

 - stub out a configuration file in `config/models/roles.yml`.
 - create a database migration to add `role_ids:jsonb` to `Membership`.
 - add `include Role::Support` to `app/models/membership.rb`.
 - add a basic `permit` call in `app/models/ability.rb`.


## Usage

The provided `Role` model is backed by a Yaml configuration in `config/models/roles.yml`.

To help explain this configuration and its options, we'll provide the following hypothetical example:

```yaml
default:
  models:
    Project: read
    Billing::Subscription: read

editor:
  manageable_roles:
    - editor
  models:
    Project: crud

billing:
  manageable_roles:
    - billing
  models:
    Billing::Subscription: manage

admin:
  includes:
    - editor
    - billing
  manageable_roles:
    - admin
```

Here's a breakdown of the structure of the configuration file:

 - `default` represents all permissions that are granted to any active member on a team.
 - `editor`, `billing`, and `admin` represent additional roles that can be assigned to a membership.
 - `models` provides a list of resources that members with a specific role will be granted.
 - `manageable_roles` provides a list of roles that can be assigned to other users by members that have the role being defined.
 - `includes` provides a list of other roles whose permissions should also be made available to members with the role being defined.
 - `manage`, `read`, etc. are all CanCanCan-defined actions that can be granted.
  - `crud` is a special value that we substitute for the 4 CRUD actions - create, read, update and destroy.
  This is instead of `manage` which covers all actions - 4 CRUD actions _and_ any extra actions the controller may respond to

The following things are true given the example configuration above:

 - By default, users on a team are read-only participants.
 - Users with the `editor` role:
   - can give other users the `editor` role.
   - can perform crud actions on project (create, read, update and destroy).
   - cannot perform any custom controller actions the projects controller responds to
 - Users with the `billing` role:
   - can give other users the `billing` role.
   - can create and update billing subscriptions.
 - Users with the `admin` role:
   - inherit all the privileges of the `editor` and `billing` roles.
   - can give other users the `editor`, `billing`, or `admin` role. (The ability to grant `editor` and `billing` privileges is inherited from the other roles listed in `includes`.)

### Assigning Multiple Actions per Resource

You can also grant more granular permissions by supplying a list of the specific actions per resource, like so:

```yaml
editor:
  models:
    project:
      - read
      - update
```

## Applying Configuration

All of these definitions are interpreted and translated into CanCanCan directives when we invoke the following Bullet Train helper in `app/models/ability.rb`:

```ruby
permit user, through: :memberships, parent: :team
```

In the example above:

 - `through` should reference a collection on `User` where access to a resource is granted. The most common example is the `memberships` association, which grants a `User` access to a `Team`. **In the context of `permit` discussions, we refer to the `Membership` model in this example as "the grant model".**
 - `parent` should indicate which level the models in `through` will grant a user access at. In the case of a `Membership`, this is `team`.

## Additional Grant Models

To illustrate the flexibility of this approach, consider that you may want to grant non-administrative team members different permissions for different `Project` objects on a `Team`. In that case, `permit` actually allows us to re-use the same role definitions to assign permissions that are scoped by a specific resource, like this:

```ruby
permit user, through: :projects_collaborators, parent: :project
```

In this example, `permit` is smart enough to only apply the permissions granted by a `Projects::Collaborator` record at the level of the `Project` it belongs to. You can turn any model into a grant model by adding `include Roles::Support` and adding a `role_ids:jsonb` attribute. You can look at `Scaffolding::AbsolutelyAbstract::CreativeConcepts::Collaborator` for an example.


## Restricting Available Roles

In some situations, you don't want all roles to be available to all Grant Models.  For example, you might have a `project_editor` role that only makes sense when applied at the Project level.  Note that this is only necessary if you want your project_editor to have more limited permissions than an admin user.  If a `project_editor` has full control of their project, you should probably just use the `admin` role.

By default all Grant Models will show all roles as options.  If you want to limit the roles available to a model, use the `roles_only` class method:

```ruby
class Membership < ApplicationRecord
  include Roles::Support
  roles_only :admin, :editor, :reader # Add this line to restrict the Membership model to only these roles
end
```

To access the array of all roles available for a particular model, use the `assignable_roles` class method.  For example, in your Membership form, you probably _only_ want to show the assignable_roles as options.  Your view could look like this:

```erb
<% Membership.assignable_roles.each do |role| %>
  <% if role.manageable_by?(current_membership.roles) %>
    <!-- View component for showing a role option. Probably a checkbox -->
  <% end %>
<% end %>
```

## Checking user permissions

Generally the CanCanCan helper method (`account_load_and_authorize_resource`) at the top of each controller will handle checking user permissions and will only load resources appropriate for the current user.

However, you may also want to check if a user can perform a specific action.  For example, in a view you may want to only show the edit button if the current user has permissions to edit the object.  For this, you can use regular CanCanCan helpers.  For example:

```
<%= link_to "Edit", [:account, @document] if can? :edit, @document %>
```

Sometimes, you might want to check for the presence of a specific role. We provide a helper to check for the admin role:
```
@membership.admin?
```

For all other roles, you can check for their presence like this:

```
@membership.roles.include?(Role.find("developer"))
```

However, when you do that, you're only checking the roles that have been directly assigned to that membership.

Imagine a scenario like this:
```
# roles.yml
admin:
  includes:
    - editor
    - billing

# somewhere else in your app:
@membership.roles << Role.admin
@membership.roles.include?(Role.find("editor"))
=> false
```

While that's technically correct that the user doesn't have the editor role, we probably want that to return true if we're checking what the user can and can't do.  For this situation, we really want to check if the user can perform a role rather than if they've had that role assigned to them.

```
# roles.yml

admin:
  includes:
    - editor
    - billing

# somewhere else in your app:

@membership.roles << Role.admin
@membership.roles.can_perform_role?(Role.find("editor"))
=> true

# You can also pass the role key as a symbol for a more concise syntax
@membership.roles.can_perform_role?(:editor)
=> true
```


## Debugging

If you want to see what CanCanCan directives are being created by your permit calls, you can add the `debug: true` option to your `permit` statement in `app/models/ability.rb`.

Likewise, to see what abilities are being added for a certain user, you can run the following on the Rails console:

```ruby
user = User.first
Ability.new(user).permit user, through: :projects_collaborators, parent: :project, debug: true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bullet-train-co/bullet_train-roles. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/bullet-train-co/bullet_train-roles/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BulletTrain::Roles project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bullet-train-co/bullet_train-roles/blob/main/CODE_OF_CONDUCT.md).
# BulletTrain::ScopeQuestions
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-scope_questions"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-scope_questions
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# Bullet Train Scope Validator

Bullet Train Scope Validator provides a simple pattern for protecting `belongs_to` associations from malicious ID stuffing. It was created by [Andrew Culver](https://twitter.com/andrewculver) and extracted from [Bullet Train](https://bullettrain.co).

## Illustrating the Problem

By default in a multitenant Rails application, unless special care is given to validating the ID assigned to a `belongs_to` association, malicious users can stuff arbitrary IDs into their request and cause an application to bleed data from other tenants.

Consider the following example from a customer relationship management (CRM) system that two competitive companies use:

### Example Models

```ruby
class Team < ApplicationRecord
  has_many :customers
  has_many :deals
end

class Customer < ApplicationRecord
  belongs_to :team
end

class Deal < ApplicationRecord
  belongs_to :team
  belongs_to :customer
end
```

### Example Controller

```ruby
class DealsController < ApplicationController
  # 👋 Not illustrated: this controller loads `@team` safely, and has a `new` and `show` action.

  def create
    if @team.deals.create(deal_params)
      redirect_to @deal
    else
      render :new
    end
  end

  def deal_params
    params.require(:deal).permit(:customer_id)
  end
end
```

☝️ Note that Strong Parameters allows `customer_id` to be set by incoming requests and isn't responsible for validating the value. We also wouldn't _want_ Strong Parameters to be responible for this, since we'd end up with duplicate validation logic in our API controllers and other places. This is a responsibility of the model.

### Example Form

```erb
<%= form.collection_select(:customer_id, @team.customers, :id, :name) %>
```

☝️ Note that the `@team.customers.all` is properly scoped to only show customers from the current team.

### Example Show View

```
We have a deal with <%= @deal.customer.name %>!
```

### The "Exploit"

A malicious user can:

 - Begin adding a new deal to their account.
 - Inspect the DOM and replace the `<select>` element for `customer_id` with an `<input type="text">` element.
 - Set the value to any number, particularly numbers that are IDs they know don't belong to their account.
 - Submit the form to create the deal.
 - When the deal is shown, it will say "We have a deal with Nintendo!", where "Nintendo" is actually the customer of another team in the system. ☠️ We've bled customer data across our application's tenant boundary.

## Usage

Building on the example above, we can use Bullet Train Scope Validator to fix the problem like so:

First, add the following in our `Gemfile`:

```ruby
gem "bullet_train-scope_validator"
```

(Be sure to also run `bundle install` and restart your Rails server.)

Then we add a `scope: true` validation and `def valid_customers` method in the model, like so:

```ruby
class Deal < ApplicationRecord
  belongs_to :team
  belongs_to :customer

  validates :customer, scope: true

  def valid_customers
    team.customers
  end
end
```

If you're wondering what the connection between `validates :customer, scope: true` and `def valid_customers` is, it's just a convention that the former will call the latter based on the name of the attibute being validated. We've favored a full-blown method definition for this instead of simply passing in a proc into the validator because having a method allows us to also DRY up our form view to use the same definition of valid options, like so:

```erb
<%= form.collection_select(:customer_id, form.object.valid_customers, :id, :name) %>
```

So with that, you're done! Any attempts to stuff IDs will be met with an "invalid" Active Record error message.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bullet-train-co/bullet_train-scope_validator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/bullet-train-co/bullet_train-scope_validator/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Bullet Train Scope Validator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bullet-train-co/bullet_train-scope_validator/blob/master/CODE_OF_CONDUCT.md).
# BulletTrain::Sortable
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-sortable"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-sortable
```

## Contributing
See [`RELEASE.md` in bullet_train-base](https://github.com/bullet-train-co/bullet_train-base/blob/main/RELEASE.md) for instructions on local development and for publishing both the gem and the npm package.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::SuperLoadAndAuthorizeResource
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-super_load_and_authorize_resource"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-super_load_and_authorize_resource
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::SuperScaffolding
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-super_scaffolding"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-super_scaffolding
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::Themes
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-themes"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-themes
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::Themes::Light
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-themes-light"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-themes-light
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# BulletTrain::Themes::TailwindCss
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "bullet_train-themes-tailwind_css"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install bullet_train-themes-tailwind_css
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
