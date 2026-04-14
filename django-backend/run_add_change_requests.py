"""
Add change_requests table to database
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query

print("\n" + "=" * 70)
print("ADDING CHANGE REQUESTS TABLE")
print("=" * 70)

sql = """
CREATE TABLE IF NOT EXISTS change_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Request details
    entry_type VARCHAR(20) NOT NULL CHECK (entry_type IN ('LABOUR', 'MATERIAL')),
    entry_id UUID NOT NULL,
    
    -- Who requested
    requested_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Request content
    request_note TEXT NOT NULL,
    current_value TEXT,
    requested_value TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    
    -- Accountant response
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP,
    accountant_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_change_requests_status ON change_requests(status);
CREATE INDEX IF NOT EXISTS idx_change_requests_requested_by ON change_requests(requested_by);
CREATE INDEX IF NOT EXISTS idx_change_requests_entry ON change_requests(entry_type, entry_id);
"""

try:
    execute_query(sql)
    print("\n✅ change_requests table created successfully!")
    print("=" * 70 + "\n")
except Exception as e:
    print(f"\n❌ Error: {e}")
    print("=" * 70 + "\n")
