"""
Accountant Documents API Views
- Material Bills
- Vendor Bills
- Site Agreements
"""
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .authentication import JWTAuthentication
from .database import fetch_all, fetch_one, execute_query
from datetime import datetime
import uuid
import os

# ============================================
# MATERIAL BILLS APIs
# ============================================

@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def upload_material_bill(request):
    """
    Accountant: Upload material bill (tiles, cement, steel, etc.)
    POST /api/construction/upload-material-bill/
    """
    try:
        from django.core.files.storage import default_storage
        from django.conf import settings
        from .time_utils import get_day_of_week
        
        user_id = request.user['user_id']
        site_id = request.data.get('site_id')
        
        # Bill Information
        bill_number = request.data.get('bill_number')
        bill_date = request.data.get('bill_date')
        vendor_name = request.data.get('vendor_name')
        vendor_type = request.data.get('vendor_type')
        
        # Material Details
        material_type = request.data.get('material_type')
        quantity = request.data.get('quantity')
        unit = request.data.get('unit')
        
        # Financial Details
        unit_price = request.data.get('unit_price')
        total_amount = request.data.get('total_amount')
        tax_amount = request.data.get('tax_amount', 0)
        discount_amount = request.data.get('discount_amount', 0)
        final_amount = request.data.get('final_amount')
        
        # Payment Details
        payment_status = request.data.get('payment_status', 'PENDING')
        payment_mode = request.data.get('payment_mode')
        payment_date = request.data.get('payment_date')
        
        # Additional
        notes = request.data.get('notes', '')
        description = request.data.get('description', '')
        
        file = request.FILES.get('file')
        
        if not all([site_id, bill_number, bill_date, vendor_name, vendor_type, material_type, quantity, unit, unit_price, total_amount, final_amount, file]):
            return Response({'error': 'Missing required fields'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate file type (PDF only)
        if not file.name.lower().endswith('.pdf'):
            return Response({'error': 'Only PDF files are allowed'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Create media directory
        media_dir = os.path.join(settings.MEDIA_ROOT, 'material_bills')
        os.makedirs(media_dir, exist_ok=True)
        
        # Generate unique filename
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        ext = os.path.splitext(file.name)[1]
        filename = f"{site_id}_MaterialBill_{bill_number}_{timestamp}{ext}"
        filepath = os.path.join('material_bills', filename)
        
        # Save file
        saved_path = default_storage.save(filepath, file)
        file_url = f"{settings.MEDIA_URL}{saved_path}"
        
        # Get current date and day of week
        today = datetime.now().date()
        day_of_week = get_day_of_week(datetime.now())
        
        # Insert into database
        bill_id = str(uuid.uuid4())
        file_type = 'application/pdf'  # Since we only allow PDF files
        
        execute_query("""
            INSERT INTO material_bills 
            (id, site_id, uploaded_by, bill_number, bill_date, vendor_name, vendor_type,
             material_type, quantity, unit, unit_price, total_amount, tax_amount, discount_amount, final_amount,
             payment_status, payment_mode, payment_date, file_url, file_name, file_type, file_size, notes, description,
             upload_date, day_of_week)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (bill_id, site_id, user_id, bill_number, bill_date, vendor_name, vendor_type,
              material_type, quantity, unit, unit_price, total_amount, tax_amount, discount_amount, final_amount,
              payment_status, payment_mode, payment_date, file_url, file.name, file_type, file.size, notes, description,
              today, day_of_week))
        
        return Response({
            'message': 'Material bill uploaded successfully',
            'bill_id': bill_id,
            'file_url': file_url,
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_material_bills(request):
    """
    Get material bills with optional filters
    GET /api/construction/material-bills/
    """
    try:
        site_id = request.query_params.get('site_id')
        vendor_type = request.query_params.get('vendor_type')
        material_type = request.query_params.get('material_type')
        payment_status = request.query_params.get('payment_status')
        
        query = """
            SELECT 
                mb.*,
                s.site_name,
                s.area,
                s.street,
                u.full_name as uploaded_by_name
            FROM material_bills mb
            JOIN sites s ON mb.site_id = s.id
            JOIN users u ON mb.uploaded_by = u.id
            WHERE mb.is_active = TRUE
        """
        
        params = []
        
        if site_id:
            query += " AND mb.site_id = %s"
            params.append(site_id)
        
        if vendor_type:
            query += " AND mb.vendor_type = %s"
            params.append(vendor_type)
        
        if material_type:
            query += " AND mb.material_type = %s"
            params.append(material_type)
        
        if payment_status:
            query += " AND mb.payment_status = %s"
            params.append(payment_status)
        
        query += " ORDER BY mb.bill_date DESC LIMIT 200"
        
        bills = fetch_all(query, tuple(params) if params else None)
        
        return Response({
            'bills': [
                {
                    'id': str(b['id']),
                    'site_id': str(b['site_id']),
                    'site_name': b['site_name'],
                    'bill_number': b['bill_number'],
                    'bill_date': b['bill_date'].isoformat() if b['bill_date'] else None,
                    'vendor_name': b['vendor_name'],
                    'vendor_type': b['vendor_type'],
                    'material_type': b['material_type'],
                    'quantity': float(b['quantity']),
                    'unit': b['unit'],
                    'unit_price': float(b['unit_price']),
                    'total_amount': float(b['total_amount']),
                    'final_amount': float(b['final_amount']),
                    'payment_status': b['payment_status'],
                    'file_url': b['file_url'],
                    'uploaded_by_name': b['uploaded_by_name'],
                }
                for b in bills
            ],
            'total': len(bills),
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# VENDOR BILLS APIs
# ============================================

@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def upload_vendor_bill(request):
    """
    Accountant: Upload vendor/service provider bill
    POST /api/construction/upload-vendor-bill/
    """
    try:
        from django.core.files.storage import default_storage
        from django.conf import settings
        from .time_utils import get_day_of_week
        
        user_id = request.user['user_id']
        site_id = request.data.get('site_id')
        
        # Bill Information
        bill_number = request.data.get('bill_number')
        bill_date = request.data.get('bill_date')
        vendor_name = request.data.get('vendor_name')
        vendor_type = request.data.get('vendor_type')
        
        # Service Details
        service_type = request.data.get('service_type')
        service_description = request.data.get('service_description', '')
        
        # Financial Details
        amount = request.data.get('amount')
        tax_amount = request.data.get('tax_amount', 0)
        discount_amount = request.data.get('discount_amount', 0)
        final_amount = request.data.get('final_amount')
        
        # Payment Details
        payment_status = request.data.get('payment_status', 'PENDING')
        payment_mode = request.data.get('payment_mode')
        payment_date = request.data.get('payment_date')
        
        notes = request.data.get('notes', '')
        file = request.FILES.get('file')
        
        if not all([site_id, bill_number, bill_date, vendor_name, vendor_type, service_type, amount, final_amount, file]):
            return Response({'error': 'Missing required fields'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate file type
        if not file.name.lower().endswith('.pdf'):
            return Response({'error': 'Only PDF files are allowed'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Create media directory
        media_dir = os.path.join(settings.MEDIA_ROOT, 'vendor_bills')
        os.makedirs(media_dir, exist_ok=True)
        
        # Generate unique filename
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        ext = os.path.splitext(file.name)[1]
        filename = f"{site_id}_VendorBill_{bill_number}_{timestamp}{ext}"
        filepath = os.path.join('vendor_bills', filename)
        
        # Save file
        saved_path = default_storage.save(filepath, file)
        file_url = f"{settings.MEDIA_URL}{saved_path}"
        
        # Get current date and day of week
        today = datetime.now().date()
        day_of_week = get_day_of_week(datetime.now())
        
        # Insert into database
        bill_id = str(uuid.uuid4())
        file_type = 'application/pdf'  # Since we only allow PDF files
        
        execute_query("""
            INSERT INTO vendor_bills 
            (id, site_id, uploaded_by, bill_number, bill_date, vendor_name, vendor_type,
             service_type, service_description, amount, tax_amount, discount_amount, final_amount,
             payment_status, payment_mode, payment_date, file_url, file_name, file_type, file_size, notes,
             upload_date, day_of_week)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (bill_id, site_id, user_id, bill_number, bill_date, vendor_name, vendor_type,
              service_type, service_description, amount, tax_amount, discount_amount, final_amount,
              payment_status, payment_mode, payment_date, file_url, file.name, file_type, file.size, notes,
              today, day_of_week))
        
        return Response({
            'message': 'Vendor bill uploaded successfully',
            'bill_id': bill_id,
            'file_url': file_url,
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_vendor_bills(request):
    """
    Get vendor bills with optional filters
    GET /api/construction/vendor-bills/
    """
    try:
        site_id = request.query_params.get('site_id')
        vendor_type = request.query_params.get('vendor_type')
        payment_status = request.query_params.get('payment_status')
        
        query = """
            SELECT 
                vb.*,
                s.site_name,
                s.area,
                s.street,
                u.full_name as uploaded_by_name
            FROM vendor_bills vb
            JOIN sites s ON vb.site_id = s.id
            JOIN users u ON vb.uploaded_by = u.id
            WHERE vb.is_active = TRUE
        """
        
        params = []
        
        if site_id:
            query += " AND vb.site_id = %s"
            params.append(site_id)
        
        if vendor_type:
            query += " AND vb.vendor_type = %s"
            params.append(vendor_type)
        
        if payment_status:
            query += " AND vb.payment_status = %s"
            params.append(payment_status)
        
        query += " ORDER BY vb.bill_date DESC LIMIT 200"
        
        bills = fetch_all(query, tuple(params) if params else None)
        
        return Response({
            'bills': [
                {
                    'id': str(b['id']),
                    'site_id': str(b['site_id']),
                    'site_name': b['site_name'],
                    'bill_number': b['bill_number'],
                    'bill_date': b['bill_date'].isoformat() if b['bill_date'] else None,
                    'vendor_name': b['vendor_name'],
                    'vendor_type': b['vendor_type'],
                    'service_type': b['service_type'],
                    'amount': float(b['amount']),
                    'final_amount': float(b['final_amount']),
                    'payment_status': b['payment_status'],
                    'file_url': b['file_url'],
                    'uploaded_by_name': b['uploaded_by_name'],
                }
                for b in bills
            ],
            'total': len(bills),
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============================================
# SITE AGREEMENTS APIs
# ============================================

@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def upload_site_agreement(request):
    """
    Accountant: Upload signed agreement for site
    POST /api/construction/upload-site-agreement/
    """
    try:
        from django.core.files.storage import default_storage
        from django.conf import settings
        from .time_utils import get_day_of_week
        
        user_id = request.user['user_id']
        site_id = request.data.get('site_id')
        
        # Agreement Information
        agreement_type = request.data.get('agreement_type')
        agreement_number = request.data.get('agreement_number', '')
        agreement_date = request.data.get('agreement_date')
        
        # Parties
        party_name = request.data.get('party_name')
        party_type = request.data.get('party_type')
        
        # Details
        title = request.data.get('title')
        description = request.data.get('description', '')
        contract_value = request.data.get('contract_value')
        start_date = request.data.get('start_date')
        end_date = request.data.get('end_date')
        
        notes = request.data.get('notes', '')
        file = request.FILES.get('file')
        
        if not all([site_id, agreement_type, agreement_date, party_name, party_type, title, file]):
            return Response({'error': 'Missing required fields'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate file type
        if not file.name.lower().endswith('.pdf'):
            return Response({'error': 'Only PDF files are allowed'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Create media directory
        media_dir = os.path.join(settings.MEDIA_ROOT, 'site_agreements')
        os.makedirs(media_dir, exist_ok=True)
        
        # Generate unique filename
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        ext = os.path.splitext(file.name)[1]
        filename = f"{site_id}_Agreement_{agreement_type.replace(' ', '_')}_{timestamp}{ext}"
        filepath = os.path.join('site_agreements', filename)
        
        # Save file
        saved_path = default_storage.save(filepath, file)
        file_url = f"{settings.MEDIA_URL}{saved_path}"
        
        # Get current date and day of week
        today = datetime.now().date()
        day_of_week = get_day_of_week(datetime.now())
        
        # Insert into database
        agreement_id = str(uuid.uuid4())
        file_type = 'application/pdf'  # Since we only allow PDF files
        
        execute_query("""
            INSERT INTO site_agreements 
            (id, site_id, uploaded_by, agreement_type, agreement_number, agreement_date,
             party_name, party_type, title, description, contract_value, start_date, end_date,
             file_url, file_name, file_type, file_size, notes, upload_date, day_of_week)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (agreement_id, site_id, user_id, agreement_type, agreement_number, agreement_date,
              party_name, party_type, title, description, contract_value, start_date, end_date,
              file_url, file.name, file_type, file.size, notes, today, day_of_week))
        
        return Response({
            'message': 'Site agreement uploaded successfully',
            'agreement_id': agreement_id,
            'file_url': file_url,
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def get_site_agreements(request):
    """
    Get site agreements with optional filters
    GET /api/construction/site-agreements/
    """
    try:
        site_id = request.query_params.get('site_id')
        agreement_type = request.query_params.get('agreement_type')
        status_filter = request.query_params.get('status')
        
        query = """
            SELECT 
                sa.*,
                s.site_name,
                s.area,
                s.street,
                u.full_name as uploaded_by_name
            FROM site_agreements sa
            JOIN sites s ON sa.site_id = s.id
            JOIN users u ON sa.uploaded_by = u.id
            WHERE sa.is_active = TRUE
        """
        
        params = []
        
        if site_id:
            query += " AND sa.site_id = %s"
            params.append(site_id)
        
        if agreement_type:
            query += " AND sa.agreement_type = %s"
            params.append(agreement_type)
        
        if status_filter:
            query += " AND sa.status = %s"
            params.append(status_filter)
        
        query += " ORDER BY sa.agreement_date DESC LIMIT 200"
        
        agreements = fetch_all(query, tuple(params) if params else None)
        
        return Response({
            'agreements': [
                {
                    'id': str(a['id']),
                    'site_id': str(a['site_id']),
                    'site_name': a['site_name'],
                    'agreement_type': a['agreement_type'],
                    'agreement_number': a['agreement_number'],
                    'agreement_date': a['agreement_date'].isoformat() if a['agreement_date'] else None,
                    'party_name': a['party_name'],
                    'party_type': a['party_type'],
                    'title': a['title'],
                    'contract_value': float(a['contract_value']) if a['contract_value'] else None,
                    'status': a['status'],
                    'file_url': a['file_url'],
                    'uploaded_by_name': a['uploaded_by_name'],
                }
                for a in agreements
            ],
            'total': len(agreements),
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

