"""
Construction Management System - Django Models
Matches the PostgreSQL schema exactly
"""
from django.db import models
import uuid

class Role(models.Model):
    """User roles in the system"""
    id = models.AutoField(primary_key=True)
    role_name = models.CharField(max_length=50, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'roles'
    
    def __str__(self):
        return self.role_name


class User(models.Model):
    """User model with approval workflow"""
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('APPROVED', 'Approved'),
        ('REJECTED', 'Rejected'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=100, unique=True)
    email = models.EmailField(max_length=255, unique=True)
    phone = models.CharField(max_length=20)
    password_hash = models.CharField(max_length=255)
    full_name = models.CharField(max_length=255, null=True, blank=True)
    role = models.ForeignKey(Role, on_delete=models.SET_NULL, null=True, db_column='role_id')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    created_at = models.DateTimeField(auto_now_add=True)
    approved_at = models.DateTimeField(null=True, blank=True)
    approved_by = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='approved_users')
    last_login = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        db_table = 'users'
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['username']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return f"{self.username} ({self.role.role_name if self.role else 'No Role'})"


class Site(models.Model):
    """Construction sites"""
    STATUS_CHOICES = [
        ('ACTIVE', 'Active'),
        ('COMPLETED', 'Completed'),
        ('ON_HOLD', 'On Hold'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    area = models.CharField(max_length=100)
    street = models.CharField(max_length=100)
    site_name = models.CharField(max_length=255)
    customer_name = models.CharField(max_length=255)
    site_code = models.CharField(max_length=50, unique=True, null=True, blank=True)
    project_value = models.DecimalField(max_digits=15, decimal_places=2, null=True, blank=True)
    start_date = models.DateField(null=True, blank=True)
    estimated_completion = models.DateField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='ACTIVE')
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='created_by')
    
    class Meta:
        db_table = 'sites'
        indexes = [
            models.Index(fields=['area']),
            models.Index(fields=['street']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return f"{self.site_name} - {self.customer_name}"


class LabourEntry(models.Model):
    """Daily labour count entries"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    supervisor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='labour_entries', db_column='supervisor_id')
    labour_count = models.IntegerField()
    labour_type = models.CharField(max_length=100, null=True, blank=True)
    entry_date = models.DateField()
    entry_time = models.DateTimeField(auto_now_add=True)
    is_modified = models.BooleanField(default=False)
    modified_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='modified_labour_entries', db_column='modified_by')
    modified_at = models.DateTimeField(null=True, blank=True)
    modification_reason = models.TextField(null=True, blank=True)
    notes = models.TextField(null=True, blank=True)
    
    class Meta:
        db_table = 'labour_entries'
        unique_together = [['site', 'entry_date']]
        indexes = [
            models.Index(fields=['site']),
            models.Index(fields=['entry_date']),
            models.Index(fields=['supervisor']),
        ]
    
    def __str__(self):
        return f"{self.site.site_name} - {self.entry_date} - {self.labour_count} workers"


class MaterialBalance(models.Model):
    """Material balance tracking"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    supervisor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='supervisor_id')
    material_type = models.CharField(max_length=100)
    quantity = models.DecimalField(max_digits=10, decimal_places=2)
    unit = models.CharField(max_length=50, null=True, blank=True)
    entry_date = models.DateField()
    updated_at = models.DateTimeField(auto_now=True)
    notes = models.TextField(null=True, blank=True)
    
    class Meta:
        db_table = 'material_balances'
        indexes = [
            models.Index(fields=['site']),
            models.Index(fields=['entry_date']),
            models.Index(fields=['material_type']),
        ]
    
    def __str__(self):
        return f"{self.site.site_name} - {self.material_type} - {self.quantity}"


class WorkUpdate(models.Model):
    """Work progress updates with images"""
    UPDATE_TYPE_CHOICES = [
        ('STARTED', 'Started'),
        ('FINISHED', 'Finished'),
        ('RECTIFIED', 'Rectified'),
        ('PROGRESS', 'Progress'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    engineer = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='engineer_id')
    update_type = models.CharField(max_length=50, choices=UPDATE_TYPE_CHOICES)
    image_url = models.TextField(null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)
    update_date = models.DateField()
    visible_to_client = models.BooleanField(default=False)
    
    class Meta:
        db_table = 'work_updates'
        indexes = [
            models.Index(fields=['site']),
            models.Index(fields=['update_date']),
            models.Index(fields=['update_type']),
        ]
    
    def __str__(self):
        return f"{self.site.site_name} - {self.update_type} - {self.update_date}"


class Complaint(models.Model):
    """Client complaints and issues"""
    STATUS_CHOICES = [
        ('OPEN', 'Open'),
        ('IN_PROGRESS', 'In Progress'),
        ('RESOLVED', 'Resolved'),
        ('CLOSED', 'Closed'),
    ]
    
    PRIORITY_CHOICES = [
        ('LOW', 'Low'),
        ('MEDIUM', 'Medium'),
        ('HIGH', 'High'),
        ('URGENT', 'Urgent'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    raised_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='raised_complaints', db_column='raised_by')
    assigned_to = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='assigned_complaints', db_column='assigned_to')
    title = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='OPEN')
    priority = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default='MEDIUM')
    created_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    resolution_notes = models.TextField(null=True, blank=True)
    proof_image_url = models.TextField(null=True, blank=True)
    
    class Meta:
        db_table = 'complaints'
        indexes = [
            models.Index(fields=['site']),
            models.Index(fields=['status']),
            models.Index(fields=['assigned_to']),
        ]
    
    def __str__(self):
        return f"{self.title} - {self.site.site_name}"


class Bill(models.Model):
    """Material bills"""
    PAYMENT_STATUS_CHOICES = [
        ('UNPAID', 'Unpaid'),
        ('PARTIAL', 'Partial'),
        ('PAID', 'Paid'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    material_type = models.CharField(max_length=100)
    quantity = models.DecimalField(max_digits=10, decimal_places=2)
    unit = models.CharField(max_length=50, null=True, blank=True)
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    total_amount = models.DecimalField(max_digits=15, decimal_places=2)
    bill_number = models.CharField(max_length=100, null=True, blank=True)
    bill_url = models.TextField(null=True, blank=True)
    vendor_name = models.CharField(max_length=255, null=True, blank=True)
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='uploaded_by')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    bill_date = models.DateField()
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='UNPAID')
    notes = models.TextField(null=True, blank=True)
    
    class Meta:
        db_table = 'bills'
        indexes = [
            models.Index(fields=['site']),
            models.Index(fields=['bill_date']),
            models.Index(fields=['material_type']),
            models.Index(fields=['payment_status']),
        ]
    
    def __str__(self):
        return f"{self.site.site_name} - {self.material_type} - {self.total_amount}"


class ExtraWork(models.Model):
    """Extra work bills and payments"""
    PAYMENT_STATUS_CHOICES = [
        ('UNPAID', 'Unpaid'),
        ('PARTIAL', 'Partial'),
        ('PAID', 'Paid'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    description = models.TextField()
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    bill_url = models.TextField(null=True, blank=True)
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='UNPAID')
    due_date = models.DateField(null=True, blank=True)
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='uploaded_by')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    paid_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    payment_date = models.DateField(null=True, blank=True)
    notes = models.TextField(null=True, blank=True)
    
    class Meta:
        db_table = 'extra_works'
        indexes = [
            models.Index(fields=['site']),
            models.Index(fields=['payment_status']),
            models.Index(fields=['due_date']),
        ]
    
    def __str__(self):
        return f"{self.site.site_name} - {self.description[:50]} - {self.amount}"


class AuditLog(models.Model):
    """Audit trail for all modifications"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    action = models.CharField(max_length=100)
    table_name = models.CharField(max_length=100, null=True, blank=True)
    record_id = models.UUIDField(null=True, blank=True)
    performed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='performed_by')
    old_values = models.JSONField(null=True, blank=True)
    new_values = models.JSONField(null=True, blank=True)
    ip_address = models.CharField(max_length=50, null=True, blank=True)
    user_agent = models.TextField(null=True, blank=True)
    timestamp = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'audit_logs'
        indexes = [
            models.Index(fields=['performed_by']),
            models.Index(fields=['timestamp']),
            models.Index(fields=['action']),
        ]
    
    def __str__(self):
        return f"{self.action} by {self.performed_by} at {self.timestamp}"
