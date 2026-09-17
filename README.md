# Autonomous Assistant Core

مشروع أتمتة بسيط وآمن يمكن تشغيله محليًا أو من خلال GitHub Actions مع OpenAI API.

## CORE — بوابة الأوامر الموحدة

بدل حفظ أوامر كثيرة، استخدم بوابة واحدة:

```text
/core <اكتب طلبك بطريقتك العادية>
```

البوابة تفهم الطلب وتربطه بمجال المشروع المناسب مثل الأمن السيبراني، الكود وGitHub، التقارير، English، كرة القدم، والتكاملات.

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
- `~/bin/report` — واجهة التقارير المحلية.

## Public Phone Intelligence

`tools/phone-osint.sh` يوفر فحصًا عامًا وآمنًا لأرقام الهاتف ضمن نطاق Public Phone Intelligence:

```bash
./tools/phone-osint.sh inspect +201001234567
./tools/phone-osint.sh intel +201001234567
./tools/phone-osint.sh deep +201001234567
./tools/phone-osint.sh audit +201001234567
./tools/phone-osint.sh report +201001234567
```

وضع `deep` يسجل وقت الرصد، مصدر إعداد الـproviders، حالات المزودين، وقواعد correlation التي تتطلب مصدرًا عامًا منسوبًا وموافقة بين مصادر مستقلة قبل اعتبار المعلومة مؤكدة. المزودون الخارجيون **opt-in** ومغلقون افتراضيًا؛ يوجد قالب إعداد في `tools/phone-intel-providers.example.conf`.

النطاق يقتصر على metadata العامة، معلومات الأعمال المنشورة، والـpublic-web mentions المسموح بها. لا ينفذ OTP أو password reset أو private-account enumeration أو identity resolution أو address discovery أو SIM/telecom manipulation أو تجاوز ضوابط الوصول.

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

الكتالوج مخصص لتمارين محلية اصطناعية ونطاقها `local-only`.

## Evidence → Finding → Validation → Report

المشروع يحتوي الآن على مسار موحّد لتحويل الأدلة الاصطناعية/المحلية إلى نتائج قابلة للمراجعة:

- `tools/finding-engine.sh` — يربط الأدلة بالمصدر والحالة ويُخرج verdict وconfidence وremediation دون تنفيذ شبكة.
- `tools/vuln-validation.sh` — يتحقق من وجود finding + proof + repeatable + confirmed status قبل إصدار `CONFIRMED`.
- `tools/report-engine.sh` — ينشئ التقرير ويستطيع تشغيل validation محليًا عبر `from-vuln` ثم تضمين نتيجة التحقق داخل التقرير.

مثال محلي:

```bash
cat > evidence.txt <<'EOF'
finding=synthetic-vulnerability
proof=deterministic-test-evidence
repeatable=yes
status=confirmed
severity=medium
remediation=patch-fixture
EOF

./tools/finding-engine.sh from-file evidence.txt
./tools/vuln-validation.sh validate evidence.txt
./tools/report-engine.sh from-vuln ctf localhost "Synthetic validation" evidence.txt
```

كل هذه الأدوات مصممة للعمل على أدلة محلية/اصطناعية فقط ولا تنفذ استغلالًا أو فحصًا لأهداف خارجية.

## Report Engine

`tools/report-engine.sh` هو محرك تقارير موحّد لنتائج الـLab والـCTF والاختبارات. المحرك لا ينفذ فحوصًا أو اتصالات؛ هو يستقبل النتائج ويحوّلها إلى تقارير Markdown تحت `~/sec_lab/reports/`.

```bash
./tools/report-engine.sh init
./tools/report-engine.sh new ctf localhost "Authentication CTF"
./tools/report-engine.sh from-file lab localhost "Local scan" result.txt
./tools/report-engine.sh from-vuln ctf localhost "Validated finding" evidence.txt
./tools/report-engine.sh list
./tools/report-engine.sh validate
./tools/report-engine.sh stats
```

كل تقرير يحمل نوع العملية والهدف والنطاق والحالة والتوقيت وملخصًا ومكان الأدلة وخطوات المتابعة. تقارير validation تحتوي أيضًا على نتيجة الـengine والـverdict عندما تستخدم `from-vuln`. النطاق الافتراضي في المحرك `local-only`.

> استخدم أدوات الأمن فقط على أنظمة تملكها أو لديك تصريح صريح لاختبارها. إعداد المختبر لا يمنحك تصريحًا لاختبار أي هدف خارجي.

## OpenAI

`openai_client.py` يستخدم Responses API بدون مكتبات خارجية. الإعدادات تقرأ من متغيرات البيئة مع قيم افتراضية آمنة. أضف `OPENAI_API_KEY` كـ GitHub Secret أو متغير بيئة محلي؛ لا تضع المفتاح داخل الملفات أو المستودع.

## CI وTest Manager

- `.github/workflows/ci.yml` يتحقق من Python وJSON وBash ويبحث عن أنماط مفاتيح/مفاتيح خاصة مسربة.
- `.github/workflows/test-manager.yml` يشغّل Test Manager على push وpull request ويدويًا.
- `.github/workflows/ctf.yml` يتحقق من CTF Manager على التغييرات الخاصة به.
- `.github/workflows/report-engine.yml` يتحقق من Report Engine ويشغّل Test Manager.
- `tools/test-manager.sh` يوحّد فحوص syntax/config، اختبارات الوحدة، فحص الأسرار، CTF validation، Report validation، وVulnerability Validation.
