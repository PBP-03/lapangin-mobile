# Admin Kelola Mitra - Flutter Implementation

## ✅ Fitur Yang Sudah Diimplementasi

### 1. **List Mitra** (`AdminMitraListPage`)
- Tampilkan semua mitra dengan status (Pending/Disetujui/Ditolak)
- Tombol **Approve Mitra** (✓ icon hijau)
- Tombol **Reject Mitra** (✗ icon merah) dengan dialog alasan penolakan
- Tap card untuk lihat detail venue mitra
- Pull-to-refresh
- Loading, error, dan empty states

### 2. **Detail Mitra** (`AdminMitraDetailPage`)
- Card info mitra (nama, email, phone) dengan gradient ungu
- List semua venue milik mitra
- Setiap venue menampilkan:
  - Status badge (Approved/Pending/Rejected)
  - Gambar venue (primary image)
  - Alamat, kontak, jumlah lapangan, deskripsi
  - **Expandable court list** dengan harga per jam
  - Tombol **Approve Venue** (hijau)
  - Tombol **Reject Venue** (merah) dengan dialog alasan

### 3. **API Integration**
- `GET /api/mitra/` - List semua mitra ✅
- `GET /api/mitra/<id>/venues/` - Detail mitra + venues ✅
- `PATCH /api/mitra/<id>/` - Approve/Reject mitra ✅
- `PATCH /api/venues/<id>/status/` - Approve/Reject venue ⚠️ **ENDPOINT BELUM ADA**

## ⚠️ Catatan Penting

### **Approve/Reject Venue akan ERROR sementara**
Endpoint `PATCH /api/venues/<uuid>/status/` **belum ada di Django backend**, jadi ketika admin tap tombol "Approve Venue" atau "Reject Venue" akan muncul error.

**Cara fix di backend (nanti):**
1. Buat view function di `app/venues/views.py`:
```python
@require_http_methods(["PATCH"])
def api_venue_status(request, venue_id):
    try:
        venue = Venue.objects.get(pk=venue_id)
        data = json.loads(request.body)
        status = data.get('status')
        rejection_reason = data.get('rejection_reason', '')
        
        if status not in ['approved', 'rejected', 'pending']:
            return JsonResponse({'status': 'error', 'message': 'Invalid status'}, status=400)
        
        venue.verification_status = status
        if status == 'rejected' and rejection_reason:
            venue.rejection_reason = rejection_reason
        venue.save()
        
        return JsonResponse({'status': 'ok', 'message': f'Venue {status} successfully'})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
```

2. Tambahkan di `lapangin/urls.py`:
```python
path('api/venues/<uuid:venue_id>/status/', venues_views.api_venue_status, name='api_venue_status'),
```

## 🎨 UI Features

- **Theme**: Purple gradient (#5409DA) matching Django admin
- **Status Colors**:
  - Approved = Green
  - Rejected = Red  
  - Pending = Orange/Yellow
- **Responsive cards** dengan shadow dan border radius
- **Pull-to-refresh** di kedua halaman
- **Dialog confirmation** untuk reject dengan textarea alasan
- **Expandable court list** dengan tap untuk show/hide
- **Image loading** dengan error fallback (broken image icon)
- **SnackBar notifications** untuk success/error feedback

## 📱 Navigation Flow

```
Dashboard Admin
  └─ Tap "Kelola Pengguna" card
      └─ AdminKelolaPenggunaPage (Tab View)
          ├─ Tab 1: User (placeholder - coming soon)
          └─ Tab 2: Mitra
              └─ AdminMitraListPage (list semua mitra)
                  ├─ Tap Approve → Update status → Reload list
                  ├─ Tap Reject → Dialog reason → Update status → Reload list
                  └─ Tap mitra card
                      └─ AdminMitraDetailPage (detail + venues)
                          ├─ Info mitra (gradient purple card)
                          ├─ List venues dengan images
                          ├─ Tap "Lihat X Lapangan" → Expand court list
                          ├─ Tap Approve Venue → ⚠️ ERROR (endpoint belum ada)
                          └─ Tap Reject Venue → ⚠️ ERROR (endpoint belum ada)
```

## 🚀 Testing

1. Login sebagai admin
2. Tap "Kelola Mitra" di dashboard
3. ✅ List mitra akan muncul
4. ✅ Approve/Reject mitra works
5. ✅ Tap mitra untuk lihat detail & venues
6. ✅ Expand court list works
7. ⚠️ Approve/Reject venue akan error (endpoint belum ada)

## 📦 Files Created

```
lib/
├── models/
│   ├── mitra_model.dart                # MitraModel + CourtModel
│   └── venue_model.dart                # VenueModel + VenueImageModel + VenueCourt
├── services/
│   └── admin_mitra_service.dart        # API calls untuk mitra & venue
└── screens/admin/
    ├── admin_kelola_pengguna_page.dart # Tab view: User & Mitra
    ├── admin_mitra_list_page.dart      # List semua mitra (embedded in tab)
    └── admin_mitra_detail_page.dart    # Detail mitra + venues
```

## 🔧 Modified Files

- `lib/main.dart` - Added `/admin/kelola-pengguna` route
- `lib/screens/admin/admin_home_page.dart` - Updated "Kelola Pengguna" to navigate to tab view
