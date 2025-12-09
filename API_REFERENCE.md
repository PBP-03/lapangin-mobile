# Django API Endpoints Reference

This document lists all Django backend API endpoints used by the Flutter mobile application.

## Base URL
```
http://127.0.0.1:8000
```

---

## Authentication Endpoints

### 1. Login
- **Endpoint:** `POST /api/auth/login/`
- **Body:**
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Login successful",
    "user": {
      "id": "string",
      "username": "string",
      "email": "string",
      "full_name": "string",
      "role": "user|mitra|admin",
      "profile_picture": "string|null",
      "phone_number": "string|null",
      "address": "string|null"
    }
  }
  ```

### 2. Register
- **Endpoint:** `POST /api/auth/register/`
- **Body:**
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string",
    "full_name": "string",
    "role": "user|mitra"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Registration successful",
    "user": { /* user object */ }
  }
  ```

### 3. Logout
- **Endpoint:** `POST /api/auth/logout/`
- **Response:**
  ```json
  {
    "message": "Logout successful"
  }
  ```

### 4. Get Profile
- **Endpoint:** `GET /api/auth/profile/`
- **Response:**
  ```json
  {
    "user": { /* user object */ }
  }
  ```

### 5. Update Profile
- **Endpoint:** `PUT /api/auth/profile/`
- **Body:**
  ```json
  {
    "full_name": "string",
    "phone_number": "string",
    "address": "string"
  }
  ```

---

## Venue Endpoints

### 1. List Venues
- **Endpoint:** `GET /api/venues/`
- **Query Parameters:**
  - `page` (int): Page number
  - `search` (string): Search query
  - `category` (string): Sports category filter
- **Response:**
  ```json
  {
    "venues": [
      {
        "id": "string",
        "name": "string",
        "owner": "string",
        "address": "string",
        "description": "string",
        "contact": "string",
        "location_url": "string",
        "number_of_courts": 0,
        "verification_status": "pending|approved|rejected",
        "images": ["url1", "url2"],
        "average_rating": 4.5,
        "categories": ["category1", "category2"],
        "average_price": 150000
      }
    ],
    "total_pages": 10,
    "current_page": 1,
    "has_next": true,
    "has_previous": false
  }
  ```

### 2. Get Venue Detail
- **Endpoint:** `GET /api/venues/{venue_id}/`
- **Response:**
  ```json
  {
    "venue": { /* venue object with full details */ },
    "images": [
      {
        "id": "string",
        "image": "url",
        "caption": "string"
      }
    ],
    "facilities": [
      {
        "id": "string",
        "name": "string"
      }
    ],
    "sports_categories": [
      {
        "id": "string",
        "name": "string"
      }
    ]
  }
  ```

### 3. Create Venue (Mitra only)
- **Endpoint:** `POST /api/venues/`
- **Body:**
  ```json
  {
    "name": "string",
    "address": "string",
    "description": "string",
    "contact": "string",
    "location_url": "string"
  }
  ```

### 4. Update Venue (Mitra only)
- **Endpoint:** `PUT /api/venues/{venue_id}/`
- **Body:** Same as create

### 5. Delete Venue (Mitra only)
- **Endpoint:** `DELETE /api/venues/{venue_id}/`

### 6. Get My Venues (Mitra only)
- **Endpoint:** `GET /api/venues/my-venues/`
- **Response:**
  ```json
  {
    "venues": [ /* array of venue objects */ ]
  }
  ```

### 7. Verify Venue (Admin only)
- **Endpoint:** `POST /api/venues/{venue_id}/verify/`
- **Response:**
  ```json
  {
    "message": "Venue verified successfully"
  }
  ```

---

## Court Endpoints

### 1. Get Courts by Venue
- **Endpoint:** `GET /api/courts/?venue={venue_id}`
- **Response:**
  ```json
  {
    "courts": [
      {
        "id": "string",
        "venue": "string",
        "name": "string",
        "description": "string",
        "sports_category": "string",
        "price_per_hour": 150000,
        "images": [
          {
            "id": "string",
            "image": "url"
          }
        ]
      }
    ]
  }
  ```

### 2. Get Available Sessions
- **Endpoint:** `GET /api/courts/{court_id}/sessions/?date=YYYY-MM-DD`
- **Response:**
  ```json
  {
    "sessions": [
      {
        "id": "string",
        "start_time": "08:00",
        "end_time": "09:00",
        "is_available": true
      }
    ]
  }
  ```

---

## Booking Endpoints

### 1. Create Booking
- **Endpoint:** `POST /api/bookings/`
- **Body:**
  ```json
  {
    "court": "court_id",
    "session": "session_id",
    "booking_date": "YYYY-MM-DD",
    "notes": "string"
  }
  ```
