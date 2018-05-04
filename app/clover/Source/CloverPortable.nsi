;Copyright (C) 2009-2012, Sophina Liu

;Website: http://NewKelpApps.twgg.org

;====================================================================================================

!define PORTABLEAPPNAME "Clover Portable"
!define NAME "CloverPortable"
!define APPNAME "Clover"
!define VER "1.2.6.0"
!define WEBSITE "NewKelpApps.twgg.org"
!define DEFAULTEXE "clover.exe"
!define DEFAULTAPPDIR "Clover"
!define DEFAULTSETTINGSPATH "CloverPortable"
!define DisableSplashScreen "false"
!define LAUNCHERLANGUAGE "TradChinese"

;=== 程式內容
Name "${PORTABLEAPPNAME}"
OutFile "..\${NAME}.exe"
Caption "${PORTABLEAPPNAME} | NewKelpApps.twgg.org"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "${PORTABLEAPPNAME}"
VIAddVersionKey Comments "允許 ${APPNAME} 從可移動裝置上執行.  更多附加資訊請參訪 ${WEBSITE}"
VIAddVersionKey CompanyName "NewKelpApps.twgg.org"
VIAddVersionKey LegalCopyright "Sophina Liu"
VIAddVersionKey FileDescription "${PORTABLEAPPNAME}"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "${PORTABLEAPPNAME}"
VIAddVersionKey LegalTrademarks ""
VIAddVersionKey OriginalFilename "${NAME}.exe"
;VIAddVersionKey PrivateBuild ""
;VIAddVersionKey SpecialBuild ""

;=== 切換 Runtime
CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user
XPStyle On

; 壓縮
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On

;=== Include
;(引用 NSIS 的 Include 資料夾內的檔案)
!include Registry.nsh
!include TextFunc.nsh
!insertmacro GetParameters

;(自訂)
!include ReadINIStrWithDefault.nsh

;=== 程式圖示
Icon "..\App\AppInfo\appicon.ico"

;=== 語言
LoadLanguageFile "${NSISDIR}\Contrib\Language files\${LAUNCHERLANGUAGE}.nlf"
!include NewKelpApps.twgg.orgLauncherLANG_${LAUNCHERLANGUAGE}.nsh

Var PROGRAMDIRECTORY
Var SETTINGSDIRECTORY
Var ADDITIONALPARAMETERS
Var EXECSTRING
Var PROGRAMEXECUTABLE
Var INIPATH
Var DISABLESPLASHSCREEN
Var ISDEFAULTDIRECTORY
Var APPTEMPDIRECTORY
Var TEMPDIREXISTS
Var FAILEDTORESTOREKEY
Var MISSINGFILEORPATH
Var APPLANGUAGE

