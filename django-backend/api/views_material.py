"""
Material Inventory Management Views
Handles material stock, usage tracking, and balance calculations
"""

from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.db import connection
from datetime import datetime, date
import uuid

from .authentication import JWTAuthentication


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_material_stock(request):
    """Get material stock for a specific site"""
    site_id = request.GET.get('site_id')
    
    if not site_id:
        return Response({
            'success': False,
            'message': 'site_id is required'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    ms.id,
                    ms.site_id,
                    s.site_name,
                    s.customer_name,
                    ms.material_type,
                    ms.total_quantity,
                    ms.unit,
                    ms.last_updated,
                    ms.notes
                FROM material_stock ms
                JOIN sites s ON ms.site_id = s.id
                WHERE ms.site_id = %s
                ORDER BY ms.material_type
            """, [site_id])
            
            columns = [col[0] for col in cursor.description]
            stock_data = [dict(zip(columns, row)) for row in cursor.fetchall()]
            
            # Convert datetime objects to strings
            for item in stock_data:
                if item['last_updated']:
                    item['last_updated'] = item['last_updated'].isoformat()
        
        return Response({
            'success': True,
            'stock': stock_data
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Error fetching material stock: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_material_balance(request):
    """Get material balance (stock - usage) for a specific site"""
    site_id = request.GET.get('site_id')
    
    if not site_id:
        return Response({
            'success': False,
            'message': 'site_id is required'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    stock_id,
                    site_id,
                    site_name,
                    customer_name,
                    material_type,
                    initial_stock,
                    total_used,
                    current_balance,
                    unit,
                    last_updated,
                    stock_status
                FROM material_balance_view
                WHERE site_id = %s
                ORDER BY material_type
            """, [site_id])
            
            columns = [col[0] for col in cursor.description]
            balance_data = [dict(zip(columns, row)) for row in cursor.fetchall()]
            
            # Convert datetime and decimal objects to strings
            for item in balance_data:
                if item['last_updated']:
                    item['last_updated'] = item['last_updated'].isoformat()
                item['initial_stock'] = float(item['initial_stock'])
                item['total_used'] = float(item['total_used'])
                item['current_balance'] = float(item['current_balance'])
        
        return Response({
            'success': True,
            'balance': balance_data
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Error fetching material balance: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def add_material_stock(request):
    """Add or update material stock for a site"""
    user_id = request.user.user_data.get('user_id')
    site_id = request.data.get('site_id')
    material_type = request.data.get('material_type')
    quantity = request.data.get('quantity')
    unit = request.data.get('unit')
    notes = request.data.get('notes', '')
    
    # Validation
    if not all([site_id, material_type, quantity, unit]):
        return Response({
            'success': False,
            'message': 'site_id, material_type, quantity, and unit are required'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        quantity = float(quantity)
        if quantity <= 0:
            return Response({
                'success': False,
                'message': 'Quantity must be greater than 0'
            }, status=status.HTTP_400_BAD_REQUEST)
    except ValueError:
        return Response({
            'success': False,
            'message': 'Invalid quantity value'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        with connection.cursor() as cursor:
            # Call the stored function
            cursor.execute("""
                SELECT update_material_stock(%s, %s, %s, %s, %s, %s)
            """, [site_id, material_type, quantity, unit, user_id, notes])
            
            stock_id = cursor.fetchone()[0]
        
        return Response({
            'success': True,
            'message': 'Material stock updated successfully',
            'stock_id': str(stock_id)
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Error updating material stock: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def record_material_usage(request):
    """Record material usage by supervisor"""
    user_id = request.user.user_data.get('user_id')
    site_id = request.data.get('site_id')
    material_type = request.data.get('material_type')
    quantity_used = request.data.get('quantity_used')
    unit = request.data.get('unit')
    usage_date = request.data.get('usage_date', str(date.today()))
    notes = request.data.get('notes', '')
    
    # Validation
    if not all([site_id, material_type, quantity_used, unit]):
        return Response({
            'success': False,
            'message': 'site_id, material_type, quantity_used, and unit are required'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        quantity_used = float(quantity_used)
        if quantity_used <= 0:
            return Response({
                'success': False,
                'message': 'Quantity used must be greater than 0'
            }, status=status.HTTP_400_BAD_REQUEST)
    except ValueError:
        return Response({
            'success': False,
            'message': 'Invalid quantity value'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        with connection.cursor() as cursor:
            # Call the stored function
            cursor.execute("""
                SELECT record_material_usage(%s, %s, %s, %s, %s, %s, %s)
            """, [site_id, user_id, material_type, quantity_used, unit, usage_date, notes])
            
            usage_id = cursor.fetchone()[0]
        
        return Response({
            'success': True,
            'message': 'Material usage recorded successfully',
            'usage_id': str(usage_id)
        })
        
    except Exception as e:
        error_message = str(e)
        
        # Check for specific errors
        if 'No stock record found' in error_message:
            return Response({
                'success': False,
                'message': f'No stock record found for {material_type}. Please add stock first.'
            }, status=status.HTTP_400_BAD_REQUEST)
        elif 'Insufficient stock' in error_message:
            return Response({
                'success': False,
                'message': 'Warning: Insufficient stock! Usage recorded but stock is negative.',
                'warning': True
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'success': False,
                'message': f'Error recording material usage: {error_message}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_material_usage_history(request):
    """Get material usage history for a site"""
    site_id = request.GET.get('site_id')
    material_type = request.GET.get('material_type')
    
    if not site_id:
        return Response({
            'success': False,
            'message': 'site_id is required'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        with connection.cursor() as cursor:
            if material_type:
                cursor.execute("""
                    SELECT 
                        id,
                        site_id,
                        site_name,
                        customer_name,
                        supervisor_id,
                        supervisor_name,
                        material_type,
                        quantity_used,
                        unit,
                        usage_date,
                        usage_time,
                        notes,
                        created_at
                    FROM material_usage_history
                    WHERE site_id = %s AND material_type = %s
                    ORDER BY usage_date DESC, usage_time DESC
                    LIMIT 100
                """, [site_id, material_type])
            else:
                cursor.execute("""
                    SELECT 
                        id,
                        site_id,
                        site_name,
                        customer_name,
                        supervisor_id,
                        supervisor_name,
                        material_type,
                        quantity_used,
                        unit,
                        usage_date,
                        usage_time,
                        notes,
                        created_at
                    FROM material_usage_history
                    WHERE site_id = %s
                    ORDER BY usage_date DESC, usage_time DESC
                    LIMIT 100
                """, [site_id])
            
            columns = [col[0] for col in cursor.description]
            usage_data = [dict(zip(columns, row)) for row in cursor.fetchall()]
            
            # Convert datetime and decimal objects to strings
            for item in usage_data:
                if item['usage_date']:
                    item['usage_date'] = item['usage_date'].isoformat()
                if item['usage_time']:
                    item['usage_time'] = item['usage_time'].isoformat()
                if item['created_at']:
                    item['created_at'] = item['created_at'].isoformat()
                item['quantity_used'] = float(item['quantity_used'])
        
        return Response({
            'success': True,
            'usage_history': usage_data
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Error fetching usage history: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_low_stock_alerts(request):
    """Get low stock alerts across all sites"""
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    site_id,
                    site_name,
                    customer_name,
                    material_type,
                    initial_stock,
                    total_used,
                    current_balance,
                    unit,
                    stock_status
                FROM low_stock_alerts
                ORDER BY 
                    CASE stock_status
                        WHEN 'OUT_OF_STOCK' THEN 1
                        WHEN 'LOW_STOCK' THEN 2
                    END,
                    current_balance ASC
            """)
            
            columns = [col[0] for col in cursor.description]
            alerts = [dict(zip(columns, row)) for row in cursor.fetchall()]
            
            # Convert decimal objects to floats
            for item in alerts:
                item['initial_stock'] = float(item['initial_stock'])
                item['total_used'] = float(item['total_used'])
                item['current_balance'] = float(item['current_balance'])
        
        return Response({
            'success': True,
            'alerts': alerts,
            'count': len(alerts)
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Error fetching low stock alerts: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_material_types(request):
    """Get list of all material types used across sites"""
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT DISTINCT material_type
                FROM material_stock
                ORDER BY material_type
            """)
            
            material_types = [row[0] for row in cursor.fetchall()]
        
        return Response({
            'success': True,
            'material_types': material_types
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Error fetching material types: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
