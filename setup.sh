#!/bin/bash

# Create backend directory and install dependencies
mkdir -p backend/src
cd backend
npm install
cd ..

# Create Flutter project
flutter create frontend
cd frontend

# Add dependencies to pubspec.yaml
flutter pub add socket_io_client
flutter pub add flutter_bloc
flutter pub add equatable
flutter pub add intl
flutter pub add emoji_picker_flutter
flutter pub add flutter_dotenv

# Get dependencies
flutter pub get

cd .. 