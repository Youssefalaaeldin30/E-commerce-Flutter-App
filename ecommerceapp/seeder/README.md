# Seeder لملء Firestore ببيانات Fake Store

### ملاحظة مهمة
**لا تُدرج** ملف `serviceAccountKey.json` في أي مستودع عام. هذا الملف يحتوي مفاتيح سرية لمشروع Firebase الخاص بك.

## الملفات الموجودة
- `package.json` — تعريف الحزمة والـ dependencies.
- `seed.js` — السكربت الذي يجلب البيانات من https://fakestoreapi.com ويمكّنها إلى مجموعة `products` في Firestore.
- `.gitignore` — لتجاهل `serviceAccountKey.json` و`node_modules`.

## خطوات التشغيل
1. أنشئ مشروع Firebase وفعّل Firestore (لوّن اختبار أولي مع قواعد سماح القراءة للجميع مؤقتًا).
2. اذهب إلى **Firebase Console → Project Settings → Service accounts** ثم اضغط **Generate new private key** وحمّل ملف JSON.
3. احفظ الملف المحمّل في نفس مجلد هذا السكربت وأعد تسميته إلى `serviceAccountKey.json`.
4. افتح سطر الأوامر في هذا المجلد ثم شغّل:
   ```bash
   npm install
   node seed.js
   ```
5. إذا نجحت العملية، ستجد المستندات في Cloud Firestore تحت مجموعة `products`.

## ملاحظات
- السكربت يستخدم `id` الخاص بالـ Fake Store كـ document id في Firestore، لذلك يمكن إعادة تشغيله بدون تكرار المستندات.
- Firestore يفرض حد 500 عملية كتابة في كل batch — السكربت يقسم العمليات إلى دفعات آمنة.
- بعد ملء البيانات، عدّل قواعد Firestore لأغراض الإنتاج لتقييد الكتابة والتعديل.
