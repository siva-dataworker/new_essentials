"""
Enhanced Budget Management Services
Handles project quotes, cost breakdown, financial timeline, and alerts
"""

from decimal import Decimal
from datetime import datetime
from typing import Dict, List, Optional
from uuid import UUID
import logging
from django.db import connection

logger = logging.getLogger(__name__)


class ProjectQuoteService:
    """Service for managing project quotes and extra costs"""
    
    @staticmethod
    def set_initial_quote(site_id: UUID, quote_amount: Decimal, admin_id: UUID, notes: str = None) -> Dict:
        """
        Set initial project quote for a site
        
        Args:
            site_id: Site UUID
            quote_amount: Initial quoted amount
            admin_id: Admin user UUID
            notes: Optional notes about the quote
            
        Returns:
            Dictionary with budget details
        """
        try:
            with connection.cursor() as cursor:
                # Check if active budget exists
                cursor.execute("""
                    SELECT budget_id FROM site_budgets 
                    WHERE site_id = %s AND is_active = TRUE
                """, [str(site_id)])
                
                existing = cursor.fetchone()
                
                if existing:
                    # Deactivate existing budget
                    cursor.execute("""
                        UPDATE site_budgets 
                        SET is_active = FALSE 
                        WHERE budget_id = %s
                    """, [existing[0]])
                
                # Create new budget with initial quote
                cursor.execute("""
                    INSERT INTO site_budgets (
                        site_id, initial_quote, extra_cost_approved,
                        labour_cost, material_cost, extra_cost,
                        allocated_by, project_status, notes, is_active
                    ) VALUES (
                        %s, %s, 0, 0, 0, 0, %s, 'ACTIVE', %s, TRUE
                    )
                    RETURNING budget_id, allocated_amount, remaining_amount
                """, [str(site_id), quote_amount, str(admin_id), notes])
                
                result = cursor.fetchone()
                budget_id, allocated, remaining = result
                
                # Create real-time update
                cursor.execute("""
                    INSERT INTO realtime_updates (
                        site_id, update_type, record_type, record_id,
                        action, changed_by, notify_roles
                    ) VALUES (
                        %s, 'BUDGET_UPDATE', 'site_budgets', %s,
                        'CREATE', %s, '["Admin", "Accountant"]'::jsonb
                    )
                """, [str(site_id), budget_id, str(admin_id)])
                
                return {
                    'success': True,
                    'budget_id': str(budget_id),
                    'initial_quote': float(quote_amount),
                    'allocated_amount': float(allocated),
                    'remaining_amount': float(remaining)
                }
                
        except Exception as e:
            logger.error(f"Error setting initial quote: {e}")
            return {'success': False, 'error': str(e)}
    
    @staticmethod
    def request_extra_cost(site_id: UUID, amount: Decimal, reason: str, 
                          category: str, requested_by: UUID) -> Dict:
        """
        Create extra cost request for admin approval
        
        Args:
            site_id: Site UUID
            amount: Requested amount
            reason: Reason for extra cost
            category: Cost category (LABOUR, MATERIAL, EQUIPMENT, OTHER)
            requested_by: User UUID making the request
            
        Returns:
            Dictionary with request details
        """
        try:
            with connection.cursor() as cursor:
                # Get active budget
                cursor.execute("""
                    SELECT budget_id FROM site_budgets 
                    WHERE site_id = %s AND is_active = TRUE
                """, [str(site_id)])
                
                budget = cursor.fetchone()
                if not budget:
                    return {'success': False, 'error': 'No active budget found'}
                
                budget_id = budget[0]
                
                # Create request
                cursor.execute("""
                    INSERT INTO extra_cost_requests (
                        site_id, budget_id, requested_amount, reason,
                        category, requested_by, status
                    ) VALUES (
                        %s, %s, %s, %s, %s, %s, 'PENDING'
                    )
                    RETURNING request_id, requested_at
                """, [str(site_id), budget_id, amount, reason, category, str(requested_by)])
                
                result = cursor.fetchone()
                request_id, requested_at = result
                
                # Create real-time update for admin
                cursor.execute("""
                    INSERT INTO realtime_updates (
                        site_id, update_type, record_type, record_id,
                        action, changed_by, notify_roles
                    ) VALUES (
                        %s, 'EXTRA_COST_REQUEST', 'extra_cost_requests', %s,
                        'CREATE', %s, '["Admin"]'::jsonb
                    )
                """, [str(site_id), request_id, str(requested_by)])
                
                return {
                    'success': True,
                    'request_id': str(request_id),
                    'status': 'PENDING',
                    'requested_at': requested_at.isoformat()
                }
                
        except Exception as e:
            logger.error(f"Error creating extra cost request: {e}")
            return {'success': False, 'error': str(e)}
    
    @staticmethod
    def approve_extra_cost(request_id: UUID, admin_id: UUID, notes: str = None) -> Dict:
        """
        Approve extra cost request and add to budget
        
        Args:
            request_id: Extra cost request UUID
            admin_id: Admin user UUID
            notes: Optional review notes
            
        Returns:
            Dictionary with approval details
        """
        try:
            with connection.cursor() as cursor:
                # Get request details
                cursor.execute("""
                    SELECT site_id, budget_id, requested_amount, status
                    FROM extra_cost_requests
                    WHERE request_id = %s
                """, [str(request_id)])
                
                request = cursor.fetchone()
                if not request:
                    return {'success': False, 'error': 'Request not found'}
                
                site_id, budget_id, amount, status = request
                
                if status != 'PENDING':
                    return {'success': False, 'error': f'Request already {status}'}
                
                # Update request status
                cursor.execute("""
                    UPDATE extra_cost_requests
                    SET status = 'APPROVED',
                        reviewed_by = %s,
                        reviewed_at = CURRENT_TIMESTAMP,
                        review_notes = %s
                    WHERE request_id = %s
                """, [str(admin_id), notes, str(request_id)])
                
                # Add to budget extra_cost_approved
                cursor.execute("""
                    UPDATE site_budgets
                    SET extra_cost_approved = extra_cost_approved + %s,
                        allocated_by = %s
                    WHERE budget_id = %s
                    RETURNING allocated_amount, remaining_amount
                """, [amount, str(admin_id), budget_id])
                
                result = cursor.fetchone()
                new_allocated, new_remaining = result
                
                # Create real-time update
                cursor.execute("""
                    INSERT INTO realtime_updates (
                        site_id, update_type, record_type, record_id,
                        action, changed_by, notify_roles
                    ) VALUES (
                        %s, 'EXTRA_COST_APPROVED', 'extra_cost_requests', %s,
                        'UPDATE', %s, '["Admin", "Accountant"]'::jsonb
                    )
                """, [site_id, str(request_id), str(admin_id)])
                
                return {
                    'success': True,
                    'request_id': str(request_id),
                    'approved_amount': float(amount),
                    'new_allocated_amount': float(new_allocated),
                    'new_remaining_amount': float(new_remaining)
                }
                
        except Exception as e:
            logger.error(f"Error approving extra cost: {e}")
            return {'success': False, 'error': str(e)}
    
    @staticmethod
    def reject_extra_cost(request_id: UUID, admin_id: UUID, notes: str) -> Dict:
        """
        Reject extra cost request
        
        Args:
            request_id: Extra cost request UUID
            admin_id: Admin user UUID
            notes: Reason for rejection
            
        Returns:
            Dictionary with rejection details
        """
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    UPDATE extra_cost_requests
                    SET status = 'REJECTED',
                        reviewed_by = %s,
                        reviewed_at = CURRENT_TIMESTAMP,
                        review_notes = %s
                    WHERE request_id = %s AND status = 'PENDING'
                    RETURNING site_id
                """, [str(admin_id), notes, str(request_id)])
                
                result = cursor.fetchone()
                if not result:
                    return {'success': False, 'error': 'Request not found or already processed'}
                
                return {
                    'success': True,
                    'request_id': str(request_id),
                    'status': 'REJECTED'
                }
                
        except Exception as e:
            logger.error(f"Error rejecting extra cost: {e}")
            return {'success': False, 'error': str(e)}
    
    @staticmethod
    def get_pending_requests(site_id: Optional[UUID] = None) -> List[Dict]:
        """
        Get pending extra cost requests
        
        Args:
            site_id: Optional site UUID to filter by
            
        Returns:
            List of pending requests
        """
        try:
            with connection.cursor() as cursor:
                if site_id:
                    cursor.execute("""
                        SELECT 
                            ecr.request_id, ecr.site_id, s.site_name,
                            ecr.requested_amount, ecr.reason, ecr.category,
                            ecr.requested_by, u.full_name as requested_by_name,
                            ecr.requested_at, ecr.status
                        FROM extra_cost_requests ecr
                        JOIN sites s ON ecr.site_id = s.id
                        JOIN users u ON ecr.requested_by = u.id
                        WHERE ecr.site_id = %s AND ecr.status = 'PENDING'
                        ORDER BY ecr.requested_at DESC
                    """, [str(site_id)])
                else:
                    cursor.execute("""
                        SELECT 
                            ecr.request_id, ecr.site_id, s.site_name,
                            ecr.requested_amount, ecr.reason, ecr.category,
                            ecr.requested_by, u.full_name as requested_by_name,
                            ecr.requested_at, ecr.status
                        FROM extra_cost_requests ecr
                        JOIN sites s ON ecr.site_id = s.id
                        JOIN users u ON ecr.requested_by = u.id
                        WHERE ecr.status = 'PENDING'
                        ORDER BY ecr.requested_at DESC
                    """)
                
                requests = []
                for row in cursor.fetchall():
                    requests.append({
                        'request_id': str(row[0]),
                        'site_id': str(row[1]),
                        'site_name': row[2],
                        'requested_amount': float(row[3]),
                        'reason': row[4],
                        'category': row[5],
                        'requested_by': str(row[6]),
                        'requested_by_name': row[7],
                        'requested_at': row[8].isoformat(),
                        'status': row[9]
                    })
                
                return requests
                
        except Exception as e:
            logger.error(f"Error getting pending requests: {e}")
            return []


class CostBreakdownService:
    """Service for managing detailed cost breakdown"""
    
    @staticmethod
    def get_cost_breakdown(site_id: UUID) -> Dict:
        """
        Get detailed cost breakdown for a site
        
        Args:
            site_id: Site UUID
            
        Returns:
            Dictionary with cost breakdown
        """
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT 
                        budget_id, site_name, initial_quote, extra_cost_approved,
                        total_allocated, labour_cost, material_cost, extra_cost,
                        total_utilized, remaining, utilization_percentage,
                        project_status, is_active
                    FROM v_site_cost_breakdown
                    WHERE site_id = %s AND is_active = TRUE
                """, [str(site_id)])
                
                row = cursor.fetchone()
                if not row:
                    return {'success': False, 'error': 'No active budget found'}
                
                return {
                    'success': True,
                    'budget_id': str(row[0]),
                    'site_name': row[1],
                    'initial_quote': float(row[2]) if row[2] else 0,
                    'extra_cost_approved': float(row[3]) if row[3] else 0,
                    'total_allocated': float(row[4]) if row[4] else 0,
                    'labour_cost': float(row[5]) if row[5] else 0,
                    'material_cost': float(row[6]) if row[6] else 0,
                    'extra_cost': float(row[7]) if row[7] else 0,
                    'total_utilized': float(row[8]) if row[8] else 0,
                    'remaining': float(row[9]) if row[9] else 0,
                    'utilization_percentage': float(row[10]) if row[10] else 0,
                    'project_status': row[11],
                    'is_active': row[12]
                }
                
        except Exception as e:
            logger.error(f"Error getting cost breakdown: {e}")
            return {'success': False, 'error': str(e)}
    
    @staticmethod
    def get_all_sites_breakdown() -> List[Dict]:
        """
        Get cost breakdown for all sites
        
        Returns:
            List of cost breakdowns
        """
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT 
                        budget_id, site_id, site_name, initial_quote, 
                        extra_cost_approved, total_allocated, labour_cost, 
                        material_cost, extra_cost, total_utilized, remaining,
                        utilization_percentage, project_status
                    FROM v_site_cost_breakdown
                    WHERE is_active = TRUE
                    ORDER BY site_name
                """)
                
                breakdowns = []
                for row in cursor.fetchall():
                    breakdowns.append({
                        'budget_id': str(row[0]),
                        'site_id': str(row[1]),
                        'site_name': row[2],
                        'initial_quote': float(row[3]) if row[3] else 0,
                        'extra_cost_approved': float(row[4]) if row[4] else 0,
                        'total_allocated': float(row[5]) if row[5] else 0,
                        'labour_cost': float(row[6]) if row[6] else 0,
                        'material_cost': float(row[7]) if row[7] else 0,
                        'extra_cost': float(row[8]) if row[8] else 0,
                        'total_utilized': float(row[9]) if row[9] else 0,
                        'remaining': float(row[10]) if row[10] else 0,
                        'utilization_percentage': float(row[11]) if row[11] else 0,
                        'project_status': row[12]
                    })
                
                return breakdowns
                
        except Exception as e:
            logger.error(f"Error getting all sites breakdown: {e}")
            return []


class FinancialTimelineService:
    """Service for managing financial timeline"""
    
    @staticmethod
    def get_timeline(site_id: UUID, limit: int = 50) -> List[Dict]:
        """
        Get financial timeline for a site
        
        Args:
            site_id: Site UUID
            limit: Maximum number of entries to return
            
        Returns:
            List of timeline entries
        """
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT 
                        ft.timeline_id, ft.event_type, ft.event_description,
                        ft.amount, ft.previous_total, ft.new_total,
                        ft.performed_by, u.full_name as performed_by_name,
                        ft.performed_at, ft.metadata
                    FROM financial_timeline ft
                    LEFT JOIN users u ON ft.performed_by = u.id
                    WHERE ft.site_id = %s
                    ORDER BY ft.performed_at DESC
                    LIMIT %s
                """, [str(site_id), limit])
                
                timeline = []
                for row in cursor.fetchall():
                    timeline.append({
                        'timeline_id': str(row[0]),
                        'event_type': row[1],
                        'event_description': row[2],
                        'amount': float(row[3]) if row[3] else 0,
                        'previous_total': float(row[4]) if row[4] else 0,
                        'new_total': float(row[5]) if row[5] else 0,
                        'performed_by': str(row[6]) if row[6] else None,
                        'performed_by_name': row[7],
                        'performed_at': row[8].isoformat(),
                        'metadata': row[9]
                    })
                
                return timeline
                
        except Exception as e:
            logger.error(f"Error getting financial timeline: {e}")
            return []


