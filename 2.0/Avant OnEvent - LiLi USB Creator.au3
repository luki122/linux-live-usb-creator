#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=icon.ico
#AutoIt3Wrapper_Compression=3
#AutoIt3Wrapper_Res_Comment=Enjoy !
#AutoIt3Wrapper_Res_Description=Easily create a Linux Live USB
#AutoIt3Wrapper_Res_Fileversion=1.5.1.85
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=Y
#AutoIt3Wrapper_Res_LegalCopyright=Copyright Thibaut Lauziere a.k.a Sl�m
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Site|http://www.linuxliveusb.com
#AutoIt3Wrapper_AU3Check_Parameters=-w 4
#AutoIt3Wrapper_Run_After=upx.exe --best --compress-resources=0 "%out%"
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $lang_ini = @ScriptDir & "\tools\settings\langs.ini"
Global $settings_ini = @ScriptDir & "\tools\settings\settings.ini"
Global $log_dir =  @ScriptDir & "\logs\"
Global $help_file_name = "Help.chm"
Global $help_available_langs = "en,fr,sp"

Global $lang, $anonymous_id

; Checking if Tools folder exists (contains tools and settings)
if DirGetSize(@ScriptDir & "\tools\",2 ) <> -1 Then
	If Not FileExists($lang_ini) Then
		MsgBox(48, "ERROR", "Language file not found !!!")
		Exit
	EndIf

	If Not FileExists($settings_ini) Then
		MsgBox(48, "ERROR", "Settings file not found !!!")
		Exit
	Else
		; Generate an unique ID for anonymous crash reports and stats
		If IniRead($settings_ini, "General", "unique_ID", "none") = "none" OR  IniRead($settings_ini, "General", "unique_ID", "none") = ""  Then
			$anonymous_id = Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1))
			IniWrite($settings_ini, "General", "unique_ID", $anonymous_id)
		Else
			$anonymous_id = IniRead($settings_ini, "General", "unique_ID", "none")
		EndIf
	EndIf
Else
		MsgBox(48, "ERROR", "Please put the 'tools' directory back")
		Exit
EndIf

; Unlock help file on Vista (because Vista will prevent opening it ... stupid)
UnlockHelp()


#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <Constants.au3>
#include <ProgressConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <Array.au3>
#include <About.au3>
#include <File.au3>
#include <md5.au3>
#include <INet.au3>
#include <ErrorHandler.au3>
#include <Ressources.au3>
#include <LiLis_heart.au3>

;                                   Version
Global $software_version = "1.6"


SendReport("Starting LiLi USB Creator" & $software_version)

_GDIPlus_Startup()



; If compiled, load the included resources else it will load files
#cs
If @Compiled == 1 Then
	; Chargement des ressources
	$EXIT_NORM = _ResourceGetAsImage("EXIT_NORM")
	$EXIT_OVER = _ResourceGetAsImage("EXIT_OVER")
	$MIN_NORM = _ResourceGetAsImage("MIN_NORM")
	$MIN_OVER = _ResourceGetAsImage("MIN_OVER")
	$BAD = _ResourceGetAsImage("BAD")
	$WARNING = _ResourceGetAsImage("WARNING")
	$GOOD = _ResourceGetAsImage("GOOD")
	$HELP = _ResourceGetAsImage("HELP")
	$CD_PNG = _ResourceGetAsImage("CD_PNG")
	$CD_HOVER_PNG = _ResourceGetAsImage("CD_HOVER_PNG")
	$ISO_PNG = _ResourceGetAsImage("ISO_PNG")
	$ISO_HOVER_PNG = _ResourceGetAsImage("ISO_HOVER_PNG")
	$DOWNLOAD_PNG = _ResourceGetAsImage("DOWNLOAD_PNG")
	$DOWNLOAD_HOVER_PNG = _ResourceGetAsImage("DOWNLOAD_HOVER_PNG")
	$LAUNCH_PNG = _ResourceGetAsImage("LAUNCH_PNG")
	$LAUNCH_HOVER_PNG = _ResourceGetAsImage("LAUNCH_HOVER_PNG")
	$REFRESH_PNG = _ResourceGetAsImage("REFRESH_PNG")
	$PNG_GUI = _ResourceGetAsImage("PNG_GUI_" & $lang)
Else 
#ce
	; Loading PNG Files
	$EXIT_NORM = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\close.PNG")
	$EXIT_OVER = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\close_hover.PNG")
	$MIN_NORM = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\min.PNG")
	$MIN_OVER = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\min_hover.PNG")
	$BAD = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\bad.png")
	$WARNING = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\warning.png")
	$GOOD = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\good.png")
	$HELP = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\help.png")
	$CD_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\cd.png")
	$CD_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\cd_hover.png")
	$ISO_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\iso.png")
	$ISO_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\iso_hover.png")
	$DOWNLOAD_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\download.png")
	$DOWNLOAD_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\download_hover.png")
	$LAUNCH_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\launch.png")
	$LAUNCH_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\launch_hover.png")
	$REFRESH_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\refresh.png")
	if FileExists(@ScriptDir & "\tools\img\GUI_" & $lang & ".png") Then
		$PNG_GUI = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\GUI_" & $lang & ".png")
	Else
		$PNG_GUI = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\GUI_English.png")
	EndIf



SendReport("Creating GUI")

$GUI = GUICreate("LiLi USB Creator", 450, 750, -1, -1, $WS_POPUP, $WS_EX_LAYERED)

SetBitmap($GUI, $PNG_GUI, 255)
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
GUISetState(@SW_SHOW, $GUI)

; Old offset was 18
$LAYERED_GUI_CORRECTION = GetVertOffset($GUI)
$CONTROL_GUI = GUICreate("CONTROL_GUI", 450, 750, 0, $LAYERED_GUI_CORRECTION, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI)

; Offset for applied on every items
$offsetx0=27
$offsety0=23

; Clickable parts of images
$EXIT_AREA = GUICtrlCreateLabel("", 335+$offsetx0, -20+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
$MIN_AREA = "";GUICtrlCreateLabel("", 135+$offsetx0, -3+$offsety0, 20, 20)
;GUICtrlSetCursor(-1, 0)
$REFRESH_AREA = GUICtrlCreateLabel("", 300+$offsetx0, 145+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
$ISO_AREA = GUICtrlCreateLabel("", 38+$offsetx0, 231+$offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
$CD_AREA = GUICtrlCreateLabel("", 146+$offsetx0, 231+$offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
$DOWNLOAD_AREA = GUICtrlCreateLabel("", 260+$offsetx0, 230+$offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
$LAUNCH_AREA = GUICtrlCreateLabel("", 35+$offsetx0, 600+$offsety0, 22, 43)
GUICtrlSetCursor(-1, 0)
$HELP_STEP1_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 105+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
$HELP_STEP2_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 201+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
$HELP_STEP3_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 339+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
$HELP_STEP4_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 449+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
$HELP_STEP5_AREA = GUICtrlCreateLabel("", 335+$offsetx0, 562+$offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)

GUISetBkColor(0x121314)
_WinAPI_SetLayeredWindowAttributes($CONTROL_GUI, 0x121314)
GUISetState(@SW_SHOW, $CONTROL_GUI)


$ZEROGraphic = _GDIPlus_GraphicsCreateFromHWND($CONTROL_GUI)

; Firt display (initialization) of images 
$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335+$offsetx0, -20+$offsety0, 20, 20)
;$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 135+$offsetx0, -3+$offsety0, 20, 20)
$DRAW_REFRESH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $REFRESH_PNG, 0, 0, 20, 20, 300+$offsetx0, 145+$offsety0, 20, 20)
$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38+$offsetx0, 231+$offsety0, 75, 75)
$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146+$offsetx0, 231+$offsety0, 75, 75)
$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260+$offsetx0, 230+$offsety0, 75, 75)
$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35+$offsetx0, 600+$offsety0, 22, 43)
$HELP_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 105+$offsety0, 20, 20)
$HELP_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 201+$offsety0, 20, 20)
$HELP_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 339+$offsety0, 20, 20)
$HELP_STEP4 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 449+$offsety0, 20, 20)
$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 562+$offsety0, 20, 20)

; Put the state for the first 3 steps
Step1_Check("bad")
Step2_Check("bad")
Step3_Check("bad")

SendReport("Creating GUI (buttons)")

