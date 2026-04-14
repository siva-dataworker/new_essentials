"""
Time validation endpoints for construction entry system
Handles entry time restrictions (8 AM - 1 PM IST)
"""

from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .authentication import JWTAuthentication
from .time_utils import (
    get_entry_time_status,
    is_within_entry_hours,
    get_entry_metadata,
    get_ist_now
)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def validate_entry_time(request):
    """
    Check if current time is within allowed entry hours (8 AM - 1 PM IST)
    GET /api/construction/validate-entry-time/
    
    Returns:
        {
            'allowed': bool,
            'current_time_ist': str,
            'current_hour': int,
            'day_of_week': str,
            'message': str,
            'remaining_minutes': int (if allowed),
            'next_window': str (if not allowed)
        }
    """
    try:
        time_status = get_entry_time_status()
        return Response(time_status, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'error': str(e),
            'allowed': False,
            'message': 'Error checking entry time'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_current_ist_time(request):
    """
    Get current IST time and day of week
    GET /api/construction/current-ist-time/
    
    Returns:
        {
            'current_time_ist': str,
            'day_of_week': str,
            'date': str,
            'time': str
        }
    """
    try:
        now_ist = get_ist_now()
        metadata = get_entry_metadata()
        
        return Response({
            'current_time_ist': now_ist.strftime('%Y-%m-%d %H:%M:%S %Z'),
            'day_of_week': metadata['day_of_week'],
            'date': metadata['entry_date'].strftime('%Y-%m-%d'),
            'time': metadata['entry_time'].strftime('%H:%M:%S'),
            'timestamp': now_ist.isoformat()
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
