# BIFriends Client

Bifriends는 경계선 지능 아동의 학습과 소통을 돕기 위해 개발된 **Flutter 기반 모바일 클라이언트**입니다. 
서비스의 목적을 달성하기 위한 보호자 온보딩, 스포트라이트 가이드 등의 인터랙션과 UI를 포함하고 있습니다.

## Tech Stack

- **Framework**: Flutter (`^3.11.1` 호환)
- **BaaS / Auth**: `firebase_core`, `firebase_auth`, `google_sign_in`
- **Networking**: `http`
- **Local Storage**: `flutter_secure_storage`
- **Hardware / OS**: `permission_handler`
- **UI / Design**: `google_fonts`, `cupertino_icons`

## Project Structure

관심사 분리를 위해 아래와 같은 폴더 구조를 채택하고 있습니다.

```text
lib/
├── main.dart               # 앱 엔트리포인트 (루트 위젯 및 라우팅)
├── firebase_options.dart   # Firebase 플랫폼별 초기화 환경 (Generated)
├── models/                 # 데이터 모델 클래스 (Data Layer)
├── screens/                # 주요 UI 페이지 컴포넌트 (Presentation Layer)
├── services/               # API 통신, 인증 등 비즈니스 로직 (Service Layer)
├── theme/                  # AppColors 등 전역 디자인 시스템 및 토큰
└── widgets/                # 재사용 가능한 공통 UI 컴포넌트 (버튼, 오버레이 등)
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Xcode & CocoaPods (iOS Target)
- Android Studio & Android SDK (Android Target)

### Installation & Run

1. 저장소 클론 및 폴더 이동
   ```bash
   git clone https://github.com/quad-S-BIFriends/bifriends-client.git
   cd bifriends-client
   ```

2. 패키지 의존성 다운로드
   ```bash
   flutter pub get
   ```

3. **Firebase 설정**
   해당 프로젝트를 정상적으로 빌드하려면 Firebase 설정 파일이 필요합니다.  
   * **Android**: `android/app/google-services.json`
   * **iOS**: `ios/Runner/GoogleService-Info.plist`

4. 앱 실행
   ```bash
   flutter run
   ```

## UI & Design System

* **Colors**: `lib/theme/app_colors.dart`에 정의된 `AppColors` 정적 변수를 참조하여 사용합니다.
* **Typography**: `google_fonts` 패키지를 활용하며, 전역 `ThemeData`를 통해 일괄 적용됩니다.

## Code Conventions & Lints

* `flutter_lints` 룰을 따릅니다 (`analysis_options.yaml`).
* 커밋 전 터미널에서 `flutter analyze` 명령어를 통해 린트 에러를 점검하는 것을 권장합니다.
* 재사용 가능한 UI widget은 반드시 `lib/widgets/` 폴더 내에 분리하여 작성합니다.