; Text for step 2
GUICtrlCreateLabel("ISO", 65+$offsetx0, 304+$offsety0, 20, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

GUICtrlCreateLabel("CD", 175+$offsetx0, 304+$offsety0, 20, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

GUICtrlCreateLabel(Translate("T�l�charger"), 262+$offsetx0, 304+$offsety0, 70, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; Text and controls for step 3
$offsetx3 = 60
$offsety3 = 150
$label_min = GUICtrlCreateLabel("0 " & Translate("Mo"), 30 + $offsetx3+$offsetx0, 228 + $offsety3+$offsety0, 30, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$label_max = GUICtrlCreateLabel("?? " & Translate("Mo"), 250 + $offsetx3+$offsetx0, 228 + $offsety3+$offsety0, 50, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$slider = GUICtrlCreateSlider(60 + $offsetx3+$offsetx0, 225 + $offsety3+$offsety0, 180, 20)
GUICtrlSetLimit($slider, 0, 0)
$slider_visual = GUICtrlCreateInput("0", 90 + $offsetx3+$offsetx0, 255 + $offsety3+$offsety0, 40, 20)
$slider_visual_Mo = GUICtrlCreateLabel(Translate("Mo"), 135 + $offsetx3+$offsetx0, 258 + $offsety3+$offsety0, 20, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$slider_visual_mode = GUICtrlCreateLabel(Translate("(Mode Live)"), 160 + $offsetx3+$offsetx0, 258 + $offsety3+$offsety0, 100, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; Text and controls for step 4
$offsetx4 = 10
$offsety4 = 195
$hide_files = GUICtrlCreateCheckbox("", 30 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 13, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$hide_files_label = GUICtrlCreateLabel(Translate("Cacher les fichiers sur la cl�"), 50 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 300, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; No more reason to keep that option because menu is integrated on right click of the key
$except_wubi = GUICtrlCreateDummy()
;$except_wubi = GUICtrlCreateCheckbox("", 200 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 13, 13)
;$except_wubi_label = GUICtrlCreateLabel(Translate("(Sauf Umenu.exe)"), 220 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 200, 20)
;GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;GUICtrlSetColor(-1, 0xFFFFFF)

$formater = GUICtrlCreateCheckbox("", 30 + $offsetx4+$offsetx0, 305 + $offsety4+$offsety0, 13, 13)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$formater_label = GUICtrlCreateLabel(Translate("Formater la cl� en FAT32 (Vos donn�es seront supprim�es!)"), 50 + $offsetx4+$offsetx0, 305 + $offsety4+$offsety0, 300, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$virtualbox = GUICtrlCreateCheckbox("", 30 + $offsetx4+$offsetx0, 325 + $offsety4+$offsety0, 13, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$virtualbox_label = GUICtrlCreateLabel(Translate("Permettre de lancer LinuxLive directement sous Windows (n�cessite internet)"), 50 + $offsetx4+$offsetx0, 325 + $offsety4+$offsety0, 300, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


; Text and controls for step 5
$label_step6_statut = GUICtrlCreateLabel("<- " & Translate("Cliquer l'�clair pour lancer l'installation"), 50 + $offsetx4+$offsetx0, 410 + $offsety4+$offsety0, 300, 60)
GUICtrlSetFont($label_step6_statut, 9, 800, 0, "Arial")
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; Filling the combo box with drive list
Global $combo
$combo = GUICtrlCreateCombo("-> " & Translate("Choisir une cl� USB"), 90+$offsetx0, 145+$offsety0, 200,-1,3)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

Refresh_DriveList()

; Setting up all global vars and local vars
Global $selected_drive, $logfile, $virtualbox_check, $virtualbox_size
Global $STEP1_OK, $STEP2_OK, $STEP3_OK
Global $DRAW_CHECK_STEP1, $DRAW_CHECK_STEP2, $DRAW_CHECK_STEP3
Global $MD5_FOLDER, $MD5_ISO, $version_in_file
Global $variante, $jackalope

$selected_drive = "->"
$file_set = 0;
$file_set_mode = "none"
$annuler = 0
$sysarg = " "
$combo_updated = 0

$STEP1_OK = 0
$STEP2_OK = 0
$STEP3_OK = 0

$MD5_FOLDER = "none"
$MD5_ISO = "none"
$version_in_file = "none"

; Sending anonymous statistics
SendStats()
SendReport(LogSystemConfig())

; Main part
While 1
	; Force retracing the combo box (bugfix)
	If $combo_updated <> 1 Then
		GUICtrlSetData($combo, GUICtrlRead($combo))
		$combo_updated = 1
	EndIf
	
	
	$MSG = GUIGetMsg(1)

	; User is choosing persistence's file size
	If $MSG[0] = $slider Then
		If GUICtrlRead($slider) > 0 Then
			GUICtrlSetData($slider_visual, GUICtrlRead($slider) * 10)
			GUICtrlSetData($slider_visual_mode, Translate("(Mode Persistant)"))
			; State is OK (value > 0)
			Step3_Check("good")
		Else
			GUICtrlSetData($slider_visual, GUICtrlRead($slider) * 10)
			GUICtrlSetData($slider_visual_mode, Translate("(Mode Live)"))
			; State is OK but warning (value = 0)
			Step3_Check("warning")

		EndIf
	EndIf


	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////// User is choosing the key                      ///////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	If $MSG[0] = $combo Then

		$selected_drive = StringLeft(GUICtrlRead($combo), 2)
		If ( StringInStr(DriveGetFileSystem($selected_drive),"FAT") >=1 And SpaceAfterLinuxLiveMB($selected_drive) > 0 ) Then
			; State is OK ( FAT32 or FAT format and 700MB+ free)
			Step1_Check("good")

			If GUICtrlRead($slider) > 0 Then
				GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
				GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
				; State is OK ( FAT32 or FAT format and 700MB+ free) and warning for live mode only on step 3
				Step3_Check("good")
				SendReport(LogSystemConfig())
			Else
				GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
				GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
				; State is OK but warning for live mode only on step 3
				Step3_Check("warning")
				SendReport(LogSystemConfig())
			EndIf

		ElseIf ( StringInStr(DriveGetFileSystem($selected_drive),"FAT") <=0 And GUICtrlRead($formater) <> $GUI_CHECKED ) Then

			MsgBox(4096, "", Translate("Veuillez choisir un disque format� en FAT32 ou FAT ou cocher l'option de formatage"))

			; State is NOT OK (no selected key)
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			Step1_Check("bad")

			; State for step 3 is NOT OK according to step 1
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			GUICtrlSetLimit($slider, 0, 0)
			Step3_Check("bad")
		Else
			If (DriveGetFileSystem($selected_drive) = "") Then
				MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun disque"))
			EndIf
			; State is NOT OK (no selected key)
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			Step1_Check("bad")

			; State for step 3 is NOT OK according to step 1
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			GUICtrlSetLimit($slider, 0, 0)
			Step3_Check("bad")
		EndIf
	EndIf

	; User is typing persistence's file size
	If $MSG[0] = $slider_visual Then
		$selected_drive = StringLeft(GUICtrlRead($combo), 2)

		If StringIsInt(GUICtrlRead($slider_visual)) And GUICtrlRead($slider_visual) <= SpaceAfterLinuxLiveMB($selected_drive) And GUICtrlRead($slider_visual) > 0 Then
			GUICtrlSetData($slider, Round(GUICtrlRead($slider_visual) / 10))
			GUICtrlSetData($slider_visual_mode, Translate("(Mode Persistant)"))
			; State is  OK (persistent mode)
			Step3_Check("good")
		ElseIf GUICtrlRead($slider_visual) = 0 Then
			GUICtrlSetData($slider_visual_mode, Translate("(Mode Live)"))
			; State is WARNING (live mode only)
			Step3_Check("warning")
		Else
			GUICtrlSetData($slider, 0)
			GUICtrlSetData($slider_visual, 0)
			GUICtrlSetData($slider_visual_mode, Translate("(Mode Live)"))
			; State is WARNING (live mode only)
			Step3_Check("warning")
		EndIf
	EndIf

	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////// Format Option                          ///////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	If $MSG[0] = $formater Then
		If GUICtrlRead($formater) == $GUI_CHECKED Then
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
			GUICtrlSetLimit($slider, SpaceAfterLinuxLiveMB($selected_drive) / 10, 0)
		Else
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
			GUICtrlSetLimit($slider, SpaceAfterLinuxLiveMB($selected_drive) / 10, 0)
		EndIf

		; update the combo box (listing drives)
		If ( ( StringInStr(DriveGetFileSystem($selected_drive),"FAT") >=1 Or GUICtrlRead($formater) == $GUI_CHECKED ) And SpaceAfterLinuxLiveMB($selected_drive) > 0 ) Then
			; State is OK ( FAT32 or FAT format and 700MB+ free)
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
			GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
			Step1_Check("good")

		ElseIf (StringInStr(DriveGetFileSystem($selected_drive),"FAT") <=0 And GUICtrlRead($formater) <> $GUI_CHECKED ) Then
			MsgBox(4096, "", Translate("Veuillez choisir un disque format� en FAT32 ou FAT ou cocher l'option de formatage"))
			GUICtrlSetData($label_max, "?? Mo")
			Step1_Check("bad")

		Else
			If (DriveGetFileSystem($selected_drive) = "") Then
				MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun disque"))
			EndIf
			;State is NOT OK (no selected key)
			GUICtrlSetData($label_max, "?? " & Translate("Mo"))
			Step1_Check("bad")

		EndIf
	EndIf

	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////// Miscellaneous actions                         ///////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	If $MSG[0] = $ISO_AREA Then
		SendReport("Start-ISO_AREA")
		$iso_file = FileOpenDialog(Translate("Choisir l'image ISO d'un CD live de Linux"), @ScriptDir & "\", "ISO (*.iso)", 1)
		If @error Then
			SendReport("IN-ISO_AREA (no iso)")
			MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun fichier"))
			$file_set = 0;
			Step2_Check("bad")
		Else
			SendReport("IN-ISO_AREA (iso selected :" & $iso_file & ")")
			$file_set = $iso_file
			$file_set_mode = "iso"
			Check_iso_integrity($file_set)
			SendReport(LogSystemConfig())
		EndIf
		SendReport("End-ISO_AREA")
	EndIf

	If $MSG[0] = $CD_AREA Then
		SendReport("Start-CD_AREA")
		$folder_file = FileSelectFolder(Translate("S�lectionner le CD live de Linux ou son r�pertoire"), "")
		If @error Then
			SendReport("IN-CD_AREA (no CD)")
			MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun CD ou dossier"))
			Step2_Check("bad")
			$file_set = 0;
		Else
			SendReport("IN-CD_AREA (CD selected :" & $folder_file & ")")
			$file_set = $folder_file;
			$file_set_mode = "folder"
			Check_folder_integrity($folder_file)
			SendReport(LogSystemConfig())
		EndIf
		SendReport("End-CD_AREA")
	EndIf

	; User refresh the drive list
	If $MSG[0] = $REFRESH_AREA Then
		Refresh_DriveList()
		; Testing 
		;$virtualbox_check = 1 
		;Finish_Help()

	EndIf

	; User clicked on Download
	If $MSG[0] = $DOWNLOAD_AREA Then
		ShellExecute(Translate("http://www.ubuntu-fr.org/telechargement"))
	EndIf
	
	; User clicked on Exit
	If $MSG[0] = $EXIT_AREA Then
		ExitLoop
	EndIf

	; User clicked on Minimize
	;If $MSG[0] = $MIN_AREA Then
		;GUISetState(@SW_MINIMIZE, $GUI)
	;EndIf

	If $MSG = -3 Then Exit

	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////// Launching the key's creation                  ///////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	If $MSG[0] = $LAUNCH_AREA Then

		SendReport("Start-LAUNCH_AREA")
		SendReport(LogSystemConfig())

		$selected_drive = StringLeft(GUICtrlRead($combo), 2)

		UpdateStatus("D�but de la cr�ation du LinuxLive USB")
		
		If $STEP1_OK >= 1 And $STEP2_OK >= 1 And $STEP3_OK >= 1 Then
			$annuler = 0
		Else
			$annuler = 2
			UpdateStatus("Veuillez valider les �tapes 1 � 3")
		EndIf
		
		; Initializing log file
		InitLog()

		; Format option has been selected
		If (GUICtrlRead($formater) == $GUI_CHECKED) And $annuler <> 2 Then
			$annuler = 0
			$annuler = MsgBox(49, Translate("Attention") & "!!!", Translate("Voulez-vous vraiment continuer et formater le disque suivant ?") & @CRLF & @CRLF & "       " & Translate("Nom") & " : ( " & $selected_drive & " ) " & DriveGetLabel($selected_drive) & @CRLF & "       " & Translate("Taille") & " : " & Round(DriveSpaceTotal($selected_drive) / 1024, 1) & " " & Translate("Go") & @CRLF & "       " & Translate("Formatage") & " : " & DriveGetFileSystem($selected_drive) & @CRLF)
			If $annuler = 1 Then
				UpdateStatus("Formatage de la cl�")
				Format_FAT32($selected_drive)
			EndIf
		EndIf

		; Starting creation if not cancelled
		If $annuler <> 2 Then

			If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
			UpdateStatus("Etape 1 � 3 valides")

			If GUICtrlRead($formater) <> $GUI_CHECKED And IniRead($settings_ini, "General", "skip_cleaning", "no") == "no" Then Clean_old_installs($selected_drive)

			If GUICtrlRead($virtualbox) == $GUI_CHECKED Then $virtualbox_check = Download_virtualBox()

			; Uncompressing ou copying files on the key
			If IniRead($settings_ini, "General", "skip_copy", "no") == "no" Then
				If $file_set_mode = "iso" Then
					UpdateStatus(Translate("D�compression de l'ISO sur la cl�") & " ( 5-10" & Translate("min") & " )")
					Run7zip('"' & @ScriptDir & '\tools\7z.exe" x "' & $file_set & '" -x![BOOT] -r -aoa -o' & $selected_drive, 703)
				Else
					UpdateStatus(Translate("Copie des fichiers vers la cl�") & " ( 5-10" & Translate("min") & " )")
					_FileCopy2($file_set & "\*.*", $selected_drive & "\")
				EndIf

				UpdateStatus(Translate("Renommage et d�placement de quelques fichiers"))
				RunWait3("cmd /c rename " & $selected_drive & "\isolinux syslinux", @ScriptDir, @SW_HIDE)
				RunWait3("cmd /c rename " & $selected_drive & "\syslinux\isolinux.cfg syslinux.cfg", @ScriptDir, @SW_HIDE)
				RunWait3("cmd /c rename " & $selected_drive & "\syslinux\text.cfg text.orig", @ScriptDir, @SW_HIDE)
				RunWait3("cmd /c copy /Y " & $selected_drive & "\syslinux\syslinux.cfg " & $selected_drive & "\syslinux.cfg", @ScriptDir, @SW_HIDE)
				FileDelete2($selected_drive & "\ubuntu")
				FileDelete2($selected_drive & "\autorun.inf")
			EndIf

			If IniRead($settings_ini, "General", "skip_boot_text", "no") == "no" Then
				CreateBootText($selected_drive)
			EndIf



			If IniRead($settings_ini, "General", "skip_persistence", "no") == "no" Then
				If GUICtrlRead($slider_visual) > 0 Then
					UpdateStatus("Cr�ation du fichier de persistance")
					Sleep(1000)
					RunDD(@ScriptDir & '\tools\dd.exe if=/dev/zero of=' & $selected_drive & '\casper-rw count=' & GUICtrlRead($slider_visual) & ' bs=1024k', GUICtrlRead($slider_visual))
					If (GUICtrlRead($hide_files) == $GUI_CHECKED) Then
						RunWait3("cmd /c attrib /D /S +S +H " & $selected_drive & "\casper-rw", @ScriptDir, @SW_HIDE)
					EndIf
					
					$time_to_format=3
					if (GUICtrlRead($slider_visual) >= 1000) Then $time_to_format=6
					if (GUICtrlRead($slider_visual) >= 2000) Then $time_to_format=10
					if (GUICtrlRead($slider_visual) >= 3000) Then $time_to_format=15
					UpdateStatus(Translate("Formatage du fichier de persistance") & " ( �"& $time_to_format & " " & Translate("min") & " )")
					RunMke2fs()
				Else
					UpdateStatus("Mode Live : pas de fichier de persistance")

				EndIf
			EndIf

			If IniRead($settings_ini, "General", "skip_bootsector", "no") == "no" Then

				UpdateStatus("Installation des secteurs de boot")
				If (IniRead($settings_ini, "General", "safe_syslinux", "no") == "yes") Then
					$sysarg = " -s"
				Else
					$sysarg = " "
				EndIf

				RunWait3(@ScriptDir & '\tools\syslinux.exe -m -a' & $sysarg & ' -d ' & $selected_drive & '\syslinux ' & $selected_drive, @ScriptDir, @SW_HIDE)
			EndIf
			
			If (GUICtrlRead($hide_files) == $GUI_CHECKED) And IniRead($settings_ini, "General", "skip_hiding", "no") == "no" Then
				Hide_live_files($selected_drive)
			EndIf

			If GUICtrlRead($virtualbox) == $GUI_CHECKED And $virtualbox_check >= 1 Then
				
				If $virtualbox_check <> 2 Then
					While @InetGetActive
						$prog = Int((100 * @InetGetBytesRead / $virtualbox_size))
						UpdateStatusNoLog(Translate("T�l�chargement de VirtualBox") & "  : " & $prog & "% ( " & Round(@InetGetBytesRead / (1024 * 1024), 1) & "/" & Round($virtualbox_size / (1024 * 1024), 1) & " " & Translate("Mo") & " )")
						Sleep(300)
					WEnd
					UpdateStatus("Le t�l�chargement est maintenant fini")
				EndIf
				
				; maybe check downloaded file ?
				
				; Next step : uncompressing vbox on the key
				Uncompress_virtualbox_on_key($selected_drive)
				
				
				;UpdateStatus("Configuration de VirtualBox Portable")
				;SetupVirtualBox($selected_drive & "\Portable-VirtualBox", $selected_drive)
				
				;Run($selected_drive & "\Portable-VirtualBox\Launch_usb.exe", @ScriptDir, @SW_HIDE)


			EndIf
			
			; Create Autorun menu
			Create_autorun($selected_drive,"test")
			
			; Creation is now done
			UpdateStatus("Votre cl� LinuxLive est maintenant pr�te !")

			If $virtualbox_check >= 1 Then
				$mem = MemGetStats()
				$avert_mem = ""
				$avert_admin = ""
				; If not admin and virtaulbox option has been selected => WARNING
				If Not IsAdmin() Then $avert_admin = Translate("Vous n'avez pas les droits suffisants pour d�marrer VirtualBox sur cette machine.") & @CRLF & Translate("Enregistrez-vous sur le compte administrateur ou lancez le logiciel avec les droits d'administrateur pour qu'il fonctionne.")

				; If not enough RAM => WARNING
				If Round($mem[2] / 1024) < 256 Then $avert_mem = Translate("Vous avez moins de 256Mo de m�moire vive disponible.") & @CRLF & Translate("Cela ne suffira pas pour lancer LinuxLive directement sous windows.")

				If $avert_admin <> "" Or $avert_mem <> "" Then
					MsgBox(64, "Attention", $avert_admin & @CRLF & $avert_mem)
				EndIf
			EndIf
			sleep(1000)
			Finish_Help($virtualbox_check)
		Else
			UpdateStatus("Veuillez valider les �tapes 1 � 3")
		EndIf
		SendReport("End-LAUNCH_AREA")
	EndIf




	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////// Retracing GUI when restoring (after minimization)            ///////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	If $MSG[0] = $GUI_EVENT_RESTORE Then
		$PNG_GUI = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\GUI_" & $lang & ".png")
		$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335+$offsetx0, -20+$offsety0, 20, 20)
		;$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 135+$offsetx0, -3+$offsety0, 20, 20)
		$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146+$offsetx0, 231+$offsety0, 75, 75)
		$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260+$offsetx0, 230+$offsety0, 75, 75)
		$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38+$offsetx0, 231+$offsety0, 75, 75)
		$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35+$offsetx0, 600+$offsety0, 22, 43)

		$HELP_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 105+$offsety0, 20, 20)
		$HELP_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 201+$offsety0, 20, 20)
		$HELP_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 339+$offsety0, 20, 20)
		$HELP_STEP4 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 449+$offsety0, 20, 20)
		$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335+$offsetx0, 562+$offsety0, 20, 20)

		; Re-checking step (to retrace traffic lights)
		Select
			Case $STEP1_OK = 0
				Step1_Check("bad")
			Case $STEP1_OK = 1
				Step1_Check("good")
			Case $STEP1_OK = 2
				Step1_Check("warning")
		EndSelect
		Select
			Case $STEP2_OK = 0
				Step2_Check("bad")
			Case $STEP2_OK = 1
				Step2_Check("good")
			Case $STEP2_OK = 2
				Step2_Check("warning")
		EndSelect
		Select
			Case $STEP3_OK = 0
				Step3_Check("bad")
			Case $STEP3_OK = 1
				Step3_Check("good")
			Case $STEP3_OK = 2
				Step3_Check("warning")
		EndSelect

	EndIf
	$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)

	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////// Hovering/ clicking on image buttons                            ///////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	; CD Button
	If $GCI_DN[4] = $CD_AREA Then
		$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_HOVER_PNG, 0, 0, 75, 75, 146+$offsetx0, 231+$offsety0, 75, 75)
		$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		While $GCI_DN[4] = $CD_AREA
			If $GCI_DN[2] = 1 Then ExitLoop
			$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		WEnd
		$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146+$offsetx0, 231+$offsety0, 75, 75)

	EndIf

	; Launching button
	If $GCI_DN[4] = $LAUNCH_AREA Then
		$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_HOVER_PNG, 0, 0, 22, 43, 35+$offsetx0, 600+$offsety0, 22, 43)

		$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		While $GCI_DN[4] = $LAUNCH_AREA
			If $GCI_DN[2] = 1 Then ExitLoop
			$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		WEnd
		$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35+$offsetx0, 600+$offsety0, 22, 43)

	EndIf
	
	; Download button
	If $GCI_DN[4] = $DOWNLOAD_AREA Then

		$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_HOVER_PNG, 0, 0, 75, 75, 260+$offsetx0, 230+$offsety0, 75, 75)

		$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		While $GCI_DN[4] = $DOWNLOAD_AREA
			If $GCI_DN[2] = 1 Then ExitLoop
			$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		WEnd
		$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260+$offsetx0, 230+$offsety0, 75, 75)

	EndIf
	
	; ISO button
	If $GCI_DN[4] = $ISO_AREA Then
		$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_HOVER_PNG, 0, 0, 75, 75, 38+$offsetx0, 231+$offsety0, 75, 75)

		$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		While $GCI_DN[4] = $ISO_AREA
			If $GCI_DN[2] = 1 Then ExitLoop
			$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		WEnd
		$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38+$offsetx0, 231+$offsety0, 75, 75)

	EndIf
	
	; EXIT button
	If $GCI_DN[4] = $EXIT_AREA Then
		$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_OVER, 0, 0, 20, 20, 335+$offsetx0, -20+$offsety0, 20, 20)
		$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		While $GCI_DN[4] = $EXIT_AREA
			If $GCI_DN[2] = 1 Then ExitLoop
			$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		WEnd
		$MSG = GUIGetMsg(1)
		If $MSG[0] = $EXIT_AREA Then ExitLoop
		$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335+$offsetx0, -20+$offsety0, 20, 20)

	EndIf
	; Minimize
	#cs
	If $GCI_DN[4] = $MIN_AREA Then
		$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_OVER, 0, 0, 20, 20, 135+$offsetx0, -3+$offsety0, 20, 20)
		$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		While $GCI_DN[4] = $MIN_AREA
			If $GCI_DN[2] = 1 Then ExitLoop
			$GCI_DN = GUIGetCursorInfo($CONTROL_GUI)
		WEnd
		If $MSG[0] = $MIN_AREA Then GUISetState(@SW_MINIMIZE, $GUI)
		$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 135+$offsetx0, -3+$offsety0, 20, 20)
	EndIf
	#ce

	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////// Help Sections                                 ///////////////////////////////////////////////////////////////////////////////
	; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	If $MSG[0] = $HELP_STEP1_AREA Then
		OpenHelpPage("etape1")
	ElseIf $MSG[0] = $HELP_STEP2_AREA Then
		OpenHelpPage("etape2")
	ElseIf $MSG[0] = $HELP_STEP3_AREA Then
		OpenHelpPage("etape3")
	ElseIf $MSG[0] = $HELP_STEP4_AREA Then
		OpenHelpPage("etape4")
	ElseIf $MSG[0] = $HELP_STEP5_AREA Then
		_About(Translate("A propos"), "LiLi USB Creator", "Copyright � " & @YEAR & " Thibaut Lauzi�re. All rights reserved.", $software_version, Translate("Guide d'utilisation"), "User_Guide", Translate("Homepage"), "http://www.linuxliveusb.com", Translate("Faire un don"), "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=1195284", @AutoItExe, 0x0000FF, 0xFFFFFF, -1, -1, -1, -1, $CONTROL_GUI)
	EndIf


