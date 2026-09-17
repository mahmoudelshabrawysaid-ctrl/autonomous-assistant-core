# Autonomous Assistant Core

مشروع أتمتة بسيط وآمن يمكن تشغيله محليًا أو من خلال GitHub Actions مع OpenAI API.

## المكونات
- `main.sh` — فحص بيئة التشغيل ووجود إعداد OpenAI بدون كشف المفتاح.
- `openai_client.py` — عميل خفيف لـ OpenAI Responses API، بدون مكتبات خارجية.
- `config.json` — إعدادات المشروع واسم متغيرات البيئة.
- `.github/workflows/ai.yml` — تشغيل يدوي آمن من GitHub Actions.
- `sync.sh` — مزامنة Git المحلية مع GitHub عند استخدام بيئة محلية.

## التشغيل من GitHub

يمكن تشغيل المشروع من **Actions → Autonomous Assistant → Run workflow**.

قبل أول تشغيل، أضف سر المستودع باسم:

`OPENAI_API_KEY`

المفتاح لا يوضع داخل الملفات ولا في الـ workflow نفسه.

## التشغيل محليًا

```bash
export OPENAI_API_KEY='ضع_المفتاح_هنا'
python3 openai_client.py "Say hello in one short sentence."
```

اختبار البيئة بدون كشف المفتاح:

```bash
./main.sh
```

## الإعدادات

يمكن تغيير النموذج أو عنوان API من متغيرات البيئة:

- `OPENAI_MODEL` — الافتراضي `gpt-4.1-mini`.
- `OPENAI_API_URL` — الافتراضي `https://api.openai.com/v1/responses`.

## الأمان

- لا يتم تخزين مفتاح OpenAI في GitHub files.
- لا يطبع البرنامج قيمة `OPENAI_API_KEY`.
- `.gitignore` يمنع الملفات المحلية الشائعة التي قد تحتوي أسرارًا.
- GitHub Actions يستخدم Secrets بدل كتابة المفتاح في الكود.

إذا تم كشف مفتاح بالخطأ، قم بإلغائه وإنشاء مفتاح جديد من OpenAI Platform.
