# WORM 🐛
A lightweight Object-Relational Mapping (ORM) library for Ruby. Allows you to keep code DRY and easily perform database operations in an object-oriented manner.

## Demo
1. From the root directory of this repo, open `pry` or `irb` in the console
2. `load 'hp_demo.rb'`
3. Use `hp_demo.rb` and the API section below as a reference to play around with the data

## How to Use WORM
* Navigate to the folder in your directory where you would like your .db database file to be saved.
* If you have an existing database.rb file you need to rewrite, run `rm database.db`
* Run `cat '{YOUR_SQL_FILE_NAME}' | sqlite3 'database.db'` (replacing {YOUR_SQL_FILE_NAME} with your own .sql file)
* Then, in your project, open a connection with `DBConnection.open('database.db')`

## Libraries
* SQLite3
* ActiveSupport::Inflector

## API
Associations between models are defined by simple class methods, like so:
```
class Pet < WORM::Base
  belongs_to :owner,
    class_name: "Wizard"

  has_one_through :house, :owner, :house

  finalize!
end
```

Querying and updating the database is made easy with WORM::Base's methods like:
* `::all`
* `::count`
* `::destroy_all`
* `::find`
* `::first`
* `::last`
* `::where`
* `#create`
* `#save`
* `#destroy`

Perform custom model validations by adding a call to `validates` in your subclass definition:
```
class House < WORM::Base
  has_many :wizards
  has_many_through :pets, :wizards, :pets
  validates :house_name

  def house_name
    ["Gryffindor", "Slytherin", "Ravenclaw", "Hufflepuff"].include?(self.name)
  end

  finalize!
end
```


## About WORM
WORM opens a connection to a provided database file by instantiating a singleton of SQLite3::Database via DBConnection. DBConnection uses native SQLite3::Database methods (`execute`, `execute2`, `last_insert_row_id`) to allow WORM to perform complex SQL queries using heredocs. The `Searchable` and `Associatable` modules extend WORM::Base to provide an intuitive API.

WORM emphasizes convention over configuration by setting sensible defaults for associations, but also allows for easy overrides if desired.
