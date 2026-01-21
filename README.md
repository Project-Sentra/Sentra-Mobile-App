# 🚗 Sentra Mobile App

<p align="center">
  <img src="assets/images/logoDark.png" alt="Sentra Logo" width="200" height="200">
</p>

<p align="center">
  <strong>Smart Parking Management System</strong><br>
  A modern Flutter application for parking spot management and reservations
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart" alt="Dart"></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase" alt="Supabase"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License"></a>
</p>

---

## 📱 About The Project

**Sentra** is a comprehensive mobile application designed to revolutionize the parking experience. Built with Flutter and powered by Supabase, it provides users with real-time parking availability, seamless booking management, and integrated payment solutions. The app follows clean architecture principles and implements modern design patterns for maintainability and scalability.

### ✨ Key Features

- 🔐 **Secure Authentication**
  - Email/Password authentication
  - Google Sign-In integration
  - Apple Sign-In support
  - Secure session management

- 🅿️ **Parking Management**
  - Real-time parking spot availability
  - Interactive facility search and filtering
  - Location-based parking discovery
  - Detailed facility information with pricing

- 🚙 **Vehicle Management**
  - Add and manage multiple vehicles
  - Set default vehicle for quick bookings
  - Store vehicle details (make, model, color, plate)
  - Easy vehicle switching

- 📅 **Booking System**
  - Real-time booking creation
  - View active and upcoming reservations
  - Booking history tracking
  - Flexible time slot selection

- 💳 **Payment Integration**
  - Multiple payment method support
  - Secure payment processing
  - Payment history and receipts
  - Default payment method management

- 👤 **User Profile**
  - Profile customization
  - Booking statistics
  - Account settings
  - Sign out functionality

- 🎨 **Modern UI/UX**
  - Dark theme with lime yellow accents
  - Smooth animations and transitions
  - Responsive design for all screen sizes
  - Intuitive bottom navigation

---

## 🏗️ Architecture

The application follows **Clean Architecture** principles with a feature-based structure:

```
lib/
├── core/                          # Core functionality
│   ├── di/                       # Dependency Injection (GetIt)
│   ├── router/                   # Navigation (GoRouter)
│   ├── theme/                    # App theming and colors
│   ├── widgets/                  # Reusable widgets
│   ├── errors/                   # Error handling
│   └── usecases/                 # Base use case classes
│
├── features/                      # Feature modules
│   ├── auth/                     # Authentication feature
│   │   ├── data/                # Data sources & repositories
│   │   ├── domain/              # Entities & use cases
│   │   └── presentation/        # UI & BLoC
│   │
│   ├── parking/                  # Parking management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── vehicles/                 # Vehicle management
│   ├── booking/                  # Booking system
│   ├── payment/                  # Payment processing
│   ├── profile/                  # User profile
│   ├── history/                  # Booking history
│   ├── home/                     # Home & navigation
│   └── splash/                   # Splash screen
│
└── main.dart                     # App entry point
```

### 🎯 Design Patterns

- **BLoC Pattern**: State management using flutter_bloc
- **Repository Pattern**: Data abstraction layer
- **Dependency Injection**: Using GetIt for loose coupling
- **Clean Architecture**: Separation of concerns across layers
- **SOLID Principles**: Maintainable and testable code

---

## 🛠️ Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile framework (v3.10+)
- **Dart**: Programming language (v3.10+)
- **flutter_bloc**: State management (v9.1.1)
- **GoRouter**: Declarative routing (v14.6.3)
- **Google Fonts**: Typography (v6.3.3)

### Backend & Services
- **Supabase**: Backend-as-a-Service
  - PostgreSQL database
  - Authentication
  - Real-time subscriptions
  - Storage

