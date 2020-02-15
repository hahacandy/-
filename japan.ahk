﻿#Include Gdip_All.ahk

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

CoordMode, Pixel, Screen

Global clientName := "NoxPlayer1"

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

Global nnx :=0
Global nny :=0



;해상도별 녹스 크기 조정 후 클릭 위치 변경
if(A_ScreenWidth == 1920 && A_ScreenHeight == 1200)
{
	Winmove, %clientName%, , , , 626, 1140
	
	leftClickX := 182
	leftClickY := 1024
	
	rightClickX := 434
	rightClickY := 1024
	
	corverWidth := 560
	corverHeight := 40
	
	corverX := 280
	corverY := 55
	
	searchImageName := "location"
	searchImageName2 := "location2"
	
	nnx := 30
	nny := 65
}
else if(A_ScreenWidth == 1920 && A_ScreenHeight == 1080)
{
	Winmove, %clientName%, , , , 558, 1020
	
	leftClickX := 179
	leftClickY := 911
	
	rightClickX := 391
	rightClickY := 912
	
	corverWidth := 540
	corverHeight := 35
	
	corverX := 260
	corverY := 49
	
	searchImageName := "location11"
	searchImageName2 := "location11"
	
	nnx := 30
	nny := 65
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

left::
	IfWinNotActive, NoxPlayer
	{
		WinActivate, NoxPlayer
	}
	click, %leftClickX%,%leftClickY%
	;sleep %clickDealy%
	isChange()
	createCover()
	capture()
	return
	

right::
	IfWinNotActive, NoxPlayer
	{
		WinActivate, NoxPlayer

	}
	click, %rightClickX%, %rightClickY%
	;sleep %clickDealy%
	isChange()
	createCover()
	capture()
	return
	
up::
	createCover()
	return
	
down::
	hideCover()
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
	IfWinActive, NoxPlayer
	{
		hideCover()
	}
	return
	
	
createCover(){

	searchY := 0 ;위에서 부터 커버를 차례대로 씌우기 위함

	Loop, 3{
		ImageSearch, vx, vy, 0, %searchY%, A_ScreenWidth, A_ScreenHeight, *100 %searchImageName%.png
		if(ErrorLevel == 0){
			searchY := vy+100
			vvx := vx - corverX
			vvy := vy - corverY
			
			Gui,%A_Index%:Show, x%vvx% y%vvy% w%corverWidth% h%corverHeight%
		}else{
			ImageSearch, vx, vy, 0, %searchY%, A_ScreenWidth, A_ScreenHeight, *100 %searchImageName2%.png
			if(ErrorLevel == 0){
				searchY := vy+100
				vvx := vx - corverX
				vvy := vy - corverY
				
				Gui,%A_Index%:Show, x%vvx% y%vvy% w%corverWidth% h%corverHeight%
			}else{
				Gui,%A_Index%:hide
			}
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
	
isChange(){
	cnt := 0
	while(true)
	{
		cnt += 1
		tooltip, %cnt%
		WinGetPos, nx, ny,,, NoxPlayer1
		ImageSearch, vx, vy, nx, ny, nx+300, ny+300, *50 current.png
		if(ErrorLevel == 0){
		}else{
			tooltip
			break
		}
	}
}
	
capture(){
	pToken := Gdip_StartUp()
	WinGetPos, nx, ny,,, NoxPlayer1
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
	