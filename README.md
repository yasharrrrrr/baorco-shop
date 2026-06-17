# BAORCO Online Shop - Django REST Framework API

فروشگاه مبلمان آنلاین BAORCO با سیستم حسابداری یکپارچه

## نمای کلی پروژه

یک سیستم جامع تجارت الکترونیکی برای فروش مبلمان آنلاین با ویژگی‌های:

- ✅ احراز هویت و سیستم مدیریت کاربران با نقش‌های مختلف (مدیر، مشتری)
- ✅ سیستم کاتالوگ محصولات جامع
- ✅ سیستم سبد خرید و سفارش‌دهی
- ✅ سیستم پرداخت اقساطی
- ✅ سیستم حسابداری کامل
- ✅ ارسال پیامک از طریق API سامانه SMS.ir
- ✅ سیستم ردیابی ارسالات
- ✅ API برای اتصال با اپلیکیشن موبایل اندروید

## ساختار پروژه

```
baorco_shop/
├── core/                      # تنظیمات اصلی پروژه
│   ├── settings.py           # Django settings
│   ├── urls.py               # URL routing
│   ├── wsgi.py               # WSGI config
│   ├── celery.py             # Celery config
│   └── __init__.py
├── accounts/                  # مدیریت کاربران
│   ├── models.py             # User, AdminProfile, CustomerProfile
│   ├── views.py              # ViewSets و API endpoints
│   ├── serializers.py        # Serializers
│   └── urls.py
├── products/                  # مدیریت محصولات
│   ├── models.py             # Product, Category, Review
│   ├── views.py              # Product ViewSets
│   ├── serializers.py        # Product Serializers
│   └── urls.py
├── orders/                    # مدیریت سفارش‌ها
│   ├── models.py             # Order, Cart, Payment
│   ├── views.py              # Order ViewSets
│   ├── serializers.py        # Order Serializers
│   └── urls.py
├── accounting/               # سیستم حسابداری
│   ├── models.py             # Invoice, Expense, Journal
│   ├── views.py              # Accounting ViewSets
│   ├── tasks.py              # Celery tasks
│   └── urls.py
├── notifications/            # اطلاع‌رسانی و SMS
│   ├── models.py             # SMS, Notification
│   ├── services.py           # SMS Service
│   └── urls.py
├── manage.py                 # Django management
├── requirements.txt          # وابستگی‌ها
└── .env.example             # تنظیمات محیط
```

## نیازمندی‌ها

- Python 3.8+
- Django 4.2+
- Django REST Framework 3.14+
- MSSQL Server 2017+
- Redis
- PostgreSQL (اختیاری)

## نصب و راه‌اندازی

### 1. نصب وابستگی‌ها

```bash
# ایجاد Virtual Environment
python -m venv venv

# فعال‌سازی Virtual Environment
# در Windows:
venv\Scripts\activate
# در Linux/Mac:
source venv/bin/activate

# نصب پکیج‌ها
pip install -r requirements.txt
```

### 2. تنظیم پایگاه داده (MSSQL)

```bash
# کپی کردن فایل .env.example و ویرایش آن
cp .env.example .env

# تنظیمات بر اساس MSSQL Server خود
DB_NAME=BAORCO_Shop
DB_USER=sa
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=1433
```

### 3. مایگریشن پایگاه داده

```bash
# ایجاد جداول پایگاه داده
python manage.py migrate

# ایجاد super user
python manage.py createsuperuser

# بارگذاری داده‌های اولیه (اختیاری)
python manage.py loaddata fixtures/initial_data.json
```

### 4. ایجاد دایرکتوری‌های مورد نیاز

```bash
mkdir logs
mkdir media
mkdir staticfiles
```

### 5. جمع‌آوری فایل‌های Static

```bash
python manage.py collectstatic --noinput
```

## راه‌اندازی سرور

### سرور توسعه (Development)

