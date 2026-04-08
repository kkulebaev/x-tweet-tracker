-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateTable
CREATE TABLE "accounts" (
    "id" TEXT NOT NULL,
    "x_username" TEXT NOT NULL,
    "x_user_id" TEXT,
    "since_id" TEXT,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tweets" (
    "tweet_id" TEXT NOT NULL,
    "account_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL,
    "text" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "raw" JSONB,
    "fetched_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "claimed_at" TIMESTAMP(3),
    "sent_to_telegram_at" TIMESTAMP(3),

    CONSTRAINT "tweets_pkey" PRIMARY KEY ("tweet_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "accounts_x_username_key" ON "accounts"("x_username");

-- CreateIndex
CREATE UNIQUE INDEX "accounts_x_user_id_key" ON "accounts"("x_user_id");

-- CreateIndex
CREATE INDEX "tweets_account_id_created_at_idx" ON "tweets"("account_id", "created_at");

-- CreateIndex
CREATE INDEX "tweets_sent_to_telegram_at_created_at_idx" ON "tweets"("sent_to_telegram_at", "created_at");

-- AddForeignKey
ALTER TABLE "tweets" ADD CONSTRAINT "tweets_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

