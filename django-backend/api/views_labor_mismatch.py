"""
Labor Entry Mismatch Detection API
Compares labor entries from Supervisors and Site Engineers
"""
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .authentication import JWTAuthentication
from .database import fetch_all
from datetime import datetime, timedelta

@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def detect_labor_mismatches(request):
    """
    Accountant: Detect mismatches between Supervisor and Site Engineer labor entries
    GET /api/construction/labor-mismatches/
    Query params:
    - site_id (optional): Filter by specific site
    - days (optional): Number of days to check (default: 7)
    """
    try:
        user_role = request.user.get('role')
        
        if user_role != 'Accountant':
            return Response({'error': 'Only accountants can access this endpoint'}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        site_id = request.query_params.get('site_id')
        days = int(request.query_params.get('days', 7))
        
        # Calculate date range
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days)
        
        # Get Supervisor labor entries
        supervisor_query = """
            SELECT 
                l.id,
                l.site_id,
                l.entry_date,
                l.labour_type,
                l.labour_count,
                l.supervisor_id,
                s.site_name,
                s.area,
                s.street,
                u.full_name as supervisor_name,
                l.submitted_by_role
            FROM labour_entries l
            JOIN sites s ON l.site_id = s.id
            JOIN users u ON l.supervisor_id = u.id
            WHERE l.entry_date >= %s AND l.entry_date <= %s
            AND l.submitted_by_role = 'Supervisor'
        """
        
        params = [start_date, end_date]
        
        if site_id:
            supervisor_query += " AND l.site_id = %s"
            params.append(site_id)
        
        supervisor_query += " ORDER BY l.entry_date DESC, l.labour_type"
        
        supervisor_entries = fetch_all(supervisor_query, tuple(params))
        
        # Get Site Engineer labor entries (from same labour_entries table)
        engineer_query = """
            SELECT 
                l.id,
                l.site_id,
                l.entry_date,
                l.labour_type,
                l.labour_count,
                l.supervisor_id as site_engineer_id,
                s.site_name,
                s.area,
                s.street,
                u.full_name as engineer_name,
                l.submitted_by_role
            FROM labour_entries l
            JOIN sites s ON l.site_id = s.id
            JOIN users u ON l.supervisor_id = u.id
            WHERE l.entry_date >= %s AND l.entry_date <= %s
            AND l.submitted_by_role = 'Site Engineer'
        """
        
        params = [start_date, end_date]
        
        if site_id:
            engineer_query += " AND l.site_id = %s"
            params.append(site_id)
        
        engineer_query += " ORDER BY l.entry_date DESC, l.labour_type"
        
        engineer_entries = fetch_all(engineer_query, tuple(params))
        
        # Detect mismatches
        mismatches = []
        mismatch_summary = {}
        
        # Group entries by site_id, date, and labour_type
        supervisor_map = {}
        for entry in supervisor_entries:
            key = f"{entry['site_id']}_{entry['entry_date']}_{entry['labour_type']}"
            supervisor_map[key] = entry
        
        engineer_map = {}
        for entry in engineer_entries:
            key = f"{entry['site_id']}_{entry['entry_date']}_{entry['labour_type']}"
            engineer_map[key] = entry
        
        # Find mismatches
        all_keys = set(supervisor_map.keys()) | set(engineer_map.keys())
        
        for key in all_keys:
            supervisor_entry = supervisor_map.get(key)
            engineer_entry = engineer_map.get(key)
            
            site_id_key, date_str, labour_type = key.split('_', 2)
            
            # Case 1: Entry exists in both but counts don't match
            if supervisor_entry and engineer_entry:
                if supervisor_entry['labour_count'] != engineer_entry['labour_count']:
                    mismatch = {
                        'site_id': site_id_key,
                        'site_name': supervisor_entry['site_name'],
                        'area': supervisor_entry['area'],
                        'street': supervisor_entry['street'],
                        'entry_date': date_str,
                        'labour_type': labour_type,
                        'mismatch_type': 'COUNT_DIFFERENCE',
                        'supervisor_count': int(supervisor_entry['labour_count']),
                        'engineer_count': int(engineer_entry['labour_count']),
                        'difference': abs(int(supervisor_entry['labour_count']) - int(engineer_entry['labour_count'])),
                        'supervisor_name': supervisor_entry['supervisor_name'],
                        'engineer_name': engineer_entry['engineer_name'],
                        'supervisor_entry_id': str(supervisor_entry['id']),
                        'engineer_entry_id': str(engineer_entry['id']),
                    }
                    mismatches.append(mismatch)
                    
                    # Add to summary
                    if site_id_key not in mismatch_summary:
                        mismatch_summary[site_id_key] = {
                            'site_name': supervisor_entry['site_name'],
                            'total_mismatches': 0,
                            'dates_with_mismatches': set(),
                        }
                    mismatch_summary[site_id_key]['total_mismatches'] += 1
                    mismatch_summary[site_id_key]['dates_with_mismatches'].add(date_str)
            
            # Case 2: Entry only in Supervisor
            elif supervisor_entry and not engineer_entry:
                mismatch = {
                    'site_id': site_id_key,
                    'site_name': supervisor_entry['site_name'],
                    'area': supervisor_entry['area'],
                    'street': supervisor_entry['street'],
                    'entry_date': date_str,
                    'labour_type': labour_type,
                    'mismatch_type': 'MISSING_ENGINEER_ENTRY',
                    'supervisor_count': int(supervisor_entry['labour_count']),
                    'engineer_count': 0,
                    'difference': int(supervisor_entry['labour_count']),
                    'supervisor_name': supervisor_entry['supervisor_name'],
                    'engineer_name': None,
                    'supervisor_entry_id': str(supervisor_entry['id']),
                    'engineer_entry_id': None,
                }
                mismatches.append(mismatch)
                
                # Add to summary
                if site_id_key not in mismatch_summary:
                    mismatch_summary[site_id_key] = {
                        'site_name': supervisor_entry['site_name'],
                        'total_mismatches': 0,
                        'dates_with_mismatches': set(),
                    }
                mismatch_summary[site_id_key]['total_mismatches'] += 1
                mismatch_summary[site_id_key]['dates_with_mismatches'].add(date_str)
            
            # Case 3: Entry only in Site Engineer
            elif engineer_entry and not supervisor_entry:
                mismatch = {
                    'site_id': site_id_key,
                    'site_name': engineer_entry['site_name'],
                    'area': engineer_entry['area'],
                    'street': engineer_entry['street'],
                    'entry_date': date_str,
                    'labour_type': labour_type,
                    'mismatch_type': 'MISSING_SUPERVISOR_ENTRY',
                    'supervisor_count': 0,
                    'engineer_count': int(engineer_entry['labour_count']),
                    'difference': int(engineer_entry['labour_count']),
                    'supervisor_name': None,
                    'engineer_name': engineer_entry['engineer_name'],
                    'supervisor_entry_id': None,
                    'engineer_entry_id': str(engineer_entry['id']),
                }
                mismatches.append(mismatch)
                
                # Add to summary
                if site_id_key not in mismatch_summary:
                    mismatch_summary[site_id_key] = {
                        'site_name': engineer_entry['site_name'],
                        'total_mismatches': 0,
                        'dates_with_mismatches': set(),
                    }
                mismatch_summary[site_id_key]['total_mismatches'] += 1
                mismatch_summary[site_id_key]['dates_with_mismatches'].add(date_str)
        
        # Convert summary to list format
        summary_list = []
        for site_id_key, data in mismatch_summary.items():
            summary_list.append({
                'site_id': site_id_key,
                'site_name': data['site_name'],
                'total_mismatches': data['total_mismatches'],
                'dates_with_mismatches': sorted(list(data['dates_with_mismatches']), reverse=True),
                'has_critical_mismatches': data['total_mismatches'] > 0,
            })
        
        return Response({
            'mismatches': mismatches,
            'summary': summary_list,
            'total_mismatches': len(mismatches),
            'date_range': {
                'start_date': start_date.isoformat(),
                'end_date': end_date.isoformat(),
                'days': days,
            },
            'message': f'Found {len(mismatches)} labor entry mismatches',
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"❌ Error detecting labor mismatches: {e}")
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
