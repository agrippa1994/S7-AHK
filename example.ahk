#SingleInstance, Force
#Include S7.ahk

obj := S7_Create()
ret := S7_ConnectTo(obj, "10.0.0.7", 0, 2)
MsgBox %ret%

ret := S7_WriteBit(obj, 0x83, 0, 0, 1, 1)
error := S7_GetLastError()
MsgBox %ret% %error%
return