```bash
python manage.py runserver 0.0.0.0:8000
```

سپس API را از این آدرس بازدید کنید:
```
http://localhost:8000/api/docs/
```

### Celery Worker (برای کارهای پس‌زمینه)

```bash
# Terminal 1: Celery Worker
celery -A core worker -l info

# Terminal 2: Celery Beat (برای کارهای زمان‌بندی شده)
celery -A core beat -l info
```

### سرور Production

```bash
# استفاده از Gunicorn
gunicorn core.wsgi:application --bind 0.0.0.0:8000

# یا استفاده از Nginx + Gunicorn
```

## API Endpoints

### احراز هویت
```
POST   /api/auth/register/              # ثبت نام
POST   /api/auth/login/                 # ورود
POST   /api/auth/phone-verification/    # تأیید شماره موبایل
POST   /api/auth/otp-verification/      # تأیید کد OTP
POST   /api/auth/token/refresh/         # تازه‌سازی توکن
```

### کاربران
```
GET    /api/users/                      # لیست کاربران (Admin فقط)
POST   /api/users/                      # ایجاد کاربر (Admin فقط)
GET    /api/users/{id}/                 # جزئیات کاربر
PUT    /api/users/{id}/                 # ویرایش کاربر
POST   /api/users/change_password/      # تغییر رمز عبور
GET    /api/users/me/                   # پروفایل کاربر جاری
```

### محصولات
```
GET    /api/products/                   # لیست محصولات
POST   /api/products/                   # ایجاد محصول (Admin)
GET    /api/products/{id}/              # جزئیات محصول
PUT    /api/products/{id}/              # ویرایش محصول (Admin)
DELETE /api/products/{id}/              # حذف محصول (Admin)
GET    /api/products/featured/          # محصولات برجسته
GET    /api/products/bestsellers/       # پرفروش‌ترین محصولات
GET    /api/products/{id}/reviews/      # نظرات محصول
POST   /api/products/{id}/reviews/      # اضافه کردن نظر
POST   /api/products/{id}/add_to_wishlist/     # اضافه کردن به علاقه‌مندی‌ها
```

### سبد و سفارش
```
GET    /api/cart/list/                  # دریافت سبد
POST   /api/cart/add_item/              # اضافه کردن محصول
POST   /api/cart/update_item/           # بروزرسانی مقدار
POST   /api/cart/remove_item/           # حذف محصول
POST   /api/cart/clear/                 # خالی کردن سبد

GET    /api/orders/                     # لیست سفارش‌ها
POST   /api/orders/                     # ایجاد سفارش جدید
GET    /api/orders/{id}/                # جزئیات سفارش
POST   /api/orders/{id}/confirm/        # تأیید سفارش (Admin)
POST   /api/orders/{id}/ship/           # ارسال سفارش (Admin)
POST   /api/orders/{id}/deliver/        # تحویل سفارش (Admin)
POST   /api/orders/{id}/cancel/         # لغو سفارش
GET    /api/orders/search/              # جستجوی سفارش‌ها (Admin)
GET    /api/orders/statistics/          # آمار سفارش‌ها (Admin)
```

### حسابداری
```
GET    /api/accounts/                   # لیست حسابات (Admin)
POST   /api/accounts/                   # ایجاد حساب (Admin)

GET    /api/invoices/                   # لیست فاکتورها
POST   /api/invoices/{id}/mark_as_paid/ # ثبت پرداخت فاکتور (Admin)

GET    /api/expenses/                   # لیست هزینه‌ها (Admin)
POST   /api/expenses/                   # اضافه کردن هزینه (Admin)
POST   /api/expenses/{id}/approve/      # تأیید هزینه (Admin)

GET    /api/financial-reports/          # لیست گزارش‌ها (Admin)
POST   /api/financial-reports/generate_income_statement/  # تولید صورت درآمد
POST   /api/financial-reports/generate_balance_sheet/     # تولید ترازنامه
```