WEnd

GUIDelete($CONTROL_GUI)
GUIDelete($GUI)

_GDIPlus_GraphicsDispose($ZEROGraphic)

_GDIPlus_ImageDispose($EXIT_NORM)
_GDIPlus_ImageDispose($EXIT_OVER)
_GDIPlus_ImageDispose($MIN_NORM)
_GDIPlus_ImageDispose($MIN_OVER)
_GDIPlus_ImageDispose($PNG_GUI)
_GDIPlus_ImageDispose($CD_PNG)
_GDIPlus_ImageDispose($CD_HOVER_PNG)
_GDIPlus_ImageDispose($ISO_PNG)
_GDIPlus_ImageDispose($ISO_HOVER_PNG)
_GDIPlus_ImageDispose($DOWNLOAD_PNG)
_GDIPlus_ImageDispose($DOWNLOAD_HOVER_PNG)
_GDIPlus_ImageDispose($LAUNCH_PNG)
_GDIPlus_ImageDispose($LAUNCH_HOVER_PNG)
_GDIPlus_ImageDispose($HELP)
_GDIPlus_ImageDispose($BAD)
_GDIPlus_ImageDispose($GOOD)
_GDIPlus_ImageDispose($WARNING)
_GDIPlus_Shutdown()



; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Files management                      ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func DirRemove2($arg1, $arg2)
	SendReport("Start-DirRemove2 ( " & $arg1 & " )")
	UpdateLog("Deleting folder : " & $arg1)
	If DirRemove($arg1, $arg2) Then
		UpdateLog("                   " & "Folder deleted")
	Else
		If DirGetSize($arg1) >= 0 Then
			UpdateLog("                   " & "Error while deleting")
		Else
			UpdateLog("                   " & "Folder not found")
		EndIf
	EndIf
	SendReport("End-DirRemove2")
