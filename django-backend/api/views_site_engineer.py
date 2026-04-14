"""
Site Engineer Views
Handles all Site Engineer related operations
"""
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db import connection
from datetime import datetime, date, time
import os
from .authentication import JWTAuthentication


def dict_fetchall(cursor):
    """Return all rows from a cursor as a dict"""
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def dict_fetchone(cursor):
    """Return one row from a cursor as a dict"""
    row = cursor.fetchone()
    if row is None:
        return None
    columns = [col[0] for col in cursor.description]
    return dict(zip(columns, row))


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_assigned_sites(request):
    """Get sites assigned to the logged-in site engineer"""
    user_id = request.user.get('user_id')
    
    try:
        with connection.cursor() as cursor:
            # Get sites assigned to this engineer
            # For now, return all sites (you can add assignment logic later)
            cursor.execute("""
                SELECT 
                    s.id as site_id,
                    s.site_name,
                    s.customer_name as location,
                    CONCAT(s.site_name, ' - ', COALESCE(s.customer_name, '')) as display_name,
                    s.area,
                    s.street,
                    s.created_at
                FROM sites s
                WHERE s.id IS NOT NULL AND s.site_name IS NOT NULL AND s.site_name != ''
                ORDER BY s.site_name
            """)
            
            sites = dict_fetchall(cursor)
            
            return Response({
                'success': True,
                'sites': sites
            })
            
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_daily_status(request, site_id):
    """Get daily status for a site (morning/evening updates done)"""
    user_id = request.user.get('user_id')
    today = date.today()
    
    try:
        with connection.cursor() as cursor:
            # Check if morning update (WORK_STARTED) is done today
            cursor.execute("""
                SELECT COUNT(*) as count
                FROM work_activity wa
                JOIN daily_site_report dsr ON wa.report_id = dsr.report_id
                WHERE dsr.site_id = %s
                AND dsr.report_date = %s
                AND wa.activity_type = 'WORK_STARTED'
                AND wa.uploaded_by = %s
            """, [str(site_id), today, str(user_id)])
            
            morning_result = dict_fetchone(cursor)
            morning_done = morning_result['count'] > 0 if morning_result else False
            
            # Check if evening update (WORK_COMPLETED) is done today
            cursor.execute("""
                SELECT COUNT(*) as count
                FROM work_activity wa
                JOIN daily_site_report dsr ON wa.report_id = dsr.report_id
                WHERE dsr.site_id = %s
                AND dsr.report_date = %s
                AND wa.activity_type = 'WORK_COMPLETED'
                AND wa.uploaded_by = %s
            """, [str(site_id), today, str(user_id)])
            
            evening_result = dict_fetchone(cursor)
            evening_done = evening_result['count'] > 0 if evening_result else False
            
            # Get today's work activities
            cursor.execute("""
                SELECT 
                    wa.activity_id,
                    wa.activity_type,
                    wa.image_path,
                    TO_CHAR(wa.uploaded_at, 'HH12:MI AM') as uploaded_at
                FROM work_activity wa
                JOIN daily_site_report dsr ON wa.report_id = dsr.report_id
                WHERE dsr.site_id = %s
                AND dsr.report_date = %s
                AND wa.uploaded_by = %s
                ORDER BY wa.uploaded_at DESC
            """, [str(site_id), today, str(user_id)])
            
            activities = dict_fetchall(cursor)
            
            return Response({
                'success': True,
                'morning_update_done': morning_done,
                'evening_update_done': evening_done,
                'work_activities': activities
            })
            
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def upload_work_activity(request):
    """Upload work activity photo (morning/evening)"""
    user_id = request.user.get('user_id')
    
    # Get form data
    site_id = request.data.get('site_id')
    activity_type = request.data.get('activity_type')  # WORK_STARTED or WORK_COMPLETED
    notes = request.data.get('notes', '')
    image = request.FILES.get('image')
    
    if not site_id or not activity_type or not image:
        return Response({
            'success': False,
            'error': 'Missing required fields'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    today = date.today()
    
    try:
        with connection.cursor() as cursor:
            # Get or create daily site report
            cursor.execute("""
                SELECT report_id FROM daily_site_report
                WHERE site_id = %s AND report_date = %s
            """, [site_id, today])
            
            report = dict_fetchone(cursor)
            
            if not report:
                # Create new report
                cursor.execute("""
                    INSERT INTO daily_site_report (site_id, report_date, status, created_at)
                    VALUES (%s, %s, 'OPEN', NOW())
                """, [site_id, today])
                report_id = cursor.lastrowid
            else:
                report_id = report['report_id']
            
            # Save image (for now, just save the filename)
            # In production, you'd upload to cloud storage
            image_filename = f"work_{activity_type}_{site_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
            image_path = f"/uploads/work_activities/{image_filename}"
            
            # TODO: Actually save the image file
            # For now, we'll just store the path
            
            # Insert work activity
            cursor.execute("""
                INSERT INTO work_activity 
                (report_id, activity_type, image_path, uploaded_by, uploaded_at)
                VALUES (%s, %s, %s, %s, NOW())
            """, [report_id, activity_type, image_path, user_id])
            
            # Check if it's past 1pm and this is a morning update
            current_time = datetime.now().time()
            deadline = time(13, 0)  # 1:00 PM
            
            if activity_type == 'WORK_STARTED' and current_time > deadline:
                # Send notification to architect and owner
                # TODO: Implement notification system
                pass
            
            return Response({
                'success': True,
                'message': f'{activity_type} uploaded successfully',
                'activity_id': cursor.lastrowid
            })
            
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_complaints(request, site_id):
    """Get complaints for a site"""
    
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    c.complaint_id,
                    c.description,
                    c.status,
                    TO_CHAR(c.created_at, 'DD Mon YYYY HH12:MI AM') as created_at,
                    s.site_name
                FROM complaints c
                JOIN sites s ON c.site_id = s.id
                WHERE c.site_id = %s
                ORDER BY 
                    CASE WHEN c.status = 'OPEN' THEN 0 ELSE 1 END,
                    c.created_at DESC
            """, [str(site_id)])
            
            complaints = dict_fetchall(cursor)
            
            return Response({
                'success': True,
                'complaints': complaints
            })
            
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def upload_complaint_rectification(request):
    """Upload rectification photo for a complaint"""
    user_id = request.user.get('user_id')
    
    # Get form data
    complaint_id = request.data.get('complaint_id')
    notes = request.data.get('notes', '')
    image = request.FILES.get('image')
    
    if not complaint_id or not image:
        return Response({
            'success': False,
            'error': 'Missing required fields'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        with connection.cursor() as cursor:
            # Get complaint details
            cursor.execute("""
                SELECT c.*, dsr.report_id
                FROM complaints c
                LEFT JOIN daily_site_report dsr ON c.site_id = dsr.site_id 
                    AND dsr.report_date = CURDATE()
                WHERE c.complaint_id = %s
            """, [complaint_id])
            
            complaint = dict_fetchone(cursor)
            
            if not complaint:
                return Response({
                    'success': False,
                    'error': 'Complaint not found'
                }, status=status.HTTP_404_NOT_FOUND)
            
            report_id = complaint['report_id']
            
            # If no report for today, create one
            if not report_id:
                cursor.execute("""
                    INSERT INTO daily_site_report (site_id, report_date, status, created_at)
                    VALUES (%s, CURDATE(), 'OPEN', NOW())
                """, [complaint['site_id']])
                report_id = cursor.lastrowid
            
            # Save image
            image_filename = f"rectification_{complaint_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
            image_path = f"/uploads/rectifications/{image_filename}"
            
            # Insert complaint action
            cursor.execute("""
                INSERT INTO complaint_actions 
                (complaint_id, report_id, image_path, resolved_by, status, created_at)
                VALUES (%s, %s, %s, %s, 'RESOLVED', NOW())
            """, [complaint_id, report_id, image_path, user_id])
            
            # Update complaint status
            cursor.execute("""
                UPDATE complaints 
                SET status = 'RESOLVED'
                WHERE complaint_id = %s
            """, [complaint_id])
            
            # TODO: Send notification to client and architect
            
            return Response({
                'success': True,
                'message': 'Rectification uploaded successfully'
            })
            
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def submit_extra_work(request):
    """Submit extra work and labour count"""
    user_id = request.user.get('user_id')
    
    # Get data
    site_id = request.data.get('site_id')
    description = request.data.get('description')
    amount = request.data.get('amount')
    labour_count = request.data.get('labour_count')
    
    if not site_id or not description or not amount:
        return Response({
            'success': False,
            'error': 'Missing required fields'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        with connection.cursor() as cursor:
            # Get site name
            cursor.execute("SELECT site_name FROM sites WHERE id = %s", [str(site_id)])
            site = dict_fetchone(cursor)
            site_name = site['site_name'] if site else f"Site {site_id}"
            
            # Get user name
            cursor.execute("SELECT full_name FROM users WHERE user_id = %s", [str(user_id)])
            user = dict_fetchone(cursor)
            user_name = user['full_name'] if user else "Site Engineer"
            
            # Create WhatsApp message
            whatsapp_message = f"""🏗️ *Extra Work Report*

📍 Site: {site_name}
📝 Description: {description}
💰 Amount: ₹{amount}
"""
            if labour_count:
                whatsapp_message += f"👷 Labour Count: {labour_count}\n"
            
            whatsapp_message += f"\nSubmitted by: {user_name}"
            
            # TODO: Store extra work in database
            # For now, just return success with WhatsApp message
            
            return Response({
                'success': True,
                'message': 'Extra work submitted successfully',
                'whatsapp_message': whatsapp_message
            })
            
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_project_files(request, site_id):
    """Get project files for a site"""
    
    try:
        # TODO: Implement project files table and storage
        # For now, return empty list
        files = []
        
        return Response({
            'success': True,
            'files': files
        })
            
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
