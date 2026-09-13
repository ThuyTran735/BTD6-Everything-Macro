#Requires AutoHotkey v2.0

#Include ..\Lib\FindText.ahk
#Include ..\Scripts\IncludeAll.ahk


TestRoundOCR() {
    global RoundDigits

    area := GetRoundArea()

    ok := FindText(
        &X,
        &Y,
        area.x1,
        area.y1,
        area.x2,
        area.y2,
        0.05,
        0.05,
        RoundDigits,
        1,
        1
    )

    if !ok {
        MsgBox("No digits found")
        return
    }

    ok := FindText().Sort(ok)
    result := FindText().Ocr(ok, 20, 20, 3)

    MsgBox(
        "OCR: " result.text
        "`nX: " result.x
        "`nY: " result.y
        "`nW: " result.w
        "`nH: " result.h
    )
}

Sleep(3000)
TestRoundOCR()