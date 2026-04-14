"""
Budget and Real-time Update Models for Admin Site Management
"""
import uuid
from django.db import models
from .models import Site, User


class SiteBudget(models.Model):
    """Site Budget Allocation Model"""
    budget_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    allocated_amount = models.DecimalField(max_digits=15, decimal_places=2)
    utilized_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    remaining_amount = models.DecimalField(max_digits=15, decimal_places=2)
    allocated_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, 
                                     db_column='allocated_by', related_name='budgets_allocated')
    allocated_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        db_table = 'site_budgets'
        managed = False  # Managed by SQL migrations
        indexes = [
            models.Index(fields=['site', 'is_active'], name='idx_site_budgets_site_active'),
            models.Index(fields=['-allocated_at'], name='idx_site_budgets_allocated_at'),
        ]
    
    def __str__(self):
        return f"{self.site.site_name} - ₹{self.allocated_amount}"
    
    def save(self, *args, **kwargs):
        """Override save to calculate remaining amount"""
        self.remaining_amount = self.allocated_amount - self.utilized_amount
        super().save(*args, **kwargs)


class RealTimeUpdate(models.Model):
    """Real-time Update Notifications Model"""
    UPDATE_TYPE_CHOICES = [
        ('LABOUR_ENTRY', 'Labour Entry'),
        ('LABOUR_CORRECTION', 'Labour Correction'),
        ('BILL_UPLOAD', 'Bill Upload'),
        ('BUDGET_UPDATE', 'Budget Update'),
    ]
    
    ACTION_CHOICES = [
        ('CREATE', 'Create'),
        ('UPDATE', 'Update'),
        ('DELETE', 'Delete'),
    ]
    
    update_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    update_type = models.CharField(max_length=50, choices=UPDATE_TYPE_CHOICES)
    record_type = models.CharField(max_length=50)  # table name
    record_id = models.UUIDField()
    action = models.CharField(max_length=20, choices=ACTION_CHOICES)
    changed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, 
                                   db_column='changed_by', related_name='updates_made')
    notify_roles = models.JSONField()  # List of role names to notify
    is_processed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'realtime_updates'
        managed = False  # Managed by SQL migrations
        indexes = [
            models.Index(fields=['site', 'is_processed', 'created_at'], 
                        name='idx_realtime_updates_site_processed'),
            models.Index(fields=['update_type', 'created_at'], 
                        name='idx_realtime_updates_type'),
            models.Index(fields=['-created_at'], 
                        name='idx_realtime_updates_created'),
        ]
    
    def __str__(self):
        return f"{self.update_type} - {self.site.site_name}"


class EnhancedAuditLog(models.Model):
    """Enhanced Audit Log Model with additional fields"""
    CHANGE_TYPE_CHOICES = [
        ('CREATE', 'Create'),
        ('UPDATE', 'Update'),
        ('DELETE', 'Delete'),
    ]
    
    audit_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id', null=True)
    table_name = models.CharField(max_length=50)
    record_id = models.UUIDField()
    field_name = models.CharField(max_length=50)
    old_value = models.TextField(null=True)
    new_value = models.TextField(null=True)
    change_type = models.CharField(max_length=20, choices=CHANGE_TYPE_CHOICES, default='UPDATE')
    changed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, 
                                   db_column='changed_by')
    changed_by_role = models.CharField(max_length=50)
    changed_at = models.DateTimeField(auto_now_add=True)
    reason = models.TextField(null=True, blank=True)
    
    class Meta:
        db_table = 'audit_logs_enhanced'
        managed = False  # Managed by SQL migrations
        indexes = [
            models.Index(fields=['site', '-changed_at'], name='idx_audit_logs_site'),
            models.Index(fields=['table_name', 'record_id'], name='idx_audit_logs_table_record'),
            models.Index(fields=['changed_by', '-changed_at'], name='idx_audit_logs_changed_by'),
        ]
    
    def __str__(self):
        return f"{self.table_name} - {self.field_name} changed by {self.changed_by_role}"
