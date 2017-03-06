CREATE TABLE pets (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE wizards (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, name)
VALUES
  (1, "Gryffindor"), (2, "Ravenclaw"), (3, "Hufflepuff"), (4, "Slytherin");

INSERT INTO
  wizards (id, fname, lname, house_id)
VALUES
  (1, "Harry", "Potter", 1),
  (2, "Ron", "Weasley", 1),
  (3, "Hermione", "Granger", 1),
  (4, "Draco", "Malfoy", 4),
  (5, "Cedric", "Diggory", 3),
  (6, "Cho", "Chang", 2),
  (7, "Luna", "Lovegood", 2),
  (8, "Tom", "Riddle", 4);

INSERT INTO
  pets (id, name, owner_id)
VALUES
  (1, "Hedwig", 1),
  (2, "Scabbers", 2),
  (3, "Crookshanks", 3),
  (4, "Nagini", 8),
  (5, "Bell", 6),
  (6, "Quibbly", 7),
  (7, "Stray Cat", NULL),
  (8, "Buddy", 5),
  (9, "Thestral", 7),
  (10, "Billy", 7);
