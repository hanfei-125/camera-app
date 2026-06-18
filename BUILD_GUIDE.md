# AI相机 APP - 构建指南

## 构建状态
- 项目源码: ✅ 完整
- Android配置: ✅ 已创建
- Flutter SDK: ⏳ 需要本地安装

---

## 一、环境准备

### 1.1 安装 Flutter SDK

**Windows 用户：**
1. 下载 Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. 解压到 `C:\flutter`
3. 将 `C:\flutter\bin` 添加到系统 PATH
4. 打开命令提示符，运行 `flutter doctor`

**配置 Android SDK：**
```bash
flutter config --android-sdk "你的Android SDK路径"
```

### 1.2 验证安装

```bash
flutter --version
flutter doctor -v
```

---

## 二、构建 Debug APK

### 2.1 获取依赖

```bash
cd D:\WorkBuddy-Projects\Claw\camera-app
flutter pub get
```

### 2.2 构建 Debug 版本

```bash
flutter build apk --debug
```

输出文件：`build\app\outputs\flutter-apk\app-debug.apk`

---

## 三、构建 Release APK（推荐用于小米手机安装）

### 3.1 生成签名密钥（首次需要）

```bash
keytool -genkey -v -keystore D:\camera-app\key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias camera-key
```

### 3.2 配置签名

编辑 `android\app\build.gradle`:

```groovy
android {
    ...
    signingConfigs {
        release {
            keyAlias 'camera-key'
            keyPassword '你的密码'
            storeFile file('D:/camera-app/key.jks')
            storePassword '你的密码'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

### 3.3 构建 Release 版本

```bash
flutter build apk --release
```

输出文件：`build\app\outputs\flutter-apk\app-release.apk`

---

## 四、使用构建脚本（一键构建）

双击运行 `build.bat`，自动执行：
1. 检查 Flutter 安装
2. 获取依赖
3. 构建 Debug APK
4. 构建 Release APK

---

## 五、小米手机安装

### 5.1 传输 APK 文件

将 `app-release.apk` 传输到小米手机：
- USB数据线连接
- 微信/QQ文件传输
- 百度网盘同步

### 5.2 安装设置

1. 打开手机 **设置**
2. 进入 **更多设置**
3. 选择 **应用程序**
4. 找到并打开 **未知来源** 选项
5. 允许来自"文件管理器"的安装

### 5.3 安装 APK

1. 打开 **文件管理器**
2. 找到 `app-release.apk`
3. 点击安装
4. 安装完成后打开应用

---

## 六、常见问题

### Q1: Flutter 未找到
```
[错误] 未找到 Flutter，请先安装 Flutter SDK
```
**解决**：安装 Flutter SDK 并添加到 PATH

### Q2: Android SDK 未配置
```
Android SDK not found
```
**解决**：运行 `flutter config --android-sdk "路径"`

### Q3: 构建失败 (依赖问题)
```
Could not resolve: com.google.mlkit:...
```
**解决**：确保网络正常，添加国内镜像：
```groovy
// android/build.gradle
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/central' }
        google()
        mavenCentral()
    }
}
```

### Q4: 安装失败 (签名问题)
```
INSTALL_PARSE_FAILED_NO_CERTIFICATES
```
**解决**：确保使用 Release 版本或添加签名配置

### Q5: 相机权限被拒绝
**解决**：
1. 打开设置 → 应用 → AI相机 → 权限
2. 允许相机和存储权限

---

## 七、开发者选项

### 启用 USB 调试
1. 设置 → 我的设备 → 全部参数
2. 连续点击 MIUI 版本 5 次
3. 返回设置 → 更多设置 → 开发者选项
4. 启用 USB 调试

### 通过 ADB 安装
```bash
adb install app-release.apk
```

---

## 八、联系方式

如有问题，请检查：
1. Flutter 环境配置
2. Android SDK 配置
3. 网络连接（下载依赖）

---

*构建指南结束*
