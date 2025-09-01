-- Autor:innen
INSERT INTO author (full_name) VALUES
  ('Lauren Roberts'),
  ('Rebecca Yarros'),
  ('Caroline Wahl')
ON CONFLICT DO NOTHING;

-- Bücher
-- Kategorie nur als Text, einfach gehalten
INSERT INTO book (isbn13, title, category, published_year) VALUES
  ('9781665954884', 'Powerless', 'Fantasy', 2023),
  ('9781649374042', 'Fourth Wing', 'Fantasy', 2023),
  ('9781649374172', 'Iron Flame (Fourth Wing 2)', 'Fantasy', 2023),
  ('9783832160456', '22 Bahnen', 'Roman', 2022),
  ('9783832168414', 'Windstärke 17', 'Roman', 2024)
ON CONFLICT DO NOTHING;

-- Buch–Autor (n:m)
INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b JOIN author a ON a.full_name = 'Lauren Roberts'
WHERE b.title = 'Powerless'
ON CONFLICT DO NOTHING;

INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b JOIN author a ON a.full_name = 'Rebecca Yarros'
WHERE b.title = 'Fourth Wing'
ON CONFLICT DO NOTHING;

INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b JOIN author a ON a.full_name = 'Rebecca Yarros'
WHERE b.title = 'Iron Flame (Fourth Wing 2)'
ON CONFLICT DO NOTHING;

INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b JOIN author a ON a.full_name = 'Caroline Wahl'
WHERE b.title = '22 Bahnen'
ON CONFLICT DO NOTHING;

INSERT INTO book_author (book_id, author_id, author_order)
SELECT b.book_id, a.author_id, 1
FROM book b JOIN author a ON a.full_name = 'Caroline Wahl'
WHERE b.title = 'Windstärke 17'
ON CONFLICT DO NOTHING;

-- Exemplare (je 1)
INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, 'POW-0001', 'MAIN' FROM book WHERE title='Powerless';

INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, 'FW-0001', 'MAIN' FROM book WHERE title='Fourth Wing';

INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, 'IF-0001', 'MAIN' FROM book WHERE title='Iron Flame (Fourth Wing 2)';

INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, '22B-0001', 'MAIN' FROM book WHERE title='22 Bahnen';

INSERT INTO book_copy (book_id, inventory_code, location)
SELECT book_id, 'WS17-0001', 'MAIN' FROM book WHERE title='Windstärke 17';

-- Nutzer
INSERT INTO "user" (email, full_name) VALUES
  ('max@example.edu', 'Max Muster'),
  ('anna@example.edu', 'Anna Beispiel')
ON CONFLICT DO NOTHING;

-- Ausleihen (eine aktiv, eine überfällig)
INSERT INTO loan (copy_id, user_id, loaned_at, due_at)
VALUES (
  (SELECT copy_id FROM book_copy WHERE inventory_code='FW-0001'),
  (SELECT user_id FROM "user" WHERE email='max@example.edu'),
  CURRENT_DATE, CURRENT_DATE + INTERVAL '14 day'
);

INSERT INTO loan (copy_id, user_id, loaned_at, due_at)
VALUES (
  (SELECT copy_id FROM book_copy WHERE inventory_code='22B-0001'),
  (SELECT user_id FROM "user" WHERE email='anna@example.edu'),
  CURRENT_DATE - INTERVAL '20 day', CURRENT_DATE - INTERVAL '5 day'
);


