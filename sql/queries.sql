-- 1) Bücher mit Autor:innen
SELECT
  b.title,
  array_agg(a.full_name ORDER BY ba.author_order) AS authors,
  b.category,
  b.published_year
FROM library.book b
LEFT JOIN library.book_author ba ON ba.book_id = b.book_id
LEFT JOIN library.author a ON a.author_id = ba.author_id
GROUP BY b.book_id, b.title, b.category, b.published_year
ORDER BY b.title;

-- 2) Aktuelle Ausleihen
SELECT
  u.full_name AS user_name,
  b.title,
  l.loaned_at,
  l.due_at,
  (l.returned_at IS NULL) AS is_active
FROM library.loan l
JOIN library."user" u ON u.user_id = l.user_id
JOIN library.book_copy bc ON bc.copy_id = l.copy_id
JOIN library.book b ON b.book_id = bc.book_id
ORDER BY l.loaned_at DESC;

-- 3) Überfällige Ausleihen
SELECT u.full_name, b.title, l.due_at
FROM library.loan l
JOIN library."user" u ON u.user_id = l.user_id
JOIN library.book_copy bc ON bc.copy_id = l.copy_id
JOIN library.book b ON b.book_id = bc.book_id
WHERE l.returned_at IS NULL
  AND l.due_at < CURRENT_DATE
ORDER BY l.due_at;

-- 4) Verfügbarkeit pro Buch
SELECT
  b.title,
  COUNT(*) AS total_copies,
  COUNT(*) FILTER (
    WHERE NOT EXISTS (
      SELECT 1 FROM library.loan l
      WHERE l.copy_id = bc.copy_id AND l.returned_at IS NULL
    )
  ) AS available_copies
FROM library.book b
JOIN library.book_copy bc ON bc.book_id = b.book_id
GROUP BY b.title
ORDER BY b.title;
