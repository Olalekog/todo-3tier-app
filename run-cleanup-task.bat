@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0terraform\cleanup-legacy-sonarqube.ps1"
