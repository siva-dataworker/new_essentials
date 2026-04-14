from django.contrib import admin
from .models import (
    Role, User, Site, MaterialMaster, DailySiteReport,
    DailyLabourSummary, DailySalaryEntry, DailyMaterialBalance,
    MaterialBill, WorkActivity, Notification, Complaint,
    ComplaintAction, AuditLog, AdminRoleChangeLog
)


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ['role_id', 'role_name', 'created_at']
    search_fields = ['role_name']


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['user_id', 'full_name', 'email', 'phone', 'role', 'is_active', 'created_at']
    list_filter = ['role', 'is_active', 'role_locked']
    search_fields = ['full_name', 'email', 'phone']


@admin.register(Site)
class SiteAdmin(admin.ModelAdmin):
    list_display = ['site_id', 'site_name', 'location', 'created_at']
    search_fields = ['site_name', 'location']


@admin.register(MaterialMaster)
class MaterialMasterAdmin(admin.ModelAdmin):
    list_display = ['material_id', 'material_name', 'created_by', 'created_at']
    search_fields = ['material_name']


@admin.register(DailySiteReport)
class DailySiteReportAdmin(admin.ModelAdmin):
    list_display = ['report_id', 'site', 'report_date', 'status', 'created_at']
    list_filter = ['status', 'report_date']
    search_fields = ['site__site_name']


@admin.register(DailyLabourSummary)
class DailyLabourSummaryAdmin(admin.ModelAdmin):
    list_display = ['labour_summary_id', 'report', 'labour_count', 'locked', 'entered_by', 'created_at']
    list_filter = ['locked']


@admin.register(DailySalaryEntry)
class DailySalaryEntryAdmin(admin.ModelAdmin):
    list_display = ['salary_id', 'report', 'total_salary', 'entered_by', 'verified', 'created_at']
    list_filter = ['verified']


@admin.register(DailyMaterialBalance)
class DailyMaterialBalanceAdmin(admin.ModelAdmin):
    list_display = ['balance_id', 'report', 'material', 'remaining_quantity', 'created_at']


@admin.register(MaterialBill)
class MaterialBillAdmin(admin.ModelAdmin):
    list_display = ['bill_id', 'report', 'material', 'bill_amount', 'uploaded_by', 'verified', 'created_at']
    list_filter = ['verified']


@admin.register(WorkActivity)
class WorkActivityAdmin(admin.ModelAdmin):
    list_display = ['activity_id', 'report', 'activity_type', 'uploaded_by', 'uploaded_at']
    list_filter = ['activity_type']


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ['notification_id', 'user', 'sent_via', 'status', 'created_at']
    list_filter = ['sent_via', 'status']


@admin.register(Complaint)
class ComplaintAdmin(admin.ModelAdmin):
    list_display = ['complaint_id', 'site', 'status', 'created_at']
    list_filter = ['status']


@admin.register(ComplaintAction)
class ComplaintActionAdmin(admin.ModelAdmin):
    list_display = ['action_id', 'complaint', 'resolved_by', 'status', 'created_at']
    list_filter = ['status']


@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ['audit_id', 'table_name', 'record_id', 'field_name', 'changed_by', 'changed_at']
    list_filter = ['table_name']
    search_fields = ['table_name', 'field_name']


@admin.register(AdminRoleChangeLog)
class AdminRoleChangeLogAdmin(admin.ModelAdmin):
    list_display = ['log_id', 'admin', 'user', 'old_role', 'new_role', 'changed_at']
