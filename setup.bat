@echo off

REM Create backend directory and initialize Go module
mkdir backend
cd backend
call go mod init chat_app
call go get github.com/gofiber/fiber/v2
call go get github.com/gofiber/contrib/websocket
call go get github.com/joho/godotenv
cd ..

REM Create Flutter project
call flutter create frontend
cd frontend

REM Add dependencies to pubspec.yaml
call flutter pub add web_socket_channel
call flutter pub add flutter_bloc
call flutter pub add equatable
call flutter pub add intl
call flutter pub add emoji_picker_flutter

REM Get dependencies
call flutter pub get

cd .. 