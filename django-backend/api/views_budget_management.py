"""
Budget Management System APIs
- Budget Allocation
- Labour Salary Rates
- Material Cost Tracking
- Budget Utilization
"""
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .authentication import JWTAuthentication
from .database import fetch_all, fetch_one, execute_query
from datetime import datetime
import uuid

# ============================================
# BUDGET ALLOCATION APIs
# ============================================

@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def allocate_budget(request):
    """
    Admin: Allocate budget for a site
    POST /api/budget/allocate/
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        
        if user_role != 'Admin':
            return Response({'error': 'Only Admin can allocate budget'}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        site_id = request.data.get('site_id')
        total_budget = request.data.get('total_budget')
        material_budget = request.data.get('material_budget')
        labour_budget = request.data.get('labour_budget')
        other_budget = request.data.get('other_budget')
        notes = request.data.get('notes', '')
        
        if not all([site_id, total_budget]):
            return Response({'error': 'site_id and total_budget are required'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        # Deactivate any existing active budget
        execute_query("""
            UPDATE site_budget_allocation
            SET status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP
            WHERE site_id = %s AND status = 'ACTIVE'
        """, (site_id,))
        
        # Create new budget allocation
        budget_id = str(uuid.uuid4())
        execute_query("""
            INSERT INTO site_budget_allocation
            (id, site_id, allocated_by, total_budget, material_budget, labour_budget, other_budget, notes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (budget_id, site_id, user_id, total_budget, material_budget, labour_budget, other_budget, notes))
        
        return Response({
            'message': 'Budget allocated successfully',
            'budget_id': budget_id
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_budget_allocation(request, site_id):
    """
    Get current budget allocation for a site
    GET /api/budget/allocation/{site_id}/
    """
    try:
        budget = fetch_one("""
            SELECT 
                sba.*,
                u.full_name as allocated_by_name
            FROM site_budget_allocation sba
            JOIN users u ON sba.allocated_by = u.id
            WHERE sba.site_id = %s AND sba.status = 'ACTIVE'
        """, (site_id,))
        
        if not budget:
            return Response({'error': 'No active budget found for this site'}, 
                          status=status.HTTP_404_NOT_FOUND)
        
        return Response({
            'budget': {
                'id': str(budget['id']),
                'total_budget': float(budget['total_budget']),
                'material_budget': float(budget['material_budget']) if budget['material_budget'] else None,
                'labour_budget': float(budget['labour_budget']) if budget['labour_budget'] else None,
                'other_budget': float(budget['other_budget']) if budget['other_budget'] else None,
                'status': budget['status'],
                'notes': budget['notes'],
                'allocated_by': budget['allocated_by_name'],
                'allocated_date': budget['allocated_date'].isoformat() if budget['allocated_date'] else None,
            }
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# LABOUR SALARY RATES APIs
# ============================================

@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def set_labour_rate(request):
    """
    Admin: Set daily salary rate for labour type
    POST /api/budget/labour-rate/
    """
    try:
        user_id = request.user['user_id']
        user_role = request.user.get('role', '')
        
        if user_role != 'Admin':
            return Response({'error': 'Only Admin can set labour rates'}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        raw_site_id = request.data.get('site_id')
        labour_type = request.data.get('labour_type')
        daily_rate = request.data.get('daily_rate')
        effective_from = request.data.get('effective_from', datetime.now().date())
        notes = request.data.get('notes', '')

        # 'global' means NULL site_id (applies to all sites)
        site_id = None if raw_site_id in (None, '', 'global') else raw_site_id

        if not all([labour_type, daily_rate]):
            return Response({'error': 'labour_type and daily_rate are required'},
                          status=status.HTTP_400_BAD_REQUEST)

        # Deactivate existing rate for this labour type
        if site_id is None:
            execute_query("""
                UPDATE labour_salary_rates
                SET is_active = FALSE, effective_to = CURRENT_DATE, updated_at = CURRENT_TIMESTAMP
                WHERE site_id IS NULL AND labour_type = %s AND is_active = TRUE
            """, (labour_type,))
        else:
            execute_query("""
                UPDATE labour_salary_rates
                SET is_active = FALSE, effective_to = CURRENT_DATE, updated_at = CURRENT_TIMESTAMP
                WHERE site_id = %s AND labour_type = %s AND is_active = TRUE
            """, (site_id, labour_type))

        # Create new rate
        rate_id = str(uuid.uuid4())
        execute_query("""
            INSERT INTO labour_salary_rates
            (id, site_id, labour_type, daily_rate, effective_from, set_by, notes)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (rate_id, site_id, labour_type, daily_rate, effective_from, user_id, notes))
        
        return Response({
            'success': True,
            'message': 'Labour rate set successfully',
            'rate_id': rate_id
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Canonical default rates — single source of truth used by all screens
CANONICAL_DEFAULT_RATES = {
    'General': 600,
    'Mason': 800,
    'Helper': 500,
    'Carpenter': 750,
    'Plumber': 700,
    'Electrician': 750,
    'Painter': 650,
    'Tile Layer': 700,
    'Tile Layerhelper': 700,
    'Kambi Fitter': 900,
    'Concrete Kot': 950,
    'Pile Labour': 800,
}

@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_labour_rates(request, site_id):
    """
    Get all active labour rates.
    For site_id='global': returns all 12 labour types — admin-set rate if available,
    otherwise the canonical default. This is the single source of truth for all screens.
    GET /api/budget/labour-rates/{site_id}/
    """
    try:
        if site_id == 'global':
            # Fetch only admin-set global rates
            db_rates = fetch_all("""
                SELECT
                    lsr.*,
                    u.full_name as set_by_name
                FROM labour_salary_rates lsr
                JOIN users u ON lsr.set_by = u.id
                WHERE lsr.site_id IS NULL AND lsr.is_active = TRUE
                ORDER BY lsr.labour_type
            """)
            # Index by labour_type
            db_map = {r['labour_type']: r for r in db_rates}

            # Return all canonical types, using DB rate where admin has set one
            result = []
            for labour_type, default_rate in CANONICAL_DEFAULT_RATES.items():
                if labour_type in db_map:
                    r = db_map[labour_type]
                    result.append({
                        'id': str(r['id']),
                        'labour_type': labour_type,
                        'daily_rate': float(r['daily_rate']),
                        'effective_from': r['effective_from'].isoformat() if r['effective_from'] else None,
                        'set_by': r['set_by_name'],
                        'notes': r['notes'],
                        'is_admin_set': True,
                    })
                else:
                    result.append({
                        'id': None,
                        'labour_type': labour_type,
                        'daily_rate': float(default_rate),
                        'effective_from': None,
                        'set_by': None,
                        'notes': '',
                        'is_admin_set': False,
                    })
            return Response({'rates': result}, status=status.HTTP_200_OK)
        else:
            rates = fetch_all("""
                SELECT
                    lsr.*,
                    u.full_name as set_by_name
                FROM labour_salary_rates lsr
                JOIN users u ON lsr.set_by = u.id
                WHERE lsr.site_id = %s AND lsr.is_active = TRUE
                ORDER BY lsr.labour_type
            """, (site_id,))
            return Response({
                'rates': [
                    {
                        'id': str(r['id']),
                        'labour_type': r['labour_type'],
                        'daily_rate': float(r['daily_rate']),
                        'effective_from': r['effective_from'].isoformat() if r['effective_from'] else None,
                        'set_by': r['set_by_name'],
                        'notes': r['notes'],
                        'is_admin_set': True,
                    }
                    for r in rates
                ]
            }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# BUDGET UTILIZATION APIs
# ============================================

@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_budget_utilization(request, site_id):
    """
    Get complete budget utilization summary for a site
    GET /api/budget/utilization/{site_id}/
    """
    try:
        # Get summary from view
        summary = fetch_one("""
            SELECT * FROM budget_utilization_summary
            WHERE site_id = %s
        """, (site_id,))
        
        if not summary:
            return Response({'error': 'No budget allocation found for this site'}, 
                          status=status.HTTP_404_NOT_FOUND)
        
        # Get detailed breakdown
        material_costs = fetch_all("""
            SELECT 
                material_type,
                SUM(total_cost) as total_cost,
                SUM(quantity) as total_quantity,
                unit
            FROM material_cost_tracking
            WHERE site_id = %s
            GROUP BY material_type, unit
            ORDER BY total_cost DESC
        """, (site_id,))
        
        labour_costs = fetch_all("""
            SELECT 
                labour_type,
                SUM(labour_count) as total_count,
                AVG(daily_rate) as avg_rate,
                SUM(total_cost) as total_cost
            FROM labour_cost_calculation
            WHERE site_id = %s
            GROUP BY labour_type
            ORDER BY total_cost DESC
        """, (site_id,))
        
        return Response({
            'summary': {
                'total_budget': float(summary['total_budget']),
                'material_budget': float(summary['material_budget']) if summary['material_budget'] else None,
                'labour_budget': float(summary['labour_budget']) if summary['labour_budget'] else None,
                'other_budget': float(summary['other_budget']) if summary['other_budget'] else None,
                'total_material_cost': float(summary['total_material_cost']),
                'total_labour_cost': float(summary['total_labour_cost']),
                'total_vendor_cost': float(summary['total_vendor_cost']),
                'total_spent': float(summary['total_spent']),
                'remaining_budget': float(summary['remaining_budget']),
                'utilization_percentage': float(summary['utilization_percentage']),
                'status': summary['status'],
            },
            'material_breakdown': [
                {
                    'material_type': m['material_type'],
                    'total_cost': float(m['total_cost']),
                    'total_quantity': float(m['total_quantity']),
                    'unit': m['unit'],
                }
                for m in material_costs
            ],
            'labour_breakdown': [
                {
                    'labour_type': l['labour_type'],
                    'total_count': int(l['total_count']),
                    'avg_rate': float(l['avg_rate']),
                    'total_cost': float(l['total_cost']),
                }
                for l in labour_costs
            ]
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_labour_cost_details(request, site_id):
    """
    Get detailed labour cost calculations for a site
    GET /api/budget/labour-costs/{site_id}/
    """
    try:
        costs = fetch_all("""
            SELECT 
                lcc.*,
                le.supervisor_id,
                u.full_name as supervisor_name
            FROM labour_cost_calculation lcc
            JOIN labour_entries le ON lcc.labour_entry_id = le.id
            JOIN users u ON le.supervisor_id = u.id
            WHERE lcc.site_id = %s
            ORDER BY lcc.entry_date DESC
            LIMIT 100
        """, (site_id,))
        
        return Response({
            'costs': [
                {
                    'id': str(c['id']),
                    'labour_type': c['labour_type'],
                    'labour_count': c['labour_count'],
                    'daily_rate': float(c['daily_rate']),
                    'total_cost': float(c['total_cost']),
                    'entry_date': c['entry_date'].isoformat() if c['entry_date'] else None,
                    'day_of_week': c['day_of_week'],
                    'supervisor_name': c['supervisor_name'],
                    'is_verified': c['is_verified'],
                }
                for c in costs
            ]
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
