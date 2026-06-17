# راهنمای شروع سریع (Quick Start Guide)

## شروع سریع پروژه BAORCO Online Shop

### پیش‌نیازها
- Python 3.8+
- Git
- Virtual Environment (venv)

---

## گام‌های راه‌اندازی

### 1️⃣ دانلود و تنظیم اولیه

```bash
# کلون کردن مخزن
git clone https://github.com/yourusername/baorco-shop.git
cd baorco-shop

# ایجاد محیط مجازی
python -m venv venv

# فعال‌سازی محیط مجازی
# در Windows:
venv\Scripts\activate
# در macOS/Linux:
source venv/bin/activate
```

### 2️⃣ نصب وابستگی‌ها

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 3️⃣ تنظیم متغیرهای محیط

```bash
# کپی کردن فایل نمونه
cp .env.example .env

# ویرایش فایل .env
# Windows: notepad .env
# macOS/Linux: nano .env

# تنظیمات ضروری:
SECRET_KEY=your-secret-key-here
DEBUG=True
DB_NAME=BAORCO_Shop
DB_USER=sa
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=1433
```

### 4️⃣ راه‌اندازی پایگاه داده

```bash
# اعمال Migration‌ها
python manage.py migrate

# ایجاد Super User (Admin)
python manage.py createsuperuser
# نام کاربری: admin
# ایمیل: admin@example.com
# رمز عبور: (انتخاب نمایید)

# ایجاد داده‌های اولیه (اختیاری)
python manage.py loaddata fixtures/initial_data.json
```

### 5️⃣ شروع سرور توسعه

```bash
python manage.py runserver
```

### 6️⃣ دسترسی به API

```
🌐 http://localhost:8000/api/
📚 مستندات: http://localhost:8000/api/docs/
```

### 7️⃣ سرویس‌های اضافی (اختیاری)

#### Redis (برای Celery)

```bash
# نصب Redis (اگر نصب نشده است)
# Windows: دانلود از https://github.com/microsoftarchive/redis/releases
# macOS: brew install redis
# Linux: sudo apt install redis-server

# شروع Redis
redis-server
```

#### Celery Worker

```bash
# در Terminal جدید
celery -A core worker -l info
```

#### Celery Beat

```bash
# در Terminal دیگری
celery -A core beat -l info
```

---

## اولین سفارش خود

### مرحله 1: ثبت نام

```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "phone": "989123456789",
    "password": "TestPassword123",
    "password2": "TestPassword123"
  }'
```

### مرحله 2: ورود

```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "TestPassword123"
  }'
```

**نتیجه:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": { ... }
}
```

**توجه:** توکن `access` را برای درخواست‌های بعدی ذخیره کنید.

### مرحله 3: مشاهده محصولات

```bash
curl http://localhost:8000/api/products/ \
  -H "Accept: application/json"
```

### مرحله 4: اضافه کردن به سبد

```bash
TOKEN="your_access_token_here"

curl -X POST http://localhost:8000/api/cart/add_item/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 1,
    "quantity": 2
  }'
```

### مرحله 5: ایجاد سفارش

```bash
TOKEN="your_access_token_here"

curl -X POST http://localhost:8000/api/orders/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "shipping_address": "تهران، خیابان ولیعصر",
    "shipping_city": "تهران",
    "shipping_postal_code": "1234567",
    "shipping_phone": "989123456789",
    "payment_method": "card",
    "is_installment": false
  }'
```

---

## دسترسی به Admin Panel

```
🔗 http://localhost:8000/admin/
👤 نام کاربری: admin
🔐 رمز عبور: (رمزی که در مرحله 4 انتخاب کردید)
```

### کارهایی که می‌توانید در Admin انجام دهید:

1. ✅ اضافه کردن محصولات جدید
2. ✅ مدیریت دسته‌بندی‌ها
3. ✅ مشاهده و مدیریت سفارش‌ها
4. ✅ مدیریت کاربران
5. ✅ تنظیم کدهای تخفیف

---

## Postman Collection

برای استفاده از Postman:

1. [دانلود Postman](https://www.postman.com/downloads/)
2. ایمپورت کنید: `postman_collection.json`
3. جایگزین کنید `{{base_url}}` با `http://localhost:8000`
4. تنظیم کنید `{{access_token}}` بعد از ورود

---

## Docker Setup (اگر Docker دارید)

```bash
# ایجاد Image و شروع Containers
docker-compose up -d

# مشاهده لاگ‌ها
docker-compose logs -f

# اجرای Migration
docker-compose exec api python manage.py migrate

# ایجاد Super User
docker-compose exec api python manage.py createsuperuser

# دسترسی
🌐 http://localhost:8000/api/
```

---

## مشکل‌یابی

### خطای "No database found"

```bash
# بررسی اتصال پایگاه داده
python manage.py dbshell

# یا بررسی تنظیمات .env
nano .env
```

### خطای "Module not found"

```bash
# مطمئن شوید Virtual Environment فعال است
# Windows: venv\Scripts\activate
# Linux/Mac: source venv/bin/activate

# نصب مجدد وابستگی‌ها
pip install -r requirements.txt
```

### پورت 8000 در حال استفاده است

```bash
# استفاده از پورت دیگر
python manage.py runserver 0.0.0.0:8001
```

### خطای Static Files

```bash
python manage.py collectstatic --noinput
```

---

## منابع مفید

📖 [Django Documentation](https://docs.djangoproject.com/)  
📖 [Django REST Framework](https://www.django-rest-framework.org/)  
📖 [Celery Documentation](https://docs.celeryproject.io/)  
📖 [MSSQL Documentation](https://docs.microsoft.com/en-us/sql/)  

---

## سوالات متداول (FAQ)

**Q: چگونه رمزعبور را تغییر دهم؟**
```bash
python manage.py changepassword admin
```

**Q: چگونه از Super User خارج شوم؟**
```bash
python manage.py shell
from django.contrib.auth import get_user_model
User = get_user_model()
user = User.objects.get(username='admin')
user.is_staff = False
user.is_superuser = False
user.save()
```

**Q: چگونه پایگاه داده را reset کنم؟**
```bash
python manage.py flush
python manage.py migrate
python manage.py createsuperuser
```

---

## مراحل بعدی

✅ مطالعه [مستندات API](API_DOCUMENTATION.md)  
✅ مطالعه [راهنمای Deployment](DEPLOYMENT.md)  
✅ تنظیم SMS.ir API Key  
✅ کانفیگ CORS برای اپلیکیشن موبایل  

---

## تماس و پشتیبانی

برای سوالات و مشکلات:
- 📧 ایمیل: support@baorco.ir
- 💬 GitHub Issues
- 📞 تلفن: [شماره تماس]

---

**خوش‌آمدید به BAORCO Online Shop! 🎉**