### Key Dependencies
```yaml
dependencies:
  # State Management
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
  
  # Dependency Injection
  get_it: ^9.2.0
  
  # Backend
  supabase_flutter: ^2.12.0
  
  # Navigation
  go_router: ^14.6.3
  
  # UI/UX
  google_fonts: ^6.3.3
  cached_network_image: ^3.4.1
  flutter_svg: ^2.0.17
  
  # Authentication
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.4
  
  # Utilities
  shared_preferences: ^2.3.5
  intl: ^0.20.2
  dartz: ^0.10.1
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10 or higher)
- Dart SDK (3.10 or higher)
- Android Studio / Xcode (for mobile development)
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Theek237/Sentra-Mobile-App.git
   cd Sentra-Mobile-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Supabase**
   - Create a project on [Supabase](https://supabase.com)
   - Run the SQL schema from `supabase/schema.sql`
   - Update Supabase credentials in `lib/main.dart`:
     ```dart
     await Supabase.initialize(
       url: 'YOUR_SUPABASE_URL',
       anonKey: 'YOUR_SUPABASE_ANON_KEY',
     );
     ```

4. **Configure OAuth (Optional)**
   - Setup Google Sign-In in Firebase Console
   - Configure Apple Sign-In in Apple Developer Portal
   - Update credentials in respective platform configurations

5. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 📊 Database Schema

The app uses Supabase (PostgreSQL) with the following main tables:

- **profiles**: User profile information
- **parking_facilities**: Parking location details
- **parking_slots**: Individual parking spots
- **reservations**: Booking records
- **vehicles**: User vehicle information
- **payments**: Payment transaction records
- **parking_sessions**: Active parking sessions

For complete schema, see [`supabase/schema.sql`](supabase/schema.sql)

---

## 🎨 Design System

### Color Palette
- **Primary**: Lime Yellow (#E2E600)
- **Background**: Pure Black (#000000)
- **Surface**: Dark Grey (#1E1E1E)
- **Text**: White (#FFFFFF)
- **Accent Colors**: Success, Error, Warning, Info

### Typography
- **Font**: Google Fonts (customizable)
- **Scales**: Headlines, Body, Captions

---

## 📸 Screenshots

| Feature | Screenshot |
|---------|------------|
| Sign In | *Coming soon* |
| Parking Facilities | *Coming soon* |
| Booking | *Coming soon* |
| Profile | *Coming soon* |

---

## 🧪 Testing

Run tests using:
```bash
flutter test
```

The project includes:
- Unit tests for use cases
- Widget tests for UI components
- Integration tests (using mocktail)

---

## 📦 Project Structure

```
Sentra-Mobile-App/
├── android/              # Android native code
├── ios/                  # iOS native code
├── lib/                  # Flutter application code
├── assets/              # Images, icons, fonts
│   ├── icons/
│   └── images/
├── supabase/            # Database schema
├── test/                # Test files
├── pubspec.yaml         # Dependencies
└── README.md           # This file
```

---

## 🔐 Security

- Secure authentication with Supabase Auth
- Row-level security (RLS) policies in database
- Encrypted data transmission
- Secure token management
- OAuth integration for social sign-in

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 🐛 Known Issues

- None currently reported

---

## 📝 Roadmap

- [ ] Push notifications for booking reminders
- [ ] Map integration for parking location visualization
- [ ] QR code scanning for parking entry/exit
- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Payment gateway integration (Stripe/PayPal)
- [ ] License plate recognition integration
- [ ] Parking duration extensions
- [ ] Social sharing features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

**Sentra Development Team**
- Mobile App Development: [Theek237](https://github.com/Theek237)
- Project Organization: [Project-Sentra](https://github.com/Project-Sentra)

---

## 📞 Support

For support and questions:
- Open an issue on GitHub
- Contact: support@sentraparking.com
- Documentation: [Wiki](https://github.com/Theek237/Sentra-Mobile-App/wiki)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- All contributors and supporters

---

<p align="center">
  Made with ❤️ by the Sentra Team
</p>

<p align="center">
  <sub>© 2026 Sentra Parking. All rights reserved.</sub>
</p>
