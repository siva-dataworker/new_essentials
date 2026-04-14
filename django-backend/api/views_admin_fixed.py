"""
Admin-specific views for enhanced features (Fixed for UUID)
"""
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.db import connection
from datetime import datetime, timedelta


def fetch_all(query, params=None):
    """Execute SELECT query and return all results"""
    with connection.cursor() as cursor:
        cursor.execute(query, params or [])
        columns = [col[0] for col in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def fetch_one(query, params=None):
    """Execute SELECT query and return one result"""
    with connection.cursor() as cursor:
        cursor.execute(query, params or [])
        columns = [col[0] for col in cursor.description]
        row = cursor.fetchone()
        return dict(zip(columns, row)) if row else None


def execute_query(query, params=None):
    """Execute INSERT/UPDATE/DELETE query"""
    with connection.cursor() as cursor:
        cursor.execute(query, params or [])


# ============================================
# SITE SELECTION & METRICS
# ============================================

@api_view(['GET'])
def get_all_sites(request):
    """Get all sites for dropdown selection"""
    try:
        sites = fetch_all("""
            SELECT id, site_name, area, street, city, created_at
            FROM sites
            WHERE site_name IS NOT NULL AND site_name != ''
            ORDER BY site_name
        """)
        
        return Response({
            'sites': [
                {
                    'id': str(s['id']),
                    'site_name': s['site_name'],
                    'location': f"{s['area'] or ''} {s['street'] or ''} {s['city'] or ''}".strip() or 'N/A',
                    'created_at': s['created_at'].isoformat() if s['created_at'] else None
                }
                for s in sites
            ]
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"Error in get_all_sites: {e}")
        return Response({
            'error': f'Failed to fetch sites: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
def get_site_metrics(request, site_id):
    """Get metrics for a specific site"""
    try:
        metrics = fetch_one("""
            SELECT s.id, s.site_name, sm.built_up_area, 
                   sm.project_value, sm.total_cost, sm.profit_loss, sm.updated_at
            FROM sites s
            LEFT JOIN site_metrics sm ON s.id = sm.site_id
            WHERE s.id = %s
        """, [site_id])
        
        if not metrics:
            return Response({
                'error': 'Site not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        return Response({
            'id': str(metrics['id']),
            'site_name': metrics['site_name'],
            'built_up_area': float(metrics['built_up_area']) if metrics['built_up_area'] else 0,
            'project_value': float(metrics['project_value']) if metrics['project_value'] else 0,
            'total_cost': float(metrics['total_cost']) if metrics['total_cost'] else 0,
            'profit_loss': float(metrics['profit_loss']) if metrics['profit_loss'] else 0,
            'updated_at': metrics['updated_at'].isoformat() if metrics['updated_at'] else None
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"Error in get_site_metrics: {e}")
        return Response({
            'error': f'Failed to fetch site metrics: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# LABOUR COUNT VIEW
# ============================================

@api_view(['GET'])
def get_labour_count_data(request, site_id):
    """Get labour count data for a site"""
    try:
        data = fetch_all("""
            SELECT le.entry_date as report_date, le.labour_count, 
                   u.full_name as entered_by, le.created_at
            FROM labour_entries le
            LEFT JOIN users u ON le.supervisor_id = u.id
            WHERE le.site_id = %s
            ORDER BY le.entry_date DESC
        """, [site_id])
        
        return Response({
            'labour_data': [
                {
                    'report_date': str(d['report_date']) if d['report_date'] else 'N/A',
                    'labour_count': d['labour_count'],
                    'entered_by': d['entered_by'] or 'Unknown',
                    'created_at': d['created_at'].isoformat() if d['created_at'] else None
                }
                for d in data
            ]
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"Error in get_labour_count_data: {e}")
        return Response({
            'error': f'Failed to fetch labour count: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# BILLS VIEW
# ============================================

@api_view(['GET'])
def get_bills_data(request, site_id):
    """Get bills data for a site"""
    try:
        bills = fetch_all("""
            SELECT mb.id as bill_id, mb.bill_date as report_date, mb.material_type as material_name,
                   mb.total_amount as bill_amount, mb.file_url as bill_image, 
                   mb.payment_status as verified,
                   u.full_name as uploaded_by, mb.created_at
            FROM material_bills mb
            LEFT JOIN users u ON mb.uploaded_by = u.id
            WHERE mb.site_id = %s AND mb.is_active = TRUE
            ORDER BY mb.bill_date DESC, mb.created_at DESC
        """, [site_id])
        
        return Response({
            'bills': [
                {
                    'bill_id': str(b['bill_id']),
                    'report_date': str(b['report_date']) if b['report_date'] else 'N/A',
                    'material_name': b['material_name'] or 'N/A',
                    'bill_amount': float(b['bill_amount']) if b['bill_amount'] else 0,
                    'bill_image': b['bill_image'],
                    'verified': b['verified'] == 'PAID',
                    'uploaded_by': b['uploaded_by'] or 'Unknown',
                    'created_at': b['created_at'].isoformat() if b['created_at'] else None
                }
                for b in bills
            ]
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"Error in get_bills_data: {e}")
        return Response({
            'error': f'Failed to fetch bills: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# FULL ACCOUNTS VIEW (P/L)
# ============================================

@api_view(['GET'])
def get_profit_loss_data(request, site_id):
    """Get complete profit/loss data for a site"""
    try:
        # Get site metrics
        metrics = fetch_one("""
            SELECT s.site_name, sm.built_up_area, sm.project_value, 
                   sm.total_cost, sm.profit_loss
            FROM sites s
            LEFT JOIN site_metrics sm ON s.id = sm.site_id
            WHERE s.id = %s
        """, [site_id])
        
        if not metrics:
            return Response({
                'error': 'Site not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Get labour cost (from labour entries - we don't have salary data, so estimate)
        labour_count = fetch_one("""
            SELECT COALESCE(SUM(le.labour_count), 0) as total_labour
            FROM labour_entries le
            WHERE le.site_id = %s
        """, [site_id])
        
        # Estimate labour cost (assuming ₹500 per labour per day)
        total_labour_cost = (labour_count['total_labour'] or 0) * 500
        
        # Get material cost
        material_cost = fetch_one("""
            SELECT COALESCE(SUM(mb.total_amount), 0) as total_material_cost
            FROM material_bills mb
            WHERE mb.site_id = %s AND mb.is_active = TRUE
        """, [site_id])
        
        return Response({
            'site_name': metrics['site_name'],
            'built_up_area': float(metrics['built_up_area']) if metrics['built_up_area'] else 0,
            'project_value': float(metrics['project_value']) if metrics['project_value'] else 0,
            'total_cost': float(metrics['total_cost']) if metrics['total_cost'] else 0,
            'profit_loss': float(metrics['profit_loss']) if metrics['profit_loss'] else 0,
            'labour_cost': float(total_labour_cost),
            'material_cost': float(material_cost['total_material_cost']) if material_cost else 0
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"Error in get_profit_loss_data: {e}")
        return Response({
            'error': f'Failed to fetch P/L data: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# MATERIAL PURCHASES
# ============================================

@api_view(['GET'])
def get_total_material_purchases(request, site_id):
    """Get total material purchased list for a site"""
    try:
        purchases = fetch_all("""
            SELECT material_type as material_name, 
                   SUM(total_amount) as total_purchased,
                   COUNT(id) as purchase_count
            FROM material_bills
            WHERE site_id = %s AND is_active = TRUE
            GROUP BY material_type
            ORDER BY SUM(total_amount) DESC
        """, [site_id])
        
        return Response({
            'purchases': [
                {
                    'material_name': p['material_name'] or 'Unknown',
                    'total_purchased': float(p['total_purchased']) if p['total_purchased'] else 0,
                    'purchase_count': p['purchase_count']
                }
                for p in purchases
            ]
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"Error in get_total_material_purchases: {e}")
        return Response({
            'error': f'Failed to fetch material purchases: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# SITE DOCUMENTS
# ============================================

@api_view(['GET'])
def get_site_documents(request, site_id):
    """Get all documents for a site"""
    try:
        documents = fetch_all("""
            SELECT id as document_id, document_type, document_name, file_path,
                   u.full_name as uploaded_by, sd.uploaded_at
            FROM site_documents sd
            LEFT JOIN users u ON sd.uploaded_by = u.id
            WHERE sd.site_id = %s
            ORDER BY sd.document_type, sd.uploaded_at DESC
        """, [site_id])
        
        # Group by document type
        grouped = {
            'PLAN': [],
            'ELEVATION': [],
            'STRUCTURE': [],
            'FINAL_OUTPUT': []
        }
        
        for doc in documents:
            doc_type = doc['document_type']
            if doc_type in grouped:
                grouped[doc_type].append({
                    'document_id': str(doc['document_id']),
                    'document_type': doc_type,
                    'document_name': doc['document_name'],
                    'file_path': doc['file_path'],
                    'uploaded_by': doc['uploaded_by'] or 'Unknown',
                    'uploaded_at': doc['uploaded_at'].isoformat() if doc['uploaded_at'] else None
                })
        
        return Response({
            'documents': grouped
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"Error in get_site_documents: {e}")
        return Response({
            'error': f'Failed to fetch documents: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# SITE COMPARISON
# ============================================

@api_view(['POST'])
def compare_sites(request):
    """Compare two sites"""
    try:
        site1_id = request.data.get('site1_id')
        site2_id = request.data.get('site2_id')
        
        if not site1_id or not site2_id:
            return Response({
                'error': 'Both site1_id and site2_id are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Get data for both sites
        sites_data = []
        for site_id in [site1_id, site2_id]:
            site_info = fetch_one("""
                SELECT s.id, s.site_name, sm.built_up_area, sm.project_value, 
                       sm.total_cost, sm.profit_loss
                FROM sites s
                LEFT JOIN site_metrics sm ON s.id = sm.site_id
                WHERE s.id = %s
            """, [site_id])
            
            if not site_info:
                continue
            
            # Get labour count
            labour = fetch_one("""
                SELECT COUNT(DISTINCT id) as total_labour_entries,
                       SUM(labour_count) as total_labour_count
                FROM labour_entries
                WHERE site_id = %s
            """, [site_id])
            
            # Get material cost
            material = fetch_one("""
                SELECT SUM(total_amount) as total_material_cost
                FROM material_bills
                WHERE site_id = %s AND is_active = TRUE
            """, [site_id])
            
            # Get materials breakdown
            materials = fetch_all("""
                SELECT material_type as material_name, SUM(total_amount) as total_purchased
                FROM material_bills
                WHERE site_id = %s AND is_active = TRUE
                GROUP BY material_type
                ORDER BY SUM(total_amount) DESC
            """, [site_id])
            
            sites_data.append({
                'site_id': str(site_info['id']),
                'site_name': site_info['site_name'],
                'built_up_area': float(site_info['built_up_area']) if site_info['built_up_area'] else 0,
                'project_value': float(site_info['project_value']) if site_info['project_value'] else 0,
                'total_cost': float(site_info['total_cost']) if site_info['total_cost'] else 0,
                'profit_loss': float(site_info['profit_loss']) if site_info['profit_loss'] else 0,
                'total_labour_entries': labour['total_labour_entries'] if labour else 0,
                'total_labour_count': labour['total_labour_count'] if labour else 0,
                'total_material_cost': float(material['total_material_cost']) if material and material['total_material_cost'] else 0,
                'materials': [
                    {
                        'material_name': m['material_name'],
                        'total_purchased': float(m['total_purchased']) if m['total_purchased'] else 0
                    }
                    for m in materials
                ]
            })
        
        if len(sites_data) != 2:
            return Response({
                'error': 'One or both sites not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        return Response({
            'site1': sites_data[0],
            'site2': sites_data[1]
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"Error in compare_sites: {e}")
        return Response({
            'error': f'Failed to compare sites: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
