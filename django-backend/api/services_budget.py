"""
Budget Allocation and Real-time Sync Services
"""
from decimal import Decimal
from datetime import datetime
from typing import Dict, List, Optional
import uuid

from .database import execute_query, fetch_one, fetch_all


class BudgetAllocationService:
    """Service for managing site budget allocations"""
    
    @staticmethod
    def set_site_budget(site_id: str, budget_amount: Decimal, admin_id: str) -> Dict:
        """
        Set or update budget allocation for a site
        
        Args:
            site_id: Site ID (UUID string)
            budget_amount: Budget amount to allocate
            admin_id: Admin user ID (UUID string)
            
        Returns:
            Dictionary with success status and budget details
        """
        try:
            # Validate inputs
            if budget_amount <= 0:
                return {
                    'success': False,
                    'error': 'Budget amount must be positive'
                }
            
            # Verify site exists
            site = fetch_one("SELECT id, site_name FROM sites WHERE id = %s", [site_id])
            if not site:
                return {
                    'success': False,
                    'error': 'Site not found'
                }
            
            # Verify admin user exists and has admin role
            admin = fetch_one("""
                SELECT u.id, u.full_name, u.role 
                FROM users u 
                WHERE u.id = %s
            """, [admin_id])
            
            if not admin:
                return {
                    'success': False,
                    'error': 'Admin user not found'
                }
            
            if admin.get('role') != 'Admin':
                return {
                    'success': False,
                    'error': 'Only admins can allocate budgets'
                }
            
            # Deactivate existing active budgets
            execute_query("""
                UPDATE site_budgets 
                SET is_active = FALSE 
                WHERE site_id = %s AND is_active = TRUE
            """, [site_id])
            
            # Create new budget
            budget_id = str(uuid.uuid4())
            remaining_amount = budget_amount
            
            execute_query("""
                INSERT INTO site_budgets (
                    budget_id, site_id, allocated_amount, utilized_amount, 
                    remaining_amount, allocated_by, is_active
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, [
                budget_id, site_id, float(budget_amount), 0.0, 
                float(remaining_amount), admin_id, True
            ])
            
            # Log budget creation
            AuditTrailService.log_change(
                site_id=site_id,
                table_name='site_budgets',
                record_id=budget_id,
                field_name='allocated_amount',
                old_value=None,
                new_value=str(budget_amount),
                changed_by=admin_id,
                changed_by_role='Admin',
                change_type='CREATE'
            )
            
            # Create real-time update notification
            RealTimeSyncService.notify_budget_update(
                site_id=site_id,
                budget_id=budget_id,
                admin_id=admin_id,
                action='CREATE'
            )
            
            # Get the created budget
            budget = fetch_one("""
                SELECT budget_id, site_id, allocated_amount, utilized_amount, 
                       remaining_amount, allocated_by, allocated_at, is_active
                FROM site_budgets
                WHERE budget_id = %s
            """, [budget_id])
            
            return {
                'success': True,
                'budget': {
                    'budget_id': str(budget['budget_id']),
                    'site_id': str(budget['site_id']),
                    'site_name': site['site_name'],
                    'allocated_amount': float(budget['allocated_amount']),
                    'utilized_amount': float(budget['utilized_amount']),
                    'remaining_amount': float(budget['remaining_amount']),
                    'allocated_by': admin['full_name'],
                    'allocated_at': budget['allocated_at'].isoformat() if budget['allocated_at'] else None,
                    'is_active': budget['is_active']
                }
            }
            
        except Exception as e:
            print(f"Error in set_site_budget: {e}")
            return {
                'success': False,
                'error': f'Failed to allocate budget: {str(e)}'
            }
    
    @staticmethod
    def get_site_budget(site_id: str) -> Optional[Dict]:
        """Get active budget for a site"""
        try:
            budget = fetch_one("""
                SELECT sb.budget_id, sb.site_id, sb.allocated_amount, sb.utilized_amount,
                       sb.remaining_amount, sb.allocated_by, sb.allocated_at, sb.updated_at,
                       sb.is_active, s.site_name, u.full_name as allocated_by_name
                FROM site_budgets sb
                JOIN sites s ON sb.site_id = s.id
                LEFT JOIN users u ON sb.allocated_by = u.id
                WHERE sb.site_id = %s AND sb.is_active = TRUE
            """, [site_id])
            
            if not budget:
                return None
            
            return {
                'budget_id': str(budget['budget_id']),
                'site_id': str(budget['site_id']),
                'site_name': budget['site_name'],
                'allocated_amount': float(budget['allocated_amount']),
                'utilized_amount': float(budget['utilized_amount']),
                'remaining_amount': float(budget['remaining_amount']),
                'allocated_by': budget['allocated_by_name'],
                'allocated_at': budget['allocated_at'].isoformat() if budget['allocated_at'] else None,
                'updated_at': budget['updated_at'].isoformat() if budget['updated_at'] else None,
                'is_active': budget['is_active']
            }
        except Exception as e:
            print(f"Error in get_site_budget: {e}")
            return None
    
    @staticmethod
    def get_budget_utilization(site_id: str) -> Dict:
        """Get budget utilization details for a site"""
        budget = BudgetAllocationService.get_site_budget(site_id)
        
        if not budget:
            return {
                'success': False,
                'error': 'No active budget found for this site'
            }
        
        utilization_percentage = 0
        if budget['allocated_amount'] > 0:
            utilization_percentage = (budget['utilized_amount'] / budget['allocated_amount']) * 100
        
        return {
            'success': True,
            'site_id': site_id,
            'allocated_amount': budget['allocated_amount'],
            'utilized_amount': budget['utilized_amount'],
            'remaining_amount': budget['remaining_amount'],
            'utilization_percentage': round(utilization_percentage, 2)
        }


class RealTimeSyncService:
    """Service for managing real-time data synchronization"""
    
    @staticmethod
    def notify_labour_update(site_id: str, entry_id: str, action: str, changed_by: str) -> None:
        """Create notification for labour entry update"""
        try:
            update_id = str(uuid.uuid4())
            execute_query("""
                INSERT INTO realtime_updates (
                    update_id, site_id, update_type, record_type, record_id,
                    action, changed_by, notify_roles
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, [
                update_id, site_id, 'LABOUR_ENTRY', 'daily_labour_summary',
                entry_id, action, changed_by,
                '["Admin", "Accountant"]'
            ])
        except Exception as e:
            print(f"Error creating labour update notification: {e}")
    
    @staticmethod
    def notify_labour_correction(site_id: str, entry_id: str, accountant_id: str) -> None:
        """Create notification for labour correction"""
        try:
            update_id = str(uuid.uuid4())
            execute_query("""
                INSERT INTO realtime_updates (
                    update_id, site_id, update_type, record_type, record_id,
                    action, changed_by, notify_roles
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, [
                update_id, site_id, 'LABOUR_CORRECTION', 'daily_labour_summary',
                entry_id, 'UPDATE', accountant_id,
                '["Admin"]'
            ])
        except Exception as e:
            print(f"Error creating labour correction notification: {e}")
    
    @staticmethod
    def notify_bill_upload(site_id: str, bill_id: str, accountant_id: str) -> None:
        """Create notification for bill upload"""
        try:
            update_id = str(uuid.uuid4())
            execute_query("""
                INSERT INTO realtime_updates (
                    update_id, site_id, update_type, record_type, record_id,
                    action, changed_by, notify_roles
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, [
                update_id, site_id, 'BILL_UPLOAD', 'material_bills',
                bill_id, 'CREATE', accountant_id,
                '["Admin"]'
            ])
        except Exception as e:
            print(f"Error creating bill upload notification: {e}")
    
    @staticmethod
    def notify_budget_update(site_id: str, budget_id: str, admin_id: str, action: str) -> None:
        """Create notification for budget update"""
        try:
            update_id = str(uuid.uuid4())
            execute_query("""
                INSERT INTO realtime_updates (
                    update_id, site_id, update_type, record_type, record_id,
                    action, changed_by, notify_roles
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, [
                update_id, site_id, 'BUDGET_UPDATE', 'site_budgets',
                budget_id, action, admin_id,
                '["Admin", "Accountant"]'
            ])
        except Exception as e:
            print(f"Error creating budget update notification: {e}")
    
    @staticmethod
    def get_pending_updates(user_id: str, last_sync: Optional[datetime] = None, 
                           site_id: Optional[str] = None) -> List[Dict]:
        """
        Get pending real-time updates for a user
        
        Args:
            user_id: User ID requesting updates (UUID string)
            last_sync: Last sync timestamp (optional)
            site_id: Filter by specific site (UUID string, optional)
            
        Returns:
            List of update dictionaries
        """
        try:
            # Get user role
            user = fetch_one("""
                SELECT u.id, u.role
                FROM users u
                WHERE u.id = %s
            """, [user_id])
            
            if not user:
                return []
            
            user_role = user.get('role', '')
            
            # Build query
            query = """
                SELECT ru.update_id, ru.site_id, ru.update_type, ru.record_type,
                       ru.record_id, ru.action, ru.created_at,
                       s.site_name, u.full_name as changed_by_name
                FROM realtime_updates ru
                JOIN sites s ON ru.site_id = s.id
                LEFT JOIN users u ON ru.changed_by = u.id
                WHERE ru.is_processed = FALSE
                  AND ru.notify_roles::jsonb ? %s
            """
            params = [user_role]
            
            # Add filters
            if last_sync:
                query += " AND ru.created_at > %s"
                params.append(last_sync)
            
            if site_id:
                query += " AND ru.site_id = %s"
                params.append(site_id)
            
            query += " ORDER BY ru.created_at ASC"
            
            updates = fetch_all(query, params)
            
            # Convert to list of dicts
            result = []
            for update in updates:
                result.append({
                    'update_id': str(update['update_id']),
                    'site_id': str(update['site_id']),
                    'site_name': update['site_name'],
                    'update_type': update['update_type'],
                    'record_type': update['record_type'],
                    'record_id': str(update['record_id']),
                    'action': update['action'],
                    'changed_by': update['changed_by_name'] or 'System',
                    'changed_at': update['created_at'].isoformat() if update['created_at'] else None
                })
            
            return result
            
        except Exception as e:
            print(f"Error getting pending updates: {e}")
            return []


class AuditTrailService:
    """Service for managing audit trail"""
    
    @staticmethod
    def log_change(site_id: Optional[int], table_name: str, record_id: str,
                   field_name: str, old_value: Optional[str], new_value: Optional[str],
                   changed_by: int, changed_by_role: str, change_type: str = 'UPDATE',
                   reason: Optional[str] = None) -> str:
        """
        Log a data change to audit trail
        
        Returns:
            UUID string of created audit log entry
        """
        try:
            audit_id = str(uuid.uuid4())
            execute_query("""
                INSERT INTO audit_logs_enhanced (
                    audit_id, site_id, table_name, record_id, field_name,
                    old_value, new_value, change_type, changed_by, changed_by_role, reason
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, [
                audit_id, site_id, table_name, record_id, field_name,
                old_value, new_value, change_type, changed_by, changed_by_role, reason
            ])
            return audit_id
        except Exception as e:
            print(f"Error logging audit trail: {e}")
            return str(uuid.uuid4())  # Return dummy UUID on error
    
    @staticmethod
    def get_audit_trail(site_id: str, filters: Optional[Dict] = None, 
                       page: int = 1, page_size: int = 50) -> Dict:
        """
        Get audit trail for a site with optional filters
        
        Args:
            site_id: Site ID (UUID string)
            filters: Optional filters (table_name, changed_by, date_from, date_to)
            page: Page number
            page_size: Records per page
            
        Returns:
            Dictionary with audit logs and pagination info
        """
        try:
            # Build query
            query = """
                SELECT al.audit_id, al.table_name, al.record_id, al.field_name,
                       al.old_value, al.new_value, al.change_type, al.changed_by_role,
                       al.changed_at, al.reason, u.full_name as changed_by_name
                FROM audit_logs_enhanced al
                LEFT JOIN users u ON al.changed_by = u.id
                WHERE al.site_id = %s
            """
            params = [site_id]
            
            # Apply filters
            if filters:
                if 'table_name' in filters:
                    query += " AND al.table_name = %s"
                    params.append(filters['table_name'])
                if 'changed_by' in filters:
                    query += " AND al.changed_by = %s"
                    params.append(filters['changed_by'])
                if 'date_from' in filters:
                    query += " AND al.changed_at >= %s"
                    params.append(filters['date_from'])
                if 'date_to' in filters:
                    query += " AND al.changed_at <= %s"
                    params.append(filters['date_to'])
            
            # Get total count
            count_query = f"SELECT COUNT(*) as count FROM ({query}) as subquery"
            count_result = fetch_one(count_query, params)
            total_count = count_result['count'] if count_result else 0
            
            # Order by most recent first
            query += " ORDER BY al.changed_at DESC"
            
            # Paginate
            offset = (page - 1) * page_size
            query += f" LIMIT {page_size} OFFSET {offset}"
            
            logs = fetch_all(query, params)
            
            # Convert to list of dicts
            audit_logs = []
            for log in logs:
                audit_logs.append({
                    'audit_id': str(log['audit_id']),
                    'table_name': log['table_name'],
                    'record_id': str(log['record_id']),
                    'field_name': log['field_name'],
                    'old_value': log['old_value'],
                    'new_value': log['new_value'],
                    'change_type': log['change_type'],
                    'changed_by': log['changed_by_name'] or 'System',
                    'changed_by_role': log['changed_by_role'],
                    'changed_at': log['changed_at'].isoformat() if log['changed_at'] else None,
                    'reason': log['reason']
                })
            
            return {
                'success': True,
                'logs': audit_logs,
                'total_count': total_count,
                'page': page,
                'page_size': page_size,
                'has_next': offset + page_size < total_count
            }
            
        except Exception as e:
            print(f"Error getting audit trail: {e}")
            return {
                'success': False,
                'error': f'Failed to get audit trail: {str(e)}'
            }
