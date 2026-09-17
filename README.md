# Autonomous Assistant Core

مشروع أتمتة بسيط وآمن للعمل داخل Termux.

## المكونات
- `main.sh` — فحص بيئة التشغيل والموارد.
- `config.json` — إعدادات المشروع.
- `sync.sh` — تهيئة Git وتجهيز المشروع للمزامنة مع GitHub.
- `LICENSE` — ترخيص MIT.

## التشغيل

```bash
chmod +x main.sh sync.sh
./main.sh
```

## GitHub

`sync.sh` لا يخزن Personal Access Token داخل رابط Git ولا داخل ملفات المشروع.
لإنشاء المستودع والرفع، استخدم GitHub CLI (`gh`) بعد تسجيل الدخول:

```bash
gh auth login
./sync.sh
```

إذا لم يكن `gh` متاحًا، يمكن تهيئة Git محليًا واستخدام أي طريقة مصادقة GitHub مناسبة.

## ملاحظة أمنية

لا تضع رموز GitHub السرية في `README.md` أو `config.json` أو داخل أوامر محفوظة في سجل الطرفية.
