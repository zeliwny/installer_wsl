!define DISTRO_NAME "Ctool"
!define INSTALL_DIR "$PROGRAMFILES\Ctool"
!define TARBALL "ctool.tar"
!define LOGO "logo.bmp"  ; Ensure you have a BMP image (<= 164x314px for best fit)

!include "MUI2.nsh"  ; Use Modern UI for better visuals

Outfile "CtoolInstaller.exe"
InstallDir ${INSTALL_DIR}
RequestExecutionLevel admin

SetCompress off  ; No compression (faster build)
SetDatablockOptimize off  ; Skip optimization (faster build)

; --- Define MUI Pages ---
!define MUI_WELCOMEPAGE_TITLE "Welcome to Custom WSL Installer"
!define MUI_WELCOMEPAGE_TEXT "This installer will install Custom WSL on your system.$\n$\nDo you want to continue?"

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "logo.bmp"  ; Add your 164x314px bitmap logo here

Page custom WelcomePage
Page instfiles

Function WelcomePage
    MessageBox MB_YESNO "Welcome to Custom WSL Installer!$\nDo you want to install this tool?" IDYES ContinueInstall
    Quit  ; If the user selects "No", exit the installer properly.

ContinueInstall:
FunctionEnd

Section "Install C-tool in WSL"
    SetOutPath ${INSTALL_DIR}
    File "${TARBALL}"
    File "install.bat"

    ; ---- Step 1: Check if WSL is Installed ----
    nsExec::ExecToStack 'powershell -ExecutionPolicy Bypass -Command "wsl --version"'
    Pop $0  ; Get return status

    StrCmp $0 "0" WSLFound  ; If WSL exists, skip installation

    ; WSL Not Found - Install WSL
    MessageBox MB_ICONINFORMATION "WSL is not installed. Installing WSL now..."
    nsExec::ExecToStack 'powershell -ExecutionPolicy Bypass -Command "wsl --install"'
    Pop $0  ; Get return status

    StrCmp $0 "0" WSLInstalledSuccessfully WSLInstallFailed

WSLInstallFailed:
    MessageBox MB_ICONSTOP "WSL installation failed. Please install WSL manually and try again."
    Quit

WSLInstalledSuccessfully:
    Sleep 15000  ; Wait for installation to complete

WSLFound:
    ; ---- Step 2: Ensure WSL 2 is Set as Default ----
    nsExec::ExecToStack 'powershell -ExecutionPolicy Bypass -Command "wsl --set-default-version 2"'
    Pop $0
    StrCmp $0 "0" ImportDistro WSL2Failed

WSL2Failed:
    MessageBox MB_ICONSTOP "Failed to set WSL 2 as the default version. You may need to enable Virtual Machine Platform manually."
    Quit

ImportDistro:
    ; ---- Step 3: Import Custom Linux Distribution ----
    nsExec::ExecToStack '"$INSTDIR\install.bat"'
    Pop $0
    StrCmp $0 "0" InstallationComplete ImportFailed

ImportFailed:
    MessageBox MB_ICONSTOP "WSL distribution import failed. Please check the tarball and try again."
    Quit

InstallationComplete:
    MessageBox MB_ICONINFORMATION "Custom WSL installation complete!"
SectionEnd