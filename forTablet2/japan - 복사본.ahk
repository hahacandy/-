#Include Gdip_All.ahk

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;SetBatchLines, -1

CoordMode, Pixel, Screen

Global clientName := "NoxPlayer"

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

Global coverCount := 10
Global realCount := 0


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
	
	corverWidth := 720
	corverHeight := 45
	
	corverX := 460
	corverY := 80
	
	searchImageName := "location"
	searchImageName2 := "location2"
	
	nnx := 100
	nny := 130
}

else
{
	msgbox 맞는 해상도가 없어서 종료
	exitapp
	return
}

Loop, %coverCount%
{
	Gui,%A_Index%:-caption
	Gui,%A_Index%:Add,Picture,x0 y0 w%corverWidth% h%corverHeight%, %A_ScriptDir%\cover.png
}



SetTimer, autoHideCover, 100
SetTimer, isClient, 100

left::
	if(!usingThread)
	{
				hideCover()
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
		hideCover()
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
		showCover()
		usingThread := false
	}
	return
	
wheeldown::
	if(!usingThread)
	{
		usingThread := true
		hideCover()
		usingThread := false
	}
	return

		
/*		
	IfWinNotActive, *제목 없음 - Windows 메모장
	{
		WinActivate, *제목 없음 - Windows 메모장
		send {enter}
	}
	IfWinNotActive, 제목 없음 - Windows 메모장
	{
		WinActivate, 제목 없음 - Windows 메모장
		send {enter}
	}
*/
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
	
createCover()
{
	realCount := 0
	Loop, %coverCount%
	{

		leftVx := 0
		leftVy := 0
		rightVx := 0
		rightVy := 0
		
		
		WinGetPos, nx, ny,,, %clientName%
		imageCount := 4
		Loop, %imageCount%
		{
			ImageSearch, leftVx, leftVy, nx, ny, nx+clientSizeW, ny+clientSizeH, *100 left%A_Index%.png
			if(leftVx > 0 && leftVy > 0){
				Loop, %imageCount%
				{
					ImageSearch, resultVx, rightVy, nx, leftVy-corverHeight, nx+clientSizeW, leftVy+corverHeight, *100 right%A_Index%.png
					if(resultVx > 0 && rightVy > 0){
						
						if((resultVx-leftVx) >= 50){
							if(rightVx == 0 || rightVx > resultVx)
								rightVx := resultVx
						}
						

					}

				}
				if(rightVx > 0 && rightVy > 0)
					break
			}

		}
		
		leftVy -= 5
		cWidth := rightVx-leftVx+10
		

		if(leftVx == "" || leftVy == "" || rightVx == "" || rightVy == "" || cWidth <= 0){
			break
		}else{
			
			Gui,%A_Index%:Show, x%leftVx% y%leftVy% w%cWidth% h%corverHeight%
			realCount += 1
			sleep 30
			
		}
		
		
		
	}
	

}
	
showCover(){
	Loop, %realCount%{
		Gui,%A_Index%:show
	}
	return
}

hideCover(){
	Loop, %coverCount%{
		Gui,%A_Index%:hide
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
	WinGetPos, nx, ny,,, %clientName%
	pBitmap := Gdip_BitmapFromScreen((nx+nnx) . "|" . (ny+nny) . "|150|60")
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
	
/*
up::
	send {ctrl down}{LWin down}
	send {left}
	send {ctrl up}{LWin up}
	return
	
down::
	send {ctrl down}{LWin down}
	send {right}
	send {ctrl up}{LWin up}
	return

space::
	IfWinNotActive, *제목 없음 - Windows 메모장
	{
		WinActivate, *제목 없음 - Windows 메모장
		send {enter}
	}
	IfWinNotActive, 제목 없음 - Windows 메모장
	{
		WinActivate, 제목 없음 - Windows 메모장
		send {enter}
	}
	return
	
*/
	