# Autonomous Assistant Core

مشروع أتمتة بسيط وآمن يمكن تشغيله محليًا أو من خلال GitHub Actions مع OpenAI API.

## CORE — بوابة الأوامر الموحدة

بدل حفظ أوامر كثيرة، استخدم بوابة واحدة:

```text
/core <اكتب طلبك بطريقتك العادية>
```

البوابة تفهم الطلب وتربطه بمجال المشروع المناسب مثل الأمن السيبراني، الكود وGitHub، التقارير، English، كرة القدم، والتكاملات. لا تحتاج لمعرفة أسماء الأدوات الداخلية.

- `core-command.sh` — بوابة تصنيف الطلبات محليًا.
- `COMMAND_DICTIONARY.md` — قاموس المصطلحات والمرادفات.
- `tasks.json` — حالة مهام المشروع.
- `SAFETY.md` — عقد السلامة وحدود التنفيذ.

## مختبر الأمن السيبراني

يوفر المشروع مختبرًا محليًا للتعلم وCTF واختبارات الأمن المصرح بها. المكونات تشمل:

- `termux-ethical-lab-install.sh` — المثبّت الأساسي للأدوات وTermux.
- `setup-sec-lab.sh` — إعداد تلقائي للمختبر.
- `lab-manager.sh` — إنشاء وإدارة ملفات المختبر، كتالوج التدريب، ومساحة CTF.
- `~/bin/sec` — واجهة الأوامر ذات الكلمة الواحدة.
- `~/bin/guard` — Safety Guard يمنع الأهداف غير المسموح بها.
- `~/bin/report` — إنشاء تقرير تلقائي لكل فحص.

## Safety Guard

الوضع الافتراضي يسمح فقط بـ `localhost` وloopback. عناوين الشبكات الخاصة لا تعمل إلا إذا كانت موجودة صراحة في:

`~/sec_lab/targets/allowlist.txt`

الأهداف العامة وأسماء النطاقات العامة والـURLs يتم رفضها من طبقة الحماية قبل تشغيل الفحص.

## CTF Manager

`tools/ctf-manager.sh` يدير كتالوج التدريب المحلي دون تنفيذ هجوم على أهداف خارجية:

```bash
./tools/ctf-manager.sh list
./tools/ctf-manager.sh show 001
./tools/ctf-manager.sh stats
./tools/ctf-manager.sh validate
```

الكتالوج الحالي يتضمن تمارين محلية اصطناعية، ونطاقها `local-only`. يمكن استخدامه مع Lab Manager لتوثيق وتمييز حالات التدريب.

## التقارير

كل فحص ناجح يحفظ مخرجاته في `~/sec_lab/reports/` وينشئ ملف Markdown مقابلاً يحتوي على التاريخ والنطاق والهدف ومكان الأدلة والملاحظات.

> استخدم أدوات الأمن فقط على أنظمة تملكها أو لديك تصريح صريح لاختبارها. إعداد المختبر لا يمنح تصريحًا لاختبار أي هدف خارجي.

## OpenAI

`openai_client.py` يستخدم Responses API بدون مكتبات خارجية. الإعدادات تقرأ من متغيرات البيئة مع قيم افتراضية آمنة. أضف `OPENAI_API_KEY` كـ GitHub Secret أو متغير بيئة محلي؛ لا تضع المفتاح داخل الملفات أو المستودع.

## CI وTest Manager

- `.github/workflows/ci.yml` يتحقق من Python وJSON وBash ويبحث عن أنماط مفاتيح/مفاتيح خاصة مسربة.
- `.github/workflows/test-manager.yml` يشغّل Test Manager على push وpull request ويدويًا.
- `.github/workflows/ctf.yml` يتحقق من CTF Manager على التغييرات الخاصة به.
- `tools/test-manager.sh` يوحّد فحوص syntax/config، اختبارات الوحدة، وفحص الأسرار وCTF validation في أمر واحد:

```bash
bash tools/test-manager.sh all
```

- `tests/test_test_manager.sh` و`tests/test_ctf_manager.sh` يتحققان من مكونات الاختبار.
- `.github/workflows/ai.yml` يبقى تشغيلًا يدويًا فقط لتجنب تشغيل API غير مقصود.

## المشروع الأصلي

- `main.sh` — فحص بيئة التشغيل ووجود إعداد OpenAI بدون كشف المفتاح.
- `sync.sh` — مزامنة Git المحلية مع GitHub عند استخدام بيئة محلية.
