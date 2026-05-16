-- ============================================================
-- Push Notification Tables Migration
-- Run this once against the Supabase PostgreSQL database.
-- ============================================================

-- 1. Device tokens — stores one or more FCM tokens per user
--    (admin registers their device; old token is replaced on re-login)
CREATE TABLE IF NOT EXISTS device_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fcm_token   TEXT NOT NULL,
    platform    VARCHAR(20) NOT NULL DEFAULT 'android',   -- 'android' | 'ios'
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_token UNIQUE (user_id, fcm_token)
);

-- Index for quick admin-token lookups
CREATE INDEX IF NOT EXISTS idx_device_tokens_user
    ON device_tokens (user_id);

-- Auto-update updated_at on upsert
CREATE OR REPLACE FUNCTION update_device_token_timestamp()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_device_tokens_updated ON device_tokens;
CREATE TRIGGER trg_device_tokens_updated
    BEFORE UPDATE ON device_tokens
    FOR EACH ROW EXECUTE FUNCTION update_device_token_timestamp();


-- 2. Guest check-ins — mirrors the SharedPreferences store on the server
--    so the admin can see them even across devices.
CREATE TABLE IF NOT EXISTS guest_checkins (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guest_name   VARCHAR(200) NOT NULL,
    guest_phone  VARCHAR(20)  NOT NULL,
    ref          VARCHAR(20)  NOT NULL,
    purpose      TEXT,
    checkin_time TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_guest_checkins_time
    ON guest_checkins (checkin_time DESC);
