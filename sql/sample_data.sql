-- Roles
INSERT INTO role (name) VALUES ('MEMBER'), ('LIBRARIAN'), ('ADMIN')
ON CONFLICT DO NOTHING;

-- Category
INSERT INTO category (name) VALUES 
  ('Fantasy'),
  ('Jugendliteratur'),
  ('Roman')
ON CONFLICT DO NOTHING;

-- Publisher
INSERT INTO publisher (name) VALUES
  ('Piper Verlag'),
  ('dtv'),
  ('DuMont Verlag')
ON CONFLICT DO NOTHING;

-- Author
INSERT INTO author (full_name) VALUES
  ('Lauren Roberts'),
  ('Rebecca Yarros'),
  ('Caroline Wahl')
ON CONFLICT DO NOTHING;

-- Books 
INSERT INTO book (isbn13, title, published_year, category_id, publisher_id)
VALUES 
  ('9781665954884', 'Powerless', 2023,
   (SELECT category_id FROM category WHERE name='Fantasy'),
   (SELECT publisher_id FROM publisher WHERE name='Piper Verlag')),

  ('9781649374042', 'Fourth Wing', 2023,
   (SELECT category_id FROM category WHERE name='Fantasy'),
   (SELECT publisher_id FROM publisher WHERE name='dtv')),

  ('9781649374172', 'Iron Flame (Fourth Wing 2)', 2023,
   (SELECT category_id FROM category WHERE name='Fantasy'),
   (SELECT publisher_id FROM publisher WHERE name='dtv')),

  ('9783832160456', '22 Bahnen', 2022,
   (SELECT category_id FROM category WHERE name='Roman'),
   (SELECT publisher_id FROM publisher WHERE name='DuMont Verlag')),

  ('9783832168414', 'Windstärke 17', 2024,
   (SELECT category_id FROM category WHERE name='Roman'),
   (SELECT publisher_id FROM publisher WHERE name='DuMont Verlag'))
ON CONFLICT DO NOTHING;

-- Buch-Autor-Beziehungen
INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b, author a
WHERE b.title='Powerless' AND a.full_name='Lauren Roberts'
ON CONFLICT DO NOTHING;

INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b, author a
WHERE b.title='Fourth Wing' AND a.full_name='Rebecca Yarros'
ON CONFLICT DO NOTHING;

INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b, author a
WHERE b.title='Iron Flame (Fourth Wing 2)' AND a.full_name='Rebecca Yarros'
ON CONFLICT DO NOTHING;

INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b, author a
WHERE b.title='22 Bahnen' AND a.full_name='Caroline Wahl'
ON CONFLICT DO NOTHING;

INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b, author a
WHERE b.title='Windstärke 17' AND a.full_name='Caroline Wahl'
ON CONFLICT DO NOTHING;

-- Exemplare (für jede Buchversion)
INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, 'POW-0001', 'MAIN' FROM book WHERE title='Powerless'
ON CONFLICT DO NOTHING;

INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, 'FW-0001', 'MAIN' FROM book WHERE title='Fourth Wing'
ON CONFLICT DO NOTHING;

INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, 'IF-0001', 'MAIN' FROM book WHERE title='Iron Flame (Fourth Wing 2)'
ON CONFLICT DO NOTHING;

INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, '22B-0001', 'MAIN' FROM book WHERE title='22 Bahnen'
ON CONFLICT DO NOTHING;

INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, 'WS17-0001', 'MAIN' FROM book WHERE title='Windstärke 17'
ON CONFLICT DO NOTHING;

-- Nutzer
INSERT INTO "user" (email, full_name, role_id)
VALUES 
  ('max@example.edu', 'Max Muster', (SELECT role_id FROM role WHERE name='MEMBER')),
  ('anna@example.edu', 'Anna Beispiel', (SELECT role_id FROM role WHERE name='MEMBER'))
ON CONFLICT DO NOTHING;

-- Ausleihen
-- Max: "Fourth Wing" aktuell ausgeliehen
INSERT INTO loan (copy_id, user_id, loaned_at, due_at)
VALUES (
  (SELECT copy_id FROM book_copy WHERE inventory_code='FW-0001'),
  (SELECT user_id FROM "user" WHERE email='max@example.edu'),
  CURRENT_DATE,
  CURRENT_DATE + INTERVAL '14 day'
);

-- Anna: "22 Bahnen" überfällig
INSERT INTO loan (copy_id, user_id, loaned_at, due_at)
VALUES (
  (SELECT copy_id FROM book_copy WHERE inventory_code='22B-0001'),
  (SELECT user_id FROM "user" WHERE email='anna@example.edu'),
  CURRENT_DATE - INTERVAL '20 day',
  CURRENT_DATE - INTERVAL '5 day'
);

