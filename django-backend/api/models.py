from django.db import models


class Role(models.Model):
    """Role model - Admin managed"""
    role_id = models.AutoField(primary_key=True)
    role_name = models.CharField(max_length=50, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'roles'
        managed = False  # Don't let Django manage this table
    
    def __str__(self):
        return self.role_name


class User(models.Model):
    """User model"""
    user_id = models.AutoField(primary_key=True)
    full_name = models.CharField(max_length=100, null=True, blank=True)
    email = models.EmailField(max_length=150, unique=True)
    phone = models.CharField(max_length=15, null=True, blank=True)
    role = models.ForeignKey(Role, on_delete=models.SET_NULL, null=True, db_column='role_id')
    role_locked = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'users'
        managed = False  # Don't let Django manage this table
    
    def __str__(self):
        return f"{self.full_name or self.email} ({self.role.role_name if self.role else 'No Role'})"


class Site(models.Model):
    """Site/Project model"""
    site_id = models.AutoField(primary_key=True)
    site_name = models.CharField(max_length=100)
    location = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'sites'
        managed = False  # Don't let Django manage this table
    
    def __str__(self):
        return self.site_name


class MaterialMaster(models.Model):
    """Material Master - Unique materials only"""
    material_id = models.AutoField(primary_key=True)
    material_name = models.CharField(max_length=100, unique=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='created_by')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'material_master'
        managed = False
    
    def __str__(self):
        return self.material_name


class DailySiteReport(models.Model):
    """Daily Site Report - One site per day"""
    report_id = models.AutoField(primary_key=True)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    report_date = models.DateField()
    status = models.CharField(max_length=20, default='OPEN')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'daily_site_report'
        managed = False
        unique_together = [['site', 'report_date']]
    
    def __str__(self):
        return f"{self.site.site_name} - {self.report_date}"


class DailyLabourSummary(models.Model):
    """Daily Labour Summary"""
    labour_summary_id = models.AutoField(primary_key=True)
    report = models.ForeignKey(DailySiteReport, on_delete=models.CASCADE, db_column='report_id')
    labour_count = models.IntegerField()
    locked = models.BooleanField(default=True)
    entered_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='entered_by')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'daily_labour_summary'
        managed = False


class DailySalaryEntry(models.Model):
    """Daily Salary Entry - Entered by Supervisor"""
    salary_id = models.AutoField(primary_key=True)
    report = models.ForeignKey(DailySiteReport, on_delete=models.CASCADE, db_column='report_id')
    total_salary = models.DecimalField(max_digits=10, decimal_places=2)
    entered_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='entered_by')
    verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'daily_salary_entry'
        managed = False


class DailyMaterialBalance(models.Model):
    """Daily Material Balance"""
    balance_id = models.AutoField(primary_key=True)
    report = models.ForeignKey(DailySiteReport, on_delete=models.CASCADE, db_column='report_id')
    material = models.ForeignKey(MaterialMaster, on_delete=models.CASCADE, db_column='material_id')
    remaining_quantity = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'daily_material_balance'
        managed = False
        unique_together = [['report', 'material']]


class MaterialBill(models.Model):
    """Material Bills - Uploaded by Supervisor"""
    bill_id = models.AutoField(primary_key=True)
    report = models.ForeignKey(DailySiteReport, on_delete=models.CASCADE, db_column='report_id')
    material = models.ForeignKey(MaterialMaster, on_delete=models.CASCADE, db_column='material_id')
    bill_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    bill_image = models.TextField(null=True)
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='uploaded_by')
    verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'material_bills'
        managed = False


class WorkActivity(models.Model):
    """Work Activity - Photos by Site Engineer"""
    ACTIVITY_CHOICES = [
        ('WORK_STARTED', 'Work Started'),
        ('WORK_COMPLETED', 'Work Completed'),
    ]
    
    activity_id = models.AutoField(primary_key=True)
    report = models.ForeignKey(DailySiteReport, on_delete=models.CASCADE, db_column='report_id')
    activity_type = models.CharField(max_length=30, choices=ACTIVITY_CHOICES)
    image_path = models.TextField()
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='uploaded_by')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'work_activity'
        managed = False


class Notification(models.Model):
    """Notifications - WhatsApp / App"""
    SENT_VIA_CHOICES = [
        ('WHATSAPP', 'WhatsApp'),
        ('APP', 'App'),
    ]
    
    notification_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column='user_id')
    message = models.TextField(null=True)
    sent_via = models.CharField(max_length=20, choices=SENT_VIA_CHOICES)
    status = models.CharField(max_length=20, default='SENT')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'notifications'
        managed = False


