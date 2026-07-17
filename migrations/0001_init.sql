-- nef-list: one table, that's it
CREATE TABLE IF NOT EXISTS entries (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  pfp TEXT,
  discord TEXT,
  telegram TEXT,
  message TEXT NOT NULL,
  edit_token TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_entries_feed ON entries (created_at DESC, id DESC);
