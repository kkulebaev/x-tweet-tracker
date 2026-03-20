-- Add fields for Telegram forwarder queue
ALTER TABLE "tweets"
  ADD COLUMN IF NOT EXISTS "claimed_at" TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS "sent_to_telegram_at" TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS "tweets_sent_to_telegram_at_created_at_idx"
  ON "tweets" ("sent_to_telegram_at", "created_at");
