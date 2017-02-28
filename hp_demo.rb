require_relative 'lib/base'

HP_DB_FILE = 'harry_potter.db'
HP_SQL_FILE = 'harry_potter.sql'

# SCHEMA

# House
# Columns: 'id', 'name'

# Wizard
# Columns: 'id', 'fname', 'lname', 'house_id'

# Pet
# Columns: 'id', 'name', 'owner_id'


`rm '#{HP_DB_FILE}'`
`cat '#{HP_SQL_FILE}' | sqlite3 '#{HP_DB_FILE}'`

DBConnection.open(HP_DB_FILE)

class House < WORM::Base
  has_many :wizards
  has_many_through :pets, :wizards, :pets

  finalize!
end

class Wizard < WORM::Base
  belongs_to :house
  has_many :pets,
    foreign_key: :owner_id

  finalize!
end

class Pet < WORM::Base
  belongs_to :owner,
    class_name: "Wizard"

  has_one_through :house, :owner, :house

  finalize!
end
