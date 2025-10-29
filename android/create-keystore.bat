@echo off
keytool -genkey -v -keystore app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass althfeth2024 -keypass althfeth2024 -dname "CN=Althfeth, OU=Development, O=Althfeth, L=City, S=State, C=SA"
echo Keystore created successfully!
pause
