# الصانع الحرفي (Al-Sane' Al-Harfiyin)

تطبيق Flutter لربط الحرفيين بالعملاء في الدول العربية (المغرب، الجزائر، تونس) مع دعم اللهجات المحلية والرسائل الصوتية.

## المميزات

- 🎙️ **رسائل صوتية**: تواصل سهل عبر الرسائل الصوتية
- 🌍 **دعم اللهجات**: أسماء المهن بلهجات مختلفة (مغربية، جزائرية، تونسية)
- 🔥 **Firebase Backend**: مصادقة، قاعدة بيانات، تخزين سحابي
- 💰 **AdMob**: إعلانات بانر ومكافآت
- 📊 **Firebase Analytics**: تتبع الأحداث والأداء
- ⚡ **تحسين التكاليف**: استخدام محدود للقراءة/الكتابة من Firebase

## البنية التقنية

- **Framework**: Flutter 3.16.5
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Storage, Functions)
- **Monetization**: Google AdMob
- **Analytics**: Firebase Analytics & Crashlytics
- **Audio**: flutter_sound, record
- **Package Name**: `com.elsane3.app`

## متطلبات التشغيل

- Flutter SDK 3.16.5 أو أحدث
- Dart SDK 3.2.0 أو أحدث
- Android SDK (للبناء على Android)
- حساب Firebase مع تفعيل الخدمات التالية:
  - Authentication
  - Firestore Database
  - Storage
  - Cloud Functions
  - Analytics
  - Crashlytics

## التثبيت والإعداد

### 1. استنساخ المشروع

```bash
git clone <repository-url>
cd alsana_alharfiyin
```

### 2. تثبيت التبعيات

```bash
flutter pub get
```

### 3. إعداد Firebase

1. أنشئ مشروع Firebase جديد على [Firebase Console](https://console.firebase.google.com/)
2. أضف تطبيق Android باسم الحزمة `com.elsane3.app`
3. حمّل ملف `google-services.json` وضعه في `android/app/`
4. فعّل الخدمات المطلوبة (Auth, Firestore, Storage, Analytics)

### 4. إعداد AdMob

1. أنشئ حساب AdMob على [AdMob Console](https://apps.admob.com/)
2. أنشئ وحدات إعلانية (Banner & Rewarded)
3. استبدل معرفات الإعلانات في `lib/services/ads_service.dart`

### 5. نشر Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

### 6. تشغيل التطبيق

```bash
flutter run
```

## البناء للإنتاج

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle (AAB)

```bash
flutter build appbundle --release
```

## هيكل المشروع

```
lib/
├── constants/          # الثوابت (ألوان، نصوص)
├── models/            # نماذج البيانات
├── providers/         # إدارة الحالة (Provider)
├── screens/           # شاشات التطبيق
│   ├── auth/         # شاشات المصادقة
│   ├── main/         # الشاشات الرئيسية
│   └── chat/         # شاشات المحادثات
├── services/          # خدمات Firebase وغيرها
├── widgets/           # مكونات قابلة لإعادة الاستخدام
└── main.dart          # نقطة الدخول

functions/             # Cloud Functions
├── index.js          # الدوال السحابية
└── package.json      # تبعيات Node.js

assets/               # الأصول (صور، أيقونات، خطوط)
├── images/
├── icons/
├── fonts/
└── audio/
```

## تقليل تكاليف Firebase

التطبيق مصمم لتقليل التكاليف من خلال:

- ✅ استخدام Listeners محدودة
- ✅ Cache للبيانات المكررة
- ✅ تحديد عمر الطلبات (48 ساعة)
- ✅ استخدام Cloud Functions للعمليات المعقدة
- ✅ ضغط الصور والملفات الصوتية

## الترخيص

هذا المشروع مملوك بشكل خاص. جميع الحقوق محفوظة.

## الدعم

للمساعدة والدعم، يرجى التواصل عبر [البريد الإلكتروني أو وسيلة التواصل المفضلة]
