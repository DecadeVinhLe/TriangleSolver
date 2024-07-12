; Triangle solver, solves every solveable standard triangle ;---------------------------------------------------------------------
;
; Author: monoceres originally, this version by Vrains
; Thanks to: eviltoaster, weaponx and The Kandie Man, MDiessel for help about degrees and radians
;
;---------------------------------------------------------------------------------------------------------------------------------
;
; Triangle laws used:
;    * Law of Cosines: a^2=b^2+c^2 -2bcCos(A)
;    * Law of Sines: a/Sin(A) = b/Sin(B) = c/Sin(C)
;    * A + B + C = 180
;
; Edit by Vrains: ;--------------------------------------------------------------------------------------------------------------
;
; New triangle laws:
;    * a^2 + b^2 = c^2
;
; I also re-did the graphics. It no longer needs the associated triangle picture, and the values are actually inputted on the
; triangle. I re wrote most of the variables as well, but most of the original maths functions are still there, so full
; credit to Monoceres. Now if you input only 2 sides, it won't return an angle of 180*, instead it presumes C = 90 and uses
; pythagoras to work the rest out.
;
;---------------------------------------------------------------------------------------------------------------------------------

#include <GDIPlus.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <Math.au3>
#include <Misc.au3>

Opt ("GUIOnEventMode", 1)
Opt ("MouseCoordMode", 2)
#NoTrayIcon

Global $hGraphic, $hPen

_Main ()

; Main dialog box. ;--------------------------------------------------------------------------------------------------------------

Func _Main ()
   Local $hGUI, $hWnd
   Global $aA_Inp, $aB_Inp, $aC_Inp, $sA_Inp, $sB_Inp, $sC_Inp

   _GDIPlus_Startup ()

   $hGUI = GUICreate ("Triangle Solver", 470, 330, -1, -1)
      $hWnd = WinGetHandle ("Triangle Solver")

      $exp = GUICtrlCreateLabel ("Enter the known sides and angles." & @CRLF & @CRLF & "Click 'solve' to solve the triangle!!", _
      10, 20, 150, 50)
         GUICtrlSetOnEvent ($exp, "_Help")

      $Hlp = GUICtrlCreateLabel ("By Vrains. " & @CRLF & @CRLF & "Thanks to Monoceres for most of the maths functions.", _
      310, 20, 150, 50)
         GUICtrlSetOnEvent ($Hlp, "_About")

      $Solve = GUICtrlCreateButton ("&Solve!!", 15, 300, 80, 20, -1, -1)
         GUICtrlSetOnEvent ($Solve, "_ProcessTriangle")
         GUICtrlSetTip ($Solve, "Solve the triangle.")
      $Reset = GUICtrlCreateButton ("&Reset", 105, 300, 80, 20, -1, -1)
         GUICtrlSetOnEvent ($Reset, "_Reset")
         GUICtrlSetTip ($Reset, "Reset all values.")
      $About = GUICtrlCreateButton ("&About", 195, 300, 80, 20, -1, -1)
         GUICtrlSetOnEvent ($About, "_About")
         GUICtrlSetTip ($About, "About the Triangle Solver")
      $Help = GUICtrlCreateButton ("&Help", 285, 300, 80, 20, -1, -1)
         GUICtrlSetOnEvent ($Help, "_Help")
         GUICtrlSetTip ($Help, "Need help?")
      $Cancel = GUICtrlCreateButton ("&Cancel", 375, 300, 80, 20)
         GUICtrlSetOnEvent ($Cancel, "_Exit")
         GUICtrlSetTip ($Cancel, "Close the dialog.")

      $aC_Inp = GUICtrlCreateInput ("", 200, 10, 70, 20)
         GUICtrlSetTip ($aC_Inp, "Angle C")
      $aA_Inp = GUICtrlCreateInput ("", 10, 245, 50, 20)
         GUICtrlSetTip ($aA_Inp, "Angle A")
      $aB_Inp = GUICtrlCreateInput ("", 410, 245, 50, 20)
         GUICtrlSetTip ($aB_Inp, "Angle B")

      $sA_Inp = GUICtrlCreateInput ("", 325, 130, 70, 20)
         GUICtrlSetTip ($sA_Inp, "Side A")
      $sC_Inp = GUICtrlCreateInput ("", 200, 260, 70, 20)
         GUICtrlSetTip ($sC_Inp, "Side C")
      $sB_Inp = GUICtrlCreateInput ("", 75, 130, 70, 20)
         GUICtrlSetTip ($sB_Inp, "Side B")

      GUICtrlCreateLabel ("C", 230, 90, 10, 20)
         GUICtrlSetTip (-1, "Angle C")
      GUICtrlCreateLabel ("B", 340, 215, 10, 20)
         GUICtrlSetTip (-1, "Angle B")
      GUICtrlCreateLabel ("A", 130, 215, 10, 20)
         GUICtrlSetTip (-1, "Angle A")

      GUICtrlCreateLabel ("c", 230, 220, 10, 20)
         GUICtrlSetTip (-1, "Side c")
      GUICtrlCreateLabel ("b", 155, 150, 10, 20)
         GUICtrlSetTip (-1, "Side b")
      GUICtrlCreateLabel ("a", 310, 150, 10, 20)
         GUICtrlSetTip (-1, "Side a")

   $hGraphic = _GDIPlus_GraphicsCreateFromHWND ($hWnd)
   $hPen = _GDIPlus_PenCreate ()

   GUIRegisterMsg (0xF,"_Paint")

   GUISetState()
   GUISetOnEvent (-3, "_Exit")

   Do
      ;;;
   Until 1 = 2

