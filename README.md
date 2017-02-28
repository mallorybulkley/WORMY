# WORM
A lightweight Object-Relational Mapping (ORM) library for Ruby. Allows you to keep code DRY and easily perform database operations in an object-oriented manner. WORM emphasizes convention over configuration by setting sensible defaults.

## Demo
1. From the root directory of this repo, open `pry` or `irb` in the console
2. `load hp_demo.rb`
3. Use `hp_demo.rb` as a reference to run commands

## Libraries
* SQLite3
* ActiveSupport::Inflector

## API
Associations between models are defined by simple class methods, like so:
```
class Pet < SQLObject
  belongs_to :owner,
    class_name: "Wizard"

  has_one_through :house, :owner, :house

  finalize!
end
```

Querying and updating the database is made easy with SQLObject's methods like:
* `::find`
* `::where`
* `#save`

## About WORM
WORM opens a connection to a provided database file by instantiating a singleton of SQLite3::Database via DBConnection. DBConnection uses native SQLite3::Database methods (`execute`, `execute2`, `last_insert_row_id`) to allow WORM to perform complex SQL queries using heredocs. The `Searchable` and `Associatable` modules extend SQLObject to provide an intuitive API.

WORM emphasizes convention over configuration by setting sensible defaults for associations, but also allows for easy overrides if desired.