EndFunc   

Func FileDelete2($arg1)
	SendReport("Start-FileDelete2 ( " & $arg1 & " )")
	UpdateLog("Deleting file : " & $arg1)
	If FileDelete($arg1) == 1 Then
		UpdateLog("                   " & "File deleted")
	Else
		If FileExists($arg1) Then
			UpdateLog("                   " & "Error while deleting")
		Else
			UpdateLog("                   " & "File not found")
		EndIf
	EndIf
	SendReport("End-FileDelete2")
EndFunc 

Func HideFile($file_or_folder) 
	SendReport("Start-HideFile ( " & $file_or_folder & " )")
	UpdateLog("Hiding file : " & $file_or_folder)
	If FileSetAttrib($file_or_folder,"+SH") == 1 Then
		UpdateLog("                   " & "File hided")
	Else
		If FileExists($file_or_folder) Then
			UpdateLog("                   " & "File not found")
		Else
			UpdateLog("                   " & "Error while hiding")
		EndIf
	EndIf
	SendReport("End-HideFile")
EndFunc

Func _FileCopy($fromFile, $tofile)
	SendReport("Start-_FileCopy")
	Local $FOF_RESPOND_YES = 16
	Local $FOF_SIMPLEPROGRESS = 256
	$winShell = ObjCreate("shell.application")
	$winShell.namespace($tofile).CopyHere($fromFile, $FOF_RESPOND_YES)
	SendReport("End-_FileCopy")
