# Autonomous Assistant Core

مشروع أتمتة بسيط وآمن يمكن تشغيله محليًا أو من خلال GitHub Actions مع OpenAI API.

## المكونات
- `main.sh` — فحص بيئة التشغيل ووجود إعداد OpenAI بدون كشف المفتاح.
- `openai_client.py` — عميل خفيف لـ OpenAI Responses API، بدون مكتبات خارجية.
- `config.json` — إعدادات المشروع واسم متغيرات البيئة.
- `.github/workflows/ai.yml` — تشغيل يدوي آمن من GitHub Actions.
- `sync.sh` — مزامنة Git المحلية مع GitHub عند استخدام بيئة محلية.
- `termux-ethical-lab-install.sh` — تجهيز مختبر أمن سيبراني للتعلم وCTF واختبارات الأنظمة المصرح بها على Termux.

## تشغيل مختبر Termux

```bash
pkg install -y git

git clone https://github.com/mahmoudelshabrawysaid-ctrl/autonomous-assistant-core.git
cd autonomous-assistant-core
bash termux-ethical-lab-install.sh
```

يحاول السكربت تثبيت: Nmap, Python 3, Git, curl, wget, Netcat, tcpdump, OpenSSH, Hydra, SQLmap، ثم ينشئ `~/sec_lab`.

> استخدم أدوات الأمن فقط على أنظمة تملكها أو لديك تصريح صريح لاختبارها، مثل مختبر محلي أو بيئة CTF.

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