Section "Main"
	;=== 找到 INI 檔
		IfFileExists "$EXEDIR\${NAME}.ini" "" NoINI
			StrCpy "$INIPATH" "$EXEDIR"
			Goto ReadINI

	ReadINI:
		;=== 讀取 INI 檔內的參數
		${ReadINIStrWithDefault} $0 "$INIPATH\${NAME}.ini" "${NAME}" "${APPNAME}Directory" "App\${DEFAULTAPPDIR}"
		StrCpy "$PROGRAMDIRECTORY" "$EXEDIR\$0"
		${ReadINIStrWithDefault} $0 "$INIPATH\${NAME}.ini" "${NAME}" "SettingsDirectory" "Data\${DEFAULTSETTINGSPATH}"
		StrCpy "$SETTINGSDIRECTORY" "$EXEDIR\$0"
		${ReadINIStrWithDefault} $ADDITIONALPARAMETERS "$INIPATH\${NAME}.ini" "${NAME}" "AdditionalParameters" ""
		${ReadINIStrWithDefault} $PROGRAMEXECUTABLE "$INIPATH\${NAME}.ini" "${NAME}" "${APPNAME}Executable"  "${DEFAULTEXE}"
		${ReadINIStrWithDefault} $DISABLESPLASHSCREEN "$INIPATH\${NAME}.ini" "${NAME}" "DisableSplashScreen" "${DisableSplashScreen}"
		Goto EndINI

	NoINI:
		;=== 若無 INI 檔則使用預設值
		StrCpy "$ADDITIONALPARAMETERS" ""
		StrCpy "$PROGRAMEXECUTABLE" "${DEFAULTEXE}"
		StrCpy "$DISABLESPLASHSCREEN" "false"

		IfFileExists "$EXEDIR\App\${DEFAULTAPPDIR}\${DEFAULTEXE}" "" NoProgramEXE
			StrCpy "$PROGRAMDIRECTORY" "$EXEDIR\App\${DEFAULTAPPDIR}"
			StrCpy "$SETTINGSDIRECTORY" "$EXEDIR\Data\${DEFAULTSETTINGSPATH}"
			StrCpy "$ISDEFAULTDIRECTORY" "true"
	
	EndINI:
		IfFileExists "$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" FoundProgramEXE

	NoProgramEXE:
		;=== 沒有執行檔
		StrCpy $MISSINGFILEORPATH $PROGRAMEXECUTABLE
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
		Abort
		
	FoundProgramEXE:
		;=== 檢查是否執行中
		FindProcDLL::FindProc "$PROGRAMEXECUTABLE"                 
		StrCmp $R0 "1" "" CheckForSettings
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherAlreadyRunning)`
			Abort
	
	CheckForSettings:
		IfFileExists "$SETTINGSDIRECTORY\*.*" SettingsFound
		;=== 沒有設定檔
		StrCmp $ISDEFAULTDIRECTORY "true" CopyDefaultSettings
		CreateDirectory $SETTINGSDIRECTORY
		Goto SettingsFound
	
	CopyDefaultSettings:
		CreateDirectory "$EXEDIR\Data"
		CreateDirectory "$EXEDIR\Data\${PORTABLEAPPNAME}"
		CopyFiles /SILENT $EXEDIR\App\DefaultData\settings\*.* $EXEDIR\Data\settings
		GoTo SettingsFound

	SettingsFound:
		;=== 判別暫存的錄檔
		StrCpy "$APPTEMPDIRECTORY" "$TEMP\${NAME}\temp_files"
		CreateDirectory "$TEMP\${NAME}\temp_files"
		;SetOutPath $SETTINGSDIRECTORY

	;Splash 畫面:
		StrCmp $DISABLESPLASHSCREEN "true" GetPassedParameters
			;=== 處理檔案前顯示 splash 畫面
			InitPluginsDir
			File /oname=$PLUGINSDIR\splash.jpg "splash.jpg"	
			newadvsplash::show /NOUNLOAD 1200 0 0 -1 /L $PLUGINSDIR\splash.jpg

	GetPassedParameters:
		;=== 取得傳遞參數
		${GetParameters} $0
		StrCmp "'$0'" "''" "" LaunchProgramParameters

		;=== 無參數
		StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"`
		Goto AdditionalParameters

	LaunchProgramParameters:
		StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" $0`

	AdditionalParameters:
		StrCmp $ADDITIONALPARAMETERS "" LaunchNow

		;=== 附加參數
		StrCpy $EXECSTRING `$EXECSTRING $ADDITIONALPARAMETERS`

	LaunchNow:
		${registry::MoveKey} "HKEY_CURRENT_USER\Software\${APPNAME}" "HKEY_CURRENT_USER\Software\${APPNAME}-BackupBy${PORTABLEAPPNAME}" $R0
		IfFileExists "$SETTINGSDIRECTORY\Clover.reg" "" CreateOurKeys
		
	;還原登錄鍵:
		IfFileExists "$WINDIR\system32\reg.exe" "" RestoreTheKey9x
			nsExec::ExecToStack `"$WINDIR\system32\reg.exe" import "$SETTINGSDIRECTORY\Clover.reg"`
			Pop $R0
			StrCmp $R0 '0' CreateOurKeys ;成功還原登錄鍵
	RestoreTheKey9x:
		${registry::RestoreKey} "$SETTINGSDIRECTORY\Clover.reg" $R0
		StrCmp $R0 '0' CreateOurKeys ;成功還原登錄鍵
		StrCpy $FAILEDTORESTOREKEY "true"
	CreateOurKeys:
		${registry::Write} "HKEY_CURRENT_USER\Software\${APPNAME}\${APPNAME}\Directories" "TempDir" "$APPTEMPDIRECTORY" "REG_SZ" $0
		Sleep 100
		${registry::Write} "HKEY_CURRENT_USER\Software\${APPNAME}\${APPNAME}" "WantAssociateFiles" 0 "REG_DWORD" $0
		Sleep 100
			Goto GetAppLanguage
		

	GetAppLanguage:
		ReadEnvStr $APPLANGUAGE "NewKelpApps.twgg.orgLocaleglibc"
		StrCmp $APPLANGUAGE "" StartProgramNow ;若無設定則移動 
		StrCmp $APPLANGUAGE "en_US" 0 +2
			StrCpy $APPLANGUAGE "en"
		StrCmp $APPLANGUAGE "zh_TW" 0 GetCurrentLanguage
			StrCpy $APPLANGUAGE "zh"

	GetCurrentLanguage:
		ReadRegStr $0 HKCU "Software\${APPNAME}\${APPNAME}\Locale" "Language"
		StrCmp `"$APPLANGUAGE"` $0 StartProgramNow ;若相同則移動
		StrCmp $APPLANGUAGE "en" SetAppLanguage
		IfFileExists "$PROGRAMDIRECTORY\Languages\$APPLANGUAGE\*.*" SetAppLanguage StartProgramNow

	SetAppLanguage:
		WriteRegStr HKCU "Software\${APPNAME}\${APPNAME}\Locale" "Language" $APPLANGUAGE
		
	StartProgramNow:
		IfFileExists "$TEMP\$APPDATA\${APPNAME}*.*" ExecTheApp
			StrCpy $TEMPDIREXISTS 'true'
		
	ExecTheApp:
		ExecWait $EXECSTRING
	
	;結尾:
		;=== 還原登錄鍵
	StrCmp $FAILEDTORESTOREKEY "true" SetOriginalKeyBack
		${registry::SaveKey} "HKEY_CURRENT_USER\Software\${APPNAME}" "$SETTINGSDIRECTORY\Clover.reg" "" $0
		Sleep 100
	SetOriginalKeyBack:
		${registry::DeleteKey} "HKEY_CURRENT_USER\Software\${APPNAME}" $0
		Sleep 100
		${registry::MoveKey} "HKEY_CURRENT_USER\Software\${APPNAME}-BackupBy${PORTABLEAPPNAME}" "HKEY_CURRENT_USER\Software\${APPNAME}" $R0
	
	;結束:
		StrCmp $DISABLESPLASHSCREEN "true" CleanupRunLocally
			Sleep 2000
			newadvsplash::stop /WAIT

	CleanupRunLocally:
		${registry::Unload}
		RMDir "$TEMP\${NAME}\temp_files\"
		IfFileExists "$TEMP\${NAME}\temp_files\*.*" "" RemoveTempDir
		MessageBox MB_YESNO|MB_ICONQUESTION `${PORTABLEAPPNAME} 的暫存資料夾仍有檔案在裡面.  若因為 ${PORTABLEAPPNAME} 的問題而導致意外關機, 當您再次啟動時, 可能需要這些檔案來復原您的工作.  如果程式沒有問題, 您可以安全的刪除它們. 您確定要刪除這些檔案?` IDYES RemoveTempDir
		Goto EndOfLauncher
		
	RemoveTempDir:
		RMDir /r "$TEMP\${NAME}\"
	
	EndOfLauncher:
		${registry::Unload}
		newadvsplash::stop /WAIT
		StrCmp $TEMPDIREXISTS 'true' "" TheEnd
			RMDir '$TEMP\$APPDATA\${APPNAME}'
			
	TheEnd:
SectionEnd