class BudgetAlertService:
    """Service for managing budget mismatch alerts"""
    
    @staticmethod
    def get_alerts(site_id: Optional[UUID] = None, unacknowledged_only: bool = True) -> List[Dict]:
        """
        Get budget mismatch alerts
        
        Args:
            site_id: Optional site UUID to filter by
            unacknowledged_only: Only return unacknowledged alerts
            
        Returns:
            List of alerts
        """
        try:
            with connection.cursor() as cursor:
                query = """
                    SELECT 
                        bma.alert_id, bma.site_id, s.site_name,
                        bma.alert_type, bma.severity, bma.message,
                        bma.current_amount, bma.threshold_amount, bma.difference_amount,
                        bma.is_acknowledged, bma.acknowledged_by, bma.acknowledged_at,
                        bma.created_at
                    FROM budget_mismatch_alerts bma
                    JOIN sites s ON bma.site_id = s.id
                    WHERE 1=1
                """
                params = []
                
                if site_id:
                    query += " AND bma.site_id = %s"
                    params.append(str(site_id))
                
                if unacknowledged_only:
                    query += " AND bma.is_acknowledged = FALSE"
                
                query += " ORDER BY bma.severity DESC, bma.created_at DESC"
                
                cursor.execute(query, params)
                
                alerts = []
                for row in cursor.fetchall():
                    alerts.append({
                        'alert_id': str(row[0]),
                        'site_id': str(row[1]),
                        'site_name': row[2],
                        'alert_type': row[3],
                        'severity': row[4],
                        'message': row[5],
                        'current_amount': float(row[6]) if row[6] else 0,
                        'threshold_amount': float(row[7]) if row[7] else 0,
                        'difference_amount': float(row[8]) if row[8] else 0,
                        'is_acknowledged': row[9],
                        'acknowledged_by': str(row[10]) if row[10] else None,
                        'acknowledged_at': row[11].isoformat() if row[11] else None,
                        'created_at': row[12].isoformat()
                    })
                
                return alerts
                
        except Exception as e:
            logger.error(f"Error getting alerts: {e}")
            return []
    
    @staticmethod
    def acknowledge_alert(alert_id: UUID, admin_id: UUID) -> Dict:
        """
        Acknowledge a budget alert
        
        Args:
            alert_id: Alert UUID
            admin_id: Admin user UUID
            
        Returns:
            Dictionary with acknowledgment details
        """
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    UPDATE budget_mismatch_alerts
                    SET is_acknowledged = TRUE,
                        acknowledged_by = %s,
                        acknowledged_at = CURRENT_TIMESTAMP
                    WHERE alert_id = %s AND is_acknowledged = FALSE
                    RETURNING alert_id
                """, [str(admin_id), str(alert_id)])
                
                result = cursor.fetchone()
                if not result:
                    return {'success': False, 'error': 'Alert not found or already acknowledged'}
                
                return {
                    'success': True,
                    'alert_id': str(result[0])
                }
                
        except Exception as e:
            logger.error(f"Error acknowledging alert: {e}")
            return {'success': False, 'error': str(e)}