EndFunc ; ==> _Main

; Painting - so the triangle stays on the GUI ;-----------------------------------------------------------------------------------
;    Me mostly, but thanks to ProgAndy as it's his method to register the message.

Func _Paint ($hWnd, $Msg, $wParam, $lParam)
   _GDIPlus_GraphicsDrawLine ($hGraphic, 65, 250, 400, 250, $hPen)
   _GDIPlus_GraphicsDrawLine ($hGraphic, 65, 250, 235, 40, $hPen)
   _GDIPlus_GraphicsDrawLine ($hGraphic, 400, 250, 235, 40, $hPen)

   _GDIPlus_GraphicsDrawLine ($hGraphic, 340, 250, 365, 205, $hPen)
   _GDIPlus_GraphicsDrawLine ($hGraphic, 125, 250, 100, 205, $hPen)
   _GDIPlus_GraphicsDrawLine ($hGraphic, 205, 80, 265, 80, $hPen)

   Return "GUI_RUNDEFMSG"
EndFunc ; ==> _Paint

; _Exit ;-------------------------------------------------------------------------------------------------------------------------

Func _Exit ()
   _GDIPlus_PenDispose ($hPen)
   _GDIPlus_GraphicsDispose ($hGraphic)
   _GDIPlus_Shutdown ()
   Exit
EndFunc

; _ProcessTriangle, does the maths!! ;--------------------------------------------------------------------------------------------
;   Mostly by Monoceres, I edited parts.

