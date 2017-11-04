require 'wormy'

DB_FILE = 'harry_potter.db'
SQL_FILE = 'harry_potter.sql'

# SCHEMA

# House
# Columns: 'id', 'name'

# Wizard
# Columns: 'id', 'fname', 'lname', 'house_id'

# Pet
# Columns: 'id', 'name', 'owner_id'


`rm '#{DB_FILE}'`
`cat '#{SQL_FILE}' | sqlite3 '#{DB_FILE}'`

WORMY::DBConnection.open(DB_FILE)

class House < WORMY::Base
  has_many :wizards
  has_many_through :pets,
    through: :wizards,
    source: :pets
  validates :house_name

  def house_name
    ["Gryffindor", "Slytherin", "Ravenclaw", "Hufflepuff"].include?(self.name)
  end

  finalize!
end

class Wizard < WORMY::Base
  belongs_to :house
  has_many :pets,
    foreign_key: :owner_id

  finalize!
end

class Pet < WORMY::Base
  belongs_to :owner,
    class_name: "Wizard"

  has_one_through :house,
    through: :owner,
    source: :house

  finalize!
end
