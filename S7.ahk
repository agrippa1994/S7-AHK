g_lastError := 0

; S7Area
S7AreaPE := 0x81
S7AreaPA := 0x82
S7AreaMK := 0x83
S7AreaDB := 0x84
S7AreaCT := 0x1C
S7AreaTM := 0x1D

; S7WordLength
S7WordLengthBit 	:= 0x01
S7WordLengthByte 	:= 0x02
S7WordLengthWord 	:= 0x04
S7WordLengthDword 	:= 0x06
S7WordLengthReal 	:= 0x08
S7WordLengthCounter := 0x1C
S7WordLengthTimer 	:= 0x1D

; Initialisierung
hModule := DllCall("LoadLibrary", Str, PathCombine(A_ScriptDir, "snap7.dll"))
if(hModule == -1 || hModule == 0) {
	MsgBox, 48, Error, snap7.dll nicht gefunden
	ExitApp
}

S7_Create_func := DllCall("GetProcAddress", "UInt", hModule, "Str", "Cli_Create")
S7_Create() {
	global S7_Create_func
	return DllCall(S7_Create_func)
}

S7_ConnectTo_func := DllCall("GetProcAddress", "UInt", hModule, "Str", "Cli_ConnectTo")
S7_ConnectTo(obj, ip, rack, slot) {
	global S7_ConnectTo_func
	return execute(DllCall(S7_ConnectTo_func, "uint", obj, "str", ip, "int", rack, "int", slot))
}

S7_WriteArea_func := DllCall("GetProcAddress", "UInt", hModule, "Str", "Cli_WriteArea")
S7_WriteBit(obj, area, db, offset, bitOffset, bit) {
	global S7_WriteArea_func, S7WordLengthBit
	
	buf := bit
	bufPtr := &buf
	
	MsgBox, %bufPtr%
	return execute(DllCall(S7_WriteArea_func, "UInt", obj, "Int", area, "Int", db, "Int", offset * 8 + bitOffset, "Int", 1, "Int", S7WordLengthBit, "Ptr", &bufPtr))
}

PathCombine(abs, rel) {
    VarSetCapacity(dest, (A_IsUnicode ? 2 : 1) * 260, 1) ; MAX_PATH
    DllCall("Shlwapi.dll\PathCombine", "UInt", &dest, "UInt", &abs, "UInt", &rel)
    Return, dest
}

BEint(ByRef Var, ByRef BE, Bytes) {
	VarSetCapacity(BE, Bytes, 0)
	
	loop, %Bytes%
	{
		byte := NumGet(Var, Bytes-A_Index, "UChar")
		NumPut(byte, BE, A_Index-1, "UChar")
		
	}
	
	loop, %Bytes% {
		MsgBox, % NumGet(BE, A_index - 1, "UChar")
	}
}

execute(retn) {
	global g_lastError
	if(retn) {
		g_lastError = retn
	}
	
	return (retn == 0)
}

S7_GetLastError() {
	global g_lastError
	err := g_lastError
	g_lastError := 0
	return err
}