from rest_framework import serializers
from .models import (
    Role, User, Site, MaterialMaster, DailySiteReport,
    DailyLabourSummary, DailySalaryEntry, DailyMaterialBalance,
    MaterialBill, WorkActivity, Notification, Complaint,
    ComplaintAction, AuditLog, AdminRoleChangeLog
)


class RoleSerializer(serializers.ModelSerializer):
    """Serializer for Role model"""
    class Meta:
        model = Role
        fields = ['role_id', 'role_name', 'created_at']
        read_only_fields = ['role_id', 'created_at']


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User model"""
    role_name = serializers.CharField(source='role.role_name', read_only=True)
    
    class Meta:
        model = User
        fields = ['user_id', 'full_name', 'email', 'phone', 'role', 'role_name', 'role_locked', 'is_active', 'created_at']
        read_only_fields = ['user_id', 'created_at']


class SiteSerializer(serializers.ModelSerializer):
    """Serializer for Site model"""
    class Meta:
        model = Site
        fields = ['site_id', 'site_name', 'location', 'created_at']
        read_only_fields = ['site_id', 'created_at']


class MaterialMasterSerializer(serializers.ModelSerializer):
    """Serializer for Material Master"""
    class Meta:
        model = MaterialMaster
        fields = ['material_id', 'material_name', 'created_by', 'created_at']
        read_only_fields = ['material_id', 'created_at']


class DailySiteReportSerializer(serializers.ModelSerializer):
    """Serializer for Daily Site Report"""
    site_name = serializers.CharField(source='site.site_name', read_only=True)
    
    class Meta:
        model = DailySiteReport
        fields = ['report_id', 'site', 'site_name', 'report_date', 'status', 'created_at']
        read_only_fields = ['report_id', 'created_at']


class DailyLabourSummarySerializer(serializers.ModelSerializer):
    """Serializer for Daily Labour Summary"""
    class Meta:
        model = DailyLabourSummary
        fields = ['labour_summary_id', 'report', 'labour_count', 'locked', 'entered_by', 'created_at']
        read_only_fields = ['labour_summary_id', 'created_at']


class DailySalaryEntrySerializer(serializers.ModelSerializer):
    """Serializer for Daily Salary Entry"""
    class Meta:
        model = DailySalaryEntry
        fields = ['salary_id', 'report', 'total_salary', 'entered_by', 'verified', 'created_at']
        read_only_fields = ['salary_id', 'created_at']


class DailyMaterialBalanceSerializer(serializers.ModelSerializer):
    """Serializer for Daily Material Balance"""
    material_name = serializers.CharField(source='material.material_name', read_only=True)
    
    class Meta:
        model = DailyMaterialBalance
        fields = ['balance_id', 'report', 'material', 'material_name', 'remaining_quantity', 'created_at']
        read_only_fields = ['balance_id', 'created_at']


class MaterialBillSerializer(serializers.ModelSerializer):
    """Serializer for Material Bills"""
    material_name = serializers.CharField(source='material.material_name', read_only=True)
    
    class Meta:
        model = MaterialBill
        fields = ['bill_id', 'report', 'material', 'material_name', 'bill_amount', 'bill_image', 'uploaded_by', 'verified', 'created_at']
        read_only_fields = ['bill_id', 'created_at']


class WorkActivitySerializer(serializers.ModelSerializer):
    """Serializer for Work Activity"""
    class Meta:
        model = WorkActivity
        fields = ['activity_id', 'report', 'activity_type', 'image_path', 'uploaded_by', 'uploaded_at']
        read_only_fields = ['activity_id', 'uploaded_at']


class NotificationSerializer(serializers.ModelSerializer):
    """Serializer for Notifications"""
    class Meta:
        model = Notification
        fields = ['notification_id', 'user', 'message', 'sent_via', 'status', 'created_at']
        read_only_fields = ['notification_id', 'created_at']


class ComplaintSerializer(serializers.ModelSerializer):
    """Serializer for Complaints"""
    site_name = serializers.CharField(source='site.site_name', read_only=True)
    
    class Meta:
        model = Complaint
        fields = ['complaint_id', 'site', 'site_name', 'report', 'description', 'status', 'created_at']
        read_only_fields = ['complaint_id', 'created_at']


class ComplaintActionSerializer(serializers.ModelSerializer):
    """Serializer for Complaint Actions"""
    class Meta:
        model = ComplaintAction
        fields = ['action_id', 'complaint', 'report', 'image_path', 'resolved_by', 'status', 'created_at']
        read_only_fields = ['action_id', 'created_at']


class AuditLogSerializer(serializers.ModelSerializer):
    """Serializer for Audit Logs"""
    class Meta:
        model = AuditLog
        fields = ['audit_id', 'table_name', 'record_id', 'field_name', 'old_value', 'new_value', 'changed_by', 'changed_at']
        read_only_fields = ['audit_id', 'changed_at']


class AdminRoleChangeLogSerializer(serializers.ModelSerializer):
    """Serializer for Admin Role Change Log"""
    class Meta:
        model = AdminRoleChangeLog
        fields = ['log_id', 'admin', 'user', 'old_role', 'new_role', 'changed_at']
        read_only_fields = ['log_id', 'changed_at']
