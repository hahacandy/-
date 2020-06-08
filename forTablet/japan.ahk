#Include Gdip_All.ahk

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

CoordMode, Pixel, Screen

Global clientName := "녹스 플레이어"

Global clientSizeW := 0
Global clientSizeH := 0

Global leftClickX := 0
Global leftClickY := 0
Global rightClickX := 0
Global rightClickY := 0

Global corverWidth := 0 ;커버의 가로 크기
Global corverHeight := 0 ;커버의 세로 크기

Global corverX := 0 ;커버 생성될 위치
Global corverY := 0

Global clickDealy := 150

Global searchImageName := ""
Global searchImageName2 := ""

Global nnx := 0
Global nny := 0

Global coverCnt := 0
Global coverCurrent := 0

Global usingThread := false



;해상도별 녹스 크기 조정 후 클릭 위치 변경
if(A_ScreenWidth == 1200 && A_ScreenHeight == 1920)
{
	clientSizeW := 1200
	clientSizeH := 1860

	WinActivate, %clientName%
	Winmove, %clientName%,,,, %clientSizeW%, %clientSizeH%
	Winmove, %clientName%,, 0, 0

	
	leftClickX := 420
	leftClickY := 1685
	
	rightClickX := 770
	rightClickY := 1685
	
	corverWidth := 630
	corverHeight := 45
	
	corverX := 460
	corverY := 80
	
	searchImageName := "location"
	searchImageName2 := "location2"
	
	nnx := 100
	nny := 100
}

else
{
	msgbox 맞는 해상도가 없어서 종료
	exitapp
	return
}

Gui,1:-caption
Gui,1:Add,Picture,x0 y0 w%corverWidth% h%corverHeight%, %A_ScriptDir%\cover.png

Gui,2:-caption
Gui,2:Add,Picture,x0 y0 w%corverWidth% h%corverHeight%, %A_ScriptDir%\cover.png

Gui,3:-caption
Gui,3:Add,Picture,x0 y0 w%corverWidth% h%corverHeight%, %A_ScriptDir%\cover.png


SetTimer, autoHideCover, 100
SetTimer, isClient, 100

left::
	if(!usingThread)
	{
		usingThread := true
		IfWinNotActive, %clientName%
		{
			WinActivate, %clientName%
		}
		click, %leftClickX%,%leftClickY%
		;sleep %clickDealy%
		isChange()
		createCover()
		capture()
		usingThread := false
	}
	return
	

RButton::
	if(!usingThread)
	{
		usingThread := true
		IfWinNotActive, %clientName%
		{
			WinActivate, %clientName%

		}
		click, %rightClickX%, %rightClickY%
		;sleep %clickDealy%
		isChange()
		createCover()
		capture()
		usingThread := false
	}
	return
	
wheelup::
	if(!usingThread)
	{
		usingThread := true
		createOneCover()
		sleep 500
		usingThread := false
	}
	return
	
wheeldown::
	if(!usingThread)
	{
		usingThread := true
		hideOneCover()
		sleep 500
		usingThread := false
	}
	return

	
autoHideCover:
	IfWinActive, %clientName%
	{
		hideCover()
		coverCurrent := coverCnt
	}
	return
	
isClient:
	IfWinNotExist, %clientName%
	{
		exitapp
	}
	return
	
	
createCover(){

	coverCnt := 0
	coverCurrent := 0
	
	WinGetPos, nx, ny,,, %clientName%

	searchY := ny ;위에서 부터 커버를 차례대로 씌우기 위함

	Loop, 3{
		ImageSearch, vx, vy, nx, %searchY%, nx+clientSizeW, ny+clientSizeH, *100 %searchImageName%.png
		if(ErrorLevel == 0){
			searchY := vy+100
			vvx := vx - corverX
			vvy := vy - corverY
			
			Gui,%A_Index%:Show, x%vvx% y%vvy% w%corverWidth% h%corverHeight%
			
			coverCnt+=1
		}else{
			ImageSearch, vx, vy, nx, %searchY%, nx+clientSizeW, ny+clientSizeH, *100 %searchImageName2%.png
			if(ErrorLevel == 0){
				searchY := vy+100
				vvx := vx - corverX
				vvy := vy - corverY
				
				Gui,%A_Index%:Show, x%vvx% y%vvy% w%corverWidth% h%corverHeight%
				coverCnt+=1
			}else{
				Gui,%A_Index%:hide
			}
		}
	}
	return
}

createOneCover(){

	Loop, 3{
		if(A_Index == coverCurrent && coverCnt >= A_Index)
		{
			Gui,%A_Index%:show
			coverCurrent-=1
			break
		}
	}
	
	return
}

hideCover(){
	Loop, 3{
		Gui,%A_Index%:hide
	}
	return
}

hideOneCover(){
	Loop, 3{
		if(A_Index-1 == coverCurrent && coverCnt >= A_Index)
		{
			Gui,%A_Index%:hide
			coverCurrent+=1
			break
		}
	}
	return
}
	
isChange(){
	cnt := 0
	while(true)
	{
		cnt += 1
		tooltip, %cnt%
		WinGetPos, nx, ny,,, %clientName%
		ImageSearch, vx, vy, nx, ny, nx+300, ny+300, *50 current.png
		if(ErrorLevel == 0){
		}else{
			tooltip
			break
		}
		
		if(cnt >= 100)
		{
			tooltip, 커버 씌우기 실패 재시도 바람
			sleep 1000
			tooltip
			break
		}
	}
}
	
capture(){
	pToken := Gdip_StartUp()
	WinGetPos, nx, ny,,, NoxPlayer1
	pBitmap := Gdip_BitmapFromScreen((nx+nnx) . "|" . (ny+nny) . "|" . (180) . "|" . (80))
	Gdip_SaveBitmapToFile(pBitmap ,"current.png")
	return
}
	
GetClientSize(hWnd, ByRef w := "", ByRef h := "")
{
	VarSetCapacity(rect, 16)
	DllCall("GetClientRect", "ptr", hWnd, "ptr", &rect)
	w := NumGet(rect, 8, "int")
	h := NumGet(rect, 12, "int")
	return
}

	