Func _ProcessTriangle()
	Local $ifsum, $ifsum2, $bool = False

	$aA = GUICtrlRead ($aA_Inp)
	$aB = GUICtrlRead ($aB_Inp)
	$aC = GUICtrlRead ($aC_Inp)
	$sA = GUICtrlRead ($sA_Inp)
	$sB = GUICtrlRead ($sB_Inp)
	$sC = GUICtrlRead ($sc_Inp)
	If StringRight ($aA, 1) = Chr (176) Then $aA = StringTrimRight ($aA, 1) ; Fixing the GUI display button
	If StringRight ($aB, 1) = Chr (176) Then $aB = StringTrimRight ($aB, 1) ; Fixing the GUI display button
	If StringRight ($aC, 1) = Chr (176) Then $aC = StringTrimRight ($aC, 1)
	; Info is gathered to see how many things are known
	If $aA <> "" Then $ifsum += 1
	If $aB <> "" Then $ifsum += 1
	If $aC <> "" Then $ifsum += 1
	If $sA <> "" Then $ifsum2 += 1
	If $sB <> "" Then $ifsum2 += 1
	If $sC <> "" Then $ifsum2 += 1

	If ($ifsum < 2 And $ifsum2 < 2) Or $ifsum2 < 1 Then ; 1 angle + 2 sides or 2 angles + 1 side is required to solve triangle
		MsgBox(16, "Error", "Not enough information entered to solve this triangle")
		Return 0
	EndIf
	If $ifsum = 2 And $aA + $aC + $aB < 180 Then
		If $aA = "" Then
			$aA = 180 - $aB - $aC
		ElseIf $aB = "" Then
			$aB = 180 - $aA - $aC
		Else
			$aC = 180 - $aA - $aB
		EndIf
		$ifsum += 1
	EndIf
	If ($aA + $aB + $aC > 180) Or ($ifsum = 3 And $aA + $aB + $aC < 180) Then ; input invalid (Angles do not add up to 180)
		MsgBox(16, "Triangle error", "Total sum of the angles must be 180�")
		Return 0
	EndIf
	If $sA <> "" And $sB <> "" And $sC <> "" Then ; If all sides are know, calculate angles
		$aA = Round(_Degree(ACos(($sB ^ 2 + $sC ^ 2 - $sA ^ 2) / (2 * $sC * $sB))), 2) ; Law of Cosines
		$aB = Round(_Degree(ACos(($sA ^ 2 + $sC ^ 2 - $sB ^ 2) / (2 * $sC * $sA))), 2) ; Law of Cosines
		$aC = 180 - $aB - $aA
	ElseIf $ifsum > 1 Then ; If we know more than one angle
		If $sA <> "" Then
			$sB = ($sA / Sin(_Radian($aA))) * Sin(_Radian($aB)) ; Law of Sines
			$sC = ($sA / Sin(_Radian($aA))) * Sin(_Radian($aC)) ; Law of Sines
		ElseIf $sB <> "" Then
			$sA = ($sB / Sin(_Radian($aB))) * Sin(_Radian($aA)) ; Law of Sines
			$sC = ($sB / Sin(_Radian($aB))) * Sin(_Radian($aC)) ; Law of Sines
		ElseIf $sC <> "" Then
			$sA = ($sC / Sin(_Radian($aC))) * Sin(_Radian($aA)) ; Law of Sines
			$sB = ($sC / Sin(_Radian($aC))) * Sin(_Radian($aB)) ; Law of Sines
		EndIf
	ElseIf $ifsum2 > 1 Then ; We know more than one side
		If $sA <> "" And $aA <> "" Then
			If $sB <> "" Then
				$aB = _Degree(ASin($sB / ($sA / Sin(_Radian($aA))))) ; Law of Sines
				$aC = 180 - $aB - $aA
				$sC = ($sA / Sin(_Radian($aA))) * Sin(_Radian($aC)) ; Law of Sines
			ElseIf $sC <> "" Then
				$aB = _Degree(ASin($sC / ($sA / Sin(_Radian($aA))))) ; Law of Sines
				$aB = 180 - $aC - $aA
				$sB = ($sA / Sin(_Radian($aA))) * Sin(_Radian($aB)) ; Law of Sines
			EndIf
		ElseIf $sC <> "" And $aC <> "" Then
			If $sB <> "" Then
				$aB = _Degree(ASin($sB / ($sC / Sin(_Radian($aC))))) ; Law of Sines
				$aA = 180 - $aB - $aC
				$sA = ($sC / Sin(_Radian($aC))) * Sin(_Radian($aA)) ; Law of Sines
			ElseIf $sA <> "" Then
				$aA = _Degree(ASin($sA / ($sC / Sin(_Radian($aC))))) ; Law of Sines
				$aB = 180 - $aA - $aC
				$sB = ($sC / Sin(_Radian($aC))) * Sin(_Radian($aB)) ; Law of Sines
			EndIf
		ElseIf $sB <> "" And $aB <> "" Then
			If $sA <> "" Then
				$aA = _Degree(ASin($sA / ($sB / Sin(_Radian($aB))))) ; Law of Sines
				$aC = 180 - $aB - $aA
				$sC = ($sB / Sin(_Radian($aB))) * Sin(_Radian($aC)) ; Law of Sines
			ElseIf $sC <> "" Then
				$aC = _Degree(ASin($sC / ($sB / Sin(_Radian($aB))))) ; Law of Sines
				$aA = 180 - $aB - $aC
				$sA = ($sB / Sin(_Radian($aB))) * Sin(_Radian($aA)) ; Law of Sines
			EndIf
		Else ; No angle and side match, have to do some extra work
         If $aA = "" And $aB = "" And $aC = "" Then ; No angles given!!
            $aC = 90 ; presumes its right angled.
            If $sA <> "" And $sB <> "" Then ; Find side c
               $sC = Sqrt (($sA ^ 2) + ($sB ^ 2)) ; Pythagorithm
            ElseIf $sA <> "" And $sC <> "" Then ; find b
               $sB = Sqrt (($sC ^ 2) - ($sA ^ 2))
            ElseIf $sB <> "" And $sC <> "" Then ; find a
               $sA = Sqrt (($sC ^ 2) - ($sB ^ 2))
            EndIf
         EndIf
			If $sA = "" Then
				$sA = Sqrt (-2 * $sB * $sC * Cos (_Radian($aA)) + $sB ^ 2 + $sC ^ 2) ; Law of Cosines
			ElseIf $sB = "" Then
				$sB = Sqrt (-2 * $sA * $sC * Cos (_Radian($aB)) + $sA ^ 2 + $sC ^ 2) ; Law of Cosines
			ElseIf $sC = "" Then
				$sC = Sqrt (-2 * $sA * $sB * Cos (_Radian($aC)) + $sA ^ 2 + $sB ^ 2) ; Law of Cosines
			EndIf
			$aA = Round (_Degree (ACos (($sB ^ 2 + $sC ^ 2 - $sA ^ 2) / (2 * $sC * $sB))), 2) ; Law of Cosines
			$aB = Round (_Degree (ACos (($sA ^ 2 + $sC ^ 2 - $sB ^ 2) / (2 * $sC * $sA))), 2) ; Law of Cosines
			$aC = 180 - $aB - $aA
		EndIf
	EndIf
	GUICtrlSetData ($sA_Inp, $sA)
	GUICtrlSetData ($sB_Inp, $sB)
	GUICtrlSetData ($sc_Inp, $sC)
	GUICtrlSetData ($aA_Inp, $aA & Chr (176))
	GUICtrlSetData ($aB_Inp, $aB & Chr (176))
	GUICtrlSetData ($aC_Inp, $aC & Chr (176))
