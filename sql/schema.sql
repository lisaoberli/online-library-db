-- Alles in ein schlichtes Schema
DROP SCHEMA IF EXISTS library CASCADE;
CREATE SCHEMA library;
SET search_path = library, public;

-- Nutzer
CREATE TABLE "user" (
  user_id BIGSERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Autor:innen
CREATE TABLE author (
  author_id BIGSERIAL PRIMARY KEY,
  full_name TEXT NOT NULL
);

-- Bücher (ohne Publisher-Tabelle; Kategorie nur als Text)
CREATE TABLE book (
  book_id BIGSERIAL PRIMARY KEY,
  isbn13 CHAR(13) UNIQUE NOT NULL,
  title TEXT NOT NULL,
  category TEXT,               -- frei wählbar (z.B. 'Fantasy', 'Roman')
  published_year INT CHECK (published_year BETWEEN 1400 AND EXTRACT(YEAR FROM now())::INT + 1),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- n:m Buch–Autor
CREATE TABLE book_author (
  book_id BIGINT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
  author_id BIGINT NOT NULL REFERENCES author(author_id) ON DELETE RESTRICT,
  author_order INT NOT NULL DEFAULT 1,
  PRIMARY KEY (book_id, author_id)
);

-- Exemplare
CREATE TABLE book_copy (
  copy_id BIGSERIAL PRIMARY KEY,
  book_id BIGINT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
  inventory_code TEXT UNIQUE NOT NULL,    -- z.B. Barcode
  location TEXT NOT NULL DEFAULT 'MAIN'
);

-- Ausleihen
CREATE TABLE loan (
  loan_id BIGSERIAL PRIMARY KEY,
  copy_id BIGINT NOT NULL REFERENCES book_copy(copy_id) ON UPDATE CASCADE,
  user_id BIGINT NOT NULL REFERENCES "user"(user_id) ON UPDATE CASCADE,
  loaned_at DATE NOT NULL DEFAULT CURRENT_DATE,
  due_at DATE NOT NULL,
  returned_at DATE,
  CHECK (due_at >= loaned_at)
);

-- Ein Exemplar darf nur eine aktive Ausleihe haben
CREATE UNIQUE INDEX uniq_active_loan_per_copy
  ON loan (copy_id)
  WHERE returned_at IS NULL;