class Complaint(models.Model):
    """Complaints"""
    complaint_id = models.AutoField(primary_key=True)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    report = models.ForeignKey(DailySiteReport, on_delete=models.CASCADE, db_column='report_id', null=True)
    description = models.TextField(null=True)
    status = models.CharField(max_length=20, default='OPEN')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'complaints'
        managed = False


class ComplaintAction(models.Model):
    """Complaint Actions"""
    action_id = models.AutoField(primary_key=True)
    complaint = models.ForeignKey(Complaint, on_delete=models.CASCADE, db_column='complaint_id')
    report = models.ForeignKey(DailySiteReport, on_delete=models.CASCADE, db_column='report_id', null=True)
    image_path = models.TextField(null=True)
    resolved_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='resolved_by')
    status = models.CharField(max_length=20, default='RESOLVED')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'complaint_actions'
        managed = False


class AuditLog(models.Model):
    """Audit Logs - For edits & verification"""
    audit_id = models.AutoField(primary_key=True)
    table_name = models.CharField(max_length=50, null=True)
    record_id = models.IntegerField(null=True)
    field_name = models.CharField(max_length=50, null=True)
    old_value = models.TextField(null=True)
    new_value = models.TextField(null=True)
    changed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='changed_by')
    changed_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'audit_logs'
        managed = False


class AdminRoleChangeLog(models.Model):
    """Admin Role Change Log"""
    log_id = models.AutoField(primary_key=True)
    admin = models.ForeignKey(User, on_delete=models.CASCADE, related_name='admin_changes', db_column='admin_id')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='role_changes', db_column='user_id')
    old_role = models.ForeignKey(Role, on_delete=models.SET_NULL, null=True, related_name='old_roles', db_column='old_role')
    new_role = models.ForeignKey(Role, on_delete=models.SET_NULL, null=True, related_name='new_roles', db_column='new_role')
    changed_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'admin_role_change_log'
        managed = False


# ============================================
# NEW ADMIN FEATURES MODELS
# ============================================

class SiteMetrics(models.Model):
    """Site Metrics - Built-up area, project value, P/L"""
    metrics_id = models.AutoField(primary_key=True)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    built_up_area = models.DecimalField(max_digits=10, decimal_places=2, null=True, help_text='in sq ft')
    project_value = models.DecimalField(max_digits=15, decimal_places=2, null=True)
    total_cost = models.DecimalField(max_digits=15, decimal_places=2, null=True)
    profit_loss = models.DecimalField(max_digits=15, decimal_places=2, null=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'site_metrics'
        managed = False
    
    def __str__(self):
        return f"{self.site.site_name} Metrics"


class SiteDocument(models.Model):
    """Site Documents - Plans, elevations, structure, final output"""
    DOCUMENT_TYPES = [
        ('PLAN', 'Plan'),
        ('ELEVATION', 'Elevation'),
        ('STRUCTURE', 'Structure'),
        ('FINAL_OUTPUT', 'Final Output'),
    ]
    
    document_id = models.AutoField(primary_key=True)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    document_type = models.CharField(max_length=20, choices=DOCUMENT_TYPES)
    document_name = models.CharField(max_length=200)
    file_path = models.TextField()
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, db_column='uploaded_by')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'site_documents'
        managed = False
    
    def __str__(self):
        return f"{self.site.site_name} - {self.document_type}"


class AdminAccessLog(models.Model):
    """Admin Access Log - Track specialized logins"""
    ACCESS_TYPES = [
        ('LABOUR_COUNT', 'Labour Count Only'),
        ('BILLS_VIEW', 'Bills Viewing Only'),
        ('FULL_ACCOUNTS', 'Complete Accounts'),
    ]
    
    log_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column='user_id')
    access_type = models.CharField(max_length=20, choices=ACCESS_TYPES)
    site = models.ForeignKey(Site, on_delete=models.SET_NULL, null=True, db_column='site_id')
    accessed_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'admin_access_log'
        managed = False


class WorkNotification(models.Model):
    """Work Notifications - Sent to chief accountant/owner"""
    notification_id = models.AutoField(primary_key=True)
    site = models.ForeignKey(Site, on_delete=models.CASCADE, db_column='site_id')
    report = models.ForeignKey(DailySiteReport, on_delete=models.CASCADE, db_column='report_id', null=True)
    notification_type = models.CharField(max_length=50)  # WORK_NOT_DONE, MISSING_DATA, etc.
    message = models.TextField()
    sent_to = models.ForeignKey(User, on_delete=models.CASCADE, db_column='sent_to')
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'work_notifications'
        managed = False
