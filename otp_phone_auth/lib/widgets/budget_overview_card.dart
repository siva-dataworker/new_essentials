import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

class BudgetOverviewCard extends StatefulWidget {
  final String siteId;
  final String siteName;
  final VoidCallback? onTap;

  const BudgetOverviewCard({
    Key? key,
    required this.siteId,
    required this.siteName,
    this.onTap,
  }) : super(key: key);

  @override
  State<BudgetOverviewCard> createState() => _BudgetOverviewCardState();
}

class _BudgetOverviewCardState extends State<BudgetOverviewCard> {
  final _budgetService = BudgetService();
  SiteBudget? _budget;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    setState(() => _isLoading = true);
    try {
      final budgetData = await _budgetService.getSiteBudget(widget.siteId);
      setState(() {
        _budget = budgetData != null ? SiteBudget.fromJson(budgetData) : null;
      });
    } catch (e) {
      print('Error loading budget: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _budget == null
                  ? _buildNoBudget()
                  : _buildBudgetInfo(),
        ),
      ),
    );
  }

  Widget _buildNoBudget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.grey.shade400),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                widget.siteName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'No budget allocated',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetInfo() {
    final budget = _budget!;
    final utilizationColor = budget.utilizationPercentage > 80
        ? Colors.red
        : budget.utilizationPercentage > 50
            ? Colors.orange
            : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.blue.shade700),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      widget.siteName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'ACTIVE',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Budget amounts
        _buildAmountRow(
          'Allocated',
          budget.formattedAllocated,
          Colors.blue.shade700,
        ),
        SizedBox(height: 8.h),
        _buildAmountRow(
          'Utilized',
          budget.formattedUtilized,
          Colors.orange.shade700,
        ),
        SizedBox(height: 8.h),
        _buildAmountRow(
          'Remaining',
          budget.formattedRemaining,
          Colors.green.shade700,
        ),
        SizedBox(height: 16.h),

        // Progress bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Utilization',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${budget.utilizationPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: utilizationColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: budget.utilizationPercentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(utilizationColor),
                minHeight: 8,
              ),
            ),
          ],
        ),

        // Allocated by
        if (budget.allocatedBy != null) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.person, size: 14.sp, color: Colors.grey.shade600),
              SizedBox(width: 4.w),
              Text(
                'By ${budget.allocatedBy}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAmountRow(String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
