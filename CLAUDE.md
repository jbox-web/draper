# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A simpler reimplementation of the Draper gem (`jbox-web/draper`) — view models / decorators for Rails,
borrowing ideas from `dekorator`.
It wraps model objects with an object-oriented layer of presentation logic, kept out of models and
procedural helpers. Ruby `>= 3.2`; the gemspec requires Rails `>= 7.2`, matching what CI and
Appraisals exercise (`7.2` / `8.0` / `8.1`). Runtime dependencies: `rails`, `request_store`, `zeitwerk`.

## Commands

All executables are bundler binstubs in `bin/`; prefer them over `bundle exec`.

- `bin/rspec` — run the full test suite (default rake task).
- `bin/rspec spec/draper/decorator_spec.rb:42` — run a single file / a single example by line.
- `bin/rubocop` — lint (config in `.rubocop.yml`, RuboCop with performance/rake/rspec/rspec_rails/capybara/factory_bot plugins).
- `bin/rake` — defaults to `spec`.
- `bin/guard` — watch files and re-run specs (see `Guardfile`).
- `ruby benchmarks/benchmarks.rb` — micro-benchmarks for the decoration path.

### Testing against multiple Rails versions

Cross-version testing uses Appraisal. Version-specific lockfiles live in `gemfiles/`
(`rails_7.2`, `rails_8.0`, `rails_8.1`), generated from `Appraisals`.

- `bin/appraisal install` — regenerate the `gemfiles/*.gemfile` after editing `Appraisals`.
- `bin/appraisal rails_8.1 rspec` — run the suite against one Rails version.
- `BUNDLE_GEMFILE=gemfiles/rails_8.0.gemfile bin/rspec` — same, as CI does it.

CI (`.github/workflows/ci.yml`) matrices Ruby `3.2`–`4.0` × Rails `7.2`/`8.0`/`8.1`, plus a RuboCop
job. Coverage is published to Qlty (`qltysh/qlty-action`), not Code Climate despite the README badges.

## Test harness

Specs run against a full dummy Rails app in `spec/dummy/` (models, controllers, mailers, decorators,
views). `spec/spec_helper.rb` boots `spec/dummy/config/environment.rb`, then loads everything under
`spec/support/` plus `spec/config_capybara.rb` and `spec/config_rspec.rb`. Feature specs use
Capybara + Cuprite (headless Chrome); FactoryBot manages fixtures; SimpleCov emits HTML + JSON
coverage into `coverage/`. `js: true` examples retry up to 3× (`rspec-rebound`). Warnings are promoted
(`--warnings` in `.rspec`, and `spec_helper` enables the deprecated/experimental/performance warning
categories while silencing warnings from gem dependencies).

## Architecture

Autoloading is Zeitwerk (`lib/draper.rb`), which ignores `draper/rails` (rake tasks) and `draper/test`
(RSpec integration) — those are `require`d explicitly, not autoloaded.

The flow, from request to decorated output:

- **`Draper.decorate(object, with:, namespace:)`** (`lib/draper.rb`) — the public entry point and the
  core of decorator inference. `decorable?` filters out nil / empty / already-decorated objects and
  blank `ActiveRecord::Relation`s (returning them undecorated); `_guess_decorator` maps `Foo` →
  `FooDecorator` (or the explicit `with:` class), prefixing a `namespace:` when given. Handles both
  single objects and Enumerables (mapping element-wise), and yields the result if a block is passed.

- **`Draper::Decorator`** (`lib/draper/decorator.rb`) — base class for all decorators (subclass it,
  place under `app/decorators`, name it `<Model>Decorator`). Its class-level `delegate` overrides
  `Module#delegate` to default `to: :object`. `decorates_association` defines a lazily-decorated,
  memoized accessor via `class_eval` (with optional `with:` / `namespace:` / `scope:`). `object`
  (alias `model`) exposes the wrapped model; `attributes` slices the model's attributes to those the
  decorator implements. Equality (`==`, `eql?`, `hash`) is by decorator class + wrapped object.
  `h`/`helpers` (both class and instance level) reach the current view context to call Rails helpers.

- **View context** — how decorators get a live view context to render helpers, held per-request in
  `RequestStore`. `Draper::ViewContext` (`lib/draper/view_context.rb`) is a `module_function`
  singleton: `current` lazily builds and caches the context, `controller`/`controller=` track the
  active controller (setting a different controller triggers `clear!`), and `clear!` wipes both keys.
  This is a single shared store — there is no separate mailer isolation.

- **`ViewContext::BuildStrategy`** (`lib/draper/view_context/build_strategy.rb`) — builds the view
  context object. `Full` (the default, set in `ViewContext.build_strategy`) uses a real controller's
  `view_context` — defaulting to `Draper.default_controller` (i.e. `ApplicationController`) with a
  synthesized `ActionController::TestRequest` when available. `Fast` builds a bare `ActionView::Base`
  subclass instead. `BuildStrategy.new(:full)` resolves the name to the matching class by camelizing.

- **Rails wiring** — `Draper::Engine` (`lib/draper/engine.rb`) hooks `ActionController` and
  `ActionMailer` on load. Both `include Draper::ViewContext::BaseHelper` (which wraps `view_context`
  to cache it into `ViewContext.current` and exposes `decorate` as a `helper_method`); controllers
  additionally `include Draper::ViewContext::ControllerHelper`, adding a `before_action
  :activate_draper` that registers the current controller into `ViewContext`. Under
  `Rails.env.test?`, the engine also wires the RSpec `type: :decorator` integration and resets the
  view context before each decorator/controller/mailer example.

## Conventions

- Every Ruby file starts with `# frozen_string_literal: true`.
- `Style/HashSyntax` uses `EnforcedShorthandSyntax: never` (write `{ key => value }`, not shorthand);
  `Layout/LineLength` max is 125.
- `Layout/IndentationConsistency` is `indented_internal_methods` — `private`/`protected` methods are
  indented one level deeper than the `private` keyword (see `decorator.rb`, `build_strategy.rb`).
- Public methods carry YARD doc comments (`@param`, `@return`, `@overload`); keep them when editing.
