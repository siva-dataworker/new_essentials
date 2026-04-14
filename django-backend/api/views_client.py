"""
Client Dashboard APIs
Provides read-only access to site information for clients
"""
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .authentication import JWTAuthentication
from .database import fetch_one, fetch_all
from django.conf import settings


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_client_site_details(request):
    """
    Get comprehensive site details for logged-in client
    GET /api/client/site-details/
    
    Returns:
    - Site information
    - Labour counts (total and recent)
    - Photos uploaded by supervisor
    - Floor designs and agreements (architect documents)
    - Project files (site engineer documents)
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        
        print(f"🔍 CLIENT API DEBUG:")
        print(f"   User ID: {user_id}")
        print(f"   User Role: {user_role}")
        
        # Only clients can access this endpoint
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get assigned sites
        sites = fetch_all("""
            SELECT 
                cs.id as assignment_id,
                cs.site_id,
                cs.assigned_date,
                s.site_name,
                s.customer_name,
                s.area,
                s.street,
                s.status,
                s.created_at
            FROM client_sites cs
            JOIN sites s ON cs.site_id = s.id
            WHERE cs.client_id = %s AND cs.is_active = TRUE
            ORDER BY cs.assigned_date DESC
        """, (user_id,))
        
        print(f"   Sites found: {len(sites) if sites else 0}")
        if sites:
            for site in sites:
                print(f"      - {site.get('customer_name')} {site.get('site_name')}")
        
        if not sites:
            return Response({
                'success': True,
                'message': 'No sites assigned',
                'sites': []
            })
        
        # Get details for each site
        site_details = []
        for site in sites:
            site_id = site['site_id']
            
            # Get labour count summary
            labour_summary = fetch_one("""
                SELECT 
                    COUNT(DISTINCT entry_date) as total_days,
                    SUM(labour_count) as total_labour_count,
                    MAX(entry_date) as last_entry_date
                FROM labour_entries
                WHERE site_id = %s
            """, (site_id,))
            
            # Get recent labour entries (last 7 days)
            recent_labour = fetch_all("""
                SELECT 
                    le.entry_date,
                    le.labour_type,
                    le.labour_count,
                    le.day_of_week,
                    u.full_name as supervisor_name
                FROM labour_entries le
                LEFT JOIN users u ON le.supervisor_id = u.id
                WHERE le.site_id = %s
                ORDER BY le.entry_date DESC
                LIMIT 7
            """, (site_id,))
            
            # Get supervisor photos
            photos = fetch_all("""
                SELECT 
                    sp.id,
                    sp.image_url,
                    sp.time_of_day,
                    sp.description,
                    sp.upload_date,
                    u.full_name as supervisor_name
                FROM site_photos sp
                LEFT JOIN users u ON sp.uploaded_by = u.id
                WHERE sp.site_id = %s
                ORDER BY sp.upload_date DESC
                LIMIT 20
            """, (site_id,))
            
            # Get architect documents (floor plans, agreements)
            architect_docs = fetch_all("""
                SELECT 
                    ad.id,
                    ad.document_type,
                    ad.title,
                    ad.description,
                    ad.file_url,
                    ad.file_name,
                    ad.file_size,
                    ad.upload_date,
                    u.full_name as architect_name
                FROM architect_documents ad
                LEFT JOIN users u ON ad.architect_id = u.id
                WHERE ad.site_id = %s AND ad.is_active = TRUE
                ORDER BY ad.upload_date DESC
            """, (site_id,))
            
            # Get site engineer documents (project files)
            engineer_docs = fetch_all("""
                SELECT 
                    sed.id,
                    sed.document_type,
                    sed.title,
                    sed.description,
                    sed.file_url,
                    sed.file_name,
                    sed.file_size,
                    sed.upload_date,
                    u.full_name as engineer_name
                FROM site_engineer_documents sed
                LEFT JOIN users u ON sed.engineer_id = u.id
                WHERE sed.site_id = %s AND sed.is_active = TRUE
                ORDER BY sed.upload_date DESC
            """, (site_id,))
            
            # Get extra requirements/costs
            extra_costs = fetch_all("""
                SELECT 
                    le.extra_cost,
                    le.extra_cost_notes,
                    le.entry_date
                FROM labour_entries le
                WHERE le.site_id = %s AND le.extra_cost > 0
                ORDER BY le.entry_date DESC
            """, (site_id,))
            
            total_extra_cost = sum(float(ec['extra_cost'] or 0) for ec in extra_costs)
            
            # Format site details
            site_name = site.get('site_name') or ''
            customer_name = site.get('customer_name') or ''
            display_name = f"{customer_name} {site_name}" if customer_name and site_name else (customer_name or site_name or f"Site {str(site_id)[:8]}")
            
            site_details.append({
                'site_id': str(site_id),
                'site_name': site_name,
                'customer_name': customer_name,
                'display_name': display_name,
                'area': site.get('area') or '',
                'street': site.get('street') or '',
                'status': site.get('status') or 'ACTIVE',
                'assigned_date': site['assigned_date'].strftime('%Y-%m-%d') if site.get('assigned_date') else None,
                'created_at': site['created_at'].strftime('%Y-%m-%d') if site.get('created_at') else None,
                
                # Labour summary
                'labour_summary': {
                    'total_days': labour_summary['total_days'] or 0,
                    'total_labour_count': labour_summary['total_labour_count'] or 0,
                    'last_entry_date': labour_summary['last_entry_date'].strftime('%Y-%m-%d') if labour_summary.get('last_entry_date') else None,
                },
                
                # Recent labour entries
                'recent_labour': [
                    {
                        'entry_date': le['entry_date'].strftime('%Y-%m-%d'),
                        'labour_type': le['labour_type'],
                        'labour_count': le['labour_count'],
                        'day_of_week': le['day_of_week'],
                        'supervisor_name': le.get('supervisor_name') or 'Unknown',
                    }
                    for le in recent_labour
                ],
                
                # Photos
                'photos': [
                    {
                        'id': str(p['id']),
                        'photo_url': p['image_url'] if p['image_url'].startswith(('http', '/media/', '/')) else f"{settings.MEDIA_URL}{p['image_url']}",
                        'time_of_day': p['time_of_day'],
                        'description': p.get('description') or '',
                        'uploaded_date': p['upload_date'].strftime('%Y-%m-%d') if p.get('upload_date') else None,
                        'supervisor_name': p.get('supervisor_name') or 'Unknown',
                    }
                    for p in photos
                ],
                
                # Architect documents (floor plans, agreements)
                'architect_documents': [
                    {
                        'id': str(d['id']),
                        'document_type': d['document_type'],
                        'title': d['title'],
                        'description': d.get('description') or '',
                        'file_url': d['file_url'] if d['file_url'].startswith(('http', '/media/', '/')) else f"{settings.MEDIA_URL}{d['file_url']}",
                        'file_name': d['file_name'],
                        'file_size': d.get('file_size'),
                        'upload_date': d['upload_date'].strftime('%Y-%m-%d') if d.get('upload_date') else None,
                        'architect_name': d.get('architect_name') or 'Unknown',
                    }
                    for d in architect_docs
                ],
                
                # Site engineer documents (project files)
                'engineer_documents': [
                    {
                        'id': str(d['id']),
                        'document_type': d['document_type'],
                        'title': d['title'],
                        'description': d.get('description') or '',
                        'file_url': d['file_url'] if d['file_url'].startswith(('http', '/media/', '/')) else f"{settings.MEDIA_URL}{d['file_url']}",
                        'file_name': d['file_name'],
                        'file_size': d.get('file_size'),
                        'upload_date': d['upload_date'].strftime('%Y-%m-%d') if d.get('upload_date') else None,
                        'engineer_name': d.get('engineer_name') or 'Unknown',
                    }
                    for d in engineer_docs
                ],
                
                # Extra costs
                'extra_requirements': {
                    'total_amount': total_extra_cost,
                    'entries': [
                        {
                            'amount': float(ec['extra_cost'] or 0),
                            'notes': ec.get('extra_cost_notes') or '',
                            'date': ec['entry_date'].strftime('%Y-%m-%d') if ec.get('entry_date') else None,
                        }
                        for ec in extra_costs
                    ]
                },
            })
        
        return Response({
            'success': True,
            'sites': site_details,
            'count': len(site_details),
        })
        
    except Exception as e:
        print(f"Error fetching client site details: {e}")
        import traceback
        traceback.print_exc()
        return Response({
            'error': f'Error fetching site details: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_client_labour_summary(request):
    """
    Get labour count summary for client's sites
    GET /api/client/labour-summary/?site_id=xxx
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        site_id = request.query_params.get('site_id')
        
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        if not site_id:
            return Response({
                'error': 'site_id is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Verify client has access to this site
        site_access = fetch_one("""
            SELECT id FROM client_sites
            WHERE client_id = %s AND site_id = %s AND is_active = TRUE
        """, (user_id, site_id))
        
        if not site_access:
            return Response({
                'error': 'You do not have access to this site'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get labour entries grouped by date
        labour_entries = fetch_all("""
            SELECT 
                le.entry_date,
                le.labour_type,
                le.labour_count,
                le.day_of_week,
                le.notes,
                u.full_name as supervisor_name
            FROM labour_entries le
            LEFT JOIN users u ON le.supervisor_id = u.id
            WHERE le.site_id = %s
            ORDER BY le.entry_date DESC, le.labour_type
        """, (site_id,))
        
        # Get summary statistics
        summary = fetch_one("""
            SELECT 
                COUNT(DISTINCT entry_date) as total_days,
                SUM(labour_count) as total_labour,
                AVG(labour_count) as avg_labour_per_day,
                MAX(entry_date) as last_entry_date,
                MIN(entry_date) as first_entry_date
            FROM labour_entries
            WHERE site_id = %s
        """, (site_id,))
        
        return Response({
            'success': True,
            'summary': {
                'total_days': summary['total_days'] or 0,
                'total_labour': summary['total_labour'] or 0,
                'avg_labour_per_day': float(summary['avg_labour_per_day'] or 0),
                'first_entry_date': summary['first_entry_date'].strftime('%Y-%m-%d') if summary.get('first_entry_date') else None,
                'last_entry_date': summary['last_entry_date'].strftime('%Y-%m-%d') if summary.get('last_entry_date') else None,
            },
            'entries': [
                {
                    'entry_date': le['entry_date'].strftime('%Y-%m-%d'),
                    'labour_type': le['labour_type'],
                    'labour_count': le['labour_count'],
                    'day_of_week': le['day_of_week'],
                    'notes': le.get('notes') or '',
                    'supervisor_name': le.get('supervisor_name') or 'Unknown',
                }
                for le in labour_entries
            ],
        })
        
    except Exception as e:
        print(f"Error fetching labour summary: {e}")
        return Response({
            'error': f'Error fetching labour summary: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_client_photos(request):
    """
    Get photos for client's site
    GET /api/client/photos/?site_id=xxx&time_of_day=Morning
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        site_id = request.query_params.get('site_id')
        time_of_day = request.query_params.get('time_of_day')  # Optional filter
        
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        if not site_id:
            return Response({
                'error': 'site_id is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Verify client has access to this site
        site_access = fetch_one("""
            SELECT id FROM client_sites
            WHERE client_id = %s AND site_id = %s AND is_active = TRUE
        """, (user_id, site_id))
        
        if not site_access:
            return Response({
                'error': 'You do not have access to this site'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Build query
        query = """
            SELECT 
                sp.id,
                sp.photo_url,
                sp.time_of_day,
                sp.description,
                sp.uploaded_date,
                sp.day_of_week,
                u.full_name as supervisor_name
            FROM site_photos sp
            LEFT JOIN users u ON sp.supervisor_id = u.id
            WHERE sp.site_id = %s AND sp.is_active = TRUE
        """
        params = [site_id]
        
        if time_of_day:
            query += " AND sp.time_of_day = %s"
            params.append(time_of_day)
        
        query += " ORDER BY sp.uploaded_date DESC"
        
        photos = fetch_all(query, tuple(params))
        
        return Response({
            'success': True,
            'photos': [
                {
                    'id': str(p['id']),
                    'photo_url': f"{settings.MEDIA_URL}{p['photo_url']}" if not p['photo_url'].startswith('http') else p['photo_url'],
                    'time_of_day': p['time_of_day'],
                    'description': p.get('description') or '',
                    'uploaded_date': p['uploaded_date'].strftime('%Y-%m-%d') if p.get('uploaded_date') else None,
                    'day_of_week': p.get('day_of_week') or '',
                    'supervisor_name': p.get('supervisor_name') or 'Unknown',
                }
                for p in photos
            ],
            'count': len(photos),
        })
        
    except Exception as e:
        print(f"Error fetching photos: {e}")
        return Response({
            'error': f'Error fetching photos: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_client_documents(request):
    """
    Get documents for client's site (architect + engineer documents)
    GET /api/client/documents/?site_id=xxx&document_type=FLOOR_PLAN
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        site_id = request.query_params.get('site_id')
        document_type = request.query_params.get('document_type')  # Optional filter
        
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        if not site_id:
            return Response({
                'error': 'site_id is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Verify client has access to this site
        site_access = fetch_one("""
            SELECT id FROM client_sites
            WHERE client_id = %s AND site_id = %s AND is_active = TRUE
        """, (user_id, site_id))
        
        if not site_access:
            return Response({
                'error': 'You do not have access to this site'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get architect documents
        arch_query = """
            SELECT 
                ad.id,
                ad.document_type,
                ad.title,
                ad.description,
                ad.file_url,
                ad.file_name,
                ad.file_size,
                ad.upload_date,
                u.full_name as uploaded_by,
                'Architect' as role
            FROM architect_documents ad
            LEFT JOIN users u ON ad.architect_id = u.id
            WHERE ad.site_id = %s AND ad.is_active = TRUE
        """
        arch_params = [site_id]
        
        if document_type:
            arch_query += " AND ad.document_type = %s"
            arch_params.append(document_type)
        
        arch_query += " ORDER BY ad.upload_date DESC"
        
        architect_docs = fetch_all(arch_query, tuple(arch_params))
        
        # Get site engineer documents
        eng_query = """
            SELECT 
                sed.id,
                sed.document_type,
                sed.title,
                sed.description,
                sed.file_url,
                sed.file_name,
                sed.file_size,
                sed.upload_date,
                u.full_name as uploaded_by,
                'Site Engineer' as role
            FROM site_engineer_documents sed
            LEFT JOIN users u ON sed.engineer_id = u.id
            WHERE sed.site_id = %s AND sed.is_active = TRUE
        """
        eng_params = [site_id]
        
        if document_type:
            eng_query += " AND sed.document_type = %s"
            eng_params.append(document_type)
        
        eng_query += " ORDER BY sed.upload_date DESC"
        
        engineer_docs = fetch_all(eng_query, tuple(eng_params))
        
        # Format documents
        all_docs = []
        
        for d in architect_docs:
            all_docs.append({
                'id': str(d['id']),
                'document_type': d['document_type'],
                'title': d['title'],
                'description': d.get('description') or '',
                'file_url': f"{settings.MEDIA_URL}{d['file_url']}" if not d['file_url'].startswith('http') else d['file_url'],
                'file_name': d['file_name'],
                'file_size': d.get('file_size'),
                'upload_date': d['upload_date'].strftime('%Y-%m-%d') if d.get('upload_date') else None,
                'uploaded_by': d.get('uploaded_by') or 'Unknown',
                'role': d['role'],
            })
        
        for d in engineer_docs:
            all_docs.append({
                'id': str(d['id']),
                'document_type': d['document_type'],
                'title': d['title'],
                'description': d.get('description') or '',
                'file_url': f"{settings.MEDIA_URL}{d['file_url']}" if not d['file_url'].startswith('http') else d['file_url'],
                'file_name': d['file_name'],
                'file_size': d.get('file_size'),
                'upload_date': d['upload_date'].strftime('%Y-%m-%d') if d.get('upload_date') else None,
                'uploaded_by': d.get('uploaded_by') or 'Unknown',
                'role': d['role'],
            })
        
        # Sort by upload date
        all_docs.sort(key=lambda x: x['upload_date'] or '', reverse=True)
        
        return Response({
            'success': True,
            'documents': all_docs,
            'count': len(all_docs),
            'architect_count': len(architect_docs),
            'engineer_count': len(engineer_docs),
        })
        
    except Exception as e:
        print(f"Error fetching documents: {e}")
        return Response({
            'error': f'Error fetching documents: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_client_photos_by_date(request):
    """
    Get photos for client's site grouped by date
    Includes both supervisor photos and site engineer photos
    GET /api/client/photos-by-date/?site_id=xxx&date=YYYY-MM-DD (optional)
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        site_id = request.query_params.get('site_id')
        filter_date = request.query_params.get('date')  # Optional date filter
        
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        if not site_id:
            return Response({
                'error': 'site_id is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Verify client has access to this site
        site_access = fetch_one("""
            SELECT id FROM client_sites
            WHERE client_id = %s AND site_id = %s AND is_active = TRUE
        """, (user_id, site_id))
        
        if not site_access:
            return Response({
                'error': 'You do not have access to this site'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get supervisor photos (from site_photos table)
        supervisor_query = """
            SELECT 
                sp.id,
                sp.image_url as photo_url,
                sp.time_of_day,
                sp.description,
                sp.upload_date as uploaded_date,
                u.full_name as uploaded_by,
                'Supervisor' as uploaded_by_role
            FROM site_photos sp
            LEFT JOIN users u ON sp.uploaded_by = u.id
            WHERE sp.site_id = %s
        """
        supervisor_params = [site_id]
        
        if filter_date:
            supervisor_query += " AND sp.upload_date = %s"
            supervisor_params.append(filter_date)
        
        supervisor_query += " ORDER BY sp.upload_date DESC, sp.time_of_day"
        
        supervisor_photos = fetch_all(supervisor_query, tuple(supervisor_params))
        
        # Get site engineer photos (from work_updates table)
        engineer_query = """
            SELECT 
                wu.id,
                wu.image_url as photo_url,
                CASE 
                    WHEN wu.update_type = 'STARTED' THEN 'Morning'
                    WHEN wu.update_type = 'FINISHED' THEN 'Evening'
                    ELSE wu.update_type
                END as time_of_day,
                wu.description,
                wu.update_date as uploaded_date,
                '' as day_of_week,
                u.full_name as uploaded_by,
                'Site Engineer' as uploaded_by_role
            FROM work_updates wu
            LEFT JOIN users u ON wu.engineer_id = u.id
            WHERE wu.site_id = %s
            AND wu.update_type IN ('STARTED', 'FINISHED')
        """
        engineer_params = [site_id]
        
        if filter_date:
            engineer_query += " AND wu.update_date = %s"
            engineer_params.append(filter_date)
        
        engineer_query += " ORDER BY wu.update_date DESC, wu.update_type"
        
        engineer_photos = fetch_all(engineer_query, tuple(engineer_params))
        
        # Combine and group photos by date
        all_photos = []
        
        # Add supervisor photos
        for photo in supervisor_photos:
            photo_url = photo['photo_url']
            # Don't prepend MEDIA_URL if photo_url already starts with /media/ or is full URL
            if photo_url.startswith('http'):
                full_url = photo_url
            elif photo_url.startswith('/media/'):
                full_url = photo_url  # Already has /media/ prefix
            elif photo_url.startswith('/'):
                full_url = photo_url
            else:
                full_url = f"{settings.MEDIA_URL}{photo_url}"
            
            all_photos.append({
                'id': str(photo['id']),
                'photo_url': full_url,
                'time_of_day': photo['time_of_day'],
                'description': photo.get('description') or '',
                'uploaded_date': photo['uploaded_date'].strftime('%Y-%m-%d') if photo.get('uploaded_date') else None,
                'day_of_week': '',
                'uploaded_by': photo.get('uploaded_by') or 'Unknown',
                'uploaded_by_role': photo['uploaded_by_role'],
            })
        
        # Add engineer photos
        for photo in engineer_photos:
            photo_url = photo['photo_url']
            # Don't prepend MEDIA_URL if photo_url already starts with /media/ or is full URL
            if photo_url.startswith('http'):
                full_url = photo_url
            elif photo_url.startswith('/media/'):
                full_url = photo_url  # Already has /media/ prefix
            elif photo_url.startswith('/'):
                full_url = photo_url
            else:
                full_url = f"{settings.MEDIA_URL}{photo_url}"
            
            all_photos.append({
                'id': str(photo['id']),
                'photo_url': full_url,
                'time_of_day': photo['time_of_day'],
                'description': photo.get('description') or '',
                'uploaded_date': photo['uploaded_date'].strftime('%Y-%m-%d') if photo.get('uploaded_date') else None,
                'day_of_week': '',
                'uploaded_by': photo.get('uploaded_by') or 'Unknown',
                'uploaded_by_role': photo['uploaded_by_role'],
            })
        
        # Group by date
        photos_by_date = {}
        for photo in all_photos:
            date = photo['uploaded_date']
            if date not in photos_by_date:
                photos_by_date[date] = []
            photos_by_date[date].append(photo)
        
        # Sort dates descending
        sorted_dates = sorted(photos_by_date.keys(), reverse=True) if photos_by_date else []
        
        return Response({
            'success': True,
            'photos_by_date': photos_by_date,
            'dates': sorted_dates,
            'total_photos': len(all_photos),
            'supervisor_photos': len(supervisor_photos),
            'engineer_photos': len(engineer_photos),
            'filter_date': filter_date,
        })
        
    except Exception as e:
        print(f"Error fetching photos by date: {e}")
        import traceback
        traceback.print_exc()
        return Response({
            'error': f'Error fetching photos: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_client_materials(request):
    """
    Get material usage summary for client's site
    GET /api/client/materials/?site_id=xxx
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        site_id = request.query_params.get('site_id')
        
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        if not site_id:
            return Response({
                'error': 'site_id is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Verify client has access to this site
        site_access = fetch_one("""
            SELECT id FROM client_sites
            WHERE client_id = %s AND site_id = %s AND is_active = TRUE
        """, (user_id, site_id))
        
        if not site_access:
            return Response({
                'error': 'You do not have access to this site'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get material usage grouped by material type
        materials = fetch_all("""
            SELECT 
                material_type,
                SUM(quantity_used) as total_used,
                unit,
                MAX(usage_date) as last_used_date,
                COUNT(*) as usage_count
            FROM material_usage
            WHERE site_id = %s
            GROUP BY material_type, unit
            ORDER BY material_type
        """, (site_id,))
        
        return Response({
            'success': True,
            'materials': [
                {
                    'material_type': m['material_type'],
                    'total_used': float(m['total_used'] or 0),
                    'unit': m['unit'] or 'units',
                    'last_used_date': m['last_used_date'].strftime('%Y-%m-%d') if m.get('last_used_date') else None,
                    'usage_count': m['usage_count'] or 0,
                }
                for m in materials
            ],
            'count': len(materials),
        })
        
    except Exception as e:
        print(f"Error fetching materials: {e}")
        return Response({
            'error': f'Error fetching materials: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_client_complaints(request):
    """
    Get all complaints/issues raised by the logged-in client
    GET /api/client/complaints/
    
    Query params:
    - site_id (optional): Filter by specific site
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        
        # Only clients can access this endpoint
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        site_id = request.GET.get('site_id')
        
        # Build query based on filters
        if site_id:
            # Verify client has access to this site
            site_access = fetch_one("""
                SELECT id FROM client_sites
                WHERE client_id = %s AND site_id = %s AND is_active = TRUE
            """, (user_id, site_id))
            
            if not site_access:
                return Response({
                    'error': 'You do not have access to this site'
                }, status=status.HTTP_403_FORBIDDEN)
            
            complaints = fetch_all("""
                SELECT 
                    c.id,
                    c.site_id,
                    s.site_name,
                    c.title,
                    c.description,
                    c.status,
                    c.priority,
                    c.created_at,
                    c.resolved_at,
                    c.resolution_notes,
                    c.proof_image_url,
                    u_assigned.full_name as assigned_to_name,
                    u_assigned.role_id as assigned_to_role
                FROM complaints c
                LEFT JOIN sites s ON c.site_id = s.id
                LEFT JOIN users u_assigned ON c.assigned_to = u_assigned.id
                WHERE c.raised_by = %s AND c.site_id = %s
                ORDER BY c.created_at DESC
            """, (user_id, site_id))
        else:
            # Get complaints from all assigned sites
            complaints = fetch_all("""
                SELECT 
                    c.id,
                    c.site_id,
                    s.site_name,
                    c.title,
                    c.description,
                    c.status,
                    c.priority,
                    c.created_at,
                    c.resolved_at,
                    c.resolution_notes,
                    c.proof_image_url,
                    u_assigned.full_name as assigned_to_name,
                    u_assigned.role_id as assigned_to_role
                FROM complaints c
                LEFT JOIN sites s ON c.site_id = s.id
                LEFT JOIN users u_assigned ON c.assigned_to = u_assigned.id
                WHERE c.raised_by = %s 
                    AND c.site_id IN (
                        SELECT site_id FROM client_sites 
                        WHERE client_id = %s AND is_active = TRUE
                    )
                ORDER BY c.created_at DESC
            """, (user_id, user_id))
        
        # Format response
        complaints_list = []
        for complaint in complaints:
            # Handle image URL
            image_url = complaint.get('proof_image_url')
            if image_url:
                if not image_url.startswith(('http', '/media/', '/')):
                    image_url = f"{settings.MEDIA_URL}{image_url}"
            
            complaints_list.append({
                'id': str(complaint['id']),
                'site_id': str(complaint['site_id']),
                'site_name': complaint['site_name'],
                'title': complaint['title'],
                'description': complaint.get('description') or '',
                'status': complaint['status'],
                'priority': complaint['priority'],
                'created_at': complaint['created_at'].isoformat() if complaint.get('created_at') else None,
                'resolved_at': complaint['resolved_at'].isoformat() if complaint.get('resolved_at') else None,
                'resolution_notes': complaint.get('resolution_notes') or '',
                'proof_image_url': image_url,
                'assigned_to_name': complaint.get('assigned_to_name'),
                'assigned_to_role': complaint.get('assigned_to_role'),
            })
        
        return Response({
            'success': True,
            'complaints': complaints_list,
            'total_count': len(complaints_list)
        })
        
    except Exception as e:
        print(f"❌ Error in get_client_complaints: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response({
            'error': f'Failed to fetch complaints: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def create_client_complaint(request):
    """
    Create a new complaint/issue by client
    POST /api/client/complaints/create/
    
    Body:
    - site_id (required): UUID of the site
    - title (required): Brief title of the issue
    - description (optional): Detailed description
    - priority (optional): LOW, MEDIUM, HIGH, URGENT (default: MEDIUM)
    - proof_image_url (optional): URL/path to proof image
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        
        # Only clients can access this endpoint
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get request data
        site_id = request.data.get('site_id')
        title = request.data.get('title', '').strip()
        description = request.data.get('description', '').strip()
        priority = request.data.get('priority', 'MEDIUM').upper()
        proof_image_url = request.data.get('proof_image_url', '').strip()
        
        # Validate required fields
        if not site_id:
            return Response({
                'error': 'site_id is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not title:
            return Response({
                'error': 'title is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate priority
        if priority not in ['LOW', 'MEDIUM', 'HIGH', 'URGENT']:
            priority = 'MEDIUM'
        
        # Verify client has access to this site
        site_access = fetch_one("""
            SELECT id FROM client_sites
            WHERE client_id = %s AND site_id = %s AND is_active = TRUE
        """, (user_id, site_id))
        
        if not site_access:
            return Response({
                'error': 'You do not have access to this site'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get architect for this site (to assign complaint to)
        architect = fetch_one("""
            SELECT id FROM users
            WHERE role_id = 6 AND is_active = TRUE
            LIMIT 1
        """)
        
        assigned_to = architect['id'] if architect else None
        
        # Create complaint
        complaint = fetch_one("""
            INSERT INTO complaints (
                site_id,
                raised_by,
                assigned_to,
                title,
                description,
                status,
                priority,
                proof_image_url,
                created_at
            ) VALUES (%s, %s, %s, %s, %s, 'OPEN', %s, %s, CURRENT_TIMESTAMP)
            RETURNING id, created_at
        """, (site_id, user_id, assigned_to, title, description, priority, proof_image_url or None))
        
        return Response({
            'success': True,
            'message': 'Complaint created successfully',
            'complaint': {
                'id': str(complaint['id']),
                'site_id': site_id,
                'title': title,
                'description': description,
                'status': 'OPEN',
                'priority': priority,
                'created_at': complaint['created_at'].isoformat(),
                'proof_image_url': proof_image_url or None
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        print(f"❌ Error in create_client_complaint: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response({
            'error': f'Failed to create complaint: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_complaint_messages(request, complaint_id):
    """
    Get all messages for a specific complaint
    GET /api/client/complaints/<complaint_id>/messages/
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        
        # Only clients can access this endpoint
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Verify client owns this complaint
        complaint = fetch_one("""
            SELECT c.id, c.site_id, c.title
            FROM complaints c
            WHERE c.id = %s AND c.raised_by = %s
        """, (complaint_id, user_id))
        
        if not complaint:
            return Response({
                'error': 'Complaint not found or access denied'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Get all messages for this complaint
        messages = fetch_all("""
            SELECT 
                cm.id,
                cm.message,
                cm.created_at,
                cm.is_read,
                u.id as sender_id,
                u.full_name as sender_name,
                u.role_id as sender_role_id,
                r.role_name as sender_role
            FROM complaint_messages cm
            LEFT JOIN users u ON cm.sender_id = u.id
            LEFT JOIN roles r ON u.role_id = r.id
            WHERE cm.complaint_id = %s
            ORDER BY cm.created_at ASC
        """, (complaint_id,))
        
        # Format messages
        messages_list = []
        for msg in messages:
            messages_list.append({
                'id': str(msg['id']),
                'message': msg['message'],
                'created_at': msg['created_at'].isoformat() if msg.get('created_at') else None,
                'is_read': msg.get('is_read', False),
                'sender': {
                    'id': str(msg['sender_id']),
                    'name': msg['sender_name'],
                    'role': msg['sender_role'],
                    'role_id': msg['sender_role_id'],
                },
                'is_own_message': str(msg['sender_id']) == str(user_id)
            })
        
        return Response({
            'success': True,
            'complaint': {
                'id': str(complaint['id']),
                'title': complaint['title'],
            },
            'messages': messages_list,
            'total_count': len(messages_list)
        })
        
    except Exception as e:
        print(f"❌ Error in get_complaint_messages: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response({
            'error': f'Failed to fetch messages: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def send_complaint_message(request, complaint_id):
    """
    Send a message/response to a complaint
    POST /api/client/complaints/<complaint_id>/messages/
    
    Body:
    - message (required): The message text
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        
        # Only clients can access this endpoint
        if user_role.lower() != 'client':
            return Response({
                'error': 'This endpoint is only for clients'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get message from request
        message = request.data.get('message', '').strip()
        
        if not message:
            return Response({
                'error': 'message is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Verify client owns this complaint
        complaint = fetch_one("""
            SELECT c.id, c.site_id
            FROM complaints c
            WHERE c.id = %s AND c.raised_by = %s
        """, (complaint_id, user_id))
        
        if not complaint:
            return Response({
                'error': 'Complaint not found or access denied'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Insert message
        new_message = fetch_one("""
            INSERT INTO complaint_messages (
                complaint_id,
                sender_id,
                message,
                created_at,
                is_read
            ) VALUES (%s, %s, %s, CURRENT_TIMESTAMP, FALSE)
            RETURNING id, created_at
        """, (complaint_id, user_id, message))
        
        return Response({
            'success': True,
            'message': {
                'id': str(new_message['id']),
                'complaint_id': complaint_id,
                'message': message,
                'created_at': new_message['created_at'].isoformat(),
                'is_own_message': True
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        print(f"❌ Error in send_complaint_message: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response({
            'error': f'Failed to send message: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
