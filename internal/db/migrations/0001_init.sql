-- init schema (no DOWN section)
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS events (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  type TEXT NOT NULL,
  occurred_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS users_email_uq ON users(email);
CREATE INDEX IF NOT EXISTS events_user_occurred_idx ON events(user_id, occurred_at);

-- seed
INSERT INTO users (name,email)
VALUES ('Alice','alice@example.com') ON CONFLICT DO NOTHING;
