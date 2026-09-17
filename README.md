# Autonomous Assistant Core

مشروع أتمتة بسيط وآمن يمكن تشغيله محليًا أو من خلال GitHub Actions مع OpenAI API.

## مختبر الأمن السيبراني

يوفر المشروع مختبرًا محليًا للتعلم وCTF واختبارات الأمن المصرح بها. المكونات الجديدة تشمل:

- `termux-ethical-lab-install.sh` — المثبّت الأساسي للأدوات وTermux.
- `setup-sec-lab.sh` — إعداد تلقائي لمرة واحدة للمختبر المحسن.
- `lab-manager.sh` — إنشاء وإدارة ملفات المختبر، كتالوج التدريب، ومساحة CTF.
- `~/bin/sec` — واجهة الأوامر ذات الكلمة الواحدة.
- `~/bin/guard` — Safety Guard يمنع الأهداف غير المسموح بها.
- `~/bin/report` — إنشاء تقرير تلقائي لكل فحص.

## الإعداد التلقائي

```bash
pkg install -y git

git clone https://github.com/mahmoudelshabrawysaid-ctrl/autonomous-assistant-core.git
cd autonomous-assistant-core
bash setup-sec-lab.sh
source ~/.bashrc
```

بعدها تصبح الأوامر:

```text
scan [target]     فحص خدمات مع تقرير تلقائي
recon [target]    اكتشاف الخدمات مع تقرير تلقائي
vuln [target]     فحص Nmap vulnerability scripts مع تقرير تلقائي
allow PRIVATE_IP  إضافة عنوان خاص محدد إلى قائمة الأهداف المسموحة
ctf               عرض كتالوج أهداف CTF المحلية
lab               إعادة تجهيز المختبر
report [file]     إنشاء تقرير
 doctor            فحص صحة المختبر والأدوات
help              عرض المساعدة
```

## Safety Guard

الوضع الافتراضي يسمح فقط بـ `localhost` وloopback. عناوين الشبكات الخاصة لا تعمل إلا إذا كانت موجودة صراحة في:

`~/sec_lab/targets/allowlist.txt`

الأهداف العامة وأسماء النطاقات العامة والـURLs يتم رفضها من طبقة الحماية قبل تشغيل الفحص.

## CTF Targets

يتم إنشاء كتالوج محلي لتمارين Web وSQLi وAuthentication وAPI وNetwork وForensics، إضافة إلى **1000 حالة تدريبية اصطناعية** قابلة للتوسع. هذه الحالات عبارة عن مواد تدريبية وبيانات مختبر، وليست نشرًا لثغرات على الإنترنت.

## التقارير

كل فحص ناجح يحفظ مخرجاته في `~/sec_lab/reports/` وينشئ ملف Markdown مقابلاً يحتوي على التاريخ والنطاق والهدف ومكان الأدلة والملاحظات.

> استخدم أدوات الأمن فقط على أنظمة تملكها أو لديك تصريح صريح لاختبارها. إعداد المختبر لا يمنح تصريحًا لاختبار أي هدف خارجي.

## المشروع الأصلي

- `main.sh` — فحص بيئة التشغيل ووجود إعداد OpenAI بدون كشف المفتاح.
- `openai_client.py` — عميل خفيف لـ OpenAI Responses API، بدون مكتبات خارجية.
- `config.json` — إعدادات المشروع واسم متغيرات البيئة.
- `.github/workflows/ai.yml` — تشغيل يدوي آمن من GitHub Actions.
- `sync.sh` — مزامنة Git المحلية مع GitHub عند استخدام بيئة محلية.

## OpenAI

قبل تشغيل وظائف OpenAI، أضف `OPENAI_API_KEY` كـ GitHub Secret أو متغير بيئة محلي. لا تضع المفتاح داخل الملفات أو المستودع.
