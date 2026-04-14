# OLD WORKING URLs - Full CRUD API with ViewSets
# This was the original working backend before Firebase integration

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views_working_old as views

router = DefaultRouter()
router.register(r'roles', views.RoleViewSet, basename='role')
router.register(r'users', views.UserViewSet, basename='user')
router.register(r'sites', views.SiteViewSet, basename='site')
router.register(r'materials', views.MaterialMasterViewSet, basename='material')
router.register(r'daily-reports', views.DailySiteReportViewSet, basename='daily-report')
router.register(r'labour-summary', views.DailyLabourSummaryViewSet, basename='labour-summary')
router.register(r'salary-entries', views.DailySalaryEntryViewSet, basename='salary-entry')
router.register(r'material-balance', views.DailyMaterialBalanceViewSet, basename='material-balance')
router.register(r'material-bills', views.MaterialBillViewSet, basename='material-bill')
router.register(r'work-activities', views.WorkActivityViewSet, basename='work-activity')
router.register(r'notifications', views.NotificationViewSet, basename='notification')
router.register(r'complaints', views.ComplaintViewSet, basename='complaint')
router.register(r'complaint-actions', views.ComplaintActionViewSet, basename='complaint-action')
router.register(r'audit-logs', views.AuditLogViewSet, basename='audit-log')
router.register(r'role-change-logs', views.AdminRoleChangeLogViewSet, basename='role-change-log')

urlpatterns = [
    path('health/', views.health_check, name='health'),
    path('health/db/', views.database_health, name='database-health'),
    path('', include(router.urls)),
]