EndFunc  

Func _FileCopy2($arg1, $arg2)
	SendReport("Start-_FileCopy2 ( " & $arg1 & " -> " & $arg2 & " )")
	_FileCopy($arg1, $arg2)
	UpdateLog("Copying folder " & $arg1 & " to " & $arg2)
	SendReport("End-_FileCopy2")
EndFunc   

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Launching third party tools                       ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Run7zip($cmd, $taille)
	Local $foo, $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip ( " & $cmd & " )")
	
	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	$line = @CRLF
	
	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("D�compression de l'ISO sur la cl�") & " ( � " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		$line &= StdoutRead($foo)
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-Run7zip")
EndFunc   

Func Run7zip2($cmd, $taille)
	Local $foo, $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip2 ( " & $cmd & " )")
	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	$line = @CRLF
	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("D�compression de VirtualBox sur la cl�") & " ( � " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		$line &= StdoutRead($foo)
		;UpdateStatus2($line)
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-Run7zip2")
EndFunc  

Func RunDD($cmd, $taille)
	SendReport("Start-RunDD ( " & $cmd & " )")
	Local $foo, $line
	UpdateLog($cmd)
	If ProcessExists("dd.exe") > 0 Then ProcessClose("dd.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
	$line = @CRLF
	While 1

		UpdateStatusNoLog(Translate("Cr�ation du fichier de persistance") & " ( " & Round(FileGetSize($selected_drive & "\casper-rw") / 1048576, 0) & "/" & Round($taille, 0) & " Mo )")
		$line &= StderrRead($foo)
		;UpdateStatus2($line)
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-RunDD")
EndFunc   

Func RunMke2fs()
	Local $foo, $line
	If ProcessExists("mke2fs.exe") > 0 Then ProcessClose("mke2fs.exe")
	$cmd = @ScriptDir & '\tools\mke2fs.exe -b 1024 ' & $selected_drive & '\casper-rw'
	SendReport("Start-RunMke2fs ( " & $cmd & " )")
	UpdateLog($cmd)
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	$line = @CRLF
	While 1
		$line &= StdoutRead($foo)
		StdinWrite($foo, "{ENTER}")
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-RunMke2fs")
EndFunc   

Func RunWait3($soft, $arg1, $arg2)
	SendReport("Start-RunWait3 ( " & $soft & " )")
	Local $line, $foo
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = @CRLF
	While True
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog("                   " & $line)
	SendReport("End-RunWait3")
EndFunc   


Func Run2($soft, $arg1, $arg2)
	SendReport("Start-Run2 ( " & $soft & " )")
	Local $line, $foo
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = @CRLF
	While True
		$line = StdoutRead($foo)
		StdinWrite($foo, @CR & @LF & @CRLF)
		If @error Then ExitLoop
		Sleep(300)
	WEnd
	UpdateLog("                   " & $line)
	SendReport("End-Run2")
EndFunc  

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Disks Management                              ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Refresh_DriveList()
	SendReport("Start-Refresh_DriveList")
	; r�cup�re la liste des disques
	$drive_list = DriveGetDrive("REMOVABLE")
	$all_drives = "|-> " & Translate("Choisir une cl� USB") & "|"
	If Not @error Then
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If ((Not $fs = "") Or (Not $space = 0)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("Go") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-1")
	$drive_list = DriveGetDrive("FIXED")
	If Not @error Then
		$all_drives &= "-> " & Translate("Suite (disques durs)") & " -------------|"
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If ((Not $fs = "") Or (Not $space = 0)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("Go") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-2")
	If $all_drives <> "|-> " & Translate("Choisir une cl� USB") & "|" Then
		GUICtrlSetData($combo, $all_drives, "-> " & Translate("Choisir une cl� USB"))
		GUICtrlSetState($combo, $GUI_ENABLE)
	Else
		GUICtrlSetData($combo, "|-> " & Translate("Aucune cl� trouv�e"), "-> " & Translate("Aucune cl� trouv�e"))
		GUICtrlSetState($combo, $GUI_DISABLE)
	EndIf
	SendReport("End-Refresh_DriveList")
EndFunc   ;==>Refresh_DriveList

Func SpaceAfterLinuxLiveMB($disk)
	SendReport("Start-SpaceAfterLinuxLiveMB")
	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - 720
		If $spacefree >= 0 And $spacefree <= 4000 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 4000 Then
			Return (4000)
		Else
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - 720
		If $spacefree >= 0 And $spacefree <= 4000 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 4000 Then
			Return (4000)
		Else
			Return 0
		EndIf
	EndIf
	SendReport("End-SpaceAfterLinuxLiveMB")
EndFunc   ;==>SpaceAfterLinuxLiveMB

Func SpaceAfterLinuxLiveGB($disk)
	SendReport("Start-SpaceAfterLinuxLiveGB")
	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - 720
		If $spacefree >= 0 Then
			Return Round($spacefree / 1024, 1)
		Else
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - 720
		If $spacefree >= 0 Then
			Return Round($spacefree / 1024, 1)
		Else
			Return 0
		EndIf
	EndIf
	SendReport("End-SpaceAfterLinuxLiveGB")
EndFunc   ;==>SpaceAfterLinuxLiveGB

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Logs and status                               ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Func InitLog()
	Global $log_dir, $logfile
	DirCreate($log_dir)
	$logfile = @ScriptDir & "\logs\" & @MDAY & "-" & @MON & "-" & @YEAR & " (" & @HOUR & "h" & @MIN & "s" & @SEC & ").log"
	UpdateLog(LogSystemConfig())
	SendReport("logfile-" & $logfile )
EndFunc

Func LogSystemConfig()
	$mem = MemGetStats()
	$line = @CRLF & "--------------------------------  System Config  --------------------------------"
	$line &= @CRLF & "LiLi USB Creator : " & $software_version
	$line &= @CRLF & "OS Type : " & @OSTYPE
	$line &= @CRLF & "OS Version : " & @OSVersion
	$line &= @CRLF & "OS Build : " & @OSBuild
	$line &= @CRLF & "OS Service Pack : " & @OSServicePack
	$line &= @CRLF & "Architecture : " & @ProcessorArch
	$line &= @CRLF & "Memory : " & Round($mem[1] / 1024) & "MB  ( with " & (100 - $mem[0]) & "% free = " & Round($mem[2] / 1024) & "MB )"
	$line &= @CRLF & "Language : " & @OSLang
	$line &= @CRLF & "Keyboard : " & @KBLayout
	$line &= @CRLF & "Resolution : " & @DesktopWidth & "x" & @DesktopHeight
	;$line &= @CRLF & "Home drive : " &@HomeDrive
	If Ping("www.google.com") > 0 Then
		$line &= @CRLF & "Internet connected : YES"
	Else
		$line &= @CRLF & "Internet connected : NO"
	EndIf
	$line &= @CRLF & "Chosen Key : " & GUICtrlRead($combo)
	$line &= @CRLF & "Free space on key : " & Round(DriveSpaceFree($selected_drive)) & "MB"
	If $file_set_mode == "iso" Then
		$line &= @CRLF & "Selected ISO : " & path_to_name($file_set)
		$line &= @CRLF & "ISO Hash : " & $MD5_ISO
	Else
		$line &= @CRLF & "Selected source : " & $file_set
		$line &= @CRLF & "Folder Hash : " & $MD5_FOLDER
		$line &= @CRLF & "Linux Version : " & $version_in_file
	EndIf
	$line &= @CRLF & "Step Status : (STEP1=" & $STEP1_OK & ") (STEP2=" & $STEP2_OK & ") (STEP3=" & $STEP3_OK & ") "
	$line &= @CRLF & "------------------------------  End of system config  ------------------------------" & @CRLF
	Return $line
EndFunc   ;==>LogSystemConfig

Func UpdateStatus($status)
	SendReport(IniRead($lang_ini, "English", $status, $status))
	_FileWriteLog($logfile, "Status : " & Translate($status))
	GUICtrlSetData($label_step6_statut, Translate($status))
EndFunc   ;==>UpdateStatus

Func UpdateLog($status)
	_FileWriteLog($logfile, $status) ; No translation in logs
EndFunc   ;==>UpdateLog

Func UpdateStatusNoLog($status)
	GUICtrlSetData($label_step6_statut, Translate($status))
EndFunc   ;==>UpdateStatusNoLog

Func SendReport($report)
	_SendData($report, "lili-Reporter")
EndFunc   ;==>SendReport


; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking steps states                      ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Step1_Check($etat)
	Global $STEP1_OK
	If $etat = "good" Then
		$STEP1_OK = 1
		$DRAW_CHECK_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $GOOD, 0, 0, 25, 40, 338+$offsetx0, 150+$offsety0, 25, 40)
	Else
		$STEP1_OK = 0
		$DRAW_CHECK_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BAD, 0, 0, 25, 40, 338+$offsetx0, 150+$offsety0, 25, 40)
	EndIf
EndFunc   ;==>Step1_Check

Func Step2_Check($etat)
	Global $STEP2_OK
	If $etat = "good" Then
		$STEP2_OK = 1
		$DRAW_CHECK_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $GOOD, 0, 0, 25, 40, 338+$offsetx0, 287+$offsety0, 25, 40)
	ElseIf $etat = "bad" Then
		$STEP2_OK = 0
		$DRAW_CHECK_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BAD, 0, 0, 25, 40, 338+$offsetx0, 287+$offsety0, 25, 40)
	Else
		$STEP2_OK = 2
		$DRAW_CHECK_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $WARNING, 0, 0, 25, 40, 338+$offsetx0, 287+$offsety0, 25, 40)
	EndIf
