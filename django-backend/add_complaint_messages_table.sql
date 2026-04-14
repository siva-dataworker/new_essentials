-- Add complaint_messages table for chat-like responses
CREATE TABLE IF NOT EXISTS complaint_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_complaint_messages_complaint ON complaint_messages(complaint_id);
CREATE INDEX IF NOT EXISTS idx_complaint_messages_sender ON complaint_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_complaint_messages_created ON complaint_messages(created_at);

-- Add comment
COMMENT ON TABLE complaint_messages IS 'Stores chat-like messages/responses for complaints between clients and builders/architects';
