class SiteBudget {
  final String budgetId;
  final String siteId;
  final String siteName;
  final double allocatedAmount;
  final double utilizedAmount;
  final double remainingAmount;
  final String? allocatedBy;
  final DateTime? allocatedAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool? hasBudget;

  SiteBudget({
    required this.budgetId,
    required this.siteId,
    required this.siteName,
    required this.allocatedAmount,
    required this.utilizedAmount,
    required this.remainingAmount,
    this.allocatedBy,
    this.allocatedAt,
    this.updatedAt,
    this.isActive = true,
    this.hasBudget,
  });

  factory SiteBudget.fromJson(Map<String, dynamic> json) {
    return SiteBudget(
      budgetId: json['budget_id'] ?? '',
      siteId: json['site_id'] ?? '',
      siteName: json['site_name'] ?? '',
      allocatedAmount: (json['allocated_amount'] ?? 0).toDouble(),
      utilizedAmount: (json['utilized_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      allocatedBy: json['allocated_by'],
      allocatedAt: json['allocated_at'] != null 
          ? DateTime.parse(json['allocated_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      isActive: json['is_active'] ?? true,
      hasBudget: json['has_budget'],
    );
  }

  double get utilizationPercentage {
    if (allocatedAmount == 0) return 0;
    return (utilizedAmount / allocatedAmount) * 100;
  }

  String get formattedAllocated => '₹${_formatCurrency(allocatedAmount)}';
  String get formattedUtilized => '₹${_formatCurrency(utilizedAmount)}';
  String get formattedRemaining => '₹${_formatCurrency(remainingAmount)}';

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)} K';
    }
    return amount.toStringAsFixed(2);
  }
}

class RealTimeUpdate {
  final String updateId;
  final String siteId;
  final String siteName;
  final String updateType;
  final String recordType;
  final String recordId;
  final String action;
  final String changedBy;
  final DateTime changedAt;

  RealTimeUpdate({
    required this.updateId,
    required this.siteId,
    required this.siteName,
    required this.updateType,
    required this.recordType,
    required this.recordId,
    required this.action,
    required this.changedBy,
    required this.changedAt,
  });

  factory RealTimeUpdate.fromJson(Map<String, dynamic> json) {
    return RealTimeUpdate(
      updateId: json['update_id'] ?? '',
      siteId: json['site_id'] ?? '',
      siteName: json['site_name'] ?? '',
      updateType: json['update_type'] ?? '',
      recordType: json['record_type'] ?? '',
      recordId: json['record_id'] ?? '',
      action: json['action'] ?? '',
      changedBy: json['changed_by'] ?? '',
      changedAt: DateTime.parse(json['changed_at']),
    );
  }

  String get updateTypeDisplay {
    switch (updateType) {
      case 'LABOUR_ENTRY':
        return 'Labour Entry';
      case 'LABOUR_CORRECTION':
        return 'Labour Correction';
      case 'BILL_UPLOAD':
        return 'Bill Upload';
      case 'BUDGET_UPDATE':
        return 'Budget Update';
      default:
        return updateType;
    }
  }

  String get actionDisplay {
    switch (action) {
      case 'CREATE':
        return 'Created';
      case 'UPDATE':
        return 'Updated';
      case 'DELETE':
        return 'Deleted';
      default:
        return action;
    }
  }
}

class AuditLog {
  final String auditId;
  final String tableName;
  final String recordId;
  final String fieldName;
  final String? oldValue;
  final String? newValue;
  final String changeType;
  final String changedBy;
  final String changedByRole;
  final DateTime changedAt;
  final String? reason;

  AuditLog({
    required this.auditId,
    required this.tableName,
    required this.recordId,
    required this.fieldName,
    this.oldValue,
    this.newValue,
    required this.changeType,
    required this.changedBy,
    required this.changedByRole,
    required this.changedAt,
    this.reason,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      auditId: json['audit_id'] ?? '',
      tableName: json['table_name'] ?? '',
      recordId: json['record_id'] ?? '',
      fieldName: json['field_name'] ?? '',
      oldValue: json['old_value'],
      newValue: json['new_value'],
      changeType: json['change_type'] ?? '',
      changedBy: json['changed_by'] ?? '',
      changedByRole: json['changed_by_role'] ?? '',
      changedAt: DateTime.parse(json['changed_at']),
      reason: json['reason'],
    );
  }

  String get changeTypeDisplay {
    switch (changeType) {
      case 'CREATE':
        return 'Created';
      case 'UPDATE':
        return 'Updated';
      case 'DELETE':
        return 'Deleted';
      default:
        return changeType;
    }
  }
}