EndFunc   ;==>Step2_Check

Func Step3_Check($etat)
	Global $STEP3_OK
	If $etat = "good" Then
		$STEP3_OK = 1
		$DRAW_CHECK_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $GOOD, 0, 0, 25, 40, 338+$offsetx0, 398+$offsety0, 25, 40)
	ElseIf $etat = "bad" Then
		$STEP3_OK = 0
		$DRAW_CHECK_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BAD, 0, 0, 25, 40, 338+$offsetx0, 398+$offsety0, 25, 40)
	Else
		$STEP3_OK = 2
		$DRAW_CHECK_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $WARNING, 0, 0, 25, 40, 338+$offsetx0, 398+$offsety0, 25, 40)
	EndIf
EndFunc   ;==>Step3_Check

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Creating boot menu                             ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func CreateBootText($selected_drive)
	SendReport("Start-CreateBootText")
	If FileExists($selected_drive & "\preseed\kubuntu.seed") Then
		UpdateStatus(Translate("D�tection automatique du type de variante") & " : Kubuntu (KDE)")
		$variante = "kubuntu"
	ElseIf FileExists($selected_drive & "\preseed\ubuntu.seed") Then
		UpdateStatus(Translate("D�tection automatique du type de variante") & " : LinuxLive (Gnome)")
		$variante = "ubuntu"
	ElseIf FileExists($selected_drive & "\preseed\xubuntu.seed") Then
		UpdateStatus(Translate("D�tection automatique du type de variante") & " : Xubuntu (XFce)")
		$variante = "xubuntu"
	ElseIf FileExists($selected_drive & "\preseed\mint.seed") Then
		UpdateStatus(Translate("D�tection automatique du type de variante") & " : Mint")
		$variante = "mint"
	ElseIf FileExists($selected_drive & "\preseed\custom.seed") Then
		UpdateStatus(Translate("D�tection automatique du type de variante") & " : Custom")
		$variante = "custom"
	Else
		UpdateStatus(Translate("Cet ISO n'est pas compatible"))
		$variante = "custom"
	EndIf
	WriteTextCFG($selected_drive)
	SendReport("End-CreateBootText")
EndFunc   ;==>CreateBootText

Func GetKbdCode()
	SendReport("Start-GetKbdCode")
	Select
		Case StringInStr("040c,080c,140c,180c", @OSLang)
			; FR
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Fran�ais (France)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_FR bootkbd=fr-latin1 console-setup/layoutcode=fr console-setup/variantcode=nodeadkeys "

		Case StringInStr("0c0c", @OSLang)
			; CA
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Fran�ais (Canada)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_CA bootkbd=fr-latin1 console-setup/layoutcode=ca console-setup/variantcode=nodeadkeys "

		Case StringInStr("100c", @OSLang)
			; Suisse FR
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Fran�ais (Suisse)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_CH bootkbd=fr-latin1 console-setup/layoutcode=ch console-setup/variantcode=fr "

		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			; German & dutch
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Allemand"))
			SendReport("End-GetKbdCode")
			Return "locale=de_DE bootkbd=de console-setup/layoutcode=de console-setup/variantcode=nodeadkeys "

		Case StringInStr("0816", @OSLang)
			; Portugais
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Portugais"))
			SendReport("End-GetKbdCode")
			Return "locale=pt_BR bootkbd=qwerty/br-abnt2 console-setup/layoutcode=br console-setup/variantcode=nodeadkeys "
			
		Case StringInStr("0410,0810", @OSLang)
			; Italien
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Italian"))
			SendReport("End-GetKbdCode")
			Return "locale=it_IT bootkbd=it console-setup/layoutcode=it console-setup/variantcode=nodeadkeys "
		Case Else
			; US
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("US ou autres (qwerty)"))
			SendReport("End-GetKbdCode")
			Return "locale=us_us bootkbd=us console-setup/layoutcode=en_US console-setup/variantcode=nodeadkeys "
	EndSelect

EndFunc   ;==>GetKbdCode

