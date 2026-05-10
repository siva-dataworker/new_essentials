"""
Cash Entries Management
Endpoints for managing accountant-confirmed cash payments.
The total_salary table has been removed; salary totals are computed
directly from cash_entries at query time.
"""
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .authentication import JWTAuthentication
from .database import fetch_all


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_cash_entries(request):
    """
    Get cash entries with optional filters.
    GET /api/construction/cash-entries/
    Query params:
      - site_id      (optional)
      - start_date   (optional) YYYY-MM-DD
      - end_date     (optional) YYYY-MM-DD
      - accountant_id (optional)
    """
    try:
        site_id      = request.query_params.get('site_id')
        start_date   = request.query_params.get('start_date')
        end_date     = request.query_params.get('end_date')
        accountant_id = request.query_params.get('accountant_id')

        query = """
            SELECT
                c.id,
                c.site_id,
                s.site_name,
                s.customer_name,
                s.area,
                s.street,
                c.accountant_id,
                u.full_name AS accountant_name,
                c.entry_date,
                c.source_type,
                c.source_entry_id,
                c.labour_type,
                c.labour_count,
                c.daily_rate,
                c.total_cost,
                c.notes,
                c.submitted_by_name,
                c.created_at,
                c.updated_at
            FROM cash_entries c
            JOIN sites s ON c.site_id = s.id
            JOIN users u ON c.accountant_id = u.id
            WHERE 1=1
        """
        params = []

        if site_id:
            query += " AND c.site_id = %s"
            params.append(site_id)
        if start_date:
            query += " AND c.entry_date >= %s"
            params.append(start_date)
        if end_date:
            query += " AND c.entry_date <= %s"
            params.append(end_date)
        if accountant_id:
            query += " AND c.accountant_id = %s"
            params.append(accountant_id)

        query += " ORDER BY c.entry_date DESC, c.created_at DESC"

        cash_entries = fetch_all(query, tuple(params) if params else None)

        formatted_entries = [
            {
                'id':               str(e['id']),
                'site_id':          str(e['site_id']),
                'site_name':        e['site_name'],
                'customer_name':    e['customer_name'],
                'area':             e['area'],
                'street':           e['street'],
                'accountant_id':    str(e['accountant_id']),
                'accountant_name':  e['accountant_name'],
                'entry_date':       e['entry_date'].isoformat() if e['entry_date'] else None,
                'source_type':      e['source_type'],
                'source_entry_id':  str(e['source_entry_id']) if e['source_entry_id'] else None,
                'labour_type':      e['labour_type'],
                'labour_count':     e['labour_count'],
                'daily_rate':       float(e['daily_rate']),
                'total_cost':       float(e['total_cost']),
                'notes':            e['notes'],
                'submitted_by_name': e['submitted_by_name'],
                'created_at':       e['created_at'].isoformat() if e['created_at'] else None,
                'updated_at':       e['updated_at'].isoformat() if e['updated_at'] else None,
            }
            for e in cash_entries
        ]

        total_cash_paid = sum(float(e['total_cost']) for e in formatted_entries)
        total_workers   = sum(e['labour_count']      for e in formatted_entries)

        return Response({
            'cash_entries': formatted_entries,
            'total_count':  len(formatted_entries),
            'summary': {
                'total_cash_paid': total_cash_paid,
                'total_workers':   total_workers,
            },
        }, status=status.HTTP_200_OK)

    except Exception as e:
        print(f"❌ [CASH ENTRIES] Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_cash_entries_summary(request):
    """
    Total confirmed salary from cash_entries, grouped by site.
    This is the single source of truth for approved/paid amounts.

    GET /api/construction/cash-entries/summary/
    Query params:
      - site_id    (optional) – filter to a single site
      - start_date (optional) YYYY-MM-DD
      - end_date   (optional) YYYY-MM-DD

    Returns:
      overall_total, overall_workers,
      by_site: [{site_id, site_name, customer_name, total_cost, total_workers, days_count}]
    """
    try:
        site_id    = request.query_params.get('site_id')
        start_date = request.query_params.get('start_date')
        end_date   = request.query_params.get('end_date')

        conditions = ["1=1"]
        params = []

        if site_id:
            conditions.append("c.site_id = %s")
            params.append(site_id)
        if start_date:
            conditions.append("c.entry_date >= %s")
            params.append(start_date)
        if end_date:
            conditions.append("c.entry_date <= %s")
            params.append(end_date)

        where = " AND ".join(conditions)

        site_query = f"""
            SELECT
                c.site_id,
                s.site_name,
                s.customer_name,
                s.area,
                s.street,
                COALESCE(SUM(c.total_cost),   0) AS total_cost,
                COALESCE(SUM(c.labour_count), 0) AS total_workers,
                COUNT(DISTINCT c.entry_date)     AS days_count
            FROM cash_entries c
            JOIN sites s ON c.site_id = s.id
            WHERE {where}
            GROUP BY c.site_id, s.site_name, s.customer_name, s.area, s.street
            ORDER BY s.customer_name, s.site_name
        """
        site_rows = fetch_all(site_query, tuple(params) if params else None)

        by_site = [
            {
                'site_id':       str(r['site_id']),
                'site_name':     r['site_name'],
                'customer_name': r['customer_name'],
                'area':          r['area'],
                'street':        r['street'],
                'total_cost':    float(r['total_cost']),
                'total_workers': int(r['total_workers']),
                'days_count':    int(r['days_count']),
            }
            for r in site_rows
        ]

        overall_total   = sum(s['total_cost']    for s in by_site)
        overall_workers = sum(s['total_workers'] for s in by_site)

        return Response({
            'success':         True,
            'overall_total':   overall_total,
            'overall_workers': overall_workers,
            'by_site':         by_site,
            'site_count':      len(by_site),
        }, status=status.HTTP_200_OK)

    except Exception as e:
        print(f"❌ [CASH SUMMARY] Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
