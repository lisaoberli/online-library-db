-- Schema
CREATE SCHEMA IF NOT EXISTS library;
SET search_path = library, public;

-- Rollen (einfach: genau eine Rolle je User)
CREATE TABLE role (
  role_id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL CHECK (name <> '')
);

INSERT INTO role (name) VALUES ('MEMBER'), ('LIBRARIAN'), ('ADMIN')
ON CONFLICT DO NOTHING;

-- User
CREATE TABLE "user" (
  user_id BIGSERIAL PRIMARY KEY,
  email CITEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role_id INT NOT NULL REFERENCES role(role_id) ON UPDATE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Publisher
CREATE TABLE publisher (
  publisher_id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL CHECK (name <> '')
);

-- Category
CREATE TABLE category (
  category_id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL CHECK (name <> '')
);

-- Author
CREATE TABLE author (
  author_id BIGSERIAL PRIMARY KEY,
  full_name TEXT NOT NULL
);

-- Books
CREATE TABLE book (
  book_id BIGSERIAL PRIMARY KEY,
  isbn13 CHAR(13) UNIQUE NOT NULL,
  title TEXT NOT NULL,
  subtitle TEXT,
  edition TEXT, -- z.B. "2. Auflage"
  published_year INT CHECK (published_year BETWEEN 1400 AND EXTRACT(YEAR FROM now())::INT + 1),
  category_id INT NOT NULL REFERENCES category(category_id) ON UPDATE CASCADE,
  publisher_id INT REFERENCES publisher(publisher_id) ON UPDATE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- n:m Book–Author
CREATE TABLE book_author (
  book_id BIGINT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
  author_id BIGINT NOT NULL REFERENCES author(author_id) ON DELETE RESTRICT,
  author_order INT NOT NULL DEFAULT 1,
  PRIMARY KEY (book_id, author_id)
);

-- Book Copy
CREATE TABLE book_copy (
  copy_id BIGSERIAL PRIMARY KEY,
  book_id BIGINT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
  inventory_code TEXT UNIQUE NOT NULL,    -- Bibliotheks-Code/Barcode
  location TEXT NOT NULL DEFAULT 'MAIN',  -- Standort
  condition_note TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE -- aus dem Bestand genommen?
);

-- Loan
CREATE TABLE loan (
  loan_id BIGSERIAL PRIMARY KEY,
  copy_id BIGINT NOT NULL REFERENCES book_copy(copy_id) ON UPDATE CASCADE,
  user_id BIGINT NOT NULL REFERENCES "user"(user_id) ON UPDATE CASCADE,
  loaned_at DATE NOT NULL DEFAULT CURRENT_DATE,
  due_at DATE NOT NULL,                   -- Fälligkeitsdatum
  returned_at DATE,                       -- wenn NULL => aktiv
  CHECK (due_at >= loaned_at)
);

-- Unique: One copy must only have one *active* loan
CREATE UNIQUE INDEX uniq_active_loan_per_copy
ON loan (copy_id)
WHERE returned_at IS NULL;

-- Reservations (queue)
CREATE TABLE reservation (
  reservation_id BIGSERIAL PRIMARY KEY,
  book_id BIGINT NOT NULL REFERENCES book(book_id) ON UPDATE CASCADE,
  user_id BIGINT NOT NULL REFERENCES "user"(user_id) ON UPDATE CASCADE,
  reserved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  position INT NOT NULL, -- 1 = als nächstes
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Just one unique active reservation
CREATE UNIQUE INDEX uniq_active_reservation
ON reservation (book_id, user_id)
WHERE is_active;

-- Unique queue position
CREATE UNIQUE INDEX uniq_queue_position
ON reservation (book_id, position)
WHERE is_active;

-- Index
CREATE INDEX idx_book_title ON book USING gin (to_tsvector('simple', title));
CREATE INDEX idx_author_name ON author (full_name);
CREATE INDEX idx_copy_book ON book_copy (book_id);
CREATE INDEX idx_loan_user_active ON loan (user_id) WHERE returned_at IS NULL;