Func WriteTextCFG($selected_drive)
	SendReport("Start-WriteTextCFG")
	Local $boot_text, $kbd_code
	$boot_text = ""
	$kbd_code = GetKbdCode()
	
	if $variante == "mint" then 
		$boot_text = "default vesamenu.c32" _
		& @LF &  "timeout 100" _
		& @LF &  "menu background splash.jpg" _
		& @LF &  "menu title Welcome to Linux Mint" _
		& @LF &  "menu color border 0 #00eeeeee #00000000" _
		& @LF &  "menu color sel 7 #ffffffff #33eeeeee" _
		& @LF &  "menu color title 0 #ffeeeeee #00000000" _
		& @LF &  "menu color tabmsg 0 #ffeeeeee #00000000" _
		& @LF &  "menu color unsel 0 #ffeeeeee #00000000" _
		& @LF &  "menu color hotsel 0 #ff000000 #ffffffff" _
		& @LF &  "menu color hotkey 7 #ffffffff #ff000000" _
		& @LF &  "menu color timeout_msg 0 #ffffffff #00000000" _
		& @LF &  "menu color timeout 0 #ffffffff #00000000" _
		& @LF &  "menu color cmdline 0 #ffffffff #00000000" _
		& @LF &  "menu hidden" _
		& @LF &  "menu hiddenrow 5"
	Elseif $variante == "custom" Then
		$boot_text &=  "DISPLAY isolinux.txt" _
					 & @LF & "TIMEOUT 300" _
					 & @LF & "PROMPT 1" _
					 & @LF & "default persist" 
	Else
		$boot_text &=  @LF & "default persist" 
	EndIf
	
	$boot_text &=  @LF & "label persist" & @LF & "menu label ^" & Translate("Mode Persistant") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append  " & $kbd_code & "noprompt cdrom-detect/try-usb=true persistent file=/cdrom/preseed/" & $variante & ".seed boot=casper initrd=/casper/initrd.gz splash--" _
			 & @LF & "label live" _
			 & @LF & "  menu label ^" & Translate("Mode Live") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append   " & $kbd_code & "noprompt cdrom-detect/try-usb=true file=/cdrom/preseed/" & $variante & ".seed boot=casper initrd=/casper/initrd.gz splash--" _
			 & @LF & "label live-install" _
			 & @LF & "  menu label ^" & Translate("Installer") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append   " & $kbd_code & "noprompt cdrom-detect/try-usb=true persistent file=/cdrom/preseed/" & $variante & ".seed boot=casper only-ubiquity initrd=/casper/initrd.gz splash --" _
			 & @LF & "label check" _
			 & @LF & "  menu label ^" & Translate("Verification des fichiers") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append   " & $kbd_code & "noprompt boot=casper integrity-check initrd=/casper/initrd.gz splash --" _
			 & @LF & "label memtest" _
			 & @LF & "  menu label ^" & Translate("Test de la RAM") _
			 & @LF & "  kernel /install/mt86plus"
	UpdateLog("Creating syslinux config file :" & @CRLF & $boot_text) 
		$file = FileOpen($selected_drive & "\syslinux\text.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	if $variante == "mint" OR $variante == "custom" then 
		$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	EndIf
	
	if $variante == "custom" then 
		FileDelete2($selected_drive & "\syslinux\isolinux.txt")
		FileCopy(@ScriptDir & "\tools\crunchbang-isolinux.txt", $selected_drive & "\syslinux\isolinux.txt", 1)
	EndIf
	
		$file = FileOpen($selected_drive & "\syslinux.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	SendReport("End-WriteTextCFG")
EndFunc   ;==>WriteTextCFG

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Graphical Part                                ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func GetVertOffset($hgui)
;Const $SM_CYCAPTION = 4
    Const $SM_CXFIXEDFRAME = 7
    Local $wtitle, $wclient, $wsize,$wside,$ans
    $wclient = WinGetClientSize($hgui)
    $wsize = WinGetPos($hgui)
    $wtitle = DllCall('user32.dll', 'int', 'GetSystemMetrics', 'int', $SM_CYCAPTION)
    $wside = DllCall('user32.dll', 'int', 'GetSystemMetrics', 'int', $SM_CXFIXEDFRAME)
    $ans = $wsize[3] - $wclient[1] - $wtitle[0] - 2 * $wside[0] +25
    Return $ans
EndFunc  ;==>GetVertOffset

Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If ($hWnd = $GUI) And ($iMsg = $WM_NCHITTEST) Then Return $HTCAPTION
EndFunc   ;==>WM_NCHITTEST

Func SetBitmap($hGUI, $hImage, $iOpacity)
	Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend

	$hScrDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	$hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
	$tSize = DllStructCreate($tagSIZE)
	$pSize = DllStructGetPtr($tSize)
	DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
	DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
	$tSource = DllStructCreate($tagPOINT)
	$pSource = DllStructGetPtr($tSource)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	$pBlend = DllStructGetPtr($tBlend)
	DllStructSetData($tBlend, "Alpha", $iOpacity)
	DllStructSetData($tBlend, "Format", $AC_SRC_ALPHA)
	_WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
	_WinAPI_ReleaseDC(0, $hScrDC)
	_WinAPI_SelectObject($hMemDC, $hOld)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>SetBitmap



Global Const $LWA_ALPHA = 0x2
Global Const $LWA_COLORKEY = 0x1

;############# EndExample #########

;===============================================================================
;
; Function Name: _WinAPI_SetLayeredWindowAttributes
; Description:: Sets Layered Window Attributes:) See MSDN for more informaion
; Parameter(s):
; $hwnd - Handle of GUI to work on
; $i_transcolor - Transparent color
; $Transparency - Set Transparancy of GUI
; $isColorRef - If True, $i_transcolor is a COLORREF( 0x00bbggrr ), else an RGB-Color
; Requirement(s): Layered Windows
; Return Value(s): Success: 1
; Error: 0
; @error: 1 to 3 - Error from DllCall
; @error: 4 - Function did not succeed - use
; _WinAPI_GetLastErrorMessage or _WinAPI_GetLastError to get more information
; Author(s): Prog@ndy
;
; Link : @@MsdnLink@@ SetLayeredWindowAttributes
; Example : Yes
;===============================================================================
;
Func _WinAPI_SetLayeredWindowAttributes($hWnd, $i_transcolor, $Transparency = 255, $dwFlages = 0x03, $isColorRef = False)
	; #############################################
	; You are NOT ALLOWED to remove the following lines
	; Function Name: _WinAPI_SetLayeredWindowAttributes
	; Author(s): Prog@ndy
	; #############################################
	If $dwFlages = Default Or $dwFlages = "" Or $dwFlages < 0 Then $dwFlages = 0x03

	If Not $isColorRef Then
		$i_transcolor = Hex(String($i_transcolor), 6)
		$i_transcolor = Execute('0x00' & StringMid($i_transcolor, 5, 2) & StringMid($i_transcolor, 3, 2) & StringMid($i_transcolor, 1, 2))
	EndIf
	Local $Ret = DllCall("user32.dll", "int", "SetLayeredWindowAttributes", "hwnd", $hWnd, "long", $i_transcolor, "byte", $Transparency, "long", $dwFlages)
	Select
		Case @error
			Return SetError(@error, 0, 0)
		Case $Ret[0] = 0
			Return SetError(4, _WinAPI_GetLastError(), 0)
		Case Else
			Return 1
	EndSelect
EndFunc   ;==>_WinAPI_SetLayeredWindowAttributes

;===============================================================================
;
; Function Name: _WinAPI_GetLayeredWindowAttributes
; Description:: Gets Layered Window Attributes:) See MSDN for more informaion
; Parameter(s):
; $hwnd - Handle of GUI to work on
; $i_transcolor - Returns Transparent color ( dword as 0x00bbggrr or string "0xRRGGBB")
; $Transparency - Returns Transparancy of GUI
; $isColorRef - If True, $i_transcolor will be a COLORREF( 0x00bbggrr ), else an RGB-Color
; Requirement(s): Layered Windows
; Return Value(s): Success: Usage of LWA_ALPHA and LWA_COLORKEY (use BitAnd)
; Error: 0
; @error: 1 to 3 - Error from DllCall
; @error: 4 - Function did not succeed
; - use _WinAPI_GetLastErrorMessage or _WinAPI_GetLastError to get more information
; - @extended contains _WinAPI_GetLastError
; Author(s): Prog@ndy
;
; Link : @@MsdnLink@@ GetLayeredWindowAttributes
; Example : Yes
;===============================================================================
;
Func _WinAPI_GetLayeredWindowAttributes($hWnd, ByRef $i_transcolor, ByRef $Transparency, $asColorRef = False)
	; #############################################
	; You are NOT ALLOWED to remove the following lines
	; Function Name: _WinAPI_SetLayeredWindowAttributes
	; Author(s): Prog@ndy
	; #############################################
	$i_transcolor = -1
	$Transparency = -1
	Local $Ret = DllCall("user32.dll", "int", "GetLayeredWindowAttributes", "hwnd", $hWnd, "long*", $i_transcolor, "byte*", $Transparency, "long*", 0)
	Select
		Case @error
			Return SetError(@error, 0, 0)
		Case $Ret[0] = 0
			Return SetError(4, _WinAPI_GetLastError(), 0)
		Case Else
			If Not $asColorRef Then
				$Ret[2] = Hex(String($Ret[2]), 6)
				$Ret[2] = '0x' & StringMid($Ret[2], 5, 2) & StringMid($Ret[2], 3, 2) & StringMid($Ret[2], 1, 2)
			EndIf
			$i_transcolor = $Ret[2]
			$Transparency = $Ret[3]
			Return $Ret[4]
	EndSelect
EndFunc   ;==>_WinAPI_GetLayeredWindowAttributes

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking ISO/File MD5 Hashes                  ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Check_iso_integrity($linux_live_file)
	SendReport("Start-Check_iso_integrity")

	Global $MD5_ISO
	If IniRead($settings_ini, "General", "skip_checking", "no") == "yes" Then
		Step2_Check("good")
		Return ""
	EndIf

	$shortname = path_to_name($linux_live_file)

	If Check_if_version_non_grata($shortname) Then Return ""
	SendReport("Start-MD5_ISO")
	$hash = MD5_ISO($linux_live_file)
	$MD5_ISO = $hash
	SendReport("End-MD5_ISO")
	$file = FileOpen(@ScriptDir & "\tools\settings\MD5SUMS.txt", 0)
	If $file = -1 Then
		FileClose($file)
		MsgBox(0, Translate("Erreur"), Translate("Impossible d'ouvrir le fichier MD5SUMS") & @CRLF & Translate("Annulation de la v�rification"))
		Step2_Check("warning")
		Return ""
	EndIf
	$this_linux = ""
	$corrupted = 0
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop
		
		; if line is not empty
		If Not StringIsSpace($line) Then 
			$array_hash = StringSplit($line, ' *', 1)
			If ($array_hash[2] = $shortname) Then
					; son nom est connu , on est sur de la version
					If ($array_hash[1] = $hash) Then
						$this_linux = $array_hash[2]
						ExitLoop
					Else
						$corrupted = 1
						ExitLoop
					EndIf
				ElseIf ($array_hash[1] = $hash) Then
					; on connait pas son nom mais la version est bonne
					$this_linux = $array_hash[2]
					ExitLoop

				EndIf
		EndIf
	WEnd
	If $corrupted = 1 Then
		MsgBox(48, Translate("Attention"), Translate("Vous avez la bonne version de Linux mais elle est corrompue ou a �t� modifi�e.") & @CRLF & Translate("Merci de la t�l�charger � nouveau"))
		Step2_Check("warning")
	ElseIf $this_linux == "" Then
		MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("Merci de v�rifier la liste de compatibilit� dans le guide d'utilisation.") & @CRLF & Translate("Si votre version est bien dans la liste c'est que le fichier est corrompu et qu'il faut le t�l�charger � nouveau"))
		Step2_Check("warning")
	Else
		MsgBox(4096, Translate("V�rification") & " OK", Translate("La version est compatible et le fichier est valide"))
		Step2_Check("good")
	EndIf
	FileClose($file)
	SendReport("End-Check_iso_integrity")
EndFunc   ;==>Check_iso_integrity

