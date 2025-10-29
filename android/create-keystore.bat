@echo off
echo Creating keystore for Althfeth app...
keytool -genkey -v -keystore app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass althfeth2024 -keypass althfeth2024 -dname "CN=Althfeth, OU=Development, O=Althfeth, L=City, S=State, C=SA"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Keystore created successfully!
    echo Location: android\app\upload-keystore.jks
    echo Alias: upload
    echo Store Password: althfeth2024
    echo Key Password: althfeth2024
    echo ========================================
) else (
    echo.
    echo Failed to create keystore!
)
pause
