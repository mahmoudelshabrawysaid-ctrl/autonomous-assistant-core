# Cybersecurity Lab Resources

مرجع منظم للمختبر. الروابط الخارجية هنا مقتصرة على المصادر الرسمية أو المشاريع الرسمية المفتوحة المصدر، ولا يتم تشغيل أو تنزيل أي شيء منها تلقائيًا.

## Learning / CTF

- [OWASP Web Security Testing Guide](https://wstg.owasp.org/) — منهج مرجعي لاختبار أمن تطبيقات الويب. استخدم النسخ المرقمة عند تثبيت مراجع طويلة الأجل.
- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) — تطبيق ويب ضعيف عمدًا للتدريب وCTF واختبار أدوات الأمن داخل بيئة مصرح بها. المشروع الرسمي على GitHub: https://github.com/juice-shop/juice-shop
- [PortSwigger Web Security Academy](https://portswigger.net/web-security) — تدريب مجاني مع مختبرات تفاعلية مخصصة للتعلم الآمن والقانوني.
- [picoCTF / CyLab Security Academy](https://www.picoctf.org/) — منصة Carnegie Mellon للتعلم والتحديات؛ الموقع يوضح أن picoCTF انتقل إلى CyLab Security Academy في 2026.
- [OverTheWire Wargames](https://overthewire.org/) — ألعاب تدريبية لمفاهيم Linux والأمن؛ ابدأ بـ Bandit للمستوى التمهيدي: https://overthewire.org/wargames/bandit/

## Android / APK

- [F-Droid](https://f-droid.org/) — مستودع/نظام توزيع لتطبيقات Android الحرة ومفتوحة المصدر.
- [GitHub Releases](https://github.com/) — عند الحاجة إلى تطبيق أو أداة من مشروع مفتوح المصدر، استخدم صفحة Releases الرسمية للمشروع وتحقق من المصدر والإصدار قبل التثبيت.

> لا يتم تخزين ملفات APK ثنائية داخل المستودع. هذا الملف يحتفظ بفهرس وروابط المصادر فقط، لتقليل مخاطر الملفات المعدلة أو الخبيثة.

## Integration policy

- لا يتم اعتبار أي رابط خارجي هدفًا للفحص لمجرد وجوده في هذا الملف.
- لا يتم تنفيذ active scanning أو exploitation على هذه الموارد من أدوات المشروع.
- أي استيراد لكود خارجي يحتاج مراجعة المصدر والترخيص والاعتمادات والاختبارات قبل دمجه.
- موارد التدريب التي توفر أهدافًا جاهزة تُستخدم فقط وفق شروطها وبداخل نطاق التدريب المصرح به.

## Lab principles

- الأهداف المحلية أو المصرح بها فقط.
- Safety Guard إلزامي قبل أي active scan.
- سجّل النطاق والوقت والنتائج لكل اختبار.
- لا تحفظ كلمات مرور أو مفاتيح API داخل التقارير أو Git.
