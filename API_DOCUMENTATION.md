# BAORCO Online Shop - API Documentation

## مستندات کامل API و راهنمای یکپارچه‌سازی

### فهرست
1. [احراز هویت](#احراز-هویت)
2. [مدیریت کاربران](#مدیریت-کاربران)
3. [کاتالوگ محصولات](#کاتالوگ-محصولات)
4. [سبد و سفارش](#سبد-و-سفارش)
5. [پرداخت و اقساط](#پرداخت-و-اقساط)
6. [حسابداری](#حسابداری)
7. [کدهای خطا](#کدهای-خطا)

---

## احراز هویت

### 1. ثبت نام (Registration)

**Endpoint:** `POST /api/auth/register/`

**Request:**
```json
{
    "username": "user@example.com",
    "email": "user@example.com",
    "phone": "989123456789",
    "password": "SecurePass123",
    "password2": "SecurePass123"
}
```

**Response (201 Created):**
```json
{
    "message": "کاربر با موفقیت ثبت نام کرد",
    "user": {
        "id": 1,
        "username": "user@example.com",
        "email": "user@example.com",
        "phone": "989123456789",
        "first_name": "",
        "last_name": "",
        "role": "customer",
        "is_verified": false,
        "created_at": "2024-01-15T10:30:00Z"
    }
}
```

**Validation:**
- رمز عبور باید حداقل 8 کاراکتر باشد
- رمزها باید یکسان باشند
- ایمیل باید منحصربه‌فرد باشد

---

### 2. ورود (Login)

**Endpoint:** `POST /api/auth/login/`

**Request:**
```json
{
    "username": "user@example.com",
    "password": "SecurePass123"
}
```

**Response (200 OK):**
```json
{
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
        "id": 1,
        "username": "user@example.com",
        "email": "user@example.com",
        "phone": "989123456789",
        "role": "customer",
        "is_verified": true,
        "admin_profile": null,
        "customer_profile": {
            "loyalty_points": 100,
            "total_purchases": "5000000.00",
            "preferred_payment_method": "card"
        }
    }
}
```

---

### 3. تأیید شماره موبایل (Phone Verification)

**Endpoint:** `POST /api/auth/phone-verification/`

**Request:**
```json
{
    "phone": "989123456789"
}
```

**Response (200 OK):**
```json
{
    "message": "کد تأیید برای شماره تلفن ارسال شد",
    "phone": "989123456789"
}
```

**SMS Content:**
```
این پیامک جهت تست می باشد و فاقد اعتبار است: زمان: 14:30 رمز یک بار مصرف: 123456 زمان اعتبار ۲دقیقه می باشد.
```

---

### 4. تأیید کد OTP (OTP Verification)

**Endpoint:** `POST /api/auth/otp-verification/`

**Request:**
```json
{
    "phone": "989123456789",
    "code": "123456"
}
```

**Response (200 OK):**
```json
{
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
        "id": 1,
        "username": "989123456789",
        "is_verified": true,
        "role": "customer"
    }
}
```

---

### 5. تازه‌سازی توکن (Token Refresh)

**Endpoint:** `POST /api/auth/token/refresh/`

**Request:**
```json
{
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## مدیریت کاربران

### 1. دریافت پروفایل کاربر جاری

**Endpoint:** `GET /api/users/me/`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200 OK):**
```json
{
    "id": 1,
    "username": "user@example.com",
    "email": "user@example.com",
    "first_name": "علی",
    "last_name": "احمدی",
    "phone": "989123456789",
    "national_id": "1234567890",
    "address": "تهران، خیابان ولیعصر",
    "city": "تهران",
    "postal_code": "1234567",
    "is_verified": true,
    "profile_image": "https://example.com/media/profiles/user1.jpg",
    "role": "customer",
    "created_at": "2024-01-15T10:30:00Z",
    "customer_profile": {
        "loyalty_points": 500,
        "total_purchases": "15000000.00",
        "preferred_payment_method": "installment",
        "company_name": "شرکت ABC",
        "business_type": "توزیع",
        "tax_id": "123456789"
    }
}
```

---

### 2. بروزرسانی پروفایل

**Endpoint:** `PUT /api/users/{id}/`

**Request:**
```json
{
    "first_name": "علی",
    "last_name": "احمدی",
    "address": "تهران، خیابان ولیعصر، پلاک 123",
    "city": "تهران",
    "postal_code": "1234567"
}
```

**Response (200 OK):**
```json
{
    "id": 1,
    "username": "user@example.com",
    "first_name": "علی",
    "last_name": "احمدی",
    ...
}
```

---

### 3. تغییر رمز عبور

**Endpoint:** `POST /api/users/change_password/`

**Request:**
```json
{
    "old_password": "OldPassword123",
    "new_password": "NewPassword456",
    "new_password2": "NewPassword456"
}
```

**Response (200 OK):**
```json
{
    "message": "رمز عبور تغییر یافت"
}
```

---

### 4. لاگ‌های ورود

**Endpoint:** `GET /api/users/login_logs/`

**Response (200 OK):**
```json
[
    {
        "id": 1,
        "ip_address": "192.168.1.1",
        "login_time": "2024-01-15T14:30:00Z",
        "logout_time": "2024-01-15T16:45:00Z",
        "is_successful": true,
        "device_info": {
            "user_agent": "Mozilla/5.0...",
            "device": "Desktop"
        }
    }
]
```

---

## کاتالوگ محصولات

### 1. دریافت لیست محصولات

**Endpoint:** `GET /api/products/`

**Query Parameters:**
```
?search=مبل               # جستجو
?category=1              # فیلتر دسته‌بندی
?page=1                  # صفحه‌بندی
?ordering=-created_at    # ترتیب‌دهی
?price_min=100000
?price_max=5000000
```

**Response (200 OK):**
```json
{
    "count": 100,
    "next": "http://api.example.com/api/products/?page=2",
    "previous": null,
    "results": [
        {
            "id": 1,
            "name": "مبل راحتی 3 نفره",
            "slug": "sofa-3-seat",
            "category_name": "مبلمان اتاق نشیمن",
            "image_url": "https://example.com/media/products/sofa1.jpg",
            "current_price": "2500000.00",
            "base_price": "3000000.00",
            "discount_percentage": 16.67,
            "quantity": 15,
            "rating": 4.5,
            "is_featured": true,
            "is_bestseller": true,
            "created_at": "2024-01-10T08:00:00Z"
        }
    ]
}
```

---

### 2. جزئیات محصول

**Endpoint:** `GET /api/products/{id}/`

**Response (200 OK):**
```json
{
    "id": 1,
    "name": "مبل راحتی 3 نفره",
    "slug": "sofa-3-seat",
    "category_name": "مبلمان اتاق نشیمن",
    "description": "مبل راحتی با طراحی مدرن",
    "detailed_description": "...",
    "image_url": "https://example.com/media/products/sofa1.jpg",
    "images": [
        {
            "id": 1,
            "image": "https://example.com/media/products/sofa1_1.jpg",
            "alt_text": "نمای جلو",
            "is_primary": true
        }
    ],
    "base_price": "3000000.00",
    "discounted_price": "2500000.00",
    "current_price": "2500000.00",
    "discount_percentage": 16.67,
    "quantity": 15,
    "sku": "SOF-001",
    "dimensions": {
        "length": 210,
        "width": 100,
        "height": 85
    },
    "weight": "150.00",
    "material": "چرم و پارچه",
    "color": "خاکستری",
    "brand": "BAORCO",
    "warranty_months": 24,
    "allows_installment": true,
    "max_installment_months": 12,
    "rating": 4.5,
    "review_count": 12,
    "reviews": [
        {
            "id": 1,
            "customer_name": "علی احمدی",
            "rating": 5,
            "title": "محصول عالی",
            "review": "کیفیت بسیار خوب و قیمت مناسب",
            "is_verified_purchase": true,
            "helpful_count": 5,
            "created_at": "2024-01-12T10:30:00Z"
        }
    ]
}
```

---

### 3. محصولات برجسته

**Endpoint:** `GET /api/products/featured/`

**Response:** لیست محصولات برجسته

---

### 4. اضافه کردن نظر

**Endpoint:** `POST /api/products/{id}/reviews/`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request:**
```json
{
    "rating": 5,
    "title": "محصول عالی",
    "review": "کیفیت بسیار خوب و قیمت مناسب"
}
```

**Response (201 Created):**
```json
{
    "id": 13,
    "customer_name": "علی احمدی",
    "rating": 5,
    "title": "محصول عالی",
    "review": "کیفیت بسیار خوب و قیمت مناسب",
    "is_verified_purchase": false,
    "helpful_count": 0,
    "created_at": "2024-01-15T14:30:00Z"
}
```

---

### 5. اضافه کردن به علاقه‌مندی‌ها

**Endpoint:** `POST /api/products/{id}/add_to_wishlist/`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (201 Created):**
```json
{
    "message": "محصول به لیست آرزو اضافه شد"
}
```

---

## سبد و سفارش

### 1. دریافت سبد خرید

**Endpoint:** `GET /api/cart/list/`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200 OK):**
```json
{
    "id": 1,
    "items": [
        {
            "id": 1,
            "product": 1,
            "product_name": "مبل راحتی 3 نفره",
            "product_image": "https://example.com/media/products/sofa1.jpg",
            "quantity": 2,
            "price": "2500000.00",
            "total_price": "5000000.00"
        }
    ],
    "total_price": "5000000.00",
    "total_items": 2,
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T14:30:00Z"
}
```

---

### 2. اضافه کردن به سبد

**Endpoint:** `POST /api/cart/add_item/`

**Request:**
```json
{
    "product_id": 1,
    "quantity": 2
}
```

**Response (201 Created):**
```json
{
    "id": 1,
    "items": [
        {
            "id": 1,
            "product": 1,
            "product_name": "مبل راحتی 3 نفره",
            "quantity": 2,
            "price": "2500000.00",
            "total_price": "5000000.00"
        }
    ],
    "total_price": "5000000.00",
    "total_items": 2
}
```

---

### 3. ایجاد سفارش

**Endpoint:** `POST /api/orders/`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request:**
```json
{
    "shipping_address": "تهران، خیابان ولیعصر، پلاک 123",
    "shipping_city": "تهران",
    "shipping_postal_code": "1234567",
    "shipping_phone": "989123456789",
    "payment_method": "installment",
    "is_installment": true,
    "installment_months": 6,
    "discount_code": "WELCOME10",
    "notes": "لطفاً با احتیاط بسته‌بندی کنید"
}
```

**Response (201 Created):**
```json
{
    "id": 1,
    "order_number": "ORD-20240115-ABC123",
    "customer_name": "علی احمدی",
    "shipping_address": "تهران، خیابان ولیعصر، پلاک 123",
    "shipping_city": "تهران",
    "status": "pending",
    "payment_status": "pending",
    "payment_method": "installment",
    "subtotal": "5000000.00",
    "tax": "450000.00",
    "shipping_cost": "0.00",
    "discount_amount": "500000.00",
    "total": "4950000.00",
    "is_installment": true,
    "installment_months": 6,
    "monthly_payment": "825000.00",
    "items": [
        {
            "id": 1,
            "product": 1,
            "product_name": "مبل راحتی 3 نفره",
            "quantity": 2,
            "price": "2500000.00",
            "discount": "0.00",
            "total_price": "5000000.00"
        }
    ],
    "installment_plans": [
        {
            "id": 1,
            "order": 1,
            "payment_number": 1,
            "amount": "825000.00",
            "due_date": "2024-02-15",
            "status": "pending",
            "is_overdue": false
        }
    ],
    "created_at": "2024-01-15T14:30:00Z"
}
```

---

### 4. دریافت لیست سفارش‌ها

**Endpoint:** `GET /api/orders/`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200 OK):**
```json
{
    "count": 5,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "order_number": "ORD-20240115-ABC123",
            "customer_name": "علی احمدی",
            "status": "pending",
            "payment_status": "pending",
            "total": "4950000.00",
            "created_at": "2024-01-15T14:30:00Z"
        }
    ]
}
```

---

### 5. جزئیات سفارش

**Endpoint:** `GET /api/orders/{id}/`

---

### 6. لغو سفارش

**Endpoint:** `POST /api/orders/{id}/cancel/`

**Request:** (خالی)

**Response (200 OK):**
```json
{
    "message": "سفارش لغو شد"
}
```

---

## پرداخت و اقساط

### 1. دریافت اقساط‌های سفارش

**Endpoint:** `GET /api/orders/{id}/`

در پاسخ سفارش، فیلد `installment_plans` شامل تمام اقساط است.

### 2. اطلاعات اقساط

```json
{
    "id": 1,
    "order": 1,
    "payment_number": 1,
    "amount": "825000.00",
    "due_date": "2024-02-15",
    "status": "pending",
    "paid_date": null,
    "payment_method": null,
    "reference_number": null,
    "is_overdue": false
}
```

---

## حسابداری

### 1. دریافت فاکتورها

**Endpoint:** `GET /api/invoices/`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200 OK):**
```json
[
    {
        "id": 1,
        "invoice_number": "INV-20240115-XYZ789",
        "order_number": "ORD-20240115-ABC123",
        "issue_date": "2024-01-15",
        "due_date": "2024-02-15",
        "status": "issued",
        "subtotal": "5000000.00",
        "tax_rate": 9.00,
        "tax_amount": "450000.00",
        "discount_amount": "500000.00",
        "total": "4950000.00",
        "paid_amount": "0.00",
        "remaining_amount": "4950000.00"
    }
]
```

---

## کدهای خطا

### کدهای HTTP

| کد | معنی | حل |
|---|---|---|
| 200 | موفق | - |
| 201 | ایجاد موفق | - |
| 400 | درخواست نامعتبر | بررسی فیلد‌ها |
| 401 | بدون احراز هویت | ورود کنید |
| 403 | بدون مجوز | کاربر مناسب نیست |
| 404 | پیدا نشد | URL را بررسی کنید |
| 500 | خطای سرور | بعداً تلاش کنید |

### خطاهای احراز هویت

```json
{
    "error": "نام کاربری یا رمز عبور اشتباه است"
}
```

### خطاهای Validation

```json
{
    "phone": ["شماره تلفن معتبر نیست"],
    "password": ["رمز عبور باید حداقل 8 کاراکتر باشد"]
}
```

---

## نکات مهم

1. **Token Expiration**: توکن دسترسی برای 1 ساعت معتبر است
2. **Refresh Token**: برای تازه‌سازی توکن دسترسی استفاده می‌شود (7 روز معتبر)
3. **Rate Limiting**: هر IP می‌تواند 100 درخواست در دقیقه ارسال کند
4. **Pagination**: پیش‌فرض 20 آیتم در هر صفحه
5. **Search**: از جستجوی متنی کامل برای محصولات استفاده می‌شود

---

## مثال‌های Curl

### ثبت نام
```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user@example.com",
    "email": "user@example.com",
    "phone": "989123456789",
    "password": "SecurePass123",
    "password2": "SecurePass123"
  }'
```

### ورود
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user@example.com",
    "password": "SecurePass123"
  }'
```

### دریافت محصولات
```bash
curl -X GET "http://localhost:8000/api/products/?search=مبل" \
  -H "Accept: application/json"
```

### ایجاد سفارش
```bash
curl -X POST http://localhost:8000/api/orders/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "shipping_address": "تهران، خیابان ولیعصر",
    "shipping_city": "تهران",
    "shipping_postal_code": "1234567",
    "shipping_phone": "989123456789",
    "payment_method": "card"
  }'
```

---

## پشتیبانی

برای سوالات و مشکلات تکنیکی، لطفاً با تیم توسعه تماس بگیرید.