EndFunc   ; ==> _ProcessTriangle

; Help box. Simple message box popup. ;-------------------------------------------------------------------------------------------

Func _Help ()
	MsgBox (64,"Help for Triangle Solver","Enter known values and click solve to find out the rest." & @CRLF & _
      "Click resest to reset all fields." & @CRLF & "The program will not warn you for everything, remember for example " & _
      "that one side cannot be greater than the sum of the others. If you are really struggling then consider searching " & _
      "the internet to see what the answer should be. If it is definitely a fault with the script then please report a bug.")
EndFunc ; ==> _Help

; _Reset, resets all values to blank ;--------------------------------------------------------------------------------------------

Func _Reset ()
	GUICtrlSetData($sA_Inp, "")
	GUICtrlSetData($sB_Inp, "")
	GUICtrlSetData($sc_Inp, "")
	GUICtrlSetData($aA_Inp, "")
	GUICtrlSetData($aB_Inp, "")
	GUICtrlSetData($aC_Inp, "")
EndFunc ; ==> _Reset

; _About, basic info about the program. ;-----------------------------------------------------------------------------------------

Func _About ()
   MsgBox (64, "About Triangle Solver.", "Triangle solver was originally written by Monoceres, whilst studying trig " & _
      "at school. This version is by MDiesel, and brings a few major improvements. I re-did the triangle in GDI+, " & _
      "to make it more graphic and also so you can input values on to the triangle. I also added another theorem, " & _
      "Pythagoras' a^2 + b^2 = c^2. This means you no longer have to input any angles, provided you enter 2 valid " & _
      "sides, it will work it out for you. This also goes some way towards having angles of 180* which happened when " & _
      "you inputted no angles.")
EndFunc ; ==> _About

; Script End!! ;------------------------------------------------------------------------------------------------------------------