"""
Budget Management API Views
"""
from decimal import Decimal, InvalidOperation
from datetime import datetime
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .authentication import JWTAuthentication
from .services_budget import (
    BudgetAllocationService,
    RealTimeSyncService,
    AuditTrailService
)


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def set_budget(request):
    """
    Set or update budget allocation for a site
    
    POST /api/admin/sites/<site_id>/budget/
    Body: {
        "budget_amount": 5000000.00
    }
    """
    user = request.user
    
    # Verify admin role
    if user.get('role') != 'Admin':
        return Response(
            {'error': 'Only admins can allocate budgets'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    site_id = request.data.get('site_id')
    budget_amount = request.data.get('budget_amount')
    
    # Validate inputs
    if not site_id:
        return Response(
            {'error': 'site_id is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if not budget_amount:
        return Response(
            {'error': 'budget_amount is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        budget_amount = Decimal(str(budget_amount))
    except (InvalidOperation, ValueError):
        return Response(
            {'error': 'Invalid budget amount'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Call service
    result = BudgetAllocationService.set_site_budget(
        site_id=str(site_id),
        budget_amount=budget_amount,
        admin_id=str(user.get('user_id'))
    )
    
    if result['success']:
        return Response(result, status=status.HTTP_201_CREATED)
    else:
        return Response(
            {'error': result['error']},
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_budget(request, site_id):
    """
    Get active budget for a site
    
    GET /api/admin/sites/<site_id>/budget/
    """
    user = request.user
    
    # Verify admin or accountant role
    if user.get('role') not in ['Admin', 'Accountant']:
        return Response(
            {'error': 'Access denied'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    budget = BudgetAllocationService.get_site_budget(str(site_id))
    
    if budget:
        return Response({'success': True, 'budget': budget})
    else:
        return Response(
            {'success': False, 'error': 'No active budget found'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_budget_utilization(request, site_id):
    """
    Get budget utilization details
    
    GET /api/admin/sites/<site_id>/budget/utilization/
    """
    user = request.user
    
    # Verify admin or accountant role
    if user.get('role') not in ['Admin', 'Accountant']:
        return Response(
            {'error': 'Access denied'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    result = BudgetAllocationService.get_budget_utilization(str(site_id))
    
    if result['success']:
        return Response(result)
    else:
        return Response(
            {'error': result['error']},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_realtime_updates(request):
    """
    Get pending real-time updates for the user
    
    GET /api/admin/realtime-updates/
    Query params:
        - last_sync: ISO timestamp of last sync (optional)
        - site_id: Filter by site (optional)
    """
    user = request.user
    
    # Verify admin or accountant role
    if user.get('role') not in ['Admin', 'Accountant']:
        return Response(
            {'error': 'Access denied'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Parse query parameters
    last_sync_str = request.GET.get('last_sync')
    site_id_str = request.GET.get('site_id')
    
    last_sync = None
    if last_sync_str:
        try:
            last_sync = datetime.fromisoformat(last_sync_str.replace('Z', '+00:00'))
        except ValueError:
            return Response(
                {'error': 'Invalid last_sync format. Use ISO 8601 format'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    site_id = None
    if site_id_str:
        site_id = site_id_str  # Keep as string (UUID)
    
    # Get updates
    updates = RealTimeSyncService.get_pending_updates(
        user_id=str(user.get('user_id')),
        last_sync=last_sync,
        site_id=site_id
    )
    
    return Response({
        'success': True,
        'updates': updates,
        'count': len(updates)
    })


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_audit_trail(request, site_id):
    """
    Get audit trail for a site
    
    GET /api/admin/sites/<site_id>/audit-trail/
    Query params:
        - table_name: Filter by table (optional)
        - changed_by: Filter by user ID (optional)
        - date_from: Filter from date (optional)
        - date_to: Filter to date (optional)
        - page: Page number (default: 1)
        - page_size: Records per page (default: 50, max: 100)
    """
    user = request.user
    
    # Verify admin role
    if user.get('role') != 'Admin':
        return Response(
            {'error': 'Only admins can view audit trail'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Parse query parameters
    filters = {}
    
    if request.GET.get('table_name'):
        filters['table_name'] = request.GET.get('table_name')
    
    if request.GET.get('changed_by'):
        try:
            filters['changed_by'] = int(request.GET.get('changed_by'))
        except ValueError:
            return Response(
                {'error': 'Invalid changed_by value'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    if request.GET.get('date_from'):
        try:
            filters['date_from'] = datetime.fromisoformat(
                request.GET.get('date_from').replace('Z', '+00:00')
            )
        except ValueError:
            return Response(
                {'error': 'Invalid date_from format'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    if request.GET.get('date_to'):
        try:
            filters['date_to'] = datetime.fromisoformat(
                request.GET.get('date_to').replace('Z', '+00:00')
            )
        except ValueError:
            return Response(
                {'error': 'Invalid date_to format'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    # Parse pagination
    try:
        page = int(request.GET.get('page', 1))
        page_size = min(int(request.GET.get('page_size', 50)), 100)
    except ValueError:
        return Response(
            {'error': 'Invalid pagination parameters'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Get audit trail
    result = AuditTrailService.get_audit_trail(
        site_id=str(site_id),
        filters=filters if filters else None,
        page=page,
        page_size=page_size
    )
    
    if result['success']:
        return Response(result)
    else:
        return Response(
            {'error': result['error']},
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_all_sites_budgets(request):
    """
    Get budgets for all sites (admin only)
    
    GET /api/admin/budgets/all/
    """
    user = request.user
    
    # Verify admin role
    if user.get('role') != 'Admin':
        return Response(
            {'error': 'Only admins can view all budgets'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    from .database import fetch_all
    
    # Get all sites with active budgets
    sites = fetch_all("SELECT id, site_name FROM sites ORDER BY site_name")
    budgets_data = []
    
    for site in sites:
        budget = BudgetAllocationService.get_site_budget(str(site['id']))
        if budget:
            budgets_data.append(budget)
        else:
            # Site without budget
            budgets_data.append({
                'site_id': str(site['id']),
                'site_name': site['site_name'],
                'allocated_amount': 0,
                'utilized_amount': 0,
                'remaining_amount': 0,
                'has_budget': False
            })
    
    return Response({
        'success': True,
        'budgets': budgets_data,
        'count': len(budgets_data)
    })