## تنظیم SMS.ir

### 1. API Key را در `.env` قرار دهید:
```
SMS_API_KEY=2qAmtPjmMp7YZ6tkLNzW1nZ4AAj5nRpaA7mZacUbD85xAB4G
```

### 2. Template IDs:
```
SMS_TEMPLATE_ID_OTP=769673           # برای OTP
SMS_TEMPLATE_ID_ORDER=800879         # برای تایید سفارش
```

### 3. فرمت ارسال SMS:
```python
{
    "mobile": "989xxxxxxxxx",
    "templateId": 769673,
    "parameters": [
        {"name": "Code", "value": "123456"},
        {"name": "Time", "value": "2"}
    ]
}
```

## اتصال با اپلیکیشن اندروید

### Base URL:
```
https://yourdomain.com/api/
```

### مثال Request (Registration):
```javascript
POST /api/auth/register/
{
    "username": "user@example.com",
    "email": "user@example.com",
    "phone": "989123456789",
    "password": "securepassword123",
    "password2": "securepassword123"
}
```

### مثال Response:
```json
{
    "message": "کاربر با موفقیت ثبت نام کرد",
    "user": {
        "id": 1,
        "username": "user@example.com",
        "email": "user@example.com",
        "phone": "989123456789",
        "role": "customer",
        "is_verified": false
    }
}
```

### مثال Phone Verification:
```javascript
POST /api/auth/phone-verification/
{
    "phone": "989123456789"
}
```

### مثال OTP Verification:
```javascript
POST /api/auth/otp-verification/
{
    "phone": "989123456789",
    "code": "123456"
}
```

### Response (با JWT Token):
```json
{
    "refresh": "eyJhbGc...",
    "access": "eyJhbGc...",
    "user": {
        "id": 1,
        "username": "user@example.com",
        "role": "customer",
        "is_verified": true
    }
}
```

## نقش‌های سیستم

### Admin
- مدیریت محصولات (ایجاد، ویرایش، حذف)
- مدیریت سفارش‌ها
- مدیریت صورت‌حساب‌ها و هزینه‌ها
- مشاهده گزارش‌های مالی
- مدیریت کاربران
- کنترل دسترسی

### Customer
- مشاهده محصولات
- افزودن به سبد خرید
- ایجاد سفارش
- مشاهده سفارش‌های خود
- ثبت نظر برای محصولات
- مدیریت علاقه‌مندی‌ها

## مجوزها و محدودیت‌های دسترسی

هر کاربر مدیر دارای مجوزهای جداگانه‌ای است:
- `can_manage_products` - مدیریت محصولات
- `can_manage_orders` - مدیریت سفارش‌ها
- `can_manage_accounting` - مدیریت حسابداری
- `can_manage_users` - مدیریت کاربران
- `can_manage_reports` - مدیریت گزارش‌ها
- `can_view_analytics` - مشاهده تجزیه‌وتحلیل

## مشکل‌یابی

### خطای Database Connection
```
# بررسی اتصال MSSQL
# مطمئن شوید MSSQL Server در حال اجرا است
# بررسی تنظیمات DB در .env
```

### خطای SMS
```
# بررسی API Key
# بررسی شماره موبایل (باید شامل کشور باشد)
# بررسی قالب‌های SMS
```

### خطای Celery
```
# مطمئن شوید Redis در حال اجرا است
# بررسی اتصال Redis: redis-cli ping
```

## ایمنی

- استفاده از JWT برای احراز هویت
- Hash کردن رمزعبورها
- CORS محدود شده
- Rate limiting
- HTTPS توصیه می‌شود برای Production
- SQL Injection protection فعال

## لایسنس

Private

## تماس و پشتیبانی

برای سوالات و مشکلات، لطفاً با تیم توسعه تماس بگیرید.

## نسخه

نسخه فعلی: 1.0.0
آخرین به‌روزرسانی: 2024
