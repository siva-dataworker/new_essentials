"""
URL Configuration for Budget Management APIs
"""
from django.urls import path
from . import views_budget

urlpatterns = [
    # Budget Management
    path('admin/sites/budget/set/', views_budget.set_budget, name='set_budget'),
    path('admin/sites/<int:site_id>/budget/', views_budget.get_budget, name='get_budget'),
    path('admin/sites/<int:site_id>/budget/utilization/', views_budget.get_budget_utilization, name='get_budget_utilization'),
    path('admin/budgets/all/', views_budget.get_all_sites_budgets, name='get_all_sites_budgets'),
    
    # Real-time Updates
    path('admin/realtime-updates/', views_budget.get_realtime_updates, name='get_realtime_updates'),
    
    # Audit Trail
    path('admin/sites/<int:site_id>/audit-trail/', views_budget.get_audit_trail, name='get_audit_trail'),
]