- **Response:**
  ```json
  {
    "booking": {
      "id": "string",
      "user": "string",
      "court": "string",
      "booking_date": "YYYY-MM-DD",
      "start_time": "08:00",
      "end_time": "09:00",
      "status": "pending",
      "total_price": 150000,
      "venue_name": "string",
      "court_name": "string"
    }
  }
  ```

### 2. Get User Bookings
- **Endpoint:** `GET /api/bookings/`
- **Query Parameters:**
  - `status` (string): Filter by status
- **Response:**
  ```json
  {
    "bookings": [ /* array of booking objects */ ]
  }
  ```

### 3. Get Booking Detail
- **Endpoint:** `GET /api/bookings/{booking_id}/`
- **Response:**
  ```json
  {
    "booking": { /* booking object with full details */ },
    "payment": {
      "id": "string",
      "amount": 150000,
      "payment_method": "cash|transfer|ewallet",
      "status": "pending|paid|failed",
      "transaction_id": "string"
    }
  }
  ```

### 4. Cancel Booking
- **Endpoint:** `PATCH /api/bookings/{booking_id}/`
- **Body:**
  ```json
  {
    "booking_status": "cancelled",
    "cancellation_reason": "string"
  }
  ```

### 5. Create Payment
- **Endpoint:** `POST /api/bookings/{booking_id}/payment/`
- **Body:**
  ```json
  {
    "amount": 150000,
    "payment_method": "cash|transfer|ewallet",
    "transaction_id": "string"
  }
  ```

---

## Review Endpoints

### 1. Get Venue Reviews
- **Endpoint:** `GET /api/reviews/venue/{venue_id}/`
- **Query Parameters:**
  - `page` (int): Page number (6 reviews per page)
- **Response:**
  ```json
  {
    "reviews": [
      {
        "id": "string",
        "user": "user_id",
        "user_name": "string",
        "venue": "venue_id",
        "booking": "booking_id",
        "rating": 5,
        "comment": "string",
        "created_at": "datetime"
      }
    ]
  }
  ```

### 2. Create Review
- **Endpoint:** `POST /api/reviews/`
- **Body:**
  ```json
  {
    "booking": "booking_id",
    "rating": 5,
    "comment": "string"
  }
  ```

### 3. Update Review
- **Endpoint:** `PUT /api/reviews/{review_id}/`
- **Body:**
  ```json
  {
    "rating": 4,
    "comment": "string"
  }
  ```

### 4. Delete Review
- **Endpoint:** `DELETE /api/reviews/{review_id}/`

---

## Dashboard Endpoints

### 1. User Dashboard
- **Endpoint:** `GET /api/dashboard/user/`
- **Response:**
  ```json
  {
    "user": { /* user object */ },
    "title": "User Dashboard"
  }
  ```

### 2. Mitra Dashboard
- **Endpoint:** `GET /api/dashboard/mitra/`
- **Response:**
  ```json
  {
    "venues": [
      {
        "id": "string",
        "name": "string",
        "verification_status": "string",
        "courts_count": 5,
        "average_price": 150000
      }
    ]
  }
  ```

### 3. Admin Dashboard
- **Endpoint:** `GET /api/dashboard/admin/`
- **Response:**
  ```json
  {
    "stats": {
      "total_users": 150,
      "total_mitras": 25,
      "total_venues": 45,
      "total_bookings": 320,
      "pending_mitras": 5,
      "pending_venues": 8
    },
    "recent_activity": [ /* array of activity logs */ ]
  }
  ```

### 4. Mitra Earnings
- **Endpoint:** `GET /api/revenue/mitra/earnings/`
- **Response:**
  ```json
  {
    "total_earnings": 5000000,
    "transactions": [
      {
        "venue": "string",
        "court": "string",
        "customer": "string",
        "date": "datetime",
        "amount": 150000
      }
    ]
  }
  ```

---

## Authentication

All endpoints (except login and register) require authentication using **session cookies**. The Flutter app manages cookies automatically through the `ApiService` class.

**Cookie Headers:**
- `Cookie: sessionid=xxx; csrftoken=xxx`
- `X-CSRFToken: xxx` (for POST/PUT/DELETE requests)

---

## Error Responses

All endpoints may return error responses:

```json
{
  "error": "Error message",
  "detail": "Detailed error information"
}
```

**HTTP Status Codes:**
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Server Error

---

## Testing the API

You can test the Django API using:

1. **Django Web Interface:**
   ```
   http://127.0.0.1:8000/
   ```

2. **Django Admin:**
   ```
   http://127.0.0.1:8000/admin/
   ```

3. **Postman/Thunder Client:**
   - Import endpoints from this document
   - Use session cookies for authentication

4. **Flutter App:**
   - Run the app and test each feature
   - Monitor network requests in debug mode

---

## Notes

- All datetime values use ISO 8601 format
- All price values are in Indonesian Rupiah (IDR)
- File uploads (images) use multipart/form-data
- Pagination typically shows 9-12 items per page
- Review pagination shows 6 reviews per page
