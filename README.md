# CargoPro Task - Flutter App

A Flutter application demonstrating Firebase Phone Authentication and REST API integration with object management capabilities.

## 🚀 Live Demo

**Web App:** [https://cargopro-task-71637.web.app](https://cargopro-task-71637.web.app)
use -phone number:8978377740 otp:999999
## 📱 Features

- **Firebase Phone Authentication**
    - OTP-based login system
    - Support for both Android and Web platforms
    - Secure session management

- **Object Management (REST API Integration)**
    - View list of all objects from REST API
    - Create new objects
    - Edit user-created objects
    - Delete user-created objects
    - Local storage for user-created object IDs

- **State Management**
    - GetX for reactive state management
    - Dependency injection with GetX bindings
    - Persistent storage with GetStorage

## 🛠️ Tech Stack

- **Framework:** Flutter 3.8.1
- **State Management:** GetX (^4.7.3)
- **Backend Services:**
    - Firebase Core (^4.2.1)
    - Firebase Auth (^6.1.2)
- **HTTP Client:** http (^1.6.0)
- **Local Storage:** get_storage (^2.1.1)
- **UI Components:**
    - Google Fonts (^6.3.2)
    - Pin Code Fields (^8.0.1)
- **Testing:** Mockito (^5.6.1)

## 📁 Project Structure

```
lib/
├── app/
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   ├── themes/
│   ├── data/
│   │   └── models/
│   │       └── api_object_model.dart
│   └── modules/
│       ├── auth/
│       │   ├── bindings/
│       │   │   └── auth_binding.dart
│       │   ├── controllers/
│       │   │   └── auth_controller.dart
│       │   └── views/
│       ├── detail/
│       │   ├── bindings/
│       │   │   └── detail_binding.dart
│       │   ├── controllers/
│       │   │   └── detail_controller.dart
│       │   └── views/
│       │       └── detail_view.dart
│       ├── home/
│       ├── object_form/
│       └── services/
└── main.dart
```

## 🔧 Setup Instructions

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Firebase account
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Mani0279/CargoPro-task.git
   cd CargoPro-task
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   The project is already configured with Firebase. Configuration files included:
    - `android/app/google-services.json` (Android)
    - `lib/firebase_options.dart` (Both platforms)

   If you want to use your own Firebase project:
    - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
    - Enable Phone Authentication in Firebase Console
    - Download configuration files and replace existing ones

4. **Run the app**

   For Android:
   ```bash
   flutter run
   ```

   For Web:
   ```bash
   flutter run -d chrome
   ```

## 🔐 Firebase Phone Authentication Setup

### For Web Platform

1. **Enable Phone Authentication**
    - Go to Firebase Console → Authentication → Sign-in method
    - Enable Phone authentication provider

2. **Add Authorized Domains**
    - Add your web app domain to authorized domains
    - For local testing: `localhost` is already authorized
    - For production: Add your Firebase Hosting domain

3. **reCAPTCHA Configuration**
    - Web phone auth uses reCAPTCHA for verification
    - Ensure reCAPTCHA is properly configured in Firebase Console

### For Android Platform

1. **Enable Phone Authentication** (same as web)

2. **SHA-1 Certificate**
    - Get your SHA-1 fingerprint:
      ```bash
      keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
      ```
    - Add SHA-1 to Firebase project settings

3. **Update google-services.json**
    - Download latest `google-services.json` from Firebase Console
    - Place in `android/app/` directory

## 📦 Dependencies Explained

```yaml
dependencies:
  get: ^4.7.3                    # State management & routing
  firebase_core: ^4.2.1          # Firebase initialization
  firebase_auth: ^6.1.2          # Phone authentication
  http: ^1.6.0                   # REST API calls
  get_storage: ^2.1.1            # Local data persistence
  google_fonts: ^6.3.2           # Custom fonts
  pin_code_fields: ^8.0.1        # OTP input UI

dev_dependencies:
  mockito: ^5.6.1                # Testing & mocking
  build_runner: ^2.10.4          # Code generation
```

## 🏗️ Code Structure & Design Choices

### 1. **GetX Architecture**
- **Bindings:** Dependency injection for controllers
- **Controllers:** Business logic and state management
- **Views:** UI components

Example:
   ```dart
   class AuthBinding extends Bindings {
     @override
     void dependencies() {
       if (!Get.isRegistered<AuthController>()) {
         Get.put<AuthController>(AuthController(), permanent: true);
       }
     }
   }
   ```

### 2. **Separation of Concerns**
- **Models:** Data structures (`api_object_model.dart`)
- **Controllers:** Business logic (`auth_controller.dart`, `detail_controller.dart`)
- **Views:** UI presentation only
- **Services:** API calls and external integrations

### 3. **Dependency Injection**
- Used GetX's `Get.put()` and `Get.find()` for DI
- `permanent: true` for authentication state persistence
- Automatic controller disposal when not needed

### 4. **Reactive State Management**
- `.obs` observables for reactive updates
- `GetX<Controller>` widgets for automatic rebuilds
- Efficient state updates without manual `setState()`

## 🌐 REST API Integration

**Base URL:** `https://api.restful-api.dev/objects`

### Endpoints Used:

- **GET** `/objects` - List all objects (returns IDs 1-13)
- **GET** `/objects?id={id}` - Get specific objects by ID
- **POST** `/objects` - Create new object
- **PUT** `/objects/{id}` - Update object (only user-created)
- **DELETE** `/objects/{id}` - Delete object (only user-created)

### API Response Example:

```json
{
  "id": "7",
  "name": "Apple MacBook Pro 16",
  "data": {
    "year": 2019,
    "price": 1849.99,
    "CPU model": "Intel Core i9",
    "Hard disk size": "1 TB"
  }
}
```

## 🚧 Limitations and Future Improvements

### FIXED Limitations:

1. **API Restrictions:**
    - The REST API's GET endpoint only returns objects with IDs 1-13 by default
    - Edit and Delete operations only work on user-created objects
    - Pre-existing objects (IDs 1-13) cannot be modified or deleted

2. **Workaround Implementation:**
    - When users create new objects, the object ID is saved locally using GetStorage
    - User-created object IDs are stored persistently on the device
    - Custom endpoint `https://api.restful-api.dev/objects?id={id}` is used to fetch user-created objects
    - User-created objects are displayed at the top of the list for easy access
    - Edit and Delete buttons are only enabled for user-created objects
    - This approach ensures full CRUD functionality works as expected for user-generated content

3. **Authentication:**
    - Phone authentication requires active internet connection
    - SMS costs apply for phone number verification

### Future Improvements:

1. **Enhanced Features:**
    - Add search and filter functionality for objects
    - Implement pagination for large datasets
    - Add offline mode with local caching
    - User profile management
    - Export data functionality

2. **API Enhancements:**
    - Integrate with a custom backend for full CRUD on all objects
    - Add real-time updates using WebSockets or Firebase Realtime Database
    - Implement data synchronization across devices

3. **UI/UX Improvements:**
    - Add animations and transitions
    - Implement pull-to-refresh
    - Dark mode support
    - Better error handling and user feedback

4. **Testing:**
    - Increase unit test coverage
    - Add integration tests
    - Implement widget tests

5. **Performance:**
    - Implement lazy loading
    - Optimize image loading
    - Add caching strategies

## 🧪 Testing

Run tests:
```bash
flutter test
```

Generate mocks (if needed):
```bash
flutter pub run build_runner build
```

## 🚀 Deployment

### Web Deployment (Firebase Hosting)

1. **Build for web:**
   ```bash
   flutter build web
   ```

2. **Deploy to Firebase:**
   ```bash
   firebase deploy
   ```

### Android Deployment

1. **Build APK:**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle:**
   ```bash
   flutter build appbundle --release
   ```

## 📝 Environment Variables

Firebase configuration is stored in:
- `firebase.json`
- `lib/firebase_options.dart`
- `android/app/google-services.json`

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is created for demonstration purposes.

## 👤 Author

**Manish Anker**
- Email: manishanker279av@gmail.com
- GitHub: [@Mani0279](https://github.com/Mani0279)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication services
- RESTful API Dev for the public API
- GetX community for state management solutions

## 📞 Support

For support, email manishanker279av@gmail.com or create an issue in the repository.

---

**Built with ❤️ using Flutter**