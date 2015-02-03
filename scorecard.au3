# This is an AutoIT script - useful as an example of how to do some complex web scraping, under user control
# (in other words, not generally useful at all :)

#include <ie.au3>
#include <Array.au3>
HotKeySet("{F8}","doDealernet")
HotKeySet("{F7}","doBearlease")
HotKeySet("{F6}","doQuit")
# Don't want to pass this around to every func...
Global $window_title = ""

While 1
   TrayTip("Scorecard 1.2.1", "F6=Quit, F7=Bearlease, F8=Dealernet", 5)
   sleep(100000)
WEnd

Func doDealernet()
   $window_title = "Dealernet 3.2"
   TransferData($window_title)
EndFunc

Func doBearlease()
   $window_title = "Bearlease 1.1"
   TransferData($window_title)
EndFunc

Func doQuit()
   Exit
EndFunc

Func TransferData($window_title)
   # This offset is used to get to the schedule level - this differs between DN and BL
   If ($window_title = "Dealernet 3.2") Then
	  $offset = 0
   Else
	  $offset = -1
   EndIf

   TrayTip($window_title, "Starting Scrape", 5)
   doLog("Attach to the frames of the window with the right title")
   Local $oIE = _IEAttach($window_title)
   If Not IsObj($oIE) Then
	  MsgBox(0, 'Error', 'Cannot locate ' & $window_title & ' window - please login to Dealernet')
	  Return
   EndIf
   doLog("Attached to window")

   doLog("Attaching to menu frame")
   Local $menu = _IEFrameGetObjByName($oIE, "Menu")
   If Not IsObj($menu) Then
	  MsgBox(0, 'Error', 'Cannot find menu frame - try re-logging in?')
	  Return
   EndIf

   doLog("Attaching to menu frame")
   Local $topmain = _IEFrameGetObjByName($oIE, "topMain")
   If Not IsObj($menu) Then
	  MsgBox(0, 'Error', 'Cannot find main contents frame - try re-logging in?')
	  Return
   EndIf

   doLog("Attach to the EFD Scorecard window")
   Local $scorecard = _IEAttach("EFD Scorecard Application")
   If Not IsObj($scorecard) Then
	  MsgBox(0, 'Error', 'Cannot locate EFD Scorecard window - please login to scorecard')
	  Return
   EndIf
   doLog("Checking to make sure we're logged into the EFD Scorecard")
   Local $oForm = _IEFormGetObjByName($scorecard, "form1")
   If Not IsObj($oForm) Then
	  MsgBox(0, 'Error', 'Connected to the EFD Scorecard window, but we are not logged in')
	  Return
   EndIf
   If $oForm.action = "Login.aspx" Then
	  MsgBox(0, "Error", 'Connected to the EFD Scorecard window, but need to re-login')
	  Return
   EndIf

   doLog("Click the top menu to get us back to a known state, then navigate to Home form")
   _IELinkClickByIndex($menu, 0)
   _IELoadWait($menu)
   _IELinkClickByIndex($menu, 9+$offset)
   _IELoadWait($menu)
   _IELinkClickByIndex($menu, 2)
   _IELoadWait($topmain)

   doLog("Get the company information from the Home form")
   Local $oForm = _IEFormGetObjByName($topmain, "homest")
   If Not IsObj($oForm) Then
	  MsgBox(0, 'Error', 'Cannot locate topmain form')
	  Return
   EndIf
   Local $entityName = getFormValue($oForm, "entityName")
   If $entityName = "" Then
	  MsgBox(0, 'Error', 'Cannot find entity - please search for a Dealernet customer')
	  Return
   EndIf
   doLog("EntityName: "&$entityName)
   Local $dateEstablished = getFormValue($oForm, "dateEstablished")
   Local $sic = getFormValue($oForm, "SIC")
   Local $programId = getSelectValue($oForm, "programId")
   Local $originCode = getSelectValue($oForm, "entityOriginCode")
   Local $state = getSelectValue($oForm, "orgJurisdiction")

   doLog("Now switch to the Schedule/App level, and click the selected application number link")
   _IELinkClickByIndex($menu, 0)
   _IELoadWait($menu)
   _IELinkClickByIndex($menu, 10+$offset)
   _IELoadWait($menu)
   _IELinkClickByIndex($menu, 4)
   _IELoadWait($topmain)
   _IELinkClickByIndex($topmain, 2)

   doLog("Get some tasty, tasty app details")
   Local $oForm = _IEFormGetObjByName($topmain, "app")
   # Before we go too far, make sure there is an app# on this form
   Local $appNumber = getFormValue($oForm, "creditAppNumber")
   If $appNumber = "" Then
	  MsgBox(0, 'Error', 'Cannot find application - please select a Dealernet application')
	  Return
   EndIf
   Local $equipDesc = getFormValue($oForm, "eqpDescription")
   Local $loanAmount = getFormValue($oForm, "submittedAmount")
   Local $creditScore = getFormValue($oForm, "creditScore")

   doLog("Get the paynet score")
   Local $paynetScore = ""
   _IELinkClickByIndex($menu, 12)
   _IELoadWait($topmain)
   _IELinkClickByIndex($topmain, 3)
   _IELoadWait($topmain)
   # This is needed since there is no form on this screen, loop thru all input fields
   $oInputs = _IETagNameGetCollection($topmain, "input")
   For $oInput in $oInputs
	  If $oInput.name = "master_score" Then
		 $paynetScore = $oInput.value
	  EndIf
   Next
   doLog("Paynet Score=" & $paynetScore)

   doLog("Get the Fico score")
   Local $ficoScore = ""
   Local $prin1Score = ""
   _IELinkClickByIndex($menu, 11)
   _IELoadWait($topmain)
   _IELinkClickByIndex($topmain, 3)
   _IELoadWait($topmain)
   # This is needed since there is no form on this screen, loop thru all input fields
   $oInputs = _IETagNameGetCollection($topmain, "input")
   For $oInput in $oInputs
	  If $oInput.name = "wsc_total_score" Then
		 $ficoScore = $oInput.value
	  EndIf
	  If $oInput.name = "cba_ol_cb_score1" Then
		 $prin1Score = $oInput.value
	  EndIf
   Next
   doLog("FICO Score=" & $ficoScore)
   doLog("Prin1 Score=" & $prin1Score)

   doLog("Now the tricky part - switch to contacts and attempt to get the dealer from the table")
   _IELinkClickByIndex($menu, 4)
   _IELoadWait($topmain)

   Local $oTable = _IETableGetCollection($topmain, 1)
   Local $contacts = _IETableWriteToArray($oTable)
   _ArrayTranspose($contacts)

   Local $vendor = ""
   For $i = 0 to UBound( $contacts, 1) - 1
	  If $contacts[$i][2] = "Vendor " or $contacts[$i][2] = "Broker/Discounter " Then
		 $vendor = $contacts[$i][0]
		 $vendor = StringStripWS($vendor, 2)
		 ExitLoop
	  EndIf
   Next
   doLog("Vendor=" & $vendor)

   doLog("Now switch over to EFD Scorecard and spew out the fields we collected")
   _IEFormImageClick($scorecard, "imgHome", "id")
   _IELoadWait($scorecard)
   _IEFormImageClick($scorecard, "imgCustomer", "id")
   _IELoadWait($scorecard)
   Local $oForm = _IEFormGetObjByName($scorecard, "form1")
   setFormValue($oForm, "MainContent_txtCustomerName", $entityName)
   setFormValue($oForm, "MainContent_txtAppID", $appNumber)
   setFormValue($oForm, "MainContent_txtNAICS", $sic)
   setSelectValue($oForm, "MainContent_ddlSource", "Trinity")
   setSelectValue($oForm, "MainContent_ddlVendorprogramType", "None of the above")
   setSelectValue($oForm, "MainContent_ddlPrior", "No")
   setSelectValue($oForm, "MainContent_ddlBankrupty", "No")
   setSelectValue($oForm, "MainContent_ddlCustomerPastDueDate", "No")
   setSelectValue($oForm, "MainContent_ddlIsOFAC", "No")

   doLog("The credit user needs to fill in some values and click submit.  Wait until that is done")
   Local $found = False
   For $i = 100 to 0 step -1
	  Local $sText = _IEBodyReadText($scorecard)
	  If StringInStr($sText, "Scorecard Inputs") Then
		 $found = True
		 ExitLoop
	  EndIf
	  ConsoleWrite("z")
	  Sleep(1000)
	  TrayTip("Waiting for Scorecard Inputs", "Timeout in " & $i, 1)
   Next
   ConsoleWrite(@CRLF)
   If not($found) Then
	  MsgBox(0, 'Error', 'Timed out waiting for Scorecard Inputs')
	  Return
   EndIf

   doLog("Ready for Scorecard Inputs")

   _IELoadWait($scorecard)
   Local $oForm = _IEFormGetObjByName($scorecard, "form1")
   setFormValue($oForm, "MainContent_ucEDFInput_txtVendor", $vendor)
   setFormValue($oForm, "MainContent_ucEDFInput_txtLoanAmount", $loanAmount)
   $yrsInBus = 2014 - $dateEstablished
   setFormValue($oForm, "MainContent_ucEDFInput_txtYears", $yrsInBus)
   setFormValue($oForm, "MainContent_ucEDFInput_txtPaynet", $paynetScore)
   setFormValue($oForm, "MainContent_ucEDFInput_txtLiquidCredit", $ficoScore)
   setFormValue($oForm, "MainContent_ucEDFInput_txtFico", $prin1Score)
   setFormValue($oForm, "MainContent_ucEDFInput_txtLeaseTerm", 60)
   setSelectValue($oForm, "MainContent_ucEDFInput_ddlState", $state)
   TrayTip("All Done", "Click 'Submit Deal' when ready", 5)
