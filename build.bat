@echo off
chcp 65001 >nul
echo ========================================
echo AI相机 - 构建APK脚本
echo ========================================
echo.

REM 检查Flutter环境
where flutter >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [错误] 未找到Flutter命令
    echo 请确保Flutter已安装并添加到PATH
    pause
    exit /b 1
)

REM 检查Android SDK
if not exist "%ANDROID_HOME%\platforms" (
    echo [错误] 未找到Android SDK
    echo 请设置ANDROID_HOME环境变量
    pause
    exit /b 1
)

echo [1/3] 获取Flutter依赖...
flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [错误] Flutter依赖获取失败
    pause
    exit /b 1
)

echo.
echo [2/3] 构建Debug APK...
flutter build apk --debug
if %ERRORLEVEL% neq 0 (
    echo [错误] APK构建失败
    pause
    exit /b 1
)

echo.
echo [3/3] 构建Release APK...
flutter build apk --release
if %ERRORLEVEL% neq 0 (
    echo [警告] Release APK构建失败，仅Debug APK可用
    pause
    exit /b 1
)

echo.
echo ========================================
echo 构建完成！
echo ========================================
echo.
echo Debug APK: build\app\outputs\flutter-apk\app-debug.apk
echo Release APK: build\app\outputs\flutter-apk\app-release.apk
echo.
echo 如需安装到手机:
echo   adb install build\app\outputs\flutter-apk\app-release.apk
echo.
pause
