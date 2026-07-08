@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0terraform\verify-legacy-sonarqube-cleanup.ps1"
