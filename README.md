# README
* Ruby version 3.1.3

* System dependencies
    - ruby version 3.1.3
    - Rails 7.2.2.1

* Configuration
    - install ruby
    - install redis
    - add .env file to the root directory, see `.env.example` for reference.
    - add config/database.yml file, see config/database.yml.example for reference.

* Database creation

  ```rake db:create```

  ```rake db:migrate```

* Application set up:
    - `bundle install`
    - `rake db:create`
    - `rake db:migrate`

* Start application
    - `rails server` - start application server

* Run tests
    - `bundle exec rspec`

# Assumptions
1. Todos::TodosSearchService - added as an example how customizable search service may look like, 
  also could be separated to sql query and usage of SqlBindings gem(actually it's for postgresql) despite the name
2. Added hi level of tests with Rspec
3. Request error handling in one place in ApiConcern
4. Addedn bare minimum of functionality but paid attention on splitting the code in appropriate places 
  and made it customizable and extensible even despite that for existing functionality it's a bit overhead.
5. Enum as string - for ability to customize in future and don't depend on order.
6. Add indexes in migration for performance optimization.

# Things to improve
1. Add logging. For now I just left TODO: comments, but it would be nice to implement logging for errors.
2. Add API docs
3. Adding cache for reads (if we would read orders and disbursements frequently).
4. Potentially for the future, we could shard databases per merchants in particular region.
5. Add some kind of authentication/authorization for data views and especially for data creation through API.
6. Add libraries to check code quality, like rubocop
7. Add test code coverage check library like simplecov.
8. Check whether some application level validations are missing.
9. Add seeds.rb
10. Rescue specific errors, not `StandardError` in rescue clauses.