EndFunc

Func setFormValue($oForm, $name, $value)
   Local $oText = _IEFormElementGetObjByName($oForm, $name)
   _IEFormElementSetValue($oText, $value)
EndFunc

Func getFormValue($oForm, $name)
   $value = _IEFormElementGetValue(_IEFormElementGetObjByName($oForm, $name))
   doLog("Form Value:" & $name & "=" & $value)
   return $value
EndFunc

Func getSelectValue($oForm, $name)
   $oSelect=_IEFormElementGetObjByName($oForm, $name)
   $colChildren = _IETagNameGetCollection($oSelect, "Option")
   For $oChild In $colChildren
	  $sValue = $oChild.value
	  $sText = $oChild.innerText
	  $vSelected = $oChild.selected
	  If $oChild.selected = "True" Then
		 # This assumes only one value in the select is checked.  True dat.
		 # ...unless nothing is checked in which case we should return ""
		 $value = $oChild.innerText
		 doLog("Form Select:" & $name & "=" & $value)
		 return $oChild.innerText
	  EndIf
   Next
   doLog($name & " getSelectValue not found")
   Return ""
EndFunc

Func setSelectValue($oForm, $name, $value)
   doLog("Form set:" & $name & "=" & $value)
   $oSelect=_IEFormElementGetObjByName($oForm, $name)
   _IEFormElementOptionSelect($oSelect, $value, 1, "byText")
EndFunc

Func doLog($msg)
   ConsoleWrite($msg&@CRLF)
   TrayTip($window_title, $msg, 1)
   Sleep(50)
Return