Func Check_if_version_non_grata($ubuntu_version)
	SendReport("Start-Check_if_version_non_grata")
	If StringInStr($ubuntu_version, "8.04") Or StringInStr($ubuntu_version, "7.10") Or StringInStr($ubuntu_version, "6.06") Or StringInStr($ubuntu_version, "amd64") Or StringInStr($ubuntu_version, "sparc") Then
		MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("Merci de v�rifier la liste de compatibilit� dans le guide d'utilisation."))
		Step2_Check("warning")
		SendReport("End-Check_if_version_non_grata (is Non grata)")
		Return 1
	ElseIf StringInStr($ubuntu_version, "9.04") Then
		$jackalope = 1
	EndIf
	SendReport("End-Check_if_version_non_grata (is not Non grata)")
EndFunc   ;==>Check_if_version_non_grata

Func MD5_ISO($FileName)
	ProgressOn(Translate("V�rification"), Translate("V�rification de l'int�grit� + compatibilit�"), "0 %", -1, -1, 16)
	Global $BufferSize = 0x20000
	If $FileName = "" Then
		SendReport("End-MD5_ISO (no iso)")
		Return "no iso"
	EndIf

	Global $FileHandle = FileOpen($FileName, 16)

	$MD5CTX = _MD5Init()
	$iterations = Ceiling(FileGetSize($FileName) / $BufferSize)
	For $i = 1 To $iterations
		_MD5Input($MD5CTX, FileRead($FileHandle, $BufferSize))
		$percent_md5 = Round(100 * $i / $iterations)
		ProgressSet($percent_md5, $percent_md5 & " %")
	Next
	$hash = _MD5Result($MD5CTX)
	FileClose($FileHandle)

	ProgressSet(100, "100%", Translate("V�rification termin�e"))
	Sleep(500)
	ProgressOff()
	Return StringTrimLeft($hash, 2)
EndFunc   ;==>MD5_ISO


Func Check_folder_integrity($folder)
	SendReport("Start-Check_folder_integrity")
	Global $version_in_file, $MD5_FOLDER
	If IniRead($settings_ini, "General", "skip_checking", "no") == "yes" Then
		Step2_Check("good")
		SendReport("End-Check_folder_integrity (skip)")
		Return ""
	EndIf

	$info_file = FileOpen($folder & "\.disk\info", 0)
	If $info_file <> -1 Then
		$version_in_file = FileReadLine($info_file)
		FileClose($info_file)
		If Check_if_version_non_grata($version_in_file) Then Return ""
	EndIf
	
	Global $progression_foldermd5
	$file = FileOpen($folder & "\md5sum.txt", 0)
	If $file = -1 Then
		MsgBox(0, Translate("Erreur"), Translate("Impossible d'ouvrir le fichier md5sum.txt"))
		FileClose($file)
		Step2_Check("warning")
		Return ""
	EndIf
	$progression_foldermd5 = ProgressOn(Translate("V�rification"), Translate("V�rification de l'int�grit�"), "0 %", -1, -1, 16)
	$corrupt = 0
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop
		$array_hash = StringSplit($line, '  .', 1)
		$file_to_hash = $folder & StringReplace($array_hash[2], "/", "\")
		$file_md5 = MD5_FOLDER($file_to_hash)
		If ($file_md5 <> $array_hash[1]) Then
			ProgressOff()
			FileClose($file)
			MsgBox(48, Translate("Erreur"), Translate("Le fichier suivant est corrumpu") & " : " & $file_to_hash)
			Step2_Check("warning")
			$corrupt = 1
			$MD5_FOLDER = "bad file :" & $file_to_hash
			ExitLoop
		EndIf
	WEnd
	ProgressSet(100, "100%", Translate("V�rification termin�e"))
	Sleep(500)
	ProgressOff()
	If $corrupt = 0 Then
		MsgBox(4096, Translate("V�rification termin�e"), Translate("Toutes les fichiers sont bons."))
		Step2_Check("good")
		$MD5_FOLDER = "Good"
	EndIf
	FileClose($file)
	SendReport("End-Check_folder_integrity")
EndFunc   ;==>Check_folder_integrity


Func MD5_FOLDER($FileName)
	Global $progression_foldermd5
	Global $BufferSize = 0x20000

	If $FileName = "" Then
		SendReport("End-MD5_FOLDER (no folder)")
		Return "no iso"
	EndIf

	Global $FileHandle = FileOpen($FileName, 16)

	$MD5CTX = _MD5Init()
	$iterations = Ceiling(FileGetSize($FileName) / $BufferSize)
	For $i = 1 To $iterations
		_MD5Input($MD5CTX, FileRead($FileHandle, $BufferSize))
		$percent_md5 = Round(100 * $i / $iterations)
		ProgressSet($percent_md5, Translate("V�rification du fichier") & " " & path_to_name($FileName) & " (" & $percent_md5 & " %)")
	Next
	$hash = _MD5Result($MD5CTX)
	FileClose($FileHandle)

	Return StringTrimLeft($hash, 2)
EndFunc   ;==>MD5_FOLDER

Func path_to_name($filepath)
	$short_name = StringSplit($filepath, '\')
	Return ($short_name[$short_name[0]])
EndFunc   ;==>path_to_name

Func unix_path_to_name($filepath)
	$short_name = StringSplit($filepath, '/')
	Return ($short_name[$short_name[0]])
EndFunc   ;==>unix_path_to_name

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Locales management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func _Language()
	SendReport("Start-_Language")
	#cs
		Case StringInStr("0413,0813", @OSLang)
		Return "Dutch"
		
		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009, 2409,2809,2c09,3009,3409", @OSLang)
		Return "English"
		
		Case StringInStr("0410,0810", @OSLang)
		Return "Italian"
		
		Case StringInStr("0414,0814", @OSLang)
		Return "Norwegian"
		
		Case StringInStr("0415", @OSLang)
		Return "Polish"
		
		Case StringInStr("0416,0816", @OSLang)
		Return "Portuguese";
		
		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a, 440a,480a,4c0a,500a", @OSLang)
		Return "Spanish"
		
		Case StringInStr("041d,081d", @OSLang)
		Return "Swedish"
	#ce

	$force_lang = IniRead($settings_ini, "General", "force_lang", "no")
	$temp = IniReadSectionNames($lang_ini)
	$available_langs = _ArrayToString($temp)
	If $force_lang <> "no" And (StringInStr( $available_langs, $force_lang) > 0) Then
		SendReport("End-_Language (Force Lang)")
		Return $force_lang
	EndIf
	Select
		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			SendReport("End-_Language (FR)")
			Return "French"
		Case StringInStr("0403,040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a", @OSLang)
			SendReport("End-_Language (SP)")
			Return "Spanish"
		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			SendReport("End-_Language (GE)")
			Return "German"	
		Case StringInStr("0410,0810", @OSLang)
			Return "Italian"			
		Case Else
			SendReport("End-_Language (EN)")
			Return "English"
	EndSelect
EndFunc   ;==>_Language

Func Translate($txt)
	Return IniRead($lang_ini, $lang, $txt, $txt)
EndFunc   ;==>Translate

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Statistics                                  ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func SendStats()
	Global $anonymous_id
	SendReport("stats-id=" & $anonymous_id & "&version=" & $software_version & "&os=" & @OSVersion & "-" & @ProcessorArch & "-" & @OSServicePack & "&lang=" & _Language_for_stats())
EndFunc   ;==>SendStats

Func _Language_for_stats()
	Select
		Case StringInStr("0413,0813", @OSLang)
			Return "Dutch"

		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009, 2409,2809,2c09,3009,3409", @OSLang)
			Return "English"

		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			Return "German"

		Case StringInStr("0410,0810", @OSLang)
			Return "Italian"

		Case StringInStr("0414,0814", @OSLang)
			Return "Norwegian"

		Case StringInStr("0415", @OSLang)
			Return "Polish"

		Case StringInStr("0416,0816", @OSLang)
			Return "Portuguese";

		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a, 240a,280a,2c0a,300a,340a,380a,3c0a,400a, 440a,480a,4c0a,500a", @OSLang)
			Return "Spanish"

		Case StringInStr("041d,081d", @OSLang)
			Return "Swedish"

		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			Return "French";remove and return function specifally to oslang
		Case Else
			Return @OSLang
	EndSelect
EndFunc   ;==>_Language_for_stats



; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Help file management                          ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Unlock help file with vista
Func UnlockHelp()
	Global $help_file_name
	If FileExists($help_file_name) Then
		IniWrite($help_file_name&":Zone.Identifier", "ZoneTransfer", "ZoneId", 5)
	EndIf
EndFunc
	
; Open help file with right page and locale
Func OpenHelpPage($page)
	Global $help_file_name, $lang
	$short_lang = StringLower(StringLeft($lang,2))
	if StringInStr($help_available_langs,$short_lang)==0 then $short_lang = "en" 
		
	If FileExists($help_file_name) Then
		Run(@ComSpec & " /c " & 'hh.exe mk:@MSITStore:' & $help_file_name & '::/' & $page & '_' & $short_lang & '.html', "", @SW_HIDE)
	Else
		MsgBox(48, Translate("Erreur"), Translate("Le fichier d'aide n'est pas pr�sent dans le dossier."))
	EndIf
EndFunc



