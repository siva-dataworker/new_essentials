#!/usr/bin/env python
"""
Create site_engineer_documents table
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.database import execute_query

def create_site_engineer_documents_table():
    """Create site_engineer_documents table"""
    
    sql = """
    CREATE TABLE IF NOT EXISTS site_engineer_documents (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
        site_engineer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        document_type VARCHAR(50) NOT NULL,
        title VARCHAR(200) NOT NULL,
        description TEXT,
        file_url VARCHAR(500) NOT NULL,
        file_name VARCHAR(200) NOT NULL,
        file_size INTEGER,
        upload_date DATE NOT NULL DEFAULT CURRENT_DATE,
        uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        day_of_week VARCHAR(10) NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    )
    """
    
    try:
        execute_query(sql)
        print("✅ site_engineer_documents table created successfully!")
        
        # Create indexes
        indexes = [
            "CREATE INDEX IF NOT EXISTS idx_site_engineer_documents_site_id ON site_engineer_documents(site_id)",
            "CREATE INDEX IF NOT EXISTS idx_site_engineer_documents_engineer_id ON site_engineer_documents(site_engineer_id)",
            "CREATE INDEX IF NOT EXISTS idx_site_engineer_documents_upload_date ON site_engineer_documents(upload_date)",
            "CREATE INDEX IF NOT EXISTS idx_site_engineer_documents_document_type ON site_engineer_documents(document_type)",
        ]
        
        for idx_sql in indexes:
            execute_query(idx_sql)
        
        print("✅ Indexes created successfully!")
        
    except Exception as e:
        print(f"❌ Error creating table: {e}")

if __name__ == '__main__':
    create_site_engineer_documents_table()
