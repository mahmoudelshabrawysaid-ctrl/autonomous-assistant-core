# Autonomous Assistant Core

مشروع أتمتة بسيط وآمن للعمل داخل Termux مع OpenAI API.

## المكونات
- `main.sh` — فحص بيئة التشغيل والموارد ووجود إعداد OpenAI.
- `openai_client.py` — إرسال طلبات إلى OpenAI Responses API باستخدام `OPENAI_API_KEY`.
- `config.json` — إعدادات المشروع وواجهة OpenAI.
- `sync.sh` — تهيئة Git وتجهيز المشروع للمزامنة مع GitHub.
- `LICENSE` — ترخيص MIT.

## تشغيل OpenAI

ضع المفتاح في متغير البيئة فقط، ولا تضعه داخل ملفات المشروع:

```bash
export OPENAI_API_KEY='ضع_المفتاح_هنا'
python3 openai_client.py "Say hello in one short sentence."
```

للتأكد من أن المفتاح موجود بدون طباعته:

```bash
./main.sh
```

## الأمان

- لا يتم تخزين مفتاح OpenAI في GitHub.
- لا يطبع البرنامج قيمة `OPENAI_API_KEY`.
- `.gitignore` يمنع ملفات `.env` من الرفع.
- إذا ظهر المفتاح في سجل أو ملف بالخطأ، قم بإلغائه من OpenAI Platform وأنشئ مفتاحًا جديدًا.

## GitHub

`sync.sh` لا يخزن Personal Access Token داخل رابط Git ولا داخل ملفات المشروع.

## ملاحظة

المشروع يستخدم Responses API ونموذج `gpt-5.6-luna` كما هو مضبوط في `config.json`.
