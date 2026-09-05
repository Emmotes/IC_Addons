;/*
;===========================================
;  FindText - Capture screen image into text and then find it
;  https://www.autohotkey.com/boards/viewtopic.php?f=6&t=17834
;
;  Author  : FeiYue
;  Version : 10.2
;  Date    : 2026-02-22
;
;  Usage:  (required AHK v1.1.34+)
;  1. Capture the image to text string.
;  2. Test find the text string on full Screen.
;  3. When test is successful, you may copy the code
;     and paste it into your own script.
;     Note: Copy the "FindText()" function and the following
;     functions and paste it into your own script Just once.
;  4. The more recommended way is to save the script as
;     "FindText.ahk" and copy it to the "Lib" subdirectory
;     of AHK program, instead of copying the "FindText()"
;     function and the following functions, add a line to
;     the beginning of your script: #Include <FindText>
;  5. If you want to call a method in the "FindTextClass" class,
;     use the parameterless FindText() to get the default object
;
;===========================================
;*/


if (!A_IsCompiled && A_LineFile=A_ScriptFullPath)
  FindText().Gui("Show")


;===== Copy The Following Functions To Your Own Code Just once =====


FindText(ByRef x:="", ByRef y:="", args*)
{
  static init, obj
  if !VarSetCapacity(init) && (init:="1")
    obj:=new FindTextClass()
  return !args.Length() ? obj : obj.FindText(x, y, args*)
}

Class FindTextClass
{  ;// Class Begin

Floor(i)
{
  if i is number
    return i+0
  else return 0
}

__New()
{
  this.bits:={ Scan0: 0, hBM: 0, oldzw: 0, oldzh: 0 }
  this.bind:={ id: 0, mode: 0, oldStyle: 0 }
  this.Lib:=[]
  this.Cursor:=0
}

__Delete()
{
  Try if (this.bits.hBM)
    DllCall("DeleteObject", "Ptr",this.bits.hBM)
}

New()
{
  return new FindTextClass()
}

help()
{
return "
(
;--------------------------------
;  FindText - Capture screen image into text and then find it
;  Version : 10.2  (2026-02-22)
;--------------------------------
;  returnArray:=FindText(
;      OutputX --> The name of the variable used to store the returned X coordinate
;    , OutputY --> The name of the variable used to store the returned Y coordinate
;    , X1 --> the search scope's upper left corner X coordinates
;    , Y1 --> the search scope's upper left corner Y coordinates
;    , X2 --> the search scope's lower right corner X coordinates
;    , Y2 --> the search scope's lower right corner Y coordinates
;    , err1 --> Fault tolerance percentage of text       (0.1=10%)
;    , err0 --> Fault tolerance percentage of background (0.1=10%)
;      Setting err1<0 or err0<0 can enable the left and right dilation algorithm
;      to ignore slight misalignment of text lines, the fault tolerance must be very small
;      In FindPic mode, err0 can set the number of rows and columns to be skipped
;    , Text --> can be a lot of text parsed into images, separated by '|'
;    , ScreenShot --> if the value is 0, the last screenshot will be used
;    , FindAll --> if the value is 0, Just find one result and return
;    , JoinText --> if you want to combine find, it can be 1, or an array of words to find
;    , offsetX --> Set the max text offset (X) for combination lookup
;    , offsetY --> Set the max text offset (Y) for combination lookup
;    , dir --> Nine directions for searching: up, down, left, right and center
;      Default dir=0, the returned result will be sorted by the smallest error,
;      Even if set a large fault tolerance, the first result still has the smallest error
;    , zoomW --> Zoom percentage of image width  (1.0=100%)
;    , zoomH --> Zoom percentage of image height (1.0=100%)
;  )
;
;  The function returns an Array containing all lookup results,
;  any result is a object with the following values:
;  {1:X, 2:Y, 3:W, 4:H, x:X+W//2, y:Y+H//2, id:Comment}
;  If no image is found, the function returns 0.
;  All coordinates are relative to Screen, colors are in RGB format
;  All 'RRGGBB' can use 'Black', 'White', 'Red', 'Green', 'Blue', 'Yellow'
;  All 'DRDGDB' can use similarity '1.0'(100%), it's floating-point number
;
;  If the return variable is set to 'ok', ok[1] is the first result found.
;  ok[1].1, ok[1].2 is the X, Y coordinate of the upper left corner of the found image,
;  ok[1].3, ok[1].4 is the width, height of the found image,
;  ok[1].x <==> ok[1].1+ok[1].3//2 ( is the Center X coordinate of the found image ),
;  ok[1].y <==> ok[1].2+ok[1].4//2 ( is the Center Y coordinate of the found image ),
;  ok[1].id is the comment text, which is included in the <> of its parameter.
;
;  If OutputX is equal to 'wait' or 'wait1'(appear), or 'wait0'(disappear)
;  it means using a loop to wait for the image to appear or disappear.
;  the OutputY is the wait time in seconds, time less than 0 means infinite waiting
;  OutputY can also add a stable time after finding: 'wait time, stable time'
;  Timeout means failure, return 0, and return other values means success
;  If you want to appear and the image is found, return the found array object
;  If you want to disappear and the image cannot be found, return 1
;  Example 1: FindText(X:='wait', Y:=3, 0,0,0,0,0,0,Text)   ; Wait 3 seconds for appear
;  Example 2: FindText(X:='wait0', Y:=-1, 0,0,0,0,0,0,Text) ; Wait indefinitely for disappear
;
;  <FindMultiColor> or <FindColor> : FindColor is FindMultiColor with only one point
;  Text:='|<>##DRDGDB $ 0/0/RRGGBB1-DRDGDB1/RRGGBB2, xn/yn/-RRGGBB3/RRGGBB4, ...'
;  Color behind '##' (0xDRDGDB) is the default allowed variation for all colors
;  Initial point (0,0) match 0xRRGGBB1(+/-0xDRDGDB1) or 0xRRGGBB2(+/-0xDRDGDB),
;  point (xn,yn) match not 0xRRGGBB3(+/-0xDRDGDB) and not 0xRRGGBB4(+/-0xDRDGDB)
;  A color group starting with '-' means all colors are excluded
;  Each point can take up to 10 sets of colors (xn/yn/RRGGBB1/.../RRGGBB10)
;
;  <FindShape> : Similar to FindMultiColor, just replacing the color with
;  whether the point is similar in color to the first point
;  Text:='|<>##DRDGDB $ 0/0/1, x1/y1/0, x2/y2/1, xn/yn/0, ...'
;
;  <FindPic> : Text parameter require manual input, Pic can use 'HBITMAP:*' handle
;  Text:='|<>##DRDGDB/RRGGBB1-DRDGDB1/RRGGBB2... $ d:\a.bmp'
;  Color behind '##' (0xDRDGDB) is the default allowed variation for all colors
;  the 0xRRGGBB1(+/-0xDRDGDB1) and 0xRRGGBB2(+/-0xDRDGDB) both transparent colors
;
;--------------------------------
)"
}

FindText(ByRef OutputX:="", ByRef OutputY:=""
  , x1:=0, y1:=0, x2:=0, y2:=0, err1:=0, err0:=0, text:=""
  , ScreenShot:=1, FindAll:=1, JoinText:=0, offsetX:=20, offsetY:=10
  , dir:=0, zoomW:=1, zoomH:=1)
{
  local
  if (OutputX ~= "i)^\s*wait[10]?\s*$")
  {
    found:=!InStr(OutputX,"0"), v:=StrSplit(OutputY ",", ",")
    , time:=this.Floor(v[1]), StableTime:=this.Floor(v[2])
    , timeout:=A_TickCount+Round(time*1000), OutputX:=""
    Loop
    {
      ok:=this.FindText(,, x1, y1, x2, y2, err1, err0, text, ScreenShot
        , FindAll, JoinText, offsetX, offsetY, dir, zoomW, zoomH)
      if (found && ok)
      {
        if (StableTime)
        {
          Sleep % StableTime*1000
          if !this.FindText(,, (v:=ok[1]).1, v.2, v.1+v.3-1, v.2+v.4-1, err1, err0
          , text, ScreenShot, FindAll, JoinText, offsetX, offsetY, dir, zoomW, zoomH)
            Continue
        }
        OutputX:=ok[1].x, OutputY:=ok[1].y, this.ok:=ok
        return ok
      }
      if (!found && !ok)
        return 1
      if (time>=0 && A_TickCount>=timeout)
        Break
      Sleep 50
    }
    return 0
  }
  SetBatchLines % (bch:=A_BatchLines)?"-1":"-1"
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy), x-=zx, y-=zy
  , this.ok:=0, info:=[]
  Loop Parse, text, |
    if IsObject(j:=this.PicInfo(A_LoopField))
      info.Push(j)
  if (w<1 || h<1 || !(num:=info.Length()) || !bits.Scan0)
  {
    SetBatchLines % bch
    return 0
  }
  arr:=[], info2:=[], k:=0, s:=""
  , mode:=(IsObject(JoinText) ? 2 : JoinText ? 1 : 0)
  For i,j in info
  {
    k:=Max(k, (j[7]=5 && j[8]!=2 ? j[9] : j[2]*j[3]))
    if (mode)
      v:=(mode=1 ? i : j[10]) . "", s.="|" v
      , (v!="") && ((!info2.HasKey(v) && info2[v]:=[]), info2[v].Push(j))
  }
  sx:=x, sy:=y, sw:=w, sh:=h, (mode=1 && JoinText:=[s])
  , allpos_max:=(FindAll || JoinText ? 10000:1)
  , VarSetCapacity(s1,k*4), VarSetCapacity(s0,k*4)
  , VarSetCapacity(ss,(sw+2)*(sh+4)), VarSetCapacity(allpos,allpos_max*8)
  , ini:={ sx:sx, sy:sy, sw:sw, sh:sh, zx:zx, zy:zy
  , mode:mode, bits:bits, ss:&ss, s1:&s1, s0:&s0
  , allpos:&allpos, allpos_max:allpos_max
  , err1:err1, err0:err0, zoomW:zoomW, zoomH:zoomH }
  Loop 2
  {
    if (err1=0 && err0=0) && (num>1 || A_Index>1)
      ini.err1:=err1:=0.05, ini.err0:=err0:=0.05
    if (!JoinText)
    {
      For i,j in info
      Loop % this.PicFind(ini, j, dir, sx, sy, sw, sh)
      {
        v:=NumGet(allpos,4*A_Index-4,"uint"), x:=(v&0xFFFF)+zx, y:=(v>>16)+zy
        , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH)
        , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:j[10]})
        if (!FindAll)
          Break 3
      }
    }
    else
    For k,v in JoinText
    {
      v:=StrSplit(Trim(RegExReplace(v, "\s*\|[|\s]*", "|"), "|")
      , (InStr(v,"|")?"|":""), " `t")
      , this.JoinText(arr, ini, info2, v, 1, offsetX, offsetY
      , FindAll, dir, 0, 0, 0, sx, sy, sw, sh)
      if (!FindAll && arr.Length())
        Break 2
    }
    if (err1!=0 || err0!=0 || arr.Length() || info[1][4] || info[1][7]=5)
      Break
  }
  SetBatchLines % bch
  if (arr.Length())
  {
    OutputX:=arr[1].x, OutputY:=arr[1].y, this.ok:=arr
    return arr
  }
  return 0
}

; the join text object use [ "abc", "xyz", "a1|a2|a3" ]

JoinText(arr, ini, info2, text, index, offsetX, offsetY
  , FindAll, dir, minX, minY, maxY, sx, sy, sw, sh)
{
  local
  if !(Len:=text.Length()) || !info2.HasKey(key:=text[index])
    return 0
  zoomW:=ini.zoomW, zoomH:=ini.zoomH, mode:=ini.mode
  For i,j in info2[key]
  if (mode!=2 || key==j[10])
  Loop % ok:=this.PicFind(ini, j, dir, sx, sy, (index=1 ? sw
  : Min(sx+offsetX+Floor(j[2]*zoomW),ini.sx+ini.sw)-sx), sh)
  {
    if (A_Index=1)
    {
      pos:=[], p:=ini.allpos-4
      Loop % ok
        pos.Push(NumGet(0|p+=4,"uint"))
    }
    v:=pos[A_Index], x:=v&0xFFFF, y:=v>>16
    , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH)
    , (index=1 && (minX:=x, minY:=y, maxY:=y+h))
    , minY1:=Min(y, minY), maxY1:=Max(y+h, maxY), sx1:=x+w
    if (index<Len)
    {
      sy1:=Max(minY1-offsetY, ini.sy)
      , sh1:=Min(maxY1+offsetY, ini.sy+ini.sh)-sy1
      if this.JoinText(arr, ini, info2, text, index+1, offsetX, offsetY
      , FindAll, 5, minX, minY1, maxY1, sx1, sy1, 0, sh1)
      && (index>1 || !FindAll)
        return 1
    }
    else
    {
      comment:=""
      For k,v in text
        comment.=(mode=2 ? v : info2[v][1][10])
      x:=minX+ini.zx, y:=minY1+ini.zy, w:=sx1-minX, h:=maxY1-minY1
      , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:comment})
      if (index>1 || !FindAll)
        return 1
    }
  }
  return 0
}

PicFind(ini, j, dir, sx, sy, sw, sh)
{
  local
  static init, MyFunc
  if !VarSetCapacity(init) && (init:="1")
  {
    x32:="VVdWU4HsmAAAAIuEJAABAACLtCQEAQAAg7wkrAAAAAWNBLCJRCRAD4QqBQAAi4Qk"
    . "8AAAAIXAD46wEQAAMf@HRCQIAAAAADHtiTwki7wk7AAAAMdEJBgAAAAAx0QkDAAA"
    . "AACLhCToAAAAi0wkDDH2MdsByIX@iUQkBH876Y4AAAAPr4Qk1AAAAInBifCZ9@8B"
    . "wYtEJASAPBgxdEyLhCTkAAAAg8MBA7QkCAEAAIkMqIPFATnfdFSLBCSZ97wk8AAA"
    . "AIO8JKwAAAAEdbUPr4QkwAAAAInBifCZ9@+NDIGLRCQEgDwYMXW0i0QkGIuUJOAA"
    . "AACDwwEDtCQIAQAAiQyCg8ABOd+JRCQYdawBfCQMg0QkCAGLjCQMAQAAi0QkCAEM"
    . "JDmEJPAAAAAPhTT@@@+LRCQYiWwkOA+vhCT0AAAAwfgKiUQkMIuEJPgAAAAPr8XB"
    . "+AqJRCREg7wkrAAAAAQPhPQEAACLhCTcAAAAA4Qk1AAAAIu0JMwAAACJRCQoi4Qk"
    . "wAAAAA+vhCTQAAAAjSywi4Qk1AAAAIu0JMAAAAD32IO8JKwAAAABjQSGiUQkNA+E"
    . "7wQAAIO8JKwAAAACD4TnCQAAg7wkrAAAAAMPhH0NAACLrCT8AAAAhe0PhWYHAACL"
    . "RCQoiYQk3AAAAIt0JBiLTCQwuAAAAAA5zg9Pxot0JEQ5dCQ4iUQkGH8Ix0QkOAAA"
    . "AACLvCTUAAAAi6wk2AAAACu8JAgBAAArrCQMAQAAg7wkuAAAAAkPhJQAAACLhCS4"
    . "AAAAg+gBg@gHD4flAgAAg@gDiUQkXA+O4AIAAMdEJEwAAAAAx0QkDAAAAAA7fCRM"
    . "x0QkVAAAAAAPjOAAAAA7bCRUD4yvEAAAi0wkTIt0JFyJ+CnI98YCAAAAD0TBi0wk"
    . "VInCiegpyPfGAQAAAA9EwYP+A4nRD0@ID0@CiUwkCIlEJATpfA8AAJCNtCYAAAAA"
    . "ifiNVQHHRCRwAAAAAMHoH8dEJGwBAAAAx0QkWAAAAAAB+MdEJGQAAAAAx0QkDAAA"
    . "AADR+IlEJASJ6MHoHwHo0fiJRCQIjUcBicYPr@I50A9MwoPACIm0JIgAAACJxg+v"
    . "8Im0JIwAAACLtCSIAAAAOXQkcH0Zi7QkjAAAADl0JGTHRCRoAAAAAA+MuQUAAIuc"
    . "JAABAACF2w+EKwgAAIuEJAwBAAAPr4QkCAEAAIP4AQ+EEwgAAIuMJLgAAACFyQ+F"
    . "cAEAAItEJAyD+AEPjmMBAACLdCRAi5wkAAEAAIPoATHtiUQkEMdEJAQAAAAAiSwk"
    . "jX4Ei0QkBIsMJIs3i0QDBIXJiUQkCInIeDeLT@w5zg+DmQgAAIn6jWv86w6NdCYA"
    . "g+oEi0r8Oc5zF4kKi0yFBIlMgwSD6AGD+P915Lj@@@@@i0wkQIPAAYMEJAGDxwSD"
    . "RCQEBIk0gYt0JAiJNIOLBCQ7RCQQdYyLhCQIAQAAD6@AwfgCicWLhCQMAQAAD6@A"
    . "wfgCiUQkBIu0JAABAADHRCQIAAAAADHAkI20JgAAAACLfCQIiwy+iUwkEA+3+cHp"
    . "EIXAiQwkdC0x2422AAAAAIsMng+30Sn6D6@SOep9D8HpECsMJA+vyTtMJAR8EYPD"
    . "ATnDdduLfCQQiTyGg8ABg0QkCAGLfCQIO3wkDHWigcSYAAAAW15fXcJkAItEJAw5"
    . "hCQEAQAAD4@vDQAAi4QkDAEAAA+vhCQIAQAAg@gBD4SUBgAAi4QkCAEAAItUJAwP"
    . "r8DB+AKJxYuEJAwBAAAPr8DB+AKJRCQEMcCF0g+PJf@@@+uax0QkXAAAAACJ6MdE"
    . "JEwAAAAAif3HRCQMAAAAAInH6RX9@@8xwIO8JLAAAAACD5TAiUQkdA+EGAcAADHA"
    . "g7wksAAAAAEPlMCJRCR4i4QktAAAAIXAD4RDDwAAi7Qk4AAAAIuMJLQAAAAx7Yuc"
    . "JOgAAACLvCTkAAAAjQSOiUQkBIsLg8YEg8NYg8cEicjB6BAPr4QkDAEAAJn3vCTw"
    . "AAAAD6+EJMAAAACJBCQPt8EPr4QkCAEAAJn3vCTsAAAAixQkjQSCiUb8i0OsjURF"
    . "AIPFFolH@Dt0JAR1pouEJLQAAACJjCSwAAAAiUQkGIuEJPQAAAAPr4QktAAAAMH4"
    . "ColEJDCLhCToAAAAx0QkRAAAAADHRCQ4AAAAAIPACIlEJBDpkvv@@4uEJLAAAADB"
    . "6BAPr4QkDAEAAJn3vCTwAAAAD6+EJMAAAACJwQ+3hCSwAAAAD6+EJAgBAACZ97wk"
    . "7AAAAI0EgYmEJLAAAADpR@v@@4uEJPAAAADRpCS0AAAAD6+EJOwAAAADhCToAAAA"
    . "gTj@@@8AiUQkEA+WwA+2wIlEJCSLhCTYAAAAhcAPju36@@+LhCTUAAAAieqLbCQQ"
    . "x0QkLAAAAADHRCQ8AAAAAMHgAolEJFAxwIu8JNQAAACF@w+OKAEAAIu0JLwAAAAB"
    . "1gNUJFCJdCQUi3QkKAN0JDyJVCRIA5QkvAAAAIl0JByJVCQgi3wkFA+2dwIPtk8B"
    . "D7Y@iTQkiUwkBDH2iXwkCDm0JLQAAAAPhpkAAACLXLUAg8YCi0y1@InYD7bXD7bb"
    . "wegQK1QkBInfD7bAK3wkCCsEJIH5@@@@P3c4ixwkD6@SjRxYweILiVwkDIHDAAQA"
    . "AA+v2A+vw40cELj+BQAAK0QkDA+vxw+vxwHYOcFzMjHA642Jy8HrEA+22w+vwA+v"
    . "2znYd+oPtt0Pr9IPr9s52nfdD7bJifgPr8cPr8k5yHfOuAEAAAA7RCQki3QkHA+U"
    . "woNEJBQEg8YBg8IBi0wkFIhW@zlMJCCJdCQcD4UT@@@@i7wk1AAAAAF8JDyLVCRI"
    . "g0QkLAEDVCQ0i3QkLDm0JNgAAAAPha@+@@+LhCT8AAAAhcAPhHb5@@+DhCTMAAAA"
    . "AYuEJNQAAAAx7ccEJAAAAACJbCQEjXj@icaNtgAAAACF9n5Ni0QkBItcJCgxyYus"
    . "JNwAAAAx0gHDAcUPtgPrEoXJD7ZDAQ+EQA0AAA+2E4PDAQnQOfkPhBoMAAAPtlMB"
    . "CdCIRA0Ag8EBOc510wF0JASDBCQBiwQkOYQk2AAAAH+f6fT4@@+J+InvicWLdCRY"
    . "hfYPhRMKAACDbCQIAYNEJGgBg0QkZAGLVCRsOVQkaA+M7AgAAIt0JFiJ8IPgAQHC"
    . "ifCDwAGJVCRsg+ADiUQkWOnz+f@@i7wk2AAAAIOEJMwAAAABhf8PjxX@@@@pifj@"
    . "@4tcJHSJRCQohdsPhZILAACLRCQQi0wkFDHSiUQkNItEJDCFyYkEJA+EhQEAAIl8"
    . "JCCJbCQcideLtCTgAAAAi0QkKAMEvou0JLwAAAAPtnQGAol0JEiLtCS8AAAAD7ZM"
    . "BgEPtgQGa@cWiXQkJIt0JDSITCRQiEQkYImEJJQAAACLFon1D7bxibQkkAAAAIlU"
    . "JCyLlCTkAAAAixS6iZQktAAAAOs3jTRxD6@AifKBxgAEAAAPr@HB4AsPr86LdCQ8"
    . "AcG4@gUAACnQD6@GD6@GAcg5ww+DpAAAAIPFCItEJCQ7hCS0AAAAD4OjCgAAi0Qk"
    . "eINEJCQCi1UAi10EhcB0D4X@D4SbCwAAi5QksAAAAInRD7bGi3QkSA+20iuUJJQA"
    . "AADB6RAPtskrhCSQAAAAKfGB+@@@@z+JVCQ8D4Zk@@@@id7B7hCJ8g+28g+vyQ+v"
    . "9jnxd4QPts8Pr8APr8k5yA+Hc@@@@4tEJDwPttsPr9uJwg+v0DnaD4dc@@@@gXwk"
    . "LP@@@wB2EoX@D4TVCQAAgywkAQ+IywkAAIPHAYNEJDRYOXwkFA+Fjf7@@4tsJByL"
    . "fCQgi4QkAAEAAINEJAwBi3QkDIXAD4SwBwAAi1QkCAOUJNAAAACNjv@@@z+LRCQE"
    . "A4QkzAAAAMHiEAnQi5QkAAEAAIkEiouEJLgAAACFwA+Fdvn@@4tEJDArBCQ5tCQE"
    . "AQAAi1QkQIkEig+PaQcAAIuEJAwBAAAPr4QkCAEAAIP4AQ+F@Pf@@4tEJAyBxJgA"
    . "AABbXl9dwmQAi4QksAAAAIu0JNgAAADHBCQAAAAAx0QkBAAAAACDwAHB4AeJhCSw"
    . "AAAAi4Qk1AAAAMHgAoX2iUQkDInoi6wksAAAAA+O3vX@@4ucJNQAAACF235ki4wk"
    . "vAAAAItcJCiLvCS8AAAAA1wkBAHBA0QkDIlEJAgBx5APtlECD7ZBAQ+2MWvAS2vS"
    . "JgHCifDB4AQp8AHQOegZwIPBBIPDAffQg8ACiEP@Ofl1zouUJNQAAAABVCQEi0Qk"
    . "CIMEJAEDRCQ0izQkObQk2AAAAA+Fef@@@+nc+@@@iwQk6Yv3@@+LhCTwAAAAi7Qk"
    . "6AAAAA+vhCTsAAAA0aQktAAAAMdEJDABAAAAjQSGicaJRCQQi4Qk+AAAAMH4CoPA"
    . "AYO8JLQAAAACiUQkLHYRgX4I@@@@AA+WwA+2wIlEJDCLRCQQi0AEicIPtswPtsDB"
    . "6hAPttKJ1g+v8ol0JHyJzg+v8Ym0JIAAAACJxg+v8IuEJPAAAACFwIm0JIQAAAAP"
    . "jroIAACLdCQsi4QkDAEAADHtx0QkPAAAAADHRCQYAAAAAA+vxolEJFCLhCTsAAAA"
    . "D6@GweACiUQkYIuEJOgAAACDwAKJRCREifCNNLUAAAAAiXQkOInGD6+EJAgBAACJ"
    . "dCRIiUQkNIuEJOwAAACFwA+OhwEAAItEJETHRCQgAAAAAIlEJBSLRCQsiUQkHGaQ"
    . "i0QkFA+2MIl0JASJxg+2QP8Ptk7+vgIAAACIRCQkiUQkCA+2wYhMJCiJRCQMjXYA"
    . "ObQktAAAAA+GmwAAAItMJBCLfCQEiwSxg8YCi1yx@InCD7bMK0wkCMHqEA+2wCtE"
    . "JAwPttIp+oH7@@@@P4kMJHcujSx6D6@Jjb0ABAAAD6@6weELD6@XAcq5@gUAACnp"
    . "D6@ID6@BAdA5w3M3Me3rkInfwe8QifkPtvkPr9IPr@85+nfoixQkD7b@D6@@idEP"
    . "r8o5+XfWD7bbD6@AD6@bOdh3yb0BAAAAO2wkMHRji0QkPIt0JBiLvCTgAAAAmY0c"
    . "tQAAAAD3vCTwAAAAD6+EJMAAAACJwYtEJCCZ97wk7AAAAItUJATB4hCNBIGJBLcP"
    . "tkQkJIPGAYl0JBiLtCTkAAAAweAICdAPtlQkKAnQiQQei3QkHItEJCyLfCQ4i0wk"
    . "NAF8JBQBTCQgAfA5tCTsAAAAfgmJRCQc6ZP+@@+LdCRIi0QkLItUJFCLTCRgAVQk"
    . "PAFMJEQB8Dm0JPAAAAAPjq8DAACJRCRI6Tr+@@8rrCTAAAAAi0QkKAOEJNQAAACJ"
    . "RCQUjUX8iUQkCItEJDSD6AiJRCQgi4Qk1AAAAIPAAolEJByLhCTQAAAAg+gBicaJ"
    . "BCSLhCTQAAAAA4Qk2AAAADnGD48fAQAAi7QkzAAAAIPAAcdEJAwAAAAAiUQkJIuE"
    . "JNQAAACD7gGJdCQsi7QkzAAAAAHwi7Qk1AAAAIlEJDSNeAErhCTMAAAAjTS1CAAA"
    . "AIPAAol0JDyJRCRIi0QkLIt0JDQ58A+PogAAAInBiwQki3QkDCu0JMwAAACLXCQI"
    . "A3QkFAOcJLwAAAD30MHoH4lEJATrVI12AI28JwAAAAA5jCTEAAAAfkWAfCQEAHQ+"
    . "iwQkOYQkyAAAAH4yD7ZTAg+2QwGDwwQPtmv8a8BLa9ImAcKJ6MHgBCnoAdDB6AeI"
    . "RA4Bg8EBOc90FIXJebIxwIPDBIhEDgGDwQE5z3Xsi3QkPAF0JAiLdCRIAXQkDIME"
    . "JAGLVCQgiwQkAVQkCDlEJCQPhTX@@@+LjCTYAAAAhckPjvrw@@+LhCTYAAAAi2wk"
    . "FANsJBzHRCQIAQAAAMdEJAwAAAAAg8ABiUQkFIuEJNQAAACJbCQEg8AEiUQkIIuE"
    . "JLQAAACLlCTUAAAAhdIPjqEAAACLVCQEi1wkKIt0JCADXCQMidErjCTUAAAAAdaJ"
    . "DCQPtkIBD7YqvwIAAAADhCSwAAAAOehyRw+2agI56HI@iwwkD7Zp@jnocjQPtmn@"
    . "OehyLA+2KTnociUPtm7+OehyHQ+2bv856HIVD7Y+OfgZ@@fXg8cCifaNvCcAAAAA"
    . "ifmDBCQBg8IBiAuDxgGDwwGLPCQ5fCQEdYiLvCTUAAAAAXwkDINEJAgBi0wkHIt0"
    . "JAgBTCQEOXQkFA+FNf@@@4mEJLQAAADpbvb@@8dEJEQAAAAAx0QkMAAAAADHRCQ4"
    . "AAAAAMdEJBgAAAAA6UXv@@+LRCQEhcAPiN@2@@85+A+P1@b@@4tEJAiFwA+Iy@b@"
    . "@znoD4@D9v@@g0QkcAGJ6In9iceLdCQ4i0QkGDnGD03Gg7wkrAAAAAOJxolEJBSL"
    . "RCQID4@nAAAAD6+EJNQAAAADRCQEhfYPhEwDAAADhCTcAAAAi3QkMDHSi1wkRIk0"
    . "JInB6yk5VCQ4fhaLtCTkAAAAiwSWAcj2AAF1BYPrAXgqg8IBOVQkFA+EVfj@@zlU"
    . "JBh+0Yu0JOAAAACLBJYByIA4AXfAgywkAXm6g7wkuAAAAAkPhA32@@+DRCRUAemL"
    . "7@@@i0QkGMdEJEQAAAAAD6+EJPQAAADHRCQ4AAAAAMH4ColEJDDpz+7@@4N8JFgB"
    . "dB+DfCRYAg+EqAIAAINsJAQB6db1@@+DRCRMAekr7@@@g0QkBAHpwvX@@5CNdCYA"
    . "A4Qk0AAAAItUJAQPr4QkwAAAAAOUJMwAAACDvCSsAAAABY0EkA+E5vX@@4lEJCQD"
    . "hCSwAAAAi7QkvAAAAA+2dAYCiXQkKIu0JLwAAAAPtnQGAYl0JCyLtCS8AAAAD7YE"
    . "BolEJDSLRCQUhcAPhAgCAACLRCREiWwkHIn1iXwkIIlEJDyLRCQwiQQkMcCJx+t1"
    . "OXwkOH5ii4Qk5AAAAItUJCSLXCQoAxS4D7ZMFQIPtkQVAStEJCwPtlQVACtUJDSJ"
    . "zgHZKd6NmQAEAAAPr8APr97B4AsPr94Bw7j+BQAAKcgPr8IPr8IB2DmEJLQAAABy"
    . "B4NsJDwBeHyDxwE5fCQUD4S29v@@OXwkGH6Fi4Qk4AAAAItUJCSLXCQoAxS4D7ZM"
    . "FQIPtkQVAStEJCwPtlQVACtUJDSJzgHZKd6NmQAEAAAPr8APr97B4AsPr94Bw7j+"
    . "BQAAKcgPr8IPr8IB2DmEJLQAAAAPgyb@@@+DLCQBD4kc@@@@i2wkHIt8JCDpCv7@"
    . "@8dEJDAAAAAAx0QkGAAAAADpT@H@@zHS6ePz@@+NdgCBfCQs@@@@AA+H+@X@@+nk"
    . "9f@@i1QkFItEJDCF0okEJA+E@fX@@zHb6xONtgAAAACDwwE5XCQUD4SQAAAAi7Qk"
    . "4AAAAItEJCgDBJ6LtCTkAAAAiwyei7QkvAAAAA+2dAYCicrB6hAp1ouUJLwAAAAP"
    . "r@Y7dCR8D7ZUAgGIVCQci5QkvAAAAA+2BAJ@Kw+2VCQcD7b1KfIPr9I7lCSAAAAA"
    . "fxUPttEp0A+vwDuEJIQAAAAPjnn@@@+DLCQBD4lv@@@@iYwksAAAAOke@f@@iYwk"
    . "sAAAAOlK9f@@i0QkMIkEJOk+9f@@g0QkCAHpLvP@@8dEJDAAAAAAx0QkRAAAAADH"
    . "RCQYAAAAAOkO7P@@MdLpvPL@@w+2VCRQi0QkSMHgEMHiCAnQD7ZUJGAJ0ImEJLAA"
    . "AADp0vT@@5CQkJCQkJCQkA=="
    x64:="QVdBVkFVQVRVV1ZTSIHsqAAAAEhjhCSgAQAASIu0JJgBAACD+QWJjCTwAAAAiZQk"
    . "+AAAAEWJxESJjCQIAQAATIu0JGgBAACLrCRwAQAAi7wkeAEAAEiNBIZIiUQkUA+E"
    . "EQUAAIX@D44TEQAAMdsx9kyJtCRoAQAAiRwkiXQkFDHAi5wk8AAAAESLrCRAAQAA"
    . "RTHSTIu0JGABAACLtCSoAQAARTH@RImEJAABAABBicRMY1wkFEUxyUUxwEwDnCRo"
    . "AQAAhe1@Net6Dx+AAAAAAEEPr8WJwUSJyJn3@QHBQ4A8AzF0PEmDwAFJY8dBAfFB"
    . "g8cBRDnFQYkMhn5DRInQmff@g@sEdckPr4QkGAEAAInBRInImff9Q4A8AzGNDIF1"
    . "xEiLlCRYAQAASYPAAUljxEEB8UGDxAFEOcWJDIJ@vQFsJBSDBCQBRAOUJLABAACL"
    . "BCQ5xw+FVv@@@0SJ4ESJZCQUTIu0JGgBAAAPr4QkgAEAAESLpCQAAQAAwfgKiUQk"
    . "OIuEJIgBAABBD6@HwfgKiUQkQIO8JPAAAAAED4TIBAAATGOsJEABAACLtCQwAQAA"
    . "TInoSAOEJFABAABIiUQkKIuEJBgBAAAPr4QkOAEAAI0EsIu0JBgBAACJRCQgi4Qk"
    . "QAEAAPfYg7wk8AAAAAGNBIaJRCQwD4SvBAAAg7wk8AAAAAIPhJQJAACDvCTwAAAA"
    . "Aw+E8gwAAIuUJJABAACF0g+FHgcAAEiLRCQoSImEJFABAACLfCQUi3QkOLgAAAAA"
    . "OfcPT8dEO3wkQIlEJBR@A0Ux@0SLtCRAAQAARIuUJEgBAABEK7QkqAEAAEQrlCSw"
    . "AQAAg7wkCAEAAAkPhI8AAACLhCQIAQAAg+gBg@gHD4e8AgAAg@gDiUQkYA+OtwIA"
    . "AMdEJEgAAAAAxwQkAAAAAEQ7dCRIx0QkWAAAAAAPjN0AAABEO1QkWA+M+A8AAIt0"
    . "JEiLfCRgRInwKfBA9scCD0TGi3QkWInCRInQidUp8ED2xwEPRMaD@wMPT+gPT8JB"
    . "icXpyQ4AAGYPH4QAAAAAAESJ8EGNUgHHRCR8AAAAAMHoH8dEJHgBAAAAx0QkXAAA"
    . "AABEAfDHRCRwAAAAAMcEJAAAAADR+EGJxUSJ0MHoH0QB0NH4icVBjUYBiccPr@o5"
    . "0A9MwoPACIm8JJQAAACJxw+v+Im8JJgAAACLvCSUAAAAOXwkfH0Zi7wkmAAAADl8"
    . "JHDHRCR0AAAAAA+MdgUAAEiDvCSYAQAAAA+E5gcAAIuEJLABAAAPr4QkqAEAAIP4"
    . "AQ+EzgcAAIuMJAgBAACFyQ+FRQEAAIsEJIP4AQ+OOQEAAIPoAkyLRCRQTIucJJgB"
    . "AABIjRyFBAAAAEUxyUUx0kOLdAgEQ4sUCESJ0UOLfAsETInQOdZyFOlJCAAADx8A"
    . "SIPoAUGLFIA51nMdQYlUgARBixSDg+kBg@n@QYlUgwR13kjHwP@@@@9Jg8EESIPA"
    . "AUmDwgFJOdlBiTSAQYk8g3WeRIuMJKgBAABEi5wksAEAAEUPr8lFD6@bQcH5AkHB"
    . "+wJEiyQkTIuUJJgBAAAx9jHAQYsssonvD7fdwe8QhcB0KkUxwEOLDIIPt9Ep2g+v"
    . "0kQ5yn0NwekQKfkPr8lBOct@E0mDwAFEOcB@2Uhj0IPAAUGJLJJIg8YBQTn0f7NI"
    . "gcSoAAAAW15fXUFcQV1BXkFfw4sEJDmEJKABAAAPj20NAACLhCSwAQAAD6+EJKgB"
    . "AACD+AEPhHoGAABEi4wkqAEAAESLnCSwAQAAMcCLFCRFD6@JRQ+v20HB+QJBwfsC"
    . "hdIPjzr@@@@rlWYPH0QAAMdEJGAAAAAARInQx0QkSAAAAABFifLHBCQAAAAAQYnG"
    . "6Tv9@@8xwIO8JPgAAAACD5TAiYQkgAAAAA+E3wYAADHAg7wk+AAAAAEPlMBFhcCJ"
    . "hCSEAAAAD4TkDgAATYnxTIm0JGgBAACLnCQYAQAASIu0JFgBAABMi6wkYAEAAEUx"
    . "wESLtCSoAQAARIu8JLABAABFMdJFixlJg8FYRInYwegQQQ+vx5n3@w+vw4nBQQ+3"
    . "w0EPr8aZ9@2NBIFCiQSGQYtBrEGNBEJBg8IWQ4lEhQBJg8ABRTnEd7uLhCSAAQAA"
    . "TIu0JGgBAABEiZwk+AAAAESJZCQUQQ+vxMH4ColEJDhJjUYIx0QkQAAAAABFMf9I"
    . "iUQkCOnK+@@@i4Qk+AAAAMHoEA+vhCSwAQAAmff@D6+EJBgBAACJwQ+3hCT4AAAA"
    . "D6+EJKgBAACZ9@2NBIGJhCT4AAAA6Yn7@@+J+EUB5ESLnCRIAQAAD6@FSJhMAfCB"
    . "OP@@@wBIiUQkCA+WwEWF2w+2wIlEJBgPjjr7@@+LvCRAAQAAx0QkJAAAAAAxwMdE"
    . "JDwAAAAAQb7+BQAARIl8JGTB5wKJfCRMRIuUJEABAABFhdIPjhwBAABIY1QkIEiL"
    . "vCQQAQAARTH@TI1sFwJIY1QkPEgDVCQoSIkUJA8fQABBD7Z1AEyLTCQIRTHbQQ+2"
    . "bf9BD7Z9@us@Dx+AAAAAAESNBHAPr8lFjZAABAAARA+v0MHhC0EPr8IBwUSJ8EQp"
    . "wEGJwEQPr8JBD6@QAco503NjSYPBCDHARTnjc11BixFBi1kEQYPDAonQD7bOD7bS"
    . "wegQKekp+g+2wCnwgfv@@@8@dpxBidhBwegQRQ+2wA+vwEUPr8BEOcB3tw+2xw+v"
    . "yQ+vwDnBd6oPttsPr9IPr9s52neduAEAAAA7RCQYSIs8JA+UwkmDxQSDwgFCiBQ@"
    . "SYPHAUQ5vCRAAQAAD48e@@@@i3QkTAF0JCCLtCRAAQAAAXQkPINEJCQBi1wkMIt8"
    . "JCQBXCQgObwkSAEAAA+Ftf7@@0SLfCRki4QkkAEAAIXAD4S@+f@@g4QkMAEAAAGL"
    . "hCRAAQAASIt8JChFMduLrCRIAQAATIusJFABAAAx20SNUP+JxoX2fk1IY9MxyQ+2"
    . "BBdNjUwVAEyNRBcBMdLrGYXJQQ+2AA+E8wwAAEEPtlD@SYPBAUmDwAEJ0EQ50Q+E"
    . "0QsAAEEPthCDwQEJ0DnOQYgBdcwB80GDwwFEOd1@puk@+f@@RInwRYnWQYnCi0Qk"
    . "XIXAD4WiCQAAg+0Bg0QkdAGDRCRwAYt0JHg5dCR0D4x7CAAAi3wkXIn4g+ABAcaJ"
    . "+IPAAYl0JHiD4AOJRCRc6Tb6@@+LhCRIAQAAg4QkMAEAAAGFwA+PFP@@@+nT+P@@"
    . "jQSQiUQkJIuEJIAAAACFwA+FTQsAAEiLRCQIRTHbi3wkOEiJRCQwi0QkGIXAD4R4"
    . "AQAARIlUJCBIi7QkWAEAAItEJCRIi4wkEAEAAEiLnCQQAQAARWvTFkIDBJ5Ii7Qk"
    . "EAEAAI1QAkhj0g+2NBaNUAFImA+2BAFIi0wkMEhj0g+2HBOLEUmJyYhEJEyJhCSc"
    . "AAAAiVQkKEiLlCRgAQAAiFwkPIlcJGhGiySa6z1EjQRxD6@ARIlEJGRBgcAABAAA"
    . "RA+vwcHgC0EPr8gByLn+BQAAK0wkZA+vyg+v0QHQOcMPg48AAABJg8EIRTniD4Nd"
    . "CgAAi4QkhAAAAEGDwgJBixFBi1kEhcB0EE2F2w+ERAsAAIuUJPgAAACJ0Q+2xg+2"
    . "0sHpECtEJGgrlCScAAAAD7bJKfGB+@@@@z8Phm3@@@9BidhBwegQRQ+2wA+vyUUP"
    . "r8BEOcF3jw+2zw+vwA+vyTnId4IPttsPr9IPr9s52g+Hcf@@@4F8JCj@@@8AdhJN"
    . "hdsPhJwJAACD7wEPiJMJAABJg8MBSINEJDBYRDlcJBgPj5L+@@9Ei1QkIIMEJAFI"
    . "g7wkmAEAAACLNCQPhE8HAABIY8aLlCQ4AQAARIuEJAgBAABIjQyFAAAAAIuEJDAB"
    . "AABIi5wkmAEAAAHqweIQRAHoCdBFhcCJRAv8D4WS+f@@i0QkOCn4ObQkoAEAAEiL"
    . "fCRQiUQP@A+PAQcAAIuEJLABAAAPr4QkqAEAAIP4AQ+FQfj@@4sEJOlC+f@@i4Qk"
    . "+AAAAESLjCRIAQAARTHbMduDwAHB4AdFhcmJhCT4AAAAi4QkQAEAAI00hQAAAAAP"
    . "jkL2@@9Ei2wkIIusJPgAAABMi7QkEAEAAIu8JEABAACF@35aTGPTTANUJChJY8VJ"
    . "jUwGAkUxwGYPH4QAAAAAAA+2EQ+2Qf9ED7ZJ@mvAS2vSJgHCRInIweAERCnIAdA5"
    . "6BnASIPBBPfQg8ACQ4gEAkmDwAFEOcd@x0EB9QH7QYPDAUQDbCQwRDmcJEgBAAB1"
    . "j+ny+@@@TInQ6dv3@@+J+EUB5MdEJCQBAAAAD6@FweACSJhMAfBIicZIiUQkCIuE"
    . "JIgBAADB+AqDwAFBg@wCiUQkIHYRgX4I@@@@AA+WwA+2wIlEJCRIi0QkCItABInC"
    . "D7bMD7bAweoQD7bSidYPr@KJtCSIAAAAic4Pr@GJtCSMAAAAicYPr@CF@4m0JJAA"
    . "AAAPjpoIAACLdCQgi4QksAEAADHJTIl0JEDHRCQ8AAAAAMdEJBQAAAAAiawkcAEA"
    . "AA+vxol0JEyJvCR4AQAAiUQkZInwD6@FweACSJhIiUQkaInwweACSJhIiUQkKIuE"
    . "JKgBAAAPr8aJRCQ4SItEJAhIg8AISIlEJDCLnCRwAQAAhdsPjl4BAACLRCQgTIts"
    . "JEDHBCQAAAAAicUPH0QAAEUPtn0BRQ+2dQBBuwIAAABBD7Z1AkyLTCQwRIn@RIh0"
    . "JBjrOkSNBHAPr8lFjZAABAAARA+v0MHhC0EPr8IBwbj+BQAARCnAQYnARA+vwkEP"
    . "r9AByjnTc2VJg8EIMclFOdx2X0GLEUGLWQRBg8MCidAPts4PttLB6BBEKflEKfIP"
    . "tsAp8IH7@@@@P3aYQYnYQcHoEEUPtsAPr8BFD6@ARDnAd7UPtscPr8kPr8A5wXeo"
    . "D7bbD6@SD6@bOdp3m7kBAAAAO0wkJHRdi0QkPItcJBTB5wjB5hAJ@g+2fCQYmUxj"
    . "y@e8JHgBAAAJ@g+vhCQYAQAAQYnAiwQkmfe8JHABAABIi5QkWAEAAEGNBIBCiQSK"
    . "idiDwAGJRCQUSIuEJGABAABCiTSIi0QkIEwDbCQoi3QkOAE0JAHoOawkcAEAAH4H"
    . "icXpuf7@@4t8JEyLRCQgi1wkZAFcJDxIi1wkaEgBXCRAAfg5vCR4AQAAD46IAwAA"
    . "iUQkTOlh@v@@SItEJChMAehIiQQki0QkICuEJBgBAACNePyLRCQwg+gIiUQkGIuE"
    . "JEABAACDwAKJRCRMi4QkOAEAAI1w@wOEJEgBAAA5xg+P@AAAAIPAAYucJDABAABE"
    . "iXwkZIlEJCCLhCRAAQAARTH2RIucJCABAABEi7wkKAEAAI1r@0yJbCRoAdiLnCRA"
    . "AQAAiUQkJESNUAErhCQwAQAAjRydCAAAAIPAAolcJDCJRCQ8O2wkJH98SIucJBAB"
    . "AABIY8dNY8aJ6UwDBCRMjUwDAonz99PB6x@rSQ8fQABBOct+RITbdEBBOfd+O0EP"
    . "thFBD7ZB@0UPtmn+a8BLa9ImAcJEiejB4AREKegB0MHoB4PBAUGIAEmDwQRJg8AB"
    . "RDnRdAiFyXm3McDr5QN8JDBEA3QkPIPGAQN8JBg5dCQgD4Vt@@@@RIt8JGRMi2wk"
    . "aESLhCRIAQAARYXAD4618f@@SGNsJExIiwQkTY11A0SJfCQgRIu8JPgAAAC+AQAA"
    . "ADH@SffVSI1cKAGLhCRIAQAAg8ABiQQki4QkQAEAAIPoAUiDwAFIiUQkGIuMJEAB"
    . "AACFyQ+OrAAAAEiLRCQYSGPXSANUJChNjQQeSY1MHQBMjRwYSInYZg8fhAAAAAAA"
    . "RA+2IEQPtlD@QbkCAAAARQH8RTnUckxED7ZQAUU51HJCRA+2Uf5FOdRyOEQPtlH@"
    . "RTnUci5ED7YRRTnUciVFD7ZQ@kU51HIbRQ+2UP9FOdRyEUUPtghFOcxFGclB99FB"
    . "g8ECSIPAAUSICkmDwAFIg8IBSIPBAUw52A+Fgf@@@wO8JEABAACDxgFIAes5NCQP"
    . "hTb@@@9Ei3wkIOnZ9v@@x0QkQAAAAADHRCQ4AAAAAEUx@8dEJBQAAAAA6fTv@@9F"
    . "he0PiFX3@@9FOfUPj0z3@@+F7Q+IRPf@@0Q51Q+PO@f@@4NEJHwBRInQRYnyQYnG"
    . "i0QkFEE5x0EPTceDvCTwAAAAA4nHiUQkGInoD4@vAAAAD6+EJEABAACF@0aNBCgP"
    . "hHwDAABEi0wkQIt8JDgxyUiLhCRQAQAA6zNmDx9EAABBOdd+GkiLtCRgAQAARInC"
    . "AxSO9gQQAXUGQYPpAXgxSIPBATlMJBgPjr74@@87TCQUicp9y0iLtCRYAQAARYnD"
    . "RAMcjkKAPBgBd7WD7wF5sIO8JAgBAAAJD4R29v@@g0QkWAHpO@D@@4tEJBTHRCRA"
    . "AAAAAEUx@w+vhCSAAQAAwfgKiUQkOOmI7@@@g3wkXAF0HoN8JFwCD4TNAgAAQYPt"
    . "AelG9v@@g0QkSAHp4O@@@0GDxQHpM@b@@w8fgAAAAACLlCQwAQAAA4QkOAEAAA+v"
    . "hCQYAQAARAHqg7wk8AAAAAUPhFn2@@+NNJCLhCT4AAAASIu8JBABAABEi0wkGAHw"
    . "jVACRYXJSGPSD7YcF41QAUiYSGPSD7Y8F4l8JCRIi7wkEAEAAA+2BAeJRCQoD4Qu"
    . "AgAAi0QkQESJVCQgRTHbi3wkOEyLlCQQAQAAiUQkMOmMAAAARDt8JDx+dkiLhCRg"
    . "AQAAQosUmAHyjUICSJhBD7YMAo1CAUhj0kEPthQSSJgrVCQoQQ+2BAJBickB2StE"
    . "JCREjYEABAAAQSnZRQ+vwQ+vwEUPr8FBuf4FAADB4AtBKclEickPr8pEAcAPr9EB"
    . "0EE5xHILg2wkMAEPiJMAAABJg8MBRDlcJBgPjgb3@@9EO1wkFESJXCQ8D41k@@@@"
    . "SIuEJFgBAABCixSYAfKNQgJImEEPtgwCjUIBSGPSQQ+2FBJImCtUJChBD7YEAkGJ"
    . "yQHZK0QkJESNgQAEAABBKdlFD6@BD6@ARQ+vwcHgC0EBwLj+BQAAKcgPr8IPr8JE"
    . "AcBBOcQPg@n+@@+D7wEPifD+@@9Ei1QkIOni@f@@ZpDHRCQ4AAAAAMdEJBQAAAAA"
    . "6avx@@8x0uks9P@@Dx9AAIF8JCj@@@8AD4cz9v@@6Rz2@@+LRCQYi3wkOIXAD4Q4"
    . "9v@@RTHATIuMJBABAADrD0mDwAFEOUQkGA+OhgAAAEiLtCRYAQAAi0QkJEIDBIZI"
    . "i7QkYAEAAEKLDIaNUAJIY9JFD7YcEYnKweoQQSnTjVABSJhFD6@bRDmcJIgAAABB"
    . "D7YEAUhj0kEPthQRfCIPtt0p2g+v0jmUJIwAAAB8EQ+20SnQD6@AO4QkkAAAAH6A"
    . "g+8BD4l3@@@@iYwk+AAAAOn7@P@@iYwk+AAAAOmK9f@@i3wkOOmB9f@@g8UB6Xrz"
    . "@@@HRCQ4AAAAAMdEJEAAAAAAx0QkFAAAAADpoez@@zHS6Qvz@@8PtkQkPA+2VCRM"
    . "weYQweAICfAJ0ImEJPgAAADpG@X@@5CQkJCQkJCQkJA="
    MyFunc:=this.MCode(StrReplace((A_PtrSize=8?x64:x32),"@","/"))
  }
  text:=j[1], w:=j[2], h:=j[3]
  , err1:=this.Floor(j[4] ? j[5] : ini.err1)
  , err0:=this.Floor(j[4] ? j[6] : ini.err0)
  , mode:=j[7], color:=j[8], n:=j[9]
  ok:=(!ini.bits.Scan0 || mode<1 || mode>5) ? 0
    : DllCall(MyFunc.Ptr, "int",mode, "uint",color, "uint",n, "int",dir
    , "Ptr",ini.bits.Scan0, "int",ini.bits.Stride
    , "int",ini.bits.zw, "int",ini.bits.zh
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "Ptr",ini.ss, "Ptr",ini.s1, "Ptr",ini.s0
    , "Ptr",text, "int",w, "int",h
    , "int",Floor(Abs(err1)*1024), "int",Floor(Abs(err0)*1024)
    , "int",(err1<0||err0<0), "Ptr",ini.allpos, "int",ini.allpos_max
    , "int",Floor(w*ini.zoomW), "int",Floor(h*ini.zoomH))
  return ok
}

code()
{
return "
(

//***** C source code of machine code *****
// gcc.exe -m32/-m64 -O2

int __attribute__((__stdcall__)) PicFind(
  int mode, unsigned int c, unsigned int n, int dir
  , unsigned char * Bmp, int Stride, int zw, int zh
  , int sx, int sy, int sw, int sh
  , unsigned char * ss, unsigned int * s1, unsigned int * s0
  , unsigned char * text, int w, int h
  , int err1, int err0, int more_err
  , unsigned int * allpos, int allpos_max
  , int new_w, int new_h )
{
  int ok, o, i, j, k, v, t, e1, e0, len1, len0, max, pic, shape, dir1;
  int x, y, x1, y1, x2, y2, x3, y3, r, g, b, rr, gg, bb, dR, dG, dB;
  int ii, jj, RunDir, DirCount, RunCount, AllCount1, AllCount2;
  unsigned int c1, c2, *cors, *arr;
  unsigned char *ts, *gs;
  ok=o=v=len1=len0=0; ts=ss+sw; gs=ts+sw; arr=allpos+allpos_max;
  //----------------------
  if (mode==5)
  {
    if (pic=(c==2))  // FindPic
    {
      cors=(unsigned int *)(text+w*h*4); j=(err0>>10)+1; n*=2; k=n<=2||cors[2]<0x1000000;
      c2=cors[1]; r=(c2>>16)&0xFF; g=(c2>>8)&0xFF; b=c2&0xFF; dR=r*r; dG=g*g; dB=b*b;
      for (y=0; y<h; y+=j)
      for (x=0; x<w; x+=j)
      {
        o=(y*w+x)*4; rr=text[2+o]; gg=text[1+o]; bb=text[o];
        for (i=2; i<n;)
        {
          c1=cors[i++]; c2=cors[i++];
          r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
          v=(c2<0x40000000) ? ((1024+(r+rr+rr))*r*r+2048*g*g+(1534-(r+rr+rr))*b*b<=c2)
          : (r*r<=((c2>>16)&0xFF)*((c2>>16)&0xFF)
          && g*g<=((c2>>8)&0xFF)*((c2>>8)&0xFF)
          && b*b<=(c2&0xFF)*(c2&0xFF));
          if (v) break;
        }
        if (v==k) continue;
        s1[len1]=(y*new_h/h)*Stride+(x*new_w/w)*4;
        s0[len1++]=rr<<16|gg<<8|bb;
      }
    }
    else  // FindMultiColor or FindColor
    {
      shape=(c==1);  // FindShape
      cors=(unsigned int *)text;
      for (i=0; i<n; i++, o+=22)
      {
        c=cors[o]; y=c>>16; x=c&0xFFFF;
        s1[len1]=(y*new_h/h)*Stride+(x*new_w/w)*4;
        s0[len1++]=o+cors[o+1]*2;
      }
      cors+=2;
    }
    goto StartLookUp;
  }
  //----------------------
  // Generate Lookup Table
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      i=(mode==4) ? (y*new_h/h)*Stride+(x*new_w/w)*4 : (y*new_h/h)*sw+(x*new_w/w);
      if (text[o++]=='1')
        s1[len1++]=i;
      else
        s0[len0++]=i;
    }
  }
  //----------------------
  // Color Position Mode
  // only used to recognize multicolored Verification Code
  if (mode==4)
  {
    y=c>>16; x=c&0xFFFF;
    c=(y*new_h/h)*Stride+(x*new_w/w)*4;
    goto StartLookUp;
  }
  //----------------------
  // Generate Two Value Image
  o=sy*Stride+sx*4; j=Stride-sw*4; i=0;
  if (mode==1)  // Color Mode
  {
    cors=(unsigned int *)(text+w*h); n*=2; k=cors[0]<0x1000000;
    for (y=0; y<sh; y++, o+=j)
    for (x=0; x<sw; x++, o+=4, i++)
    {
      rr=Bmp[2+o]; gg=Bmp[1+o]; bb=Bmp[o];
      for (t=0; t<n;)
      {
        c1=cors[t++]; c2=cors[t++];
        r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
        v=(c2<0x40000000) ? ((1024+(r+rr+rr))*r*r+2048*g*g+(1534-(r+rr+rr))*b*b<=c2)
        : (r*r<=((c2>>16)&0xFF)*((c2>>16)&0xFF)
        && g*g<=((c2>>8)&0xFF)*((c2>>8)&0xFF)
        && b*b<=(c2&0xFF)*(c2&0xFF));
        if (v) break;
      }
      ts[i]=(v==k) ? 2:1;
    }
  }
  else if (mode==2)  // Gray Threshold Mode
  {
    c=(c+1)<<7;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        ts[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15<c) ? 2:1;
  }
  else if (mode==3)  // Gray Difference Mode
  {
    o-=Stride+4; j-=8; k=sw+2;
    for (y=sy-1; y<=sy+sh; y++, o+=j)
    {
      for (x=sx-1; x<=sx+sw; x++, o+=4, i++)
        gs[i]=(x<0||x>=zw||y<0||y>=zh)?0:(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15)>>7;
    }
    for (i=0, y=1; y<=sh; y++)
    for (x=1; x<=sw; x++, i++)
    {
      o=y*k+x; n=gs[o]+c;
      ts[i]=(gs[o-1]>n || gs[o+1]>n
      || gs[o-k-1]>n || gs[o-k]>n || gs[o-k+1]>n
      || gs[o+k-1]>n || gs[o+k]>n || gs[o+k+1]>n) ? 2:1;
    }
  }
  if (more_err)
  {
    for (sx++, i=0, y=0; y<sh; y++)
      for (x=0; x<sw; x++, i++)
        ss[i]=ts[i]|(x==0?0:ts[i-1])|(x==sw-1?0:ts[i+1]);
  }
  else ss=ts;
  //----------------------
  StartLookUp:
  err1=(len1*err1)>>10;
  err0=(len0*err0)>>10;
  if (err1>=len1) len1=0;
  if (err0>=len0) len0=0;
  max=(len1>len0) ? len1 : len0;
  w=new_w; h=new_h; x1=0; y1=0; x2=sw-w; y2=sh-h;
  // 1 ==> ( Left to Right ) Top to Bottom
  // 2 ==> ( Right to Left ) Top to Bottom
  // 3 ==> ( Left to Right ) Bottom to Top
  // 4 ==> ( Right to Left ) Bottom to Top
  // 5 ==> ( Top to Bottom ) Left to Right
  // 6 ==> ( Bottom to Top ) Left to Right
  // 7 ==> ( Top to Bottom ) Right to Left
  // 8 ==> ( Bottom to Top ) Right to Left
  // 9 ==> Center to Four Sides
  if (dir==9)
  {
    x=(x1+x2)/2; y=(y1+y2)/2; i=x2-x1+1; j=y2-y1+1;
    AllCount1=i*j; i=(i>j?i:j)+8;
    AllCount2=i*i; RunCount=0; DirCount=1; RunDir=0;
    for (ii=0; RunCount<AllCount1 && ii<AllCount2;)
    {
      for(jj=0; jj<DirCount; jj++, ii++)
      {
        if(x>=x1 && x<=x2 && y>=y1 && y<=y2)
        {
          RunCount++;
          goto FindPos;
          FindPos_GoBak:;
        }
        if (RunDir==0) y--;
        else if (RunDir==1) x++;
        else if (RunDir==2) y++;
        else x--;
      }
      if (RunDir & 1) DirCount++;
      RunDir = (++RunDir) & 3;
    }
    goto Return1;
  }
  dir1=(dir<1 || dir>8) ? 0 : dir-1;
  if (dir1>3) { r=y1; y1=x1; x1=r; r=y2; y2=x2; x2=r; }
  for (y3=y1; y3<=y2; y3++)
  {
    for (x3=x1; x3<=x2; x3++)
    {
      y=(dir1 & 2) ? y1+y2-y3 : y3;
      x=(dir1 & 1) ? x1+x2-x3 : x3;
      if (dir1>3) { r=y; y=x; x=r; }
      //----------------------
      FindPos:
      e1=err1; e0=err0;
      if (mode<4)
      {
        o=y*sw+x;
        for (i=0; i<max; i++)
        {
          if (i<len1 && ss[o+s1[i]]<2 && (--e1)<0) goto NoMatch;
          if (i<len0 && (ss[o+s0[i]]&1)==0 && (--e0)<0) goto NoMatch;
        }
      }
      else if (mode==5)
      {
        o=(sy+y)*Stride+(sx+x)*4;
        if (pic)
        {
          for (i=0; i<max; i++)
          {
            j=o+s1[i]; c=s0[i]; r=Bmp[2+j]-(c>>16);
            g=Bmp[1+j]-((c>>8)&0xFF); b=Bmp[j]-(c&0xFF);
            if ((r*r>dR || g*g>dG || b*b>dB) && (--e1)<0) goto NoMatch;
          }
        }
        else
        {
          for (i=0; i<max; i++)
          {
            j=o+s1[i]; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
            for (j=i*22, k=cors[j]>0xFFFFFF, n=s0[i]; j<n;)
            {
              c1=cors[j++]; c2=cors[j++];
              if (shape) { if (i==0) { c=rr<<16|gg<<8|bb; goto MatchOK; } c1=c; }
              r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
              v=(c2<0x40000000) ? ((1024+(r+rr+rr))*r*r+2048*g*g+(1534-(r+rr+rr))*b*b<=c2)
              : (r*r<=((c2>>16)&0xFF)*((c2>>16)&0xFF)
              && g*g<=((c2>>8)&0xFF)*((c2>>8)&0xFF)
              && b*b<=(c2&0xFF)*(c2&0xFF));
              if (v) { if (k) goto NoMatch2; goto MatchOK; }
            }
            if (k) goto MatchOK;
            NoMatch2:
            if (i==0 || (--e1)<0) goto NoMatch;
            MatchOK:;
          }
        }
      }
      else  // mode==4
      {
        o=(sy+y)*Stride+(sx+x)*4;
        j=o+c; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
        for (i=0; i<max; i++)
        {
          if (i<len1)
          {
            j=o+s1[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if ((1024+(r+rr+rr))*r*r+2048*g*g+(1534-(r+rr+rr))*b*b>n && (--e1)<0) goto NoMatch;
          }
          if (i<len0)
          {
            j=o+s0[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if ((1024+(r+rr+rr))*r*r+2048*g*g+(1534-(r+rr+rr))*b*b<=n && (--e0)<0) goto NoMatch;
          }
        }
      }
      ok++;
      if (allpos)
      {
        allpos[ok-1]=(sy+y)<<16|(sx+x);
        if (dir==0) arr[ok-1]=err1-e1;
        if (ok>=allpos_max) goto Return1;
      }
      NoMatch:
      if (dir==9) goto FindPos_GoBak;
    }
  }
  //----------------------
  Return1:
  if (!allpos || w*h==1)
    return ok;
  // Sort by smallest error
  if (dir==0)
  {
    for (i=1; i<ok; i++)
    {
      k=arr[i]; v=allpos[i];
      for (j=i-1; j>=0 && arr[j]>k; j--)
      {
        arr[j+1]=arr[j]; allpos[j+1]=allpos[j];
      }
      arr[j+1]=k; allpos[j+1]=v;
    }
  }
  // Clean up overlapping results
  w=(w*w)>>2; h=(h*h)>>2; k=ok; ok=0;
  for (i=0; i<k; i++)
  {
    c1=allpos[i]; x1=c1&0xFFFF; y1=c1>>16;
    for (j=0; j<ok; j++)
    {
      c2=allpos[j]; x=(c2&0xFFFF)-x1; y=(c2>>16)-y1;
      if (x*x<w && y*y<h) goto NoMatch3;
    }
    allpos[ok++]=c1;
    NoMatch3:;
  }
  return ok;
}

)"
}

PicInfo(text)
{
  local
  if !InStr(text, "$")
    return
  static init, info, bmp
  if !VarSetCapacity(init) && (init:="1")
    info:=[], bmp:=[]
  key:=(r:=StrLen(v:=Trim(text,"|")))<10000 ? v
    : DllCall("ntdll\RtlComputeCrc32", "uint",0
    , "Ptr",&v, "uint",r*(1+!!A_IsUnicode), "uint")
  if info.HasKey(key)
    return info[key]
  comment:="", seterr:=err1:=err0:=0
  ; You Can Add Comment Text within The <>
  if RegExMatch(v, "O)<([^>\n]*)>", r)
    v:=StrReplace(v,r[0]), comment:=Trim(r[1])
  ; You can Add two fault-tolerant in the [], separated by commas
  if RegExMatch(v, "O)\[([^\]\n]*)]", r)
  {
    v:=StrReplace(v,r[0]), r:=StrSplit(r[1] ",", ",")
    , seterr:=1, err1:=r[1], err0:=r[2]
  }
  color:=SubStr(v,1,InStr(v,"$")-1), v:=Trim(SubStr(v,InStr(v,"$")+1))
  mode:=InStr(color,"##") ? 5 : InStr(color,"#") ? 4
    : InStr(color,"**") ? 3 : InStr(color,"*") ? 2 : 1
  color:=RegExReplace(StrReplace(color,"@","-"), "[*#\s]")
  (mode=1 || mode=5) && color:=StrReplace(color,"0x")
  if (mode=5)
  {
    if !(v~="^[\s\-\w.]+/[\s\-\w.]+/[\s\-\w./,]+$")  ; <FindPic>
    {
      if !(hBM:=LoadPicture(v))
      {
        MsgBox, 4096, Tip, Can't Load Picture ! %v%
        return
      }
      this.GetBitmapWH(hBM, w, h)
      if (w<1 || h<1)
        return
      hBM2:=this.CreateDIBSection(w, h, 32, Scan0)
      this.CopyHBM(hBM2, 0, 0, hBM, 0, 0, w, h)
      DllCall("DeleteObject", "Ptr",hBM)
      if (!Scan0)
        return
      arr:=StrSplit(color "/", "/"), arr.Pop(), n:=arr.Length()
      bmp.Push(buf:=this.Buffer(w*h*4 + n*2*4)), v:=buf.Ptr, p:=v+w*h*4-4
      DllCall("RtlMoveMemory", "Ptr",v, "Ptr",Scan0, "Ptr",w*h*4)
      DllCall("DeleteObject", "Ptr",hBM2), color:=Trim(arr[1],"-")
      For k1,v1 in arr
        c:=StrSplit(Trim(v1,"-") "-" color, "-")
        , x:=this.Floor(c[2]), x:=(x<=0||x>1 ? 0 : A_Index=1
        ? Floor(255*(1-x))*0x010101 : Floor(4606*255*255*(1-x)*(1-x)))
        , NumPut(this.ToRGB(c[1],InStr(v1,"-")=1), 0|p+=4, "uint")
        , NumPut((InStr(c[2],".")?x:this.Floor("0x" c[2])|0x40000000), 0|p+=4, "uint")
      color:=2
    }
    else  ; <FindMultiColor> or <FindColor> or <FindShape>
    {
      color:=Trim(StrSplit(color "/", "/")[1], "-")
      arr:=StrSplit(Trim(RegExReplace(v, "i)\s|0x"), ","), ",")
      n:=arr.Length(), bmp.Push(buf:=this.Buffer(n*22*4)), v:=buf.Ptr
      shape:=(n>1 && StrLen(StrSplit(arr[1] "//","/")[3])=1 ? 1:0)
      For k1,v1 in arr
      {
        r:=StrSplit(v1 "/","/"), x:=this.Floor(r[1]), y:=this.Floor(r[2])
        , (A_Index=1) ? (x1:=x2:=x, y1:=y2:=y)
        : (x1:=Min(x1,x), x2:=Max(x2,x), y1:=Min(y1,y), y2:=Max(y2,y))
      }
      For k1,v1 in arr
      {
        r:=StrSplit(v1 "/","/"), x:=this.Floor(r[1])-x1, y:=this.Floor(r[2])-y1
        , NumPut(y<<16|x, 0|p:=v+(A_Index-1)*22*4, "uint")
        , NumPut(n1:=Min(Max(r.Length()-3,0),(shape?1:10)), 0|p+=4, "uint")
        Loop % n1
          c:=StrSplit(Trim(v1:=r[2+A_Index],"-") "-" color, "-")
          , x:=this.Floor(c[2]), x:=(x<=0||x>1?0:Floor(4606*255*255*(1-x)*(1-x)))
          , NumPut(this.ToRGB(c[1],InStr(v1,"-")=1||(shape&&!v1)), 0|p+=4, "uint")
          , NumPut((InStr(c[2],".")?x:this.Floor("0x" c[2])|0x40000000), 0|p+=4, "uint")
      }
      color:=shape, w:=x2-x1+1, h:=y2-y1+1
    }
  }
  else
  {
    r:=StrSplit(v ".", "."), w:=this.Floor(r[1])
    , v:=this.base64tobit(r[2]), h:=StrLen(v)//w
    if (w<1 || h<1 || StrLen(v)!=w*h)
      return
    arr:=StrSplit(color "/", "/"), arr.Pop(), n:=arr.Length()
    , bmp.Push(buf:=this.Buffer(StrPut(v, "CP0") + n*2*4))
    , StrPut(v, buf.Ptr, "CP0"), v:=buf.Ptr, p:=v+w*h-4
    , color:=this.Floor(color)
    if (mode=1)
    {
      For k1,v1 in arr
        c:=StrSplit(Trim(v1,"-") "-", "-")
        , x:=this.Floor(c[2]), x:=(x<=0||x>1?0:Floor(4606*255*255*(1-x)*(1-x)))
        , NumPut(this.ToRGB(c[1],InStr(v1,"-")=1), 0|p+=4, "uint")
        , NumPut((InStr(c[2],".")?x:this.Floor("0x" c[2])|0x40000000), 0|p+=4, "uint")
    }
    else if (mode=4)
    {
      r:=StrSplit(Trim(arr[1],"-") "-", "-")
      , n:=this.Floor(r[2]), n:=(n<=0||n>1?0:Floor(4606*255*255*(1-n)*(1-n)))
      , c:=this.Floor(r[1]), color:=(c<1||c>w*h?0:((c-1)//w)<<16|Mod(c-1,w))
    }
  }
  return info[key]:=[v, w, h, seterr, err1, err0, mode, color, n, comment]
}

ToRGB(color, f:=0)  ; color can use: RRGGBB, Red, Yellow, Black, White
{
  static init, tab
  if !VarSetCapacity(init) && (init:="1")
    tab:=Object("Black", "000000", "White", "FFFFFF"
    , "Red", "FF0000", "Green", "008000", "Blue", "0000FF"
    , "Yellow", "FFFF00", "Silver", "C0C0C0", "Gray", "808080"
    , "Teal", "008080", "Navy", "000080", "Aqua", "00FFFF"
    , "Olive", "808000", "Lime", "00FF00", "Fuchsia", "FF00FF"
    , "Purple", "800080", "Maroon", "800000")
  return this.Floor("0x" (tab.HasKey(color)?tab[color]:color))&0xFFFFFF|(f?0x1000000:0)
}

Buffer(size, FillByte:="")
{
  local
  buf:={}, buf.SetCapacity("_key", size), p:=buf.GetAddress("_key")
  , (FillByte!="" && DllCall("RtlFillMemory","Ptr",p,"Ptr",size,"uchar",FillByte))
  , buf.Ptr:=p, buf.Size:=size
  return buf
}

GetBitsFromScreen(ByRef x:=0, ByRef y:=0, ByRef w:=0, ByRef h:=0
  , ScreenShot:=1, ByRef zx:=0, ByRef zy:=0, ByRef zw:=0, ByRef zh:=0)
{
  local
  static init, CAPTUREBLT
  if !VarSetCapacity(init) && (init:="1")  ; thanks Descolada
  {
    DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*",i:=0)
    CAPTUREBLT:=i ? 0 : 0x40000000
  }
  if InStr(A_OSVersion, ".")  ; thanks QQ:349029755
    Try DllCall("SetThreadDpiAwarenessContext", "Ptr",-3)
  (!IsObject(this.bits) && this.bits:={Scan0:0, hBM:0, oldzw:0, oldzh:0})
  , bits:=this.bits
  if (!ScreenShot && bits.Scan0)
  {
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
    , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
    return bits
  }
  bch:=A_BatchLines, cri:=A_IsCritical
  Critical
  bits.BindWindow:=id:=this.BindWindow(0,0,1)
  if (id)
  {
    WinGet, id, ID, ahk_id %id%
    WinGetPos, zx, zy, zw, zh, ahk_id %id%
  }
  if (!id)
  {
    SysGet, zx, 76
    SysGet, zy, 77
    SysGet, zw, 78
    SysGet, zh, 79
  }
  this.UpdateBits(bits, zx, zy, zw, zh)
  , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
  , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
  if (!ScreenShot || w<1 || h<1 || !bits.hBM)
  {
    Critical % cri
    SetBatchLines % bch
    return bits
  }
  sx:=x, sy:=y, sw:=w, sh:=h, x--, y--, w+=2, h+=2
  , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
  , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
  if IsFunc(k:="GetBitsFromScreen2")
    && %k%(bits, x-zx, y-zy, w, h)
  {
    ; Get the bind window use bits.BindWindow
    ; Each small range of data obtained from DXGI must be
    ; copied to the screenshot cache using FindText().CopyBits()
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    x:=sx, y:=sy, w:=sw, h:=sh
    Critical % cri
    SetBatchLines % bch
    return bits
  }
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",bits.hBM, "Ptr")
  if (id)
  {
    if (mode:=this.BindWindow(0,0,0,1))<2
    {
      hDC:=DllCall("GetDCEx", "Ptr",id, "Ptr",0, "int",3, "Ptr")
      DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , "Ptr",hDC, "int",x-zx, "int",y-zy, "uint",0xCC0020|CAPTUREBLT)
      DllCall("ReleaseDC", "Ptr",id, "Ptr",hDC)
    }
    else
    {
      hBM2:=this.CreateDIBSection(zw, zh)
      mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
      oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
      DllCall("UpdateWindow", "Ptr",id)
      ; RDW_INVALIDATE=0x1|RDW_ERASE=0x4|RDW_ALLCHILDREN=0x80|RDW_FRAME=0x400
      ; DllCall("RedrawWindow", "Ptr",id, "Ptr",0, "Ptr",0, "uint", 0x485)
      DllCall("PrintWindow", "Ptr",id, "Ptr",mDC2, "uint",(mode>3)*3)
      DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , "Ptr",mDC2, "int",x-zx, "int",y-zy, "uint",0xCC0020)
      DllCall("SelectObject", "Ptr",mDC2, "Ptr",oBM2)
      DllCall("DeleteDC", "Ptr",mDC2)
      DllCall("DeleteObject", "Ptr",hBM2)
    }
  }
  else
  {
    hDC:=DllCall("GetWindowDC","Ptr",id:=DllCall("GetDesktopWindow","Ptr"),"Ptr")
    DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
      , "Ptr",hDC, "int",x, "int",y, "uint",0xCC0020|CAPTUREBLT)
    DllCall("ReleaseDC", "Ptr",id, "Ptr",hDC)
  }
  if this.CaptureCursor(0,0,0,0,0,1)
    this.CaptureCursor(mDC, zx, zy, zw, zh)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
  x:=sx, y:=sy, w:=sw, h:=sh
  Critical % cri
  SetBatchLines % bch
  return bits
}

UpdateBits(bits, zx, zy, zw, zh)
{
  local
  if (zw>bits.oldzw || zh>bits.oldzh || !bits.hBM)
  {
    Try DllCall("DeleteObject", "Ptr",bits.hBM)
    bits.hBM:=this.CreateDIBSection(zw, zh, bpp:=32, ppvBits)
    , bits.Scan0:=(!bits.hBM ? 0:ppvBits)
    , bits.Stride:=((zw*bpp+31)//32)*4
    , bits.oldzw:=zw, bits.oldzh:=zh
  }
  bits.zx:=zx, bits.zy:=zy, bits.zw:=zw, bits.zh:=zh
}

CreateDIBSection(w, h, bpp:=32, ByRef ppvBits:=0)
{
  local
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  , NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
  , NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  return DllCall("CreateDIBSection", "Ptr",0, "Ptr",&bi
    , "int",0, "Ptr*",ppvBits:=0, "Ptr",0, "int",0, "Ptr")
}

GetBitmapWH(hBM, ByRef w, ByRef h)
{
  local
  VarSetCapacity(bm, size:=(A_PtrSize=8 ? 32:24), 0)
  , DllCall("GetObject", "Ptr",hBM, "int",size, "Ptr",&bm)
  , w:=NumGet(bm,4,"int"), h:=Abs(NumGet(bm,8,"int"))
}

CopyHBM(hBM1, x1, y1, hBM2, x2, y2, w, h, Clear:=0)
{
  local
  if (w<1 || h<1 || !hBM1 || !hBM2)
    return
  mDC1:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM1:=DllCall("SelectObject", "Ptr",mDC1, "Ptr",hBM1, "Ptr")
  mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
  DllCall("BitBlt", "Ptr",mDC1, "int",x1, "int",y1, "int",w, "int",h
  , "Ptr",mDC2, "int",x2, "int",y2, "uint",0xCC0020)
  if (Clear)
    DllCall("BitBlt", "Ptr",mDC1, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC1, "int",x1, "int",y1, "uint",MERGECOPY:=0xC000CA)
  DllCall("SelectObject", "Ptr",mDC1, "Ptr",oBM1)
  DllCall("DeleteDC", "Ptr",mDC1)
  DllCall("SelectObject", "Ptr",mDC2, "Ptr",oBM2)
  DllCall("DeleteDC", "Ptr",mDC2)
}

CopyBits(Scan01,Stride1,x1,y1,Scan02,Stride2,x2,y2,w,h,Reverse:=0)
{
  local
  if (w<1 || h<1 || !Scan01 || !Scan02)
    return
  static init, MFCopyImage
  if !VarSetCapacity(init) && (init:="1")
  {
    MFCopyImage:=DllCall("GetProcAddress", "Ptr"
    , DllCall("LoadLibrary", "Str","Mfplat.dll", "Ptr")
    , "AStr","MFCopyImage", "Ptr")
  }
  if (MFCopyImage && !Reverse)  ; thanks QQ:121507989
  {
    return DllCall(MFCopyImage
      , "Ptr",Scan01+y1*Stride1+x1*4, "int",Stride1
      , "Ptr",Scan02+y2*Stride2+x2*4, "int",Stride2
      , "uint",w*4, "uint",h)
  }
  ListLines % (lls:=A_ListLines)?0:0
  SetBatchLines % (bch:=A_BatchLines)?"-1":"-1"
  p1:=Scan01+(y1-1)*Stride1+x1*4
  , p2:=Scan02+(y2-1)*Stride2+x2*4, w*=4
  , (Reverse) && (p2+=(h+1)*Stride2, Stride2:=-Stride2)
  Loop % h
    DllCall("RtlMoveMemory","Ptr",p1+=Stride1,"Ptr",p2+=Stride2,"Ptr",w)
  SetBatchLines % bch
  ListLines % lls
}

DrawHBM(hBM, lines)
{
  local
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",hBM, "Ptr")
  oldc:="", brush:=0, VarSetCapacity(rect, 16)
  For k,v in lines  ; [ [x, y, w, h, color] ]
  if IsObject(v)
  {
    if (oldc!=v[5])
    {
      oldc:=v[5], BGR:=(oldc&0xFF)<<16|oldc&0xFF00|(oldc>>16)&0xFF
      DllCall("DeleteObject", "Ptr",brush)
      brush:=DllCall("CreateSolidBrush", "uint",BGR, "Ptr")
    }
    DllCall("SetRect", "Ptr",&rect, "int",v[1], "int",v[2]
      , "int",v[1]+v[3], "int",v[2]+v[4])
    DllCall("FillRect", "Ptr",mDC, "Ptr",&rect, "Ptr",brush)
  }
  DllCall("DeleteObject", "Ptr",brush)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteObject", "Ptr",mDC)
}

; Bind the window so that it can find images when obscured
; by other windows, it's equivalent to always being
; at the front desk. Unbind Window using FindText().BindWindow(0)

BindWindow(bind_id:=0, bind_mode:=0, get_id:=0, get_mode:=0)
{
  local
  (!IsObject(this.bind) && this.bind:={id:0, mode:0, oldStyle:0})
  , bind:=this.bind
  if (get_id)
    return bind.id
  if (get_mode)
    return bind.mode
  if (bind_id)
  {
    bind.id:=bind_id:=this.Floor(bind_id)
    , bind.mode:=bind_mode, bind.oldStyle:=0
    if (bind_mode & 1)
    {
      WinGet, i, ExStyle, ahk_id %bind_id%
      bind.oldStyle:=i
      WinSet, Transparent, 255, ahk_id %bind_id%
      Loop 30
      {
        Sleep 100
        WinGet, i, Transparent, ahk_id %bind_id%
      }
      Until (i=255)
    }
  }
  else
  {
    bind_id:=bind.id
    if (bind.mode & 1)
      WinSet, ExStyle, % bind.oldStyle, ahk_id %bind_id%
    bind.id:=0, bind.mode:=0, bind.oldStyle:=0
  }
}

; Use FindText().CaptureCursor(1) to Capture Cursor
; Use FindText().CaptureCursor(0) to Cancel Capture Cursor

CaptureCursor(hDC:=0, zx:=0, zy:=0, zw:=0, zh:=0, get_cursor:=0)
{
  local
  if (get_cursor)
    return this.Cursor
  if (hDC=1 || hDC=0) && (zw=0)
  {
    this.Cursor:=hDC
    return
  }
  VarSetCapacity(mi, 40, 0), NumPut(16+A_PtrSize, mi, "int")
  DllCall("GetCursorInfo", "Ptr",&mi)
  bShow:=NumGet(mi, 4, "int")
  hCursor:=NumGet(mi, 8, "Ptr")
  x:=NumGet(mi, 8+A_PtrSize, "int")
  y:=NumGet(mi, 12+A_PtrSize, "int")
  if (!bShow) || (x<zx || y<zy || x>=zx+zw || y>=zy+zh)
    return
  VarSetCapacity(ni, 40, 0)
  DllCall("GetIconInfo", "Ptr",hCursor, "Ptr",&ni)
  xCenter:=NumGet(ni, 4, "int")
  yCenter:=NumGet(ni, 8, "int")
  hBMMask:=NumGet(ni, (A_PtrSize=8?16:12), "Ptr")
  hBMColor:=NumGet(ni, (A_PtrSize=8?24:16), "Ptr")
  DllCall("DrawIconEx", "Ptr",hDC
    , "int",x-xCenter-zx, "int",y-yCenter-zy, "Ptr",hCursor
    , "int",0, "int",0, "int",0, "int",0, "int",3)
  DllCall("DeleteObject", "Ptr",hBMMask)
  DllCall("DeleteObject", "Ptr",hBMColor)
}

MCode(hex)
{
  local
  flag:=((hex~="[^A-Fa-f\d\s]") ? 1:4), len:=0
  Loop 2
    if !DllCall("crypt32\CryptStringToBinary", "Str",hex, "uint",0, "uint",flag
    , "Ptr",(A_Index=1?0:(p:=this.Buffer(len)).Ptr), "uint*",len, "Ptr",0, "Ptr",0)
      return
  if DllCall("VirtualProtect", "Ptr",p.Ptr, "Ptr",len, "uint",0x40, "uint*",0)
    return p
}

bin2hex(addr, size, base64:=0)
{
  local
  flag:=(base64 ? 1:4)|0x40000000, len:=0
  Loop 2
    DllCall("crypt32\CryptBinaryToString", "Ptr",addr, "uint",size, "uint",flag
    , "Ptr",(A_Index=1?0:(p:=this.Buffer(len*2)).Ptr), "uint*",len)
  return RegExReplace(StrGet(p.Ptr, len), "\s+")
}

base64tobit(s)
{
  local
  ListLines % (lls:=A_ListLines)?0:0
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop Parse, Chars
    if InStr(s, A_LoopField, 1)
      s:=RegExReplace(s, "[" A_LoopField "]", ((i:=A_Index-1)>>5&1)
      . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1))
  s:=RegExReplace(RegExReplace(s,"[^01]+"),"10*$")
  ListLines % lls
  return s
}

bit2base64(s)
{
  local
  ListLines % (lls:=A_ListLines)?0:0
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop Parse, Chars
    s:=StrReplace(s, "|" . ((i:=A_Index-1)>>5&1)
    . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1), A_LoopField)
  ListLines % lls
  return s
}

ASCII(s)
{
  local
  if RegExMatch(s, "O)\$(\d+)\.([\w+/]+)", r)
  {
    s:=RegExReplace(this.base64tobit(r[2]),".{" r[1] "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s:=""
  return s
}

; You can put the text library at the beginning of the script,
; and Use FindText().PicLib(Text,1) to add the text library to PicLib()'s Lib,
; Use FindText().PicLib("comment1|comment2|...") to get text images from Lib

PicLib(comments, add_to_Lib:=0, index:=1)
{
  local
  (!IsObject(this.Lib) && this.Lib:=[]), Lib:=this.Lib
  , (!Lib.HasKey(index) && Lib[index]:=[]), Lib:=Lib[index]
  if (add_to_Lib)
  {
    re:="O)<([^>\n]*)>[^$\n]+\$[^""\r\n]+"
    Loop Parse, comments, |
      if RegExMatch(A_LoopField, re, r)
      {
        s1:=Trim(r[1]), s2:=""
        Loop Parse, s1
          s2.=Format("_{:d}", Ord(A_LoopField))
        (s2!="") && Lib[s2]:=r[0]
      }
  }
  else
  {
    Text:=""
    Loop Parse, comments, |
    {
      s1:=Trim(A_LoopField), s2:=""
      Loop Parse, s1
        s2.=Format("_{:d}", Ord(A_LoopField))
      (Lib.HasKey(s2)) && Text.="|" Lib[s2]
    }
    return Text
  }
}

; Decompose a string into individual characters and get their data

PicN(Number, index:=1)
{
  return this.PicLib(RegExReplace(Number,".","|$0"), 0, index)
}

; Use FindText().PicX(Text) to automatically cut into multiple characters
; Can't be used in ColorPos mode, because it can cause position errors

PicX(Text)
{
  local
  if !RegExMatch(Text, "O)(<[^$\n]+)\$(\d+)\.([\w+/]+)", r)
    return Text
  v:=this.base64tobit(r[3]), Text:=""
  c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
  txt:=RegExReplace(v,".{" r[2] "}","$0`n")
  While InStr(txt,c)
  {
    While !(txt~="m`n)^" c)
      txt:=RegExReplace(txt,"m`n)^.")
    i:=0
    While (txt~="m`n)^.{" i "}" c)
      i:=Format("{:d}",i+1)
    v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
    txt:=RegExReplace(txt,"m`n)^.{" i "}")
    if (v!="")
      Text.="|" r[1] "$" i "." this.bit2base64(v)
  }
  return Text
}

; Screenshot and retained as the last screenshot.

ScreenShot(x1:=0, y1:=0, x2:=0, y2:=0)
{
  this.FindText(,, x1, y1, x2, y2)
}

; Get the RGB color of a point from the last screenshot.
; If the point to get the color is beyond the range of
; Screen, it will return White color (0xFFFFFF).

GetColor(x, y, fmt:=1)
{
  local
  bits:=this.GetBitsFromScreen(,,,,0,zx,zy,zw,zh), x-=zx, y-=zy
  , c:=(x>=0 && x<zw && y>=0 && y<zh && bits.Scan0)
  ? NumGet(bits.Scan0+y*bits.Stride+x*4,"uint") : 0xFFFFFF
  return (fmt ? Format("0x{:06X}",c&0xFFFFFF) : c)
}

; Set the RGB color of a point in the last screenshot

SetColor(x, y, color:=0x000000)
{
  local
  bits:=this.GetBitsFromScreen(,,,,0,zx,zy,zw,zh), x-=zx, y-=zy
  if (x>=0 && x<zw && y>=0 && y<zh && bits.Scan0)
    NumPut(color, bits.Scan0+y*bits.Stride+x*4, "uint")
}

; Identify a line of text or verification code
; based on the result returned by FindText().
; offsetX is the maximum interval between two texts,
; if it exceeds, a "*" sign will be inserted.
; offsetY is the maximum height difference between two texts.
; overlapW is used to set the width of the overlap.
; Return Association array {text:Text, x:X, y:Y, w:W, h:H}

Ocr(ok, offsetX:=20, offsetY:=20, overlapW:=0)
{
  local
  ocr_Text:=ocr_X:=ocr_Y:=min_X:=dx:=""
  For k,v in ok
    x:=v.1
    , min_X:=(A_Index=1 || x<min_X ? x : min_X)
    , max_X:=(A_Index=1 || x>max_X ? x : max_X)
  While (min_X!="" && min_X<=max_X)
  {
    LeftX:=""
    For k,v in ok
    {
      x:=v.1, y:=v.2
      if (x<min_X) || (ocr_Y!="" && Abs(y-ocr_Y)>offsetY)
        Continue
      ; Get the leftmost X coordinates
      if (LeftX="" || x<LeftX)
        LeftX:=x, LeftY:=y, LeftW:=v.3, LeftH:=v.4, LeftOCR:=v.id
    }
    if (LeftX="")
      Break
    if (ocr_X="")
      ocr_X:=LeftX, min_Y:=LeftY, max_Y:=LeftY+LeftH
    ; If the interval exceeds the set value, add "*" to the result
    ocr_Text.=(ocr_Text!="" && LeftX>dx ? "*":"") . LeftOCR
    ; Update for next search
    min_X:=LeftX+LeftW-(overlapW>LeftW//2 ? LeftW//2:overlapW)
    , dx:=LeftX+LeftW+offsetX, ocr_Y:=LeftY
    , (LeftY<min_Y && min_Y:=LeftY)
    , (LeftY+LeftH>max_Y && max_Y:=LeftY+LeftH)
  }
  (ocr_X="") && ocr_X:=min_Y:=min_X:=max_Y:=0
  return {text:ocr_Text, x:ocr_X, y:min_Y, w:min_X-ocr_X, h:max_Y-min_Y}
}

; Sort the results of FindText() from left to right
; and top to bottom, ignore slight height difference

Sort(ok, dy:=10)
{
  local
  if !IsObject(ok)
    return ok
  s:="", n:=150000, ypos:=[]
  For k,v in ok
  {
    x:=v.x, y:=v.y, add:=1
    For k1,v1 in ypos
    if Abs(y-v1)<=dy
    {
      y:=v1, add:=0
      Break
    }
    if (add)
      ypos.Push(y)
    s.=(y*n+x) "." k "|"
  }
  s:=Trim(s,"|")
  Sort, s, N D|
  ok2:=[]
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
  return ok2
}

; Sort the results of FindText() according to the nearest distance

Sort2(ok, px, py)
{
  local
  if !IsObject(ok)
    return ok
  s:=""
  For k,v in ok
    s.=((v.x-px)**2+(v.y-py)**2) "." k "|"
  s:=Trim(s,"|")
  Sort, s, N D|
  ok2:=[]
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
  return ok2
}

; Sort the results of FindText() according to the search direction

Sort3(ok, dir:=1)
{
  local
  if !IsObject(ok)
    return ok
  s:="", n:=150000
  For k,v in ok
    x:=v.1, y:=v.2
    , s.=(dir=1 ? y*n+x
    : dir=2 ? y*n-x
    : dir=3 ? -y*n+x
    : dir=4 ? -y*n-x
    : dir=5 ? x*n+y
    : dir=6 ? x*n-y
    : dir=7 ? -x*n+y
    : dir=8 ? -x*n-y : y*n+x) "." k "|"
  s:=Trim(s,"|")
  Sort, s, N D|
  ok2:=[]
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
  return ok2
}

; Prompt mouse position in remote assistance

MouseTip(x:="", y:="", w:=10, h:=10, d:=3)
{
  local
  if (x="")
  {
    VarSetCapacity(pt,16,0), DllCall("GetCursorPos","Ptr",&pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  Loop 4
  {
    this.RangeTip(x-w, y-h, 2*w+1, 2*h+1, (A_Index & 1 ? "Red":"Blue"), d)
    Sleep 500
  }
  this.RangeTip()
}

; Shows a range of the borders, similar to the ToolTip

RangeTip(x:="", y:="", w:="", h:="", color:="Red", d:=3, num:=1)
{
  local
  ListLines % (lls:=A_ListLines)?0:0
  static init, tab
  if !VarSetCapacity(init) && (init:="1")
    tab:=[]
  (!tab.HasKey(num) && tab[num]:=[0,0,0,0]), Range:=tab[num]
  if (x="")
  {
    if (Range[1])
    Loop 4
    {
      Gui, % Range[A_Index] ":Destroy"
      Range[A_Index]:=0
    }
    ListLines % lls
    return
  }
  if !(Range[1])
  {
    Loop 4
    {
      Gui, New, +Hwndid +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
      Range[A_Index]:=id
    }
  }
  x:=Floor(x), y:=Floor(y), w:=Floor(w), h:=Floor(h), d:=Floor(d)
  Loop 4
  {
    i:=A_Index
    , x1:=(i=2 ? x+w : x-d)
    , y1:=(i=3 ? y+h : y-d)
    , w1:=(i=1 || i=3 ? w+2*d : d)
    , h1:=(i=2 || i=4 ? h+2*d : d)
    Gui, % Range[i] ":Color", %color%
    Gui, % Range[i] ":Show", NA x%x1% y%y1% w%w1% h%h1%
  }
  ListLines % lls
}

State(key)
{
  return GetKeyState(key,"P") || GetKeyState(key)
}

; Use RButton to select the screen range

GetRange(ww:=25, hh:=8, key:="RButton")
{
  local
  static init, KeyOff, hk
  if !VarSetCapacity(init) && (init:="1")
    KeyOff:=this.GetRange.Bind(this, "Off")
  if (ww=="Off")
    return hk:=Trim(A_ThisHotkey, "*")
  ;---------------------
  GetRange_HotkeyIf:=_Gui:=this.GuiNew()
  _Gui.Opt("-Caption +ToolWindow +E0x80000")
  _Gui.Title:="GetRange_HotkeyIf"
  _Gui.Show("NA x0 y0 w0 h0")
  ;---------------------
  if GetKeyState("Ctrl")
    Send {Ctrl Up}
  Hotkey, IfWinExist, GetRange_HotkeyIf
  keys:=key "|Up|Down|Left|Right"
  For k,v in StrSplit(keys, "|")
  {
    if GetKeyState(v)
      Send {%v% Up}
    Hotkey, *%v%, %KeyOff%, On UseErrorLevel
  }
  Hotkey, IfWinExist
  ;---------------------
  Critical % (cri:=A_IsCritical)?"Off":"Off"
  CoordMode, Mouse
  tip:=this.Lang("s5")
  hk:="", oldx:=oldy:="", keydown:=0
  Loop
  {
    Sleep 50
    MouseGetPos, x2, y2
    if (hk=key) || this.State(key) || this.State("Ctrl")
    {
      keydown++
      if (keydown=1)
        MouseGetPos, x1, y1, Bind_ID
      timeout:=A_TickCount+3000
      While (A_TickCount<timeout) && (this.State(key) || this.State("Ctrl"))
        Sleep 50
      hk:=""
      if (keydown>=2)
        Break
    }
    else if (hk="Up") || this.State("Up")
      (hh>1 && hh--), hk:=""
    else if (hk="Down") || this.State("Down")
      hh++, hk:=""
    else if (hk="Left") || this.State("Left")
      (ww>1 && ww--), hk:=""
    else if (hk="Right") || this.State("Right")
      ww++, hk:=""
    x:=(keydown?x1:x2), y:=(keydown?y1:y2)
    this.RangeTip(x-ww, y-hh, 2*ww+1, 2*hh+1, (A_MSec<500?"Red":"Blue"))
    if (oldx=x2 && oldy=y2)
      Continue
    oldx:=x2, oldy:=y2
    ToolTip % "x: " x " y: " y "`n" tip
  }
  ToolTip
  this.RangeTip()
  Hotkey, IfWinExist, GetRange_HotkeyIf
  For k,v in StrSplit(keys, "|")
    Hotkey, *%v%, %KeyOff%, Off UseErrorLevel
  Hotkey, IfWinExist
  GetRange_HotkeyIf.Destroy()
  Critical % cri
  return [x-ww, y-hh, x+ww, y+hh, Bind_ID]
}

GetRange2(key:="LButton")
{
  local
  FindText_GetRange:=_Gui:=this.GuiNew()
  _Gui.Opt("+LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
  _Gui.BackColor:="White"
  WinSet, Transparent, 10
  this.GetBitsFromScreen(,,,,0,x,y,w,h)
  _Gui.Title:="FindText_GetRange"
  _Gui.Show("NA x" x " y" y " w" w " h" h)
  CoordMode, Mouse
  tip:=this.Lang("s7"), oldx:=oldy:=""
  Loop
  {
    Sleep 50
    MouseGetPos, x1, y1
    if (oldx=x1 && oldy=y1)
      Continue
    oldx:=x1, oldy:=y1
    ToolTip % "x: " x1 " y: " y1 " w: 0 h: 0`n" tip
  }
  Until this.State(key) || this.State("Ctrl")
  Loop
  {
    Sleep 50
    MouseGetPos, x2, y2
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
    this.RangeTip(x, y, w, h, (A_MSec<500 ? "Red":"Blue"))
    if (oldx=x2 && oldy=y2)
      Continue
    oldx:=x2, oldy:=y2
    ToolTip % "x: " x " y: " y " w: " w " h: " h "`n" tip
  }
  Until !(this.State(key) || this.State("Ctrl"))
  ToolTip
  this.RangeTip()
  FindText_GetRange.Destroy()
  Clipboard:=x "," y "," (x+w-1) "," (y+h-1)
  return [x, y, x+w-1, y+h-1]
}

BitmapFromScreen(ByRef x:=0, ByRef y:=0, ByRef w:=0, ByRef h:=0
  , ScreenShot:=1, ByRef zx:=0, ByRef zy:=0, ByRef zw:=0, ByRef zh:=0)
{
  local
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
  if (w<1 || h<1 || !bits.hBM)
    return
  hBM:=this.CreateDIBSection(w, h)
  this.CopyHBM(hBM, 0, 0, bits.hBM, x-zx, y-zy, w, h, 1)
  return hBM
}

; Quickly save screen image to BMP file for debugging
; if file = 0 or "", save to Clipboard

SavePic(file:=0, x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  hBM:=this.BitmapFromScreen(x, y, w, h, ScreenShot)
  this.SaveBitmapToFile(file, hBM)
  DllCall("DeleteObject", "Ptr",hBM)
}

; Save Bitmap To File, if file = 0 or "", save to Clipboard
; hBM_or_file can be a bitmap handle or file path, eg: "c:\1.bmp"

SaveBitmapToFile(file, hBM_or_file, x:=0, y:=0, w:=0, h:=0)
{
  local
  if hBM_or_file is number
    hBM_or_file:="HBITMAP:*" hBM_or_file
  if !hBM:=DllCall("CopyImage", "Ptr",LoadPicture(hBM_or_file)
  , "int",0, "int",0, "int",0, "uint",0x2008)
    return
  if (file) || (w!=0 && h!=0)
  {
    (w=0 || h=0) && this.GetBitmapWH(hBM, w, h)
    hBM2:=this.CreateDIBSection(w, -h, bpp:=(file ? 24 : 32))
    this.CopyHBM(hBM2, 0, 0, hBM, x, y, w, h)
    DllCall("DeleteObject", "Ptr",hBM), hBM:=hBM2
  }
  VarSetCapacity(dib, dib_size:=(A_PtrSize=8 ? 104:84), 0)
  , DllCall("GetObject", "Ptr",hBM, "int",dib_size, "Ptr",&dib)
  , pbi:=&dib+(bitmap_size:=A_PtrSize=8 ? 32:24)
  , size:=NumGet(pbi+20, "uint"), pBits:=NumGet(pbi-A_PtrSize, "Ptr")
  if (!file)
  {
    hdib:=DllCall("GlobalAlloc", "uint",2, "Ptr",40+size, "Ptr")
    pdib:=DllCall("GlobalLock", "Ptr",hdib, "Ptr")
    DllCall("RtlMoveMemory", "Ptr",pdib, "Ptr",pbi, "Ptr",40)
    DllCall("RtlMoveMemory", "Ptr",pdib+40, "Ptr",pBits, "Ptr",size)
    DllCall("GlobalUnlock", "Ptr",hdib)
    DllCall("OpenClipboard", "Ptr",0)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "uint",8, "Ptr",hdib)
    DllCall("CloseClipboard")
  }
  else
  {
    if InStr(file,"\") && !FileExist(dir:=RegExReplace(file,"[^\\]*$"))
      Try FileCreateDir, % dir
    VarSetCapacity(bf, 14, 0), NumPut(0x4D42, bf, "short")
    NumPut(54+size, bf, 2, "uint"), NumPut(54, bf, 10, "uint")
    f:=FileOpen(file, "w"), f.RawWrite(bf, 14)
    , f.RawWrite(pbi+0, 40), f.RawWrite(pBits+0, size), f.Close()
  }
  DllCall("DeleteObject", "Ptr",hBM)
}

; Show the saved Picture file

ShowPic(file:="", show:=1, ByRef x:="", ByRef y:="", ByRef w:="", ByRef h:="")
{
  local
  if (file="")
  {
    this.ShowScreenShot()
    return
  }
  if !(hBM:=LoadPicture(file))
    return
  this.GetBitmapWH(hBM, w, h)
  bits:=this.GetBitsFromScreen(,,,,0,x,y,zw,zh)
  this.UpdateBits(bits, x, y, Max(w,zw), Max(h,zh))
  this.CopyHBM(bits.hBM, 0, 0, hBM, 0, 0, w, h)
  DllCall("DeleteObject", "Ptr",hBM)
  if (show)
    this.ShowScreenShot(x, y, x+w-1, y+h-1, 0)
  return 1
}

; Show the memory Screenshot for debugging

ShowScreenShot(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  static init, hPic, oldx, oldy, oldw, oldh, FindText_Screen
  if !VarSetCapacity(init) && (init:="1")
    FindText_Screen:=""
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
  {
    if (FindText_Screen)
      FindText_Screen.Destroy(), FindText_Screen:=""
    return
  }
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  if !hBM:=this.BitmapFromScreen(x,y,w,h,ScreenShot)
    return
  ;---------------
  if (!FindText_Screen)
  {
    FindText_Screen:=_Gui:=this.GuiNew()  ; WS_EX_NOACTIVATE:=0x08000000
    _Gui.Opt("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
    _Gui.MarginX:=0, _Gui.MarginY:=0
    id:=_Gui.Add("Pic", "w" w " h" h), hPic:=id.Hwnd
    _Gui.Title:="Show Pic"
    _Gui.Show("NA x" x " y" y " w" w " h" h)
    oldx:=x, oldy:=y, oldw:=w, oldh:=h
  }
  else if (oldx!=x || oldy!=y || oldw!=w || oldh!=h)
  {
    if (oldw!=w || oldh!=h)
      FindText_Screen[hPic].Move(,, w, h)
    FindText_Screen.Show("NA x" x " y" y " w" w " h" h)
    oldx:=x, oldy:=y, oldw:=w, oldh:=h
  }
  this.BitmapToWindow(hPic, 0, 0, hBM, 0, 0, w, h)
  DllCall("DeleteObject", "Ptr",hBM)
}

BitmapToWindow(hwnd, x1, y1, hBM, x2, y2, w, h)
{
  local
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",hBM, "Ptr")
  hDC:=DllCall("GetDC", "Ptr",hwnd, "Ptr")
  DllCall("BitBlt", "Ptr",hDC, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC, "int",x2, "int",y2, "uint",0xCC0020)
  DllCall("ReleaseDC", "Ptr",hwnd, "Ptr",hDC)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
}

; Quickly get the search data of screen image

GetTextFromScreen(x1:=0, y1:=0, x2:=0, y2:=0, Threshold:=""
  , ScreenShot:=1, ByRef rx:="", ByRef ry:="", cut:=1)
{
  local
  if (x1=0 && y1=0 && x2=0 && y2=0)
    return this.Gui("CaptureS", ScreenShot)
  SetBatchLines % (bch:=A_BatchLines)?"-1":"-1"
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy)
  if (w<1 || h<1 || !bits.Scan0)
  {
    SetBatchLines % bch
    return
  }
  ListLines % (lls:=A_ListLines)?0:0
  gs:=[]
  j:=bits.Stride-w*4, p:=bits.Scan0+(y-zy)*bits.Stride+(x-zx)*4-j-4
  Loop % h + 0*(k:=0)
  Loop % w + 0*(p+=j)
    c:=NumGet(0|p+=4,"uint")
    , gs[++k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
  if InStr(Threshold,"**")
  {
    Threshold:=Trim(Threshold,"* "), (Threshold="" && Threshold:=50)
    s:="", sw:=w, w-=2, h-=2, x++, y++
    Loop % h + 0*(y1:=0)
    Loop % w + 0*(y1++)
      i:=y1*sw+A_Index+1, j:=gs[i]+Threshold
      , s.=( gs[i-1]>j || gs[i+1]>j
      || gs[i-sw]>j || gs[i+sw]>j
      || gs[i-sw-1]>j || gs[i-sw+1]>j
      || gs[i+sw-1]>j || gs[i+sw+1]>j ) ? "1":"0"
    Threshold:="**" Threshold
  }
  else
  {
    Threshold:=Trim(Threshold,"* ")
    if (Threshold="")
    {
      pp:=[]
      Loop 256
        pp[A_Index-1]:=0
      Loop % w*h
        pp[gs[A_Index]]++
      IP0:=IS0:=0
      Loop 256
        k:=A_Index-1, IP0+=k*pp[k], IS0+=pp[k]
      Threshold:=Floor(IP0/IS0)
      Loop 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop % LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP0-IP1, IS2:=IS0-IS1
        if (IS1!=0 && IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
    }
    s:=""
    Loop % w*h
      s.=gs[A_Index]<=Threshold ? "1":"0"
    Threshold:="*" Threshold
  }
  ListLines % lls
  ;--------------------
  w:=Format("{:d}",w), CutUp:=CutDown:=0
  if (cut=1)
  {
    re1:="(^0{" w "}|^1{" w "})"
    re2:="(0{" w "}$|1{" w "}$)"
    While (s~=re1)
      s:=RegExReplace(s,re1), CutUp++
    While (s~=re2)
      s:=RegExReplace(s,re2), CutDown++
  }
  rx:=x+w//2, ry:=y+CutUp+(h-CutUp-CutDown)//2
  s:="|<>" Threshold "$" w "." this.bit2base64(s)
  ;--------------------
  SetBatchLines % bch
  return s
}

; Wait for the screen image to change within a few seconds
; Take a Screenshot before using it: FindText().ScreenShot()

WaitChange(time:=-1, x1:=0, y1:=0, x2:=0, y2:=0)
{
  local
  hash:=this.GetPicHash(x1, y1, x2, y2, 0)
  time:=this.Floor(time), timeout:=A_TickCount+Round(time*1000)
  Loop
  {
    if (hash!=this.GetPicHash(x1, y1, x2, y2, 1))
      return 1
    if (time>=0 && A_TickCount>=timeout)
      Break
    Sleep 10
  }
  return 0
}

; Wait for the screen image to stabilize

WaitNotChange(time:=1, timeout:=30, x1:=0, y1:=0, x2:=0, y2:=0)
{
  local
  oldhash:="", time:=this.Floor(time)
  , timeout:=A_TickCount+Round(this.Floor(timeout)*1000)
  Loop
  {
    hash:=this.GetPicHash(x1, y1, x2, y2, 1), t:=A_TickCount
    if (hash!=oldhash)
      oldhash:=hash, timeout2:=t+Round(time*1000)
    if (t>=timeout2)
      return 1
    if (t>=timeout)
      return 0
    Sleep 100
  }
}

GetPicHash(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  static init:=DllCall("LoadLibrary", "Str","ntdll", "Ptr")
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy), x-=zx, y-=zy
  if (w<1 || h<1 || !bits.Scan0)
    return 0
  hash:=0, Stride:=bits.Stride, p:=bits.Scan0+(y-1)*Stride+x*4, w*=4
  ListLines % (lls:=A_ListLines)?0:0
  Loop % h
    hash:=(hash*31+DllCall("ntdll\RtlComputeCrc32", "uint",0
      , "Ptr",p+=Stride, "uint",w, "uint"))&0xFFFFFFFF
  ListLines % lls
  return hash
}

WindowToScreen(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  if (!id)
    WinGet, id, ID, A
  VarSetCapacity(rect, 16, 0)
  , DllCall("GetWindowRect", "Ptr",id, "Ptr",&rect)
  , x:=x1+NumGet(rect,"int"), y:=y1+NumGet(rect,4,"int")
}

ScreenToWindow(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  this.WindowToScreen(dx, dy, 0, 0, id), x:=x1-dx, y:=y1-dy
}

ClientToScreen(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  if (!id)
    WinGet, id, ID, A
  VarSetCapacity(pt, 8, 0), NumPut(0, pt, "int64")
  , DllCall("ClientToScreen", "Ptr",id, "Ptr",&pt)
  , x:=x1+NumGet(pt,"int"), y:=y1+NumGet(pt,4,"int")
}

ScreenToClient(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  this.ClientToScreen(dx, dy, 0, 0, id), x:=x1-dx, y:=y1-dy
}

; It is not like FindText always use Screen Coordinates,
; But like built-in command PixelGetColor using CoordMode Settings

PixelGetColor(x, y, ScreenShot:=1, id:="")
{
  if (A_CoordModePixel="Window")
    this.WindowToScreen(x, y, x, y, id)
  else if (A_CoordModePixel="Client")
    this.ClientToScreen(x, y, x, y, id)
  if (ScreenShot)
    this.ScreenShot(x, y, x, y)
  return this.GetColor(x, y)
}

; It is not like FindText always use Screen Coordinates,
; But like built-in command ImageSearch using CoordMode Settings
; ImageFile can use "*n *TransBlack/White/RRGGBB-DRDGDB... d:\a.bmp"

ImageSearch(ByRef rx:="", ByRef ry:="", x1:=0, y1:=0, x2:=0, y2:=0
  , ImageFile:="", ScreenShot:=1, FindAll:=0, dir:=1)
{
  local
  dx:=dy:=0
  if (A_CoordModePixel="Window")
    this.WindowToScreen(dx, dy, 0, 0)
  else if (A_CoordModePixel="Client")
    this.ClientToScreen(dx, dy, 0, 0)
  text:=""
  Loop Parse, ImageFile, |
  if (v:=Trim(A_LoopField))!=""
  {
    text.=InStr(v,"$") ? "|" v
    : Format("|##{:06X}",RegExMatch(v,"O)(^|\s)\*(\d+)\s",r)?r[2]*0x010101:0)
    . (RegExMatch(v, "Oi)(^|\s)\*Trans(\S+)\s", r) ? "/" Trim(r[2],"/"):"")
    . "$" Trim(RegExReplace(v,"(^|\s)\*\S+"))
  }
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x1:=y1:=-n, x2:=y2:=n
  if (ok:=this.FindText(,, x1+dx, y1+dy, x2+dx, y2+dy
    , 0, 0, text, ScreenShot, FindAll,,,, dir))
  {
    For k,v in ok  ; you can use ok:=FindText().ok
      v.1-=dx, v.2-=dy, v.x-=dx, v.y-=dy
    rx:=ok[1].1, ry:=ok[1].2, ErrorLevel:=0
    return ok
  }
  else
  {
    rx:=ry:="", ErrorLevel:=1
    return 0
  }
}

; It is not like FindText always use Screen Coordinates,
; But like built-in command PixelSearch using CoordMode Settings
; ColorID can use "RRGGBB-DRDGDB|RRGGBB-DRDGDB", Variation in 0-255

PixelSearch(ByRef rx:="", ByRef ry:="", x1:=0, y1:=0, x2:=0, y2:=0
  , ColorID:="", Variation:=0, ScreenShot:=1, FindAll:=0, dir:=1)
{
  local
  text:=Format("##{:06X}$0/0/", this.Floor(Variation)*0x010101)
  . Trim(StrReplace(ColorID, "|", "/"), " /")
  return this.ImageSearch(rx, ry, x1, y1, x2, y2, text, ScreenShot, FindAll, dir)
}

; Pixel count of certain colors within the range indicated by Screen Coordinates
; ColorID can use "RRGGBB-DRDGDB|RRGGBB-DRDGDB", Variation in 0-255

PixelCount(x1:=0, y1:=0, x2:=0, y2:=0, ColorID:="", Variation:=0, ScreenShot:=1)
{
  local
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy), x-=zx, y-=zy
  sum:=0, VarSetCapacity(s1,4), VarSetCapacity(s0,4)
  ini:={ bits:bits, ss:0, s1:&s1, s0:&s0, allpos:0, allpos_max:0
    , err1:0, err0:0, zoomW:1, zoomH:1 }
  text:=Format("##{:06X}$0/0/", this.Floor(Variation)*0x010101)
  . Trim(StrReplace(StrSplit(ColorID ",", ",")[1], "|", "/"), " /")
  if IsObject(j:=this.PicInfo(text))
    sum:=this.PicFind(ini, j, 1, x, y, w, h)
  return sum
}

; Create color blocks containing a specified number of specified colors
; ColorID can use "RRGGBB-DRDGDB|RRGGBB-DRDGDB", "*128", "**50"
; Count1, Count0 is the minimum number of black and white dots after binarization of this color block

ColorBlock(ColorID, w, h, Count1:=0, Count0:=0)
{
  local
  (Count0>0 && Count1:=0)
  Text:="|<>[" (1-Count1/(w*h)) "," (1-Count0/(w*h)) "]"
  . Trim(StrReplace(ColorID,"|","/")," /") . Format("${:d}.",w)
  . this.bit2base64(StrReplace(Format(Format("{{}:0{:d}d{}}",w*h),0),"0"
  , (Count0>0 ? "0":"1")))
  return Text
}

Click(x:="", y:="", other1:="", other2:="", GoBack:=0)
{
  local
  CoordMode, Mouse, % (bak:=A_CoordModeMouse)?"Screen":"Screen"
  if GoBack
    MouseGetPos, oldx, oldy
  MouseMove, x, y, 0
  Sleep 30
  Click % x "," y "," other1 "," other2
  if GoBack
    MouseMove, oldx, oldy, 0
  CoordMode, Mouse, %bak%
  return 1
}

; Running AHK code dynamically with new threads

Class Thread
{
  __New(args*)
  {
    this.pid:=this.Exec(args*)
  }
  __Delete()
  {
    Process, Close, % this.pid
  }
  Exec(s, Ahk:="", args:="")    ; required AHK v1.1.34+ and Ahk2Exe Use .exe
  {
    local
    Ahk:=Ahk ? Ahk : A_IsCompiled ? A_ScriptFullPath : A_AhkPath
    s:="`nDllCall(""SetWindowText"",""Ptr"",A_ScriptHwnd,""Str"",""<AHK>"")`n"
      . "`nSetBatchLines,-1`n" . s, s:=RegExReplace(s, "\R", "`r`n")
    Try
    {
      shell:=ComObjCreate("WScript.Shell")
      oExec:=shell.Exec("""" Ahk """ /script /force /CP0 * " args)
      oExec.StdIn.Write(s)
      oExec.StdIn.Close(), pid:=oExec.ProcessID
    }
    Catch
    {
      f:=A_Temp "\~ahk.tmp"
      s:="`r`nTry FileDelete " f "`r`n" s
      Try FileDelete % f
      FileAppend % s, % f
      r:=this.Clear.Bind(this)
      SetTimer % r, -3000
      Run "%Ahk%" /script /force /CP0 "%f%" %args%,, UseErrorLevel, pid
    }
    return pid
  }
  Clear()
  {
    Try FileDelete % A_Temp "\~ahk.tmp"
    SetTimer,, Off
  }
}

; FindText().QPC() Use the same as A_TickCount

QPC()
{
  static init, f, c
  if !VarSetCapacity(init) && (init:="1")
    f:=0, c:=DllCall("QueryPerformanceFrequency", "Int64*",f)+(f/=1000)
  return (!DllCall("QueryPerformanceCounter","Int64*",c))*0+(c/f)
}

; FindText().ToolTip() Use the same as ToolTip

ToolTip(s:="", x:="", y:="", num:=1, arg:="")
{
  local
  static init, ini, tip, timer
  if !VarSetCapacity(init) && (init:="1")
    ini:=[], tip:=[], timer:=[]
  f:="ToolTip_" . this.Floor(num)
  if (s="")
  {
    Try tip[f].Destroy()
    ini[f]:="", tip[f]:=""
    return
  }
  ;-----------------
  r1:=A_CoordModeToolTip
  r2:=A_CoordModeMouse
  CoordMode Mouse, Screen
  MouseGetPos x1, y1
  CoordMode Mouse, %r1%
  MouseGetPos x2, y2
  CoordMode Mouse, %r2%
  (x!="" && x:="x" (this.Floor(x)+x1-x2))
  , (y!="" && y:="y" (this.Floor(y)+y1-y2))
  , (x="" && y="" && x:="x" (x1+16) " y" (y1+16))
  ;-----------------
  bgcolor:=arg.bgcolor!="" ? arg.bgcolor : "FAFBFC"
  color:=arg.color!="" ? arg.color : "Black"
  font:=arg.font ? arg.font : "Consolas"
  size:=arg.size ? arg.size : "10"
  bold:=arg.bold ? arg.bold : ""
  trans:=arg.trans!="" ? arg.trans & 255 : 255
  timeout:=arg.timeout!="" ? arg.timeout : ""
  ;-----------------
  r:=bgcolor "|" color "|" font "|" size "|" bold "|" trans "|" s
  if (!ini.HasKey(f) || ini[f]!=r)
  {
    ini[f]:=r
    Try tip[f].Destroy()
    tip[f]:=_Gui:=this.GuiNew()  ; WS_EX_LAYERED:=0x80000, WS_EX_TRANSPARENT:=0x20
    _Gui.Opt("+LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x80020")
    _Gui.MarginX:=2, _Gui.MarginY:=2
    _Gui.BackColor:=bgcolor
    _Gui.SetFont("c" color " s" size " " bold, font)
    _Gui.Add("Text",, s)
    _Gui.Title:=f
    _Gui.Show("Hide")
    WinSet, Transparent, % trans
  }
  tip[f].Opt("+AlwaysOnTop")
  tip[f].Show("NA " x " " y)
  if (timeout)
  {
    (!timer.HasKey(f) && timer[f]:=this.ToolTip.Bind(this,"","","",num))
    , r:=timer[f]
    SetTimer % r, % -Round(Abs(this.Floor(timeout)*1000))-1
  }
}

; FindText().ObjView()  view object values for Debug

ObjView(obj, keyname:="")
{
  local
  if IsObject(obj)  ; thanks lexikos's type(v)
  {
    s:=""
    For k,v in obj
      s.=this.ObjView(v, keyname "[" (StrLen(k)>1000
      || [k].GetCapacity(1) ? """" k """":k) "]")
  }
  else
    s:=keyname ": " (StrLen(obj)>1000
    || [obj].GetCapacity(1) ? """" obj """":obj) "`n"
  if (keyname!="")
    return s
  ;------------------
  _Gui:=this.GuiNew("+AlwaysOnTop")
  _Gui.Add("Button", "y270 w350 gCancel Default", "OK")
  _Gui.Add("Edit", "xp y10 w350 h250 -Wrap -WantReturn")
  _Gui["Edit1"].Value:=s
  _Gui.Title:="Debug view object values"
  _Gui.Show()
  DetectHiddenWindows 0
  WinWaitClose % "ahk_id " _Gui.Hwnd
  _Gui.Destroy()
}

EditScroll(hEdit, regex:="", line:=0, pos:=0)
{
  local
  ControlGetText, s,, ahk_id %hEdit%
  pos:=(regex!="") ? InStr(SubStr(s,1,s~=regex) " ","`n",0,-1)
    : (line>1) ? InStr(s,"`n",0,1,line-1) : pos
  SendMessage, 0xB1, pos, pos,, ahk_id %hEdit%
  SendMessage, 0xB7,,,, ahk_id %hEdit%
}

LastCtrl()
{
  local
  return (G:=this.GuiFromHwnd(WinExist()))[G.LastHwnd]
}

Hide(args*)
{
  WinMinimize
  WinHide
  ToolTip
  DetectHiddenWindows 0
  WinWaitClose % "ahk_id " WinExist()
}

SC(RGB, hwnd)
{
  SendMessage,0x2001,0,(RGB&0xFF)<<16|RGB&0xFF00|(RGB>>16)&0xFF,,% "ahk_id " hwnd
}


;==== Optional GUI interface ====


Gui(cmd, arg1:="", args*)
{
  local
  static
  local bch, cri, lls, _Gui
  ListLines % InStr("MouseMove|ToolTipOff",cmd)?0:A_ListLines
  static init
  if !VarSetCapacity(init) && (init:="1")
  {
    SavePicDir:=A_Temp "\Ahk_ScreenShot\"
    G_ := this.Gui.Bind(this)
    G_G := this.Gui.Bind(this, "G")
    G_Run := this.Gui.Bind(this, "Run")
    G_Show := this.Gui.Bind(this, "Show")
    G_KeyDown := this.Gui.Bind(this, "KeyDown")
    G_LButtonDown := this.Gui.Bind(this, "LButtonDown")
    G_RButtonDown := this.Gui.Bind(this, "RButtonDown")
    G_MouseMove := this.Gui.Bind(this, "MouseMove")
    G_ScreenShot := this.Gui.Bind(this, "ScreenShot")
    G_ShowPic := this.Gui.Bind(this, "ShowPic")
    G_Slider := this.Gui.Bind(this, "Slider")
    G_ToolTip := this.Gui.Bind(this, "ToolTip")
    G_ToolTipOff := this.Gui.Bind(this, "ToolTipOff")
    G_SaveScr := this.Gui.Bind(this, "SaveScr")
    G_PicShowOK := this.Gui.Bind(this, "PicShowOK")
    G_Drag := this.Gui.Bind(this, "Drag")
    FindText_Capture:=FindText_Main:=""
    PrevControl:=x:=y:=oldx:=oldy:=""
    Pics:=[], hBM_old:=dx:=dy:=0
    bch:=A_BatchLines, cri:=A_IsCritical
    Critical
    #NoEnv
    Lang:=this.Lang(,1), Tip_Text:=this.Lang(,2)
    G_.Call("MakeCaptureWindow")
    G_.Call("MakeMainWindow")
    OnMessage(0x100, G_KeyDown)
    OnMessage(0x201, G_LButtonDown)
    OnMessage(0x204, G_RButtonDown)
    OnMessage(0x200, G_MouseMove)
    Menu, Tray, Add
    Menu, Tray, Add, % Lang["s1"], % G_Show
    if (!A_IsCompiled && A_LineFile=A_ScriptFullPath)
    {
      Menu, Tray, Default, % Lang["s1"]
      Menu, Tray, Click, 1
      Menu, Tray, Icon, Shell32.dll, 23
    }
    Critical % cri
    SetBatchLines % bch
    this.GuiNew("+LastFound").Destroy()
  }
  Switch cmd
  {
  Case "G":
    id:=this.LastCtrl()
    Try id.OnEvent("Click", G_Run)
    Catch
      Try id.OnEvent("Change", G_Run)
    return
  Case "Run":
    Critical
    G_.Call(arg1.Name)
    return
  Case "Show":
    FindText_Main.Show(arg1 ? "Center" : "")
    ControlFocus,, % "ahk_id " hscr
    return
  Case "Cancel", "Cancel2":
    WinHide
    return
  Case "MakeCaptureWindow":
    WindowColor:="0xDDEEFF"
    Try FindText_Capture.Destroy()
    FindText_Capture:=_Gui:=this.GuiNew()
    _Gui.Opt("+LastFound +AlwaysOnTop -DPIScale")
    _Gui.MarginX:=15, _Gui.MarginY:=10
    _Gui.BackColor:=WindowColor
    _Gui.SetFont("s12", "Verdana")
    Tab:=_Gui.Add("Tab3", "vMyTab1 -Wrap", StrSplit(Lang["s18"],"|"))
    Tab.UseTab(1)
    C_:=[], Cid_:=[]
    , nW:=71, nH:=25, w:=h:=12, pW:=nW*(w+1)-1, pH:=(nH+1)*(h+1)-1
    id:=_Gui.Add("Text", "w" pW " h" pH), Cid_[id.Hwnd]:=-1
    _Gui.Opt("-Theme")
    ListLines % (lls:=A_ListLines)?0:0
    Loop % nW*(nH+1)
    {
      i:=A_Index, j:=i=1 ? "xp yp Section" : Mod(i,nW)=1 ? "xs y+1":"x+1"
      id:=_Gui.Add("Progress", j " w" w " h" h " -E0x20000 Smooth")
      C_[i]:=id.Hwnd, Cid_[id.Hwnd]:=i
    }
    ListLines % lls
    _Gui.Opt("+Theme")
    _Gui.Add("Slider", "xs w" pW " vMySlider1 +Center Page20 Line10 NoTicks AltSubmit")
    G_G.Call()
    _Gui.Add("Slider", "ys h" pH " vMySlider2 +Center Page20 Line10 NoTicks AltSubmit +Vertical")
    G_G.Call()
    Tab.UseTab(2)
    id:=_Gui.Add("Pic", "w" (pW-135) " h" pH " +Border -Background Section"), hPic:=id.Hwnd
    Pic_hBM:=this.CreateDIBSection(Pic_w:=(pW-135), Pic_h:=pH)
    _Gui.Add("Slider", "xs wp vMySlider3 +Center Page20 Line10 NoTicks AltSubmit")
    G_G.Call()
    _Gui.Add("Slider", "ys h" pH " vMySlider4 +Center Page20 Line10 NoTicks AltSubmit +Vertical")
    G_G.Call()
    _Gui.Add("ListBox", "ys w120 h200 vSelectBox AltSubmit 0x100")
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vClearAll", Lang["ClearAll"])
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vOpenDir", Lang["OpenDir"])
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vLoadPic", Lang["LoadPic"])
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vSavePic", Lang["SavePic"])
    G_G.Call()
    Tab.UseTab()
    ;--------------
    _Gui.Add("Text", "xm Section", Lang["SelGray"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelGray ReadOnly")
    _Gui.Add("Text", "x+15 ys", Lang["SelColor"])
    _Gui.Add("Edit", "x+5 yp-3 w150 vSelColor ReadOnly")
    _Gui.Add("Text", "x+15 ys", Lang["SelR"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelR ReadOnly")
    _Gui.Add("Text", "x+5 ys", Lang["SelG"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelG ReadOnly")
    _Gui.Add("Text", "x+5 ys", Lang["SelB"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelB ReadOnly")
    ;--------------
    id:=_Gui.Add("Button", "xm Hidden Section", Lang["Auto"])
    id.GetPos(pX, pY, pW, pH)
    w:=Round(pW*0.75), i:=Round(w*3+15+pW*0.5-w*1.5)
    _Gui.Add("Button", "xm+" i " yp w" w " hp -Wrap vRepU", Lang["RepU"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutU", Lang["CutU"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutU3", Lang["CutU3"])
    G_G.Call()
    _Gui.Add("Button", "xm wp hp -Wrap vRepL", Lang["RepL"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutL", Lang["CutL"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutL3", Lang["CutL3"])
    G_G.Call()
    _Gui.Add("Button", "x+15 w" pW " hp -Wrap vAuto", Lang["Auto"])
    G_G.Call()
    _Gui.Add("Button", "x+15 w" w " hp -Wrap vRepR", Lang["RepR"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutR", Lang["CutR"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutR3", Lang["CutR3"])
    G_G.Call()
    _Gui.Add("Button", "xm+" i " wp hp -Wrap vRepD", Lang["RepD"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutD", Lang["CutD"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutD3", Lang["CutD3"])
    G_G.Call()
    ;--------------
    Tab:=_Gui.Add("Tab3", "ys -Wrap", StrSplit(Lang["s2"],"|"))
    Tab.UseTab(1)
    _Gui.Add("Text", "x+30 y+35", Lang["Threshold"])
    _Gui.Add("Edit", "x+15 w100 vThreshold")
    _Gui.Add("Button", "x+15 yp-3 vGray2Two", Lang["Gray2Two"])
    G_G.Call()
    Tab.UseTab(2)
    _Gui.Add("Text", "x+30 y+35", Lang["GrayDiff"])
    _Gui.Add("Edit", "x+15 w100 vGrayDiff", "50")
    _Gui.Add("Button", "x+15 yp-3 vGrayDiff2Two", Lang["GrayDiff2Two"])
    G_G.Call()
    Tab.UseTab(3)
    _Gui.Add("Text", "x+10 y+15 Section", Lang["Similar1"] " 0")
    _Gui.Add("Slider", "x+0 w100 vSimilar1 +Center Page1 NoTicks ToolTip")
    G_G.Call()
    _Gui.Add("Text", "x+0", "100")
    _Gui.Add("Button", "x+10 ys-2 vAddColorSim", Lang["AddColorSim"])
    G_G.Call()
    _Gui.Add("Text", "x+25 ys+4", Lang["DiffRGB2"])
    _Gui.Add("Edit", "x+5 ys w80 vDiffRGB2 Limit3")
    _Gui.Add("UpDown", "vdRGB2 Range0-255 Wrap", 50)
    _Gui.Add("Button", "x+10 ys-2 vAddColorDiff", Lang["AddColorDiff"])
    G_G.Call()
    _Gui.Add("Button", "xs vUndo2", Lang["Undo2"])
    G_G.Call()
    _Gui.Add("Edit", "x+10 yp+2 w340 vColorList")
    _Gui.Add("Button", "x+10 yp-2 vColor2Two", Lang["Color2Two"])
    G_G.Call()
    Tab.UseTab(4)
    _Gui.Add("Text", "x+30 y+35", Lang["Similar2"] " 0")
    _Gui.Add("Slider", "x+0 w120 vSimilar2 +Center Page1 NoTicks ToolTip")
    G_G.Call()
    _Gui.Add("Text", "x+0", "100")
    _Gui.Add("Button", "x+15 yp-3 vColorPos2Two", Lang["ColorPos2Two"])
    G_G.Call()
    Tab.UseTab(5)
    _Gui.Add("Text", "x+30 y+15 Section", Lang["Similar3"] " 0")
    _Gui.Add("Slider", "x+0 w120 vSimilar3 +Center Page1 NoTicks ToolTip")
    G_G.Call()
    _Gui.Add("Text", "x+0", "100")
    _Gui.Add("Button", "x+15 ys-2 vUndo", Lang["Undo"])
    G_G.Call()
    _Gui.Add("Checkbox", "xs vMultiColor", Lang["MultiColor"])
    G_G.Call()
    _Gui.Add("Checkbox", "x+50 vFindShape", Lang["FindShape"])
    G_G.Call()
    Tab.UseTab()
    ;--------------
    _Gui.Add("Button", "xm vReset", Lang["Reset"])
    G_G.Call()
    _Gui.Add("Checkbox", "x+15 yp+5 vModify", Lang["Modify"])
    G_G.Call()
    _Gui.Add("Text", "x+30", Lang["Comment"])
    _Gui.Add("Edit", "x+5 yp-2 w250 vComment")
    _Gui.Add("Button", "x+10 yp-3 vSplitAdd", Lang["SplitAdd"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vAllAdd", Lang["AllAdd"])
    G_G.Call()
    _Gui.Add("Button", "x+30 wp vOK", Lang["OK"])
    G_G.Call()
    _Gui.Add("Button", "x+15 wp vCancel", Lang["Cancel"])
    G_G.Call()
    _Gui.Add("Button", "xm vBind0", Lang["Bind0"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind1", Lang["Bind1"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind2", Lang["Bind2"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind3", Lang["Bind3"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind4", Lang["Bind4"])
    G_G.Call()
    _Gui.Add("Button", "x+30 vSavePic2", Lang["SavePic2"])
    G_G.Call()
    _Gui.Title:=Lang["s3"]
    _Gui.Show("Hide")
    _Gui.OnEvent("DropFiles", G_Drag)
    return
  Case "Drag":
    Try G_.Call("LoadPic", args[2][1])
    return
  Case "MakeMainWindow":
    Try FindText_Main.Destroy()
    FindText_Main:=_Gui:=this.GuiNew()
    _Gui.Opt("+LastFound +AlwaysOnTop -DPIScale")
    _Gui.MarginX:=15, _Gui.MarginY:=10
    _Gui.BackColor:=WindowColor
    _Gui.SetFont("s12", "Verdana")
    _Gui.Add("Text", "xm", Lang["NowHotkey"])
    _Gui.Add("Edit", "x+5 w160 vNowHotkey ReadOnly")
    _Gui.Add("Hotkey", "x+5 w160 vSetHotkey1")
    s:="F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|LWin|Ctrl|Shift|Space|MButton"
      . "|ScrollLock|CapsLock|Ins|Esc|BS|Del|Tab|Home|End|PgUp|PgDn"
      . "|NumpadDot|NumpadSub|NumpadAdd|NumpadDiv|NumpadMult"
    _Gui.Add("DDL", "x+5 w160 vSetHotkey2", StrSplit(s,"|"))
    _Gui.Add("Button", "x+15 vApply", Lang["Apply"])
    G_G.Call()
    _Gui.Add("GroupBox", "xm y+0 w280 h55 vMyGroup cBlack")
    _Gui.Add("Text", "xp+15 yp+20 Section", Lang["Myww"] ": ")
    _Gui.Add("Text", "x+0 w80", nW//2)
    _Gui.Add("UpDown", "vMyww Range1-100", nW//2)
    _Gui.Add("Text", "x+15 ys", Lang["Myhh"] ": ")
    _Gui.Add("Text", "x+0 w80", nH//2)
    id:=_Gui.Add("UpDown", "vMyhh Range1-100", nH//2)
    id.GetPos(pX, pY, pW, pH)
    _Gui["MyGroup"].Move(,, pX+pW, pH+30)
    id:=_Gui.Add("Checkbox", "x+100 ys vAddFunc", Lang["AddFunc"] " FindText()")
    id.GetPos(pX, pY, pW, pH)
    pW:=pX+pW-15, pW:=(pW<720?720:pW), w:=pW//5
    _Gui.Add("Button", "xm y+18 w" w " vCutL2", Lang["CutL2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCutR2", Lang["CutR2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCutU2", Lang["CutU2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCutD2", Lang["CutD2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vUpdate", Lang["Update"])
    G_G.Call()
    _Gui.SetFont("s6 bold", "Verdana")
    _Gui.Add("Edit", "xm y+10 w" pW " h260 vMyPic -Wrap HScroll")
    _Gui.SetFont("s12 norm", "Verdana")
    w:=pW//3
    _Gui.Add("Button", "xm w" w " vCapture", Lang["Capture"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vTest", Lang["Test"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCopy", Lang["Copy"])
    G_G.Call()
    _Gui.Add("Button", "xm y+0 wp vCaptureS", Lang["CaptureS"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vGetRange", Lang["GetRange"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vGetOffset", Lang["GetOffset"])
    G_G.Call()
    _Gui.Add("Edit", "xm y+10 w130 hp vClipText")
    _Gui.Add("Button", "x+0 vPaste", Lang["Paste"])
    G_G.Call()
    _Gui.Add("Button", "x+0 vTestClip", Lang["TestClip"])
    G_G.Call()
    id:=_Gui.Add("Button", "x+0 vGetClipOffset", Lang["GetClipOffset"])
    G_G.Call()
    id.GetPos(x,, w)
    w:=((pW+15)-(x+w))//2
    _Gui.Add("Edit", "x+0 w" w " hp vOffset")
    _Gui.Add("Button", "x+0 wp vCopyOffset", Lang["CopyOffset"])
    G_G.Call()
    _Gui.SetFont("cBlue")
    id:=_Gui.Add("Edit", "xm w" pW " h250 vscr -Wrap HScroll"), hscr:=id.Hwnd
    _Gui.Title:=Lang["s4"]
    _Gui.Show("Hide")
    G_.Call("LoadScr")
    OnExit(G_SaveScr)
    return
  Case "LoadScr":
    f:=A_Temp "\~scr1.tmp"
    FileRead, s, % f
    FindText_Main["scr"].Value:=s
    return
  Case "SaveScr":
    f:=A_Temp "\~scr1.tmp"
    s:=FindText_Main["scr"].Value
    Try FileDelete % f
    FileAppend % s, % f
    return
  Case "Capture", "CaptureS":
    _Gui:=FindText_Main
    if show_gui:=WinExist("ahk_id " _Gui.Hwnd)
      this.Hide()
    if (cmd="Capture")
    {
      w:=_Gui["Myww"].Value
      h:=_Gui["Myhh"].Value
      p:=this.GetRange(w, h)
      sx:=p[1], sy:=p[2], sw:=p[3]-p[1]+1, sh:=p[4]-p[2]+1
      , Bind_ID:=p[5], bind_mode:=""
      _Gui:=FindText_Capture
      _Gui["MyTab1"].Choose(1)
    }
    else
    {
      sx:=0, sy:=0, sw:=1, sh:=1, Bind_ID:=WinExist("A"), bind_mode:=""
      _Gui:=FindText_Capture
      _Gui["MyTab1"].Choose(2)
    }
    n:=150000, x:=y:=-n, w:=h:=2*n
    hBM:=this.BitmapFromScreen(x,y,w,h,(arg1=0?0:1))
    Pics:=[], Pics[hBM]:=1, hBM_x:=hBM_y:=0
    G_.Call("CaptureUpdate")
    G_.Call("PicUpdate")
    Names:=["HBITMAP:*" hBM], s:="<New>"
    Loop Files, % SavePicDir "*.bmp"
      Names.Push(v:=A_LoopFileFullPath), s.="|" RegExReplace(v,"i)^.*\\|\.bmp$")
    _Gui["SelectBox"].Delete()
    _Gui["SelectBox"].Add(StrSplit(Trim(s,"|"),"|"))
    ;------------------------
    s:="SelGray|SelColor|SelR|SelG|SelB|Threshold|Comment|ColorList"
    Loop Parse, s, |
      _Gui[A_LoopField].Value:=""
    For k,v in ["Similar1","Similar2","Similar3"]
      _Gui[v].Value:=90
    _Gui["Modify"].Value:=Modify:=0
    _Gui["MultiColor"].Value:=MultiColor:=0
    _Gui["FindShape"].Value:=FindShape:=0
    _Gui["GrayDiff"].Value:=50
    _Gui["Gray2Two"].Opt("+Default")
    _Gui.Show("Center")
    _Gui["Gray2Two"].Focus()
    Event:=Result:=""
    DetectHiddenWindows 0
    Critical, Off
    WinWaitClose % "ahk_id " _Gui.Hwnd
    Critical
    ToolTip
    Pics[hBM]:=1, hBM_old:=0
    For k,v in Pics
      Try DllCall("DeleteObject", "Ptr",k)
    Text:=RegExMatch(Result,"O)\|<[^>\n]*>[^$\n]+\$[^""\r\n]+",r)?r[0]:""
    ;------------------------
    _Gui:=FindText_Main
    if (bind_mode!="")
    {
      WinGetTitle, tt, ahk_id %Bind_ID%
      WinGetClass, tc, ahk_id %Bind_ID%
      tt:=Trim(SubStr(tt,1,30) (tc ? " ahk_class " tc:""))
      tt:=StrReplace(RegExReplace(tt,"[;``]","``$0"),"""","""""")
      Result:="`nSetTitleMatchMode 2`nid:=WinExist(""" tt """)"
        . "`nFindText().BindWindow(id" (bind_mode=0 ? "":"," bind_mode)
        . ")  `; " Lang["s6"] " FindText().BindWindow(0)`n`n" Result
    }
    if (Event="OK")
    {
      s:=""
      if (!A_IsCompiled)
        Try FileRead, s, %A_LineFile%
      re:="Oi)\n\s*FindText[^\n]+args\*[\s\S]*?Script_End[(){}\s]+}"
      s:=RegExMatch(s, re, r) ? "`n;==========`n" r[0] "`n" : ""
      _Gui["scr"].Value:=Result "`n" s
      _Gui["MyPic"].Value:=Trim(this.ASCII(Result),"`n")
    }
    else if (Event="SplitAdd" || Event="AllAdd")
    {
      s:=_Gui["scr"].Value
      r:=SubStr(s, 1, InStr(s,"=FindText("))
      i:=j:=0, re:="<[^>\n]*>[^$\n]+\$[^""\r\n]+"
      While j:=RegExMatch(r, re,, j+1)
        i:=InStr(r, "`n", 0, j)
      _Gui["scr"].Value:=SubStr(s,1,i) . Result . SubStr(s,i+1)
      _Gui["MyPic"].Value:=Trim(this.ASCII(Result),"`n")
    }
    if (Event) && RegExMatch(Result, "O)\$\d+\.[\w+/]{1,100}", r)
      this.EditScroll(hscr, "\Q" r[0] "\E")
    Event:=Result:=s:=""
    ;----------------------
    if (show_gui && arg1="")
      G_Show.Call()
    else Clipboard:=Text
    return Text
  Case "CaptureUpdate":
    nX:=sx, nY:=sy, nW:=sw, nH:=sh
    bits:=this.GetBitsFromScreen(nX,nY,nW,nH,0,zx,zy)
    cors:=[], show:=[], ascii:=[]
    , SelPos:=bg:=color:=Result:=""
    , dx:=dy:=CutLeft:=CutRight:=CutUp:=CutDown:=0
    ListLines % (lls:=A_ListLines)?0:0
    if (nW>0 && nH>0 && bits.Scan0)
    {
      j:=bits.Stride-nW*4, p:=bits.Scan0+(nY-zy)*bits.Stride+(nX-zx)*4-j-4
      Loop % nH + 0*(k:=0)
      Loop % nW + 0*(p+=j)
        show[++k]:=1, cors[k]:=NumGet(0|p+=4,"uint")
    }
    Loop % 25 + 0*(ty:=dy-1)*(k:=0)
    Loop % 71 + 0*(tx:=dx-1)*(ty++)
      this.SC(((++tx)<nW && ty<nH ? cors[ty*nW+tx+1]:WindowColor), C_[++k])
    Loop % 71 + 0*(k:=71*25)
      this.SC(0xFFFFAA, C_[++k])
    ListLines % lls
    _Gui:=FindText_Capture
    _Gui["MySlider1"].Enabled:=nW>71
    _Gui["MySlider2"].Enabled:=nH>25
    _Gui["MySlider1"].Value:=0
    _Gui["MySlider2"].Value:=0
    return
  Case "PicUpdate":
    Try i:=0, i:=Pics.HasKey(hBM_old)
    Try (!i) && DllCall("DeleteObject", "Ptr",hBM_old)
    this.GetBitmapWH(hBM, hBM_w, hBM_h), hBM_old:=hBM
    G_.Call("PicShow", 1)
    return
  Case "MySlider3", "MySlider4":
    hBM_x:=Round(FindText_Capture["MySlider3"].Value*(hBM_w-Pic_w)/100)
    hBM_y:=Round(FindText_Capture["MySlider4"].Value*(hBM_h-Pic_h)/100)
    G_.Call("PicShow")
    return
  Case "PicShow":
    w:=hBM_w-Pic_w, h:=hBM_h-Pic_h
    , hBM_x:=Max(Min(hBM_x,w),0), hBM_y:=Max(Min(hBM_y,h),0)
    if (w<0 || h<0)
      this.DrawHBM(Pic_hBM, [[0, 0, Pic_w, Pic_h, WindowColor]])
    this.CopyHBM(Pic_hBM,0,0,hBM,hBM_x,hBM_y,Min(Pic_w,hBM_w),Min(Pic_h,hBM_h))
    if (arg1)
      G_PicShowOK.Call()
    else
    {
      this.BitmapToWindow(hPic,0,0,Pic_hBM,0,0,Pic_w,Pic_h)
      SetTimer % G_PicShowOK, -1000
    }
    FindText_Capture["MySlider3"].Value:=w>0?Round(hBM_x/w*100):0
    FindText_Capture["MySlider4"].Value:=h>0?Round(hBM_y/h*100):0
    return
  Case "PicShowOK":
    FindText_Capture[hPic].Value:="*w0 *h0 HBITMAP:*" Pic_hBM
    return
  Case "Reset":
    G_.Call("CaptureUpdate")
    return
  Case "LoadPic":
    FindText_Capture.Opt("+OwnDialogs")
    f:=arg1
    if (f="")
    {
      if !FileExist(SavePicDir)
        FileCreateDir % SavePicDir
      f:=SavePicDir "*.bmp"
      Loop Files, % f
        f:=A_LoopFileFullPath
      FileSelectFile, f,, %f%, Select Picture
    }
    if !InStr(f,"HBITMAP:") && !FileExist(f)
    {
      MsgBox, 4096, Tip, % Lang["s17"]
      return
    }
    if !this.ShowPic(f, 0, sx, sy, sw, sh)
      return
    hBM:=this.BitmapFromScreen(sx, sy, sw, sh, 0)
    sw:=Min(sw,71), sh:=Min(sh,25)
    G_.Call("CaptureUpdate")
    G_.Call("PicUpdate")
    return
  Case "SavePic":
    FindText_Capture.Hide()
    this.ScreenShot(), this.ShowPic("HBITMAP:*" hBM)
    Try this.GuiFromHwnd(WinExist("Show Pic")).Opt("+OwnDialogs")
    Loop
    {
      p:=this.GetRange2()
      MsgBox, 4099, Tip, % Lang["s15"]
      IfMsgBox, No
        Continue
      Break
    }
    IfMsgBox, Yes
      G_.Call("ScreenShot", p[1] "|" p[2] "|" p[3] "|" p[4] "|0")
    this.ShowPic()
    return
  Case "SelectBox":
    SelectBox:=FindText_Capture["SelectBox"].Value
    Try f:="", f:=Names[SelectBox]
    if (f!="")
      G_.Call("LoadPic", f)
    return
  Case "ClearAll":
    FindText_Capture.Opt("+OwnDialogs")
    MsgBox, 4100, Tip, % Lang["s19"]
    IfMsgBox, Yes
    {
      FindText_Capture.Hide()
      FileDelete % SavePicDir "*.bmp"
    }
    return
  Case "OpenDir":
    if !FileExist(SavePicDir)
      FileCreateDir % SavePicDir
    Run % SavePicDir
    return
  Case "GetRange":
    _Gui:=FindText_Main
    _Gui.Opt("+LastFound")
    this.Hide()
    p:=this.GetRange2(), v:=p[1] ", " p[2] ", " p[3] ", " p[4]
    s:=_Gui["scr"].Value
    re:="i)(=FindText\([^\n]*?)([^(,\n]*,){4}([^,\n]*,[^,\n]*,[^,\n]*Text)"
    if SubStr(s,1,s~="i)\n\s*FindText[^\n]+args\*")~=re
    {
      s:=RegExReplace(s, re, "$1 " v ",$3",, 1)
      _Gui["scr"].Value:=s
    }
    _Gui["Offset"].Value:=v
    G_Show.Call()
    return
  Case "Test", "TestClip":
    _Gui:=FindText_Main
    _Gui.Opt("+LastFound")
    this.Hide()
    ;----------------------
    if (cmd="Test")
      s:=_Gui["scr"].Value
    else
      s:=_Gui["ClipText"].Value
    if (cmd="Test") && InStr(s, "MCode(")
    {
      s:="`n#NoEnv`nMenu, Tray, Click, 1`n" s "`nExitApp`n"
      Thread1:=new this.Thread(s)
      DetectHiddenWindows, 1
      WinWait % "ahk_class AutoHotkey ahk_pid " Thread1.pid,, 3
      if (!ErrorLevel)
        WinWaitClose,,, 30
      ; Thread1:=""  ; kill the Thread
    }
    else
    {
      t:=A_TickCount, v:=X:=Y:=""
      if RegExMatch(s, "O)<[^>\n]*>[^$\n]+\$[^""\r\n]+", r)
        v:=this.FindText(X, Y, 0,0,0,0, 0,0, r[0])
      r:=StrSplit(Lang["s8"] "||||", "|")
      MsgBox, 4096, Tip, % r[1] ":`t" (IsObject(v)?v.Length():v) "`n`n"
        . r[2] ":`t" (A_TickCount-t) " " r[3] "`n`n"
        . r[4] ":`t" X ", " Y "`n`n"
        . r[5] ":`t<" (IsObject(v)?v[1].id:"") ">", 3
      Try For i,j in v
        if (i<=2)
          this.MouseTip(j.x, j.y)
      v:="", Clipboard:=X "," Y
    }
    ;----------------------
    G_Show.Call()
    return
  Case "GetOffset", "GetClipOffset":
    FindText_Main.Hide()
    p:=this.GetRange()
    _Gui:=FindText_Main
    if (cmd="GetOffset")
      s:=_Gui["scr"].Value
    else
      s:=_Gui["ClipText"].Value
    if RegExMatch(s, "O)<[^>\n]*>[^$\n]+\$[^""\r\n]+", r)
    && this.FindText(X, Y, 0,0,0,0, 0,0, r[0])
    {
      r:=StrReplace("X+" ((p[1]+p[3])//2-X)
        . ", Y+" ((p[2]+p[4])//2-Y), "+-", "-")
      if (cmd="GetOffset")
      {
        re:="i)(\(\)\.\w*Click\w*\()[^,\n]*,[^,)\n]*"
        if SubStr(s,1,s~="i)\n\s*FindText[^\n]+args\*")~=re
          s:=RegExReplace(s, re, "$1" r,, 1)
        _Gui["scr"].Value:=s
      }
      _Gui["Offset"].Value:=r
    }
    s:="", G_Show.Call()
    return
  Case "Paste":
    if RegExMatch(Clipboard, "O)\|?<[^>\n]*>[^$\n]+\$[^""\r\n]+", r)
    {
      FindText_Main["ClipText"].Value:=r[0]
      FindText_Main["MyPic"].Value:=Trim(this.ASCII(r[0]),"`n")
    }
    return
  Case "CopyOffset":
    Clipboard:=FindText_Main["Offset"].Value
    return
  Case "Copy":
    ControlGet, s, Selected,,, ahk_id %hscr%
    if (s="")
    {
      s:=FindText_Main["scr"].Value
      r:=FindText_Main["AddFunc"].Value
      if (r != 1)
        s:=RegExReplace(s, "i)\n\s*FindText[^\n]+args\*[\s\S]*")
        , s:=RegExReplace(s, "i)\n; ok:=FindText[\s\S]*")
        , s:=SubStr(s, (s~="i)\n[ \t]*Text"))
    }
    Clipboard:=RegExReplace(s, "\R", "`r`n")
    ControlFocus,, % "ahk_id " hscr
    return
  Case "Apply":
    _Gui:=FindText_Main
    NowHotkey:=_Gui["NowHotkey"].Value
    SetHotkey1:=_Gui["SetHotkey1"].Value
    SetHotkey2:=_Gui["SetHotkey2"].Text
    if (NowHotkey!="")
      Hotkey, *%NowHotkey%,, Off UseErrorLevel
    k:=SetHotkey1!="" ? SetHotkey1 : SetHotkey2
    if (k!="")
      Hotkey, *%k%, %G_ScreenShot%, On UseErrorLevel
    _Gui["NowHotkey"].Value:=k
    _Gui["SetHotkey1"].Value:=""
    _Gui["SetHotkey2"].Choose(0)
    return
  Case "ScreenShot":
    Critical
    if !FileExist(SavePicDir)
      FileCreateDir % SavePicDir
    Loop
      f:=SavePicDir . Format("{:03d}.bmp",A_Index)
    Until !FileExist(f)
    this.SavePic(f, StrSplit(arg1,"|")*)
    CoordMode, ToolTip
    this.ToolTip(Lang["s9"],, 0,, { bgcolor:"Yellow", color:"Red"
      , size:48, bold:"bold", trans:200, timeout:0.2 })
    return
  Case "Bind0", "Bind1", "Bind2", "Bind3", "Bind4":
    this.BindWindow(Bind_ID, bind_mode:=SubStr(cmd,5))
    n:=150000, x:=y:=-n, w:=h:=2*n
    hBM:=this.BitmapFromScreen(x,y,w,h,1)
    G_.Call("PicUpdate")
    FindText_Capture["MyTab1"].Choose(2)
    this.BindWindow(0)
    return
  Case "MySlider1", "MySlider2":
    SetTimer % G_Slider, -10
    return
  Case "Slider":
    Critical
    dx:=nW>71 ? Round(FindText_Capture["MySlider1"].Value*(nW-71)/100):0
    dy:=nH>25 ? Round(FindText_Capture["MySlider2"].Value*(nH-25)/100):0
    if (oldx=dx && oldy=dy)
      return
    ListLines % (lls:=A_ListLines)?0:0
    Loop % 25 + 0*(ty:=dy-1)*(k:=0)
    Loop % 71 + 0*(tx:=dx-1)*(ty++)
      this.SC(((++tx)>=nW || ty>=nH || !show[i:=ty*nW+tx+1]
      ? WindowColor : bg="" ? cors[i] : ascii[i] ? 0:0xFFFFFF), C_[++k])
    Loop % 71*(oldx!=dx) + 0*(i:=nW*nH+dx)*(k:=71*25)
      this.SC((show[++i]?0xFF0000:0xFFFFAA), C_[++k])
    ListLines % lls
    oldx:=dx, oldy:=dy
    return
  Case "RepColor", "CutColor":
    if (cmd="RepColor")
      show[k]:=1, c:=(bg="" ? cors[k] : ascii[k] ? 0:0xFFFFFF)
    else
      show[k]:=0, c:=WindowColor
    if (tx:=Mod(k-1,nW)-dx)>=0 && tx<71 && (ty:=(k-1)//nW-dy)>=0 && ty<25
      this.SC(c, C_[ty*71+tx+1])
    return
  Case "RepL":
    if (CutLeft<=0) || (bg!="" && InStr(color,"**") && CutLeft=1)
      return
    k:=CutLeft-nW, CutLeft--
    Loop % nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("RepColor"))
    return
  Case "CutL":
    if (CutLeft+CutRight>=nW)
      return
    CutLeft++, k:=CutLeft-nW
    Loop % nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("CutColor"))
    return
  Case "CutL3":
    Loop 3
      G_.Call("CutL")
    return
  Case "RepR":
    if (CutRight<=0) || (bg!="" && InStr(color,"**") && CutRight=1)
      return
    k:=1-CutRight, CutRight--
    Loop % nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("RepColor"))
    return
  Case "CutR":
    if (CutLeft+CutRight>=nW)
      return
    CutRight++, k:=1-CutRight
    Loop % nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("CutColor"))
    return
  Case "CutR3":
    Loop 3
      G_.Call("CutR")
    return
  Case "RepU":
    if (CutUp<=0) || (bg!="" && InStr(color,"**") && CutUp=1)
      return
    k:=(CutUp-1)*nW, CutUp--
    Loop % nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("RepColor"))
    return
  Case "CutU":
    if (CutUp+CutDown>=nH)
      return
    CutUp++, k:=(CutUp-1)*nW
    Loop % nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("CutColor"))
    return
  Case "CutU3":
    Loop 3
      G_.Call("CutU")
    return
  Case "RepD":
    if (CutDown<=0) || (bg!="" && InStr(color,"**") && CutDown=1)
      return
    k:=(nH-CutDown)*nW, CutDown--
    Loop % nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("RepColor"))
    return
  Case "CutD":
    if (CutUp+CutDown>=nH)
      return
    CutDown++, k:=(nH-CutDown)*nW
    Loop % nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("CutColor"))
    return
  Case "CutD3":
    Loop 3
      G_.Call("CutD")
    return
  Case "Gray2Two":
    ListLines % (lls:=A_ListLines)?0:0
    gs:=[], k:=0
    Loop % nW*nH
      gs[++k]:=((((c:=cors[k])>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    _Gui:=FindText_Capture
    _Gui["Threshold"].Focus()
    Threshold:=_Gui["Threshold"].Value
    if (Threshold="")
    {
      pp:=[]
      Loop 256
        pp[A_Index-1]:=0
      Loop % nW*nH
        if (show[A_Index])
          pp[gs[A_Index]]++
      IP0:=IS0:=0
      Loop 256
        k:=A_Index-1, IP0+=k*pp[k], IS0+=pp[k]
      Threshold:=Floor(IP0/IS0)
      Loop 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop % LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP0-IP1, IS2:=IS0-IS1
        if (IS1!=0 && IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
      _Gui["Threshold"].Value:=Threshold
    }
    Threshold:=Round(Threshold)
    color:="*" Threshold, k:=i:=0
    Loop % nW*nH
      ascii[++k]:=v:=(gs[k]<=Threshold)
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines % lls
    return
  Case "GrayDiff2Two":
    _Gui:=FindText_Capture
    GrayDiff:=_Gui["GrayDiff"].Value
    if (GrayDiff="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s11"], 1
      return
    }
    ListLines % (lls:=A_ListLines)?0:0
    gs:=[], k:=0
    Loop % nW*nH
      gs[++k]:=((((c:=cors[k])>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    if (CutLeft=0)
      G_.Call("CutL")
    if (CutRight=0)
      G_.Call("CutR")
    if (CutUp=0)
      G_.Call("CutU")
    if (CutDown=0)
      G_.Call("CutD")
    GrayDiff:=Round(GrayDiff)
    color:="**" GrayDiff, k:=i:=0
    Loop % nW*nH
      j:=gs[++k]+GrayDiff
      , ascii[k]:=v:=( gs[k-1]>j || gs[k+1]>j
      || gs[k-nW]>j || gs[k+nW]>j
      || gs[k-nW-1]>j || gs[k-nW+1]>j
      || gs[k+nW-1]>j || gs[k+nW+1]>j )
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines % lls
    return
  Case "AddColorSim", "AddColorDiff":
    _Gui:=FindText_Capture
    c:=StrReplace(_Gui["SelColor"].Value, "0x")
    if (c="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s12"], 1
      return
    }
    s:=RegExReplace(_Gui["ColorList"].Value, "i)\s|0x")
    if InStr(cmd, "Sim")
      v:=_Gui["Similar1"].Value, v:=c "-" Round(v/100,2)
    else
      v:=_Gui["dRGB2"].Value, v:=c "-" Format("{:06X}",v<<16|v<<8|v)
    s:=RegExReplace(RegExReplace(s,c "-[^/]*") "/" v, "//+", "/")
    _Gui["ColorList"].Value:=Trim(s,"/")
    ControlSend,, {End}, % "ahk_id " _Gui["ColorList"].Hwnd
    G_.Call("Color2Two")
    return
  Case "Undo2":
    _Gui:=FindText_Capture
    s:=_Gui["ColorList"].Value
    s:=RegExReplace("/" s, "/[^/]+$")
    _Gui["ColorList"].Value:=Trim(s,"/")
    ControlSend,, {End}, % "ahk_id " _Gui["ColorList"].Hwnd
    return
  Case "Color2Two":
    _Gui:=FindText_Capture
    color:=Trim(RegExReplace(_Gui["ColorList"].Value, "i)\s|0x"), "/")
    if (color="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s16"], 1
      return
    }
    ListLines % (lls:=A_ListLines)?0:0
    k:=i:=v:=0, arr:=StrSplit(StrReplace(color,"@","-"), "/")
    j:=InStr(color,"-")!=1
    Loop % nW*nH
    {
      c:=cors[++k], rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
      For k1,v1 in arr
      {
        r:=StrSplit(Trim(v1,"-") "-", "-"), c:=this.ToRGB(r[1]), n:=r[2]
        , r:=((c>>16)&0xFF)-rr, g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
        if InStr(n, ".")
        {
          n:=this.Floor(n), n:=(n<=0||n>1?0:Floor(4606*255*255*(1-n)*(1-n)))
          if v:=((1024+(r+rr+rr))*r*r+2048*g*g+(1534-(r+rr+rr))*b*b<=n)
            Break
        }
        else
        {
          c:=this.Floor("0x" n), dR:=(c>>16)&0xFF, dG:=(c>>8)&0xFF, dB:=c&0xFF
          if v:=(Abs(r)<=dR && Abs(g)<=dG && Abs(b)<=dB)
            Break
        }
      }
      ascii[k]:=v:=(v=j), (show[k] && i:=(v?i+1:i-1))
    }
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines % lls
    return
  Case "ColorPos2Two":
    _Gui:=FindText_Capture
    c:=_Gui["SelColor"].Value
    if (c="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s12"], 1
      return
    }
    n:=_Gui["Similar2"].Value, n:=Round(n/100,2), color:="#" c "-" n
    , n:=(n<=0||n>1?0:Floor(4606*255*255*(1-n)*(1-n)))
    , rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF, k:=i:=0
    ListLines % (lls:=A_ListLines)?0:0
    Loop % nW*nH
      c:=cors[++k], r:=((c>>16)&0xFF)-rr, g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
      , ascii[k]:=v:=((1024+(r+rr+rr))*r*r+2048*g*g+(1534-(r+rr+rr))*b*b<=n)
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines % lls
    return
  Case "BlackWhite":
    Loop % 25 + 0*(ty:=dy-1)*(k:=0)
    Loop % 71 + 0*(tx:=dx-1)*(ty++)
    if (k++)*0 + (++tx)<nW && ty<nH && show[i:=ty*nW+tx+1]
      this.SC((ascii[i]?0:0xFFFFFF), C_[k])
    return
  Case "Modify":
    Modify:=FindText_Capture["Modify"].Value
    return
  Case "MultiColor":
    MultiColor:=FindText_Capture["MultiColor"].Value
    Result:=""
    ToolTip
    return
  Case "FindShape":
    FindShape:=FindText_Capture["FindShape"].Value
    (FindShape && !MultiColor) && FindText_Capture["MultiColor"].Value:=MultiColor:=1
    return
  Case "Undo":
    Result:=RegExReplace(Result, ",[^/]+/[^/]+/[^/]+$")
    ToolTip % Trim(Result, ",")
    return
  Case "Similar1", "Similar2", "Similar3":
    i:=FindText_Capture[cmd].Value
    For k,v in ["Similar1","Similar2","Similar3"]
      (v!=cmd) && FindText_Capture[v].Value:=i
    return
  Case "GetTxt":
    txt:=""
    if (bg="")
      return
    k:=0
    ListLines % (lls:=A_ListLines)?0:0
    Loop % nH
    {
      v:=""
      Loop % nW
        v.=!show[++k] ? "" : ascii[k] ? "1":"0"
      txt.=v="" ? "" : v "`n"
    }
    ListLines % lls
    return
  Case "Auto":
    G_.Call("GetTxt")
    if (txt="")
    {
      FindText_Capture.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s13"], 1
      return
    }
    While InStr(txt,bg)
    {
      if (txt~="^" bg "+\n")
        txt:=RegExReplace(txt, "^" bg "+\n"), G_.Call("CutU")
      else if !(txt~="m`n)[^\n" bg "]$")
        txt:=RegExReplace(txt, "m`n)" bg "$"), G_.Call("CutR")
      else if (txt~="\n" bg "+\n$")
        txt:=RegExReplace(txt, "\n\K" bg "+\n$"), G_.Call("CutD")
      else if !(txt~="m`n)^[^\n" bg "]")
        txt:=RegExReplace(txt, "m`n)^" bg), G_.Call("CutL")
      else Break
    }
    txt:=""
    return
  Case "OK", "SplitAdd", "AllAdd":
    _Gui:=FindText_Capture
    _Gui.Opt("+OwnDialogs")
    G_.Call("GetTxt")
    if (txt="") && (!MultiColor)
    {
      MsgBox, 4096, Tip, % Lang["s13"], 1
      return
    }
    if InStr(color,"#") && (!MultiColor)
    {
      k:=i:=j:=0
      ListLines % (lls:=A_ListLines)?0:0
      Loop % nW*nH
      {
        if (!show[++k])
          Continue
        i++
        if (k=SelPos)
        {
          j:=i
          Break
        }
      }
      ListLines % lls
      if (j=0)
      {
        MsgBox, 4096, Tip, % Lang["s12"], 1
        return
      }
      color:="#" j "-" StrSplit(color "-","-")[2]
    }
    Comment:=_Gui["Comment"].Value
    if (cmd="SplitAdd") && (!MultiColor)
    {
      if InStr(color,"#")
      {
        MsgBox, 4096, Tip, % Lang["s14"], 3
        return
      }
      bg:=StrLen(StrReplace(txt,"0"))
        > StrLen(StrReplace(txt,"1")) ? "1":"0"
      s:="", i:=0, k:=nW*nH+1+CutLeft
      Loop % w:=nW-CutLeft-CutRight
      {
        i++
        if (!show[k++] && A_Index<w)
          Continue
        i:=Format("{:d}",i)
        v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
        txt:=RegExReplace(txt,"m`n)^.{" i "}"), i:=0
        While InStr(v,bg)
        {
          if (v~="^" bg "+\n")
            v:=RegExReplace(v,"^" bg "+\n")
          else if !(v~="m`n)[^\n" bg "]$")
            v:=RegExReplace(v,"m`n)" bg "$")
          else if (v~="\n" bg "+\n$")
            v:=RegExReplace(v,"\n\K" bg "+\n$")
          else if !(v~="m`n)^[^\n" bg "]")
            v:=RegExReplace(v,"m`n)^" bg)
          else Break
        }
        if (v!="")
        {
          v:=Format("{:d}.",InStr(v,"`n")-1) . this.bit2base64(v)
          s.="`nText.=""|<" SubStr(Comment,1,1) ">" color "$" v """`n"
          Comment:=SubStr(Comment, 2)
        }
      }
      Event:=cmd, Result:=s
      _Gui.Hide()
      return
    }
    if (!MultiColor)
      txt:=Format("{:d}.",InStr(txt,"`n")-1) . this.bit2base64(txt)
    else
    {
      n:=_Gui["Similar3"].Value, n:=Round(n/100,2), color:="##" n
      , n:=(n<=0||n>1?0:Floor(4606*255*255*(1-n)*(1-n)))
      , arr:=StrSplit(Trim(StrReplace(Result,",","/"),"/"),"/"), s:="", i:=1
      SetFormat, IntegerFast, d
      Loop % arr.Length()//3
        x1:=arr[i++], y1:=arr[i++], c1:=arr[i++], c:="0x" c1
        , (A_Index=1 && (x:=x1, y:=y1, rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF))
        , r:=((c>>16)&0xFF)-rr, g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
        , s.="," (x1-x) "/" (y1-y) "/" (FindShape
        ? (1024+(r+rr+rr))*r*r+2048*g*g+(1534-(r+rr+rr))*b*b<=n:c1)
      txt:=SubStr(s,2)
    }
    s:="`nText.=""|<" Comment ">" color "$" txt """`n"
    if (cmd="SplitAdd" || cmd="AllAdd")
    {
      Event:=cmd, Result:=s
      _Gui.Hide()
      return
    }
    x:=nX+CutLeft+(nW-CutLeft-CutRight)//2
    y:=nY+CutUp+(nH-CutUp-CutDown)//2
    s:=StrReplace(s, "Text.=", "Text:="), r:=StrSplit(Lang["s8"] "|||||||", "|")
    s:="`; #Include <FindText>`nFindText(,,0)`n"
    . "`nt1:=A_TickCount, Text:=X:=Y:=""""`n" s
    . "`nif (ok:=FindText(X, Y, " x "-150000, "
    . y "-150000, " x "+150000, " y "+150000, 0, 0, Text))"
    . "`n{"
    . "`n  `; FindText()." . "Click(" . "X, Y, ""L"")"
    . "`n}`n"
    . "`n`; ok:=FindText(X:=""wait"", Y:=3, 0,0,0,0,0,0,Text)    `; " r[7]
    . "`n`; ok:=FindText(X:=""wait0"", Y:=-1, 0,0,0,0,0,0,Text)  `; " r[8]
    . "`n`nMsgBox, 4096, Tip, `% """ r[1] ":``t"" (IsObject(ok)?ok.Length():ok)"
    . "`n  . ""``n``n" r[2] ":``t"" (A_TickCount-t1) "" " r[3] """"
    . "`n  . ""``n``n" r[4] ":``t"" X "", "" Y"
    . "`n  . ""``n``n" r[5] ":``t<"" (IsObject(ok)?ok[1].id:"""") "">""`n"
    . "`nTry For i,v in ok  `; ok " r[6] " ok:=FindText().ok"
    . "`n  if (i<=2)"
    . "`n    FindText().MouseTip(ok[i].x, ok[i].y)`n"
    Event:=cmd, Result:=s
    _Gui.Hide()
    return
  Case "SavePic2":
    x:=nX+CutLeft, w:=nW-CutLeft-CutRight
    y:=nY+CutUp, h:=nH-CutUp-CutDown
    G_.Call("ScreenShot", x "|" y "|" (x+w-1) "|" (y+h-1) "|0")
    return
  Case "ShowPic":
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    FindText_Main["MyPic"].Value:=Trim(this.ASCII(s),"`n")
    return
  Case "KeyDown":
    Critical
    _Gui:=FindText_Main
    if (WinExist()!=_Gui.Hwnd)
      return
    Try ctrl:="", ctrl:=args[3]
    if (ctrl=hscr)
      SetTimer % G_ShowPic, -150
    else if (ctrl=_Gui["ClipText"].Hwnd)
    {
      s:=_Gui["ClipText"].Value
      _Gui["MyPic"].Value:=Trim(this.ASCII(s),"`n")
    }
    return
  Case "LButtonDown":
    Critical
    if (WinExist()!=FindText_Capture.Hwnd)
      return G_.Call("KeyDown", arg1, args*)
    CoordMode, Mouse
    MouseGetPos, k1, k2,, k6, 2
    if (k6=hPic)
    {
      ListLines % (lls:=A_ListLines)?0:0
      Loop
      {
        Sleep 50
        MouseGetPos, k3, k4
        this.RangeTip(Min(k1,k3), Min(k2,k4)
        , Abs(k1-k3)+1, Abs(k2-k4)+1, (A_MSec<500 ? "Red":"Blue"))
      }
      Until !this.State("LButton")
      ListLines % lls
      this.RangeTip()
      this.GetBitsFromScreen(,,,,0,zx,zy)
      this.ClientToScreen(sx, sy, 0, 0, hPic)
      sx:=Min(k1,k3)-sx+hBM_x+zx, sy:=Min(k2,k4)-sy+hBM_y+zy
      , sw:=Abs(k1-k3)+1, sh:=Abs(k2-k4)+1
      if (sw+sh)<5
        sx-=71//2, sy-=25//2, sw:=71, sh:=25
      G_.Call("CaptureUpdate")
      FindText_Capture["MyTab1"].Choose(1)
      return
    }
    if !(Cid_.HasKey(k6) && k5:=Cid_[k6])
      return
    if (k5=-1)
    {
      MouseMove, k1+2, k2+2, 0
      MouseGetPos,,,, k6, 2
      MouseMove, k1, k2, 0
      if !(Cid_.HasKey(k6) && k5:=Cid_[k6]) || (k5=-1)
        return
    }
    if (k5>71*25)
    {
      k1:=nW*nH+dx+(k5-71*25)
      this.SC(((show[k1]:=!show[k1])?0xFF0000:0xFFFFAA), k6)
      return
    }
    k3:=Mod(k5-1,71)+dx, k4:=(k5-1)//71+dy
    if (k3>=nW || k4>=nH)
      return
    k1:=k4*nW+k3+1
    if (Modify && bg!="" && show[k1])
      this.SC(((ascii[k1]:=!ascii[k1])?0:0xFFFFFF), k6)
    else
    {
      k2:=cors[k1], SelPos:=k1
      _Gui:=FindText_Capture
      _Gui["SelGray"].Value:=(((k2>>16)&0xFF)*38+((k2>>8)&0xFF)*75+(k2&0xFF)*15)>>7
      _Gui["SelColor"].Value:=Format("0x{:06X}",k2&0xFFFFFF)
      _Gui["SelR"].Value:=(k2>>16)&0xFF
      _Gui["SelG"].Value:=(k2>>8)&0xFF
      _Gui["SelB"].Value:=k2&0xFF
    }
    if (MultiColor && show[k1])
    {
      (FindShape && Result="") && G_.Call("ColorPos2Two")
      k2:=Format(",{:d}/{:d}/{:06X}", nX+k3, nY+k4, cors[k1]&0xFFFFFF)
      , Result.=InStr(Result,k2) ? "":k2
      ToolTip % Trim(Result, ",")
    }
    return
  Case "RButtonDown":
    Critical
    MouseGetPos,,,, k2, 2
    if (k2!=hPic)
      return
    CoordMode, Mouse
    MouseGetPos, k1, k2
    k5:=hBM_x, k6:=hBM_y
    ListLines % (lls:=A_ListLines)?0:0
    Loop
    {
      Sleep 10
      MouseGetPos, k3, k4
      hBM_x:=k5+k1-k3, hBM_y:=k6+k2-k4
      G_.Call("PicShow")
    }
    Until !this.State("RButton")
    ListLines % lls
    return
  Case "MouseMove":
    Try ctrl_name:="", ctrl_name:=this.GuiCtrlFromHwnd(args[3]).Name
    if (PrevControl != ctrl_name)
    {
      ToolTip
      PrevControl:=ctrl_name
      Try SetTimer % G_ToolTip, % (PrevControl ? -500:"Off")
      Try SetTimer % G_ToolTipOff, % (PrevControl ? -5500:"Off")
    }
    return
  Case "ToolTip":
    MouseGetPos,,, _TT
    if WinExist("ahk_id " _TT " ahk_class AutoHotkeyGUI")
      Try ToolTip % Tip_Text[PrevControl]
    return
  Case "ToolTipOff":
    ToolTip
    return
  Case "CutL2", "CutR2", "CutU2", "CutD2":
    s:=FindText_Main["MyPic"].Value
    s:=Trim(s,"`n") . "`n", v:=SubStr(cmd,4,1)
    if (v="U")
      s:=RegExReplace(s,"^[^\n]+\n")
    else if (v="D")
      s:=RegExReplace(s,"[^\n]+\n$")
    else if (v="L")
      s:=RegExReplace(s,"m`n)^[^\n]")
    else if (v="R")
      s:=RegExReplace(s,"m`n)[^\n]$")
    FindText_Main["MyPic"].Value:=Trim(s,"`n")
    return
  Case "Update":
    ControlFocus,, % "ahk_id " hscr
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    if !RegExMatch(s, "O)(<[^>\n]*>[^$\n]+\$)\d+\.[\w+/]+", r)
      return
    v:=FindText_Main["MyPic"].Value
    v:=Trim(v,"`n") . "`n", w:=Format("{:d}",InStr(v,"`n")-1)
    v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    s:=StrReplace(s, r[0], r[1] . w "." this.bit2base64(v))
    v:="{End}{Shift Down}{Home}{Shift Up}{Del}"
    ControlSend,, %v%, ahk_id %hscr%
    Control, EditPaste, %s%,, ahk_id %hscr%
    ControlSend,, {Home}, ahk_id %hscr%
    return
  }
}

Lang(text:="", getLang:=0)
{
  local
  static init, Lang1, Lang2
  if !VarSetCapacity(init) && (init:="1")
  {
    s:="
    (
Myww       = Width = Adjust the width of the capture range
Myhh       = Height = Adjust the height of the capture range
AddFunc    = Add = Additional FindText() in Copy
NowHotkey  = Hotkey = Current screenshot hotkey
SetHotkey1 = = First sequence Screenshot hotkey
SetHotkey2 = = Second sequence Screenshot hotkey
Apply      = Apply = Apply new screenshot hotkey
CutU2      = CutU = Cut the Upper Edge of the text in the edit box below
CutL2      = CutL = Cut the Left Edge of the text in the edit box below
CutR2      = CutR = Cut the Right Edge of the text in the edit box below
CutD2      = CutD = Cut the Lower Edge of the text in the edit box below
Update     = Update = Update the text in the edit box below to the line of Code
GetRange   = GetRange = Get screen range to Clipboard and update the search range of the Code
GetOffset  = GetOffset = Get position offset relative to the Text from the Code and update FindText().Click()
GetClipOffset  = GetOffset2 = Get position offset relative to the Text from the Left Box
Capture    = Capture = Initiate Image Capture Sequence
CaptureS   = CaptureS = Restore the Saved ScreenShot by Hotkey and then start capturing
Test       = Test = Test the Text from the Code to see if it can be found on the screen
TestClip   = Test2 = Test the Text from the Left Box and copy the result to Clipboard
Paste      = Paste = Paste the Text from Clipboard to the Left Box
CopyOffset = Copy2 = Copy the Offset to Clipboard
Copy       = Copy = Copy the selected or all of the code to the clipboard
Reset      = Reset = Reset to Original Captured Image
SplitAdd   = SplitAdd = Using Markup Segmentation to Generate Text Library
AllAdd     = AllAdd = Append Another FindText Search Text into Previously Generated Code
Gray2Two      = Gray2Two = Converts Image Pixels from Gray Threshold to Black or White
GrayDiff2Two  = GrayDiff2Two = Converts Image Pixels from Gray Difference to Black or White
Color2Two     = Color2Two = Converts Image Pixels from Color List to Black or White
ColorPos2Two  = ColorPos2Two = Converts Image Pixels from Color Position to Black or White
SelGray    = Gray = Gray value of the selected color
SelColor   = Color = The selected color
SelR       = R = Red component of the selected color
SelG       = G = Green component of the selected color
SelB       = B = Blue component of the selected color
RepU       = -U = Undo Cut the Upper Edge by 1
CutU       = U = Cut the Upper Edge by 1
CutU3      = U3 = Cut the Upper Edge by 3
RepL       = -L = Undo Cut the Left Edge by 1
CutL       = L = Cut the Left Edge by 1
CutL3      = L3 = Cut the Left Edge by 3
Auto       = Auto = Automatic Cut Edge after image has been converted to black and white
RepR       = -R = Undo Cut the Right Edge by 1
CutR       = R = Cut the Right Edge by 1
CutR3      = R3 = Cut the Right Edge by 3
RepD       = -D = Undo Cut the Lower Edge by 1
CutD       = D = Cut the Lower Edge by 1
CutD3      = D3 = Cut the Lower Edge by 3
Modify     = Modify = Allows Modify the Black and White Image
MultiColor = FindMultiColor = Click multiple colors with the mouse, then Click OK button
FindShape  = FindShape = Click multiple colors, it will be binarized based on the first color
Undo       = Undo = Undo the last selected color
Undo2      = Undo = Undo the last added color in Color List
Comment    = Comment = Optional Comment used to Label Code ( Within <> )
Threshold  = Gray Threshold = Gray Threshold which Determines Black or White Pixel Conversion (0-255)
GrayDiff   = Gray Difference = Gray Difference which Determines Black or White Pixel Conversion (0-255)
Similar1   = Similarity = Adjust color similarity as Equivalent to The Selected Color
Similar2   = Similarity = Adjust color similarity as Equivalent to The Selected Color
Similar3   = Similarity = Adjust color similarity as Equivalent to The Selected Color
AddColorSim  = Add = Add Color to Color List and Run Color2Two
AddColorDiff = Add = Add Color to Color List and Run Color2Two
ColorList  = = Color list for converting black and white images
DiffRGB    = R/G/B = Determine the allowed R/G/B Error (0-255) when Find MultiColor
DiffRGB2   = R/G/B = Determine the allowed R/G/B Error (0-255)
Bind0      = BindWin1 = Bind the window and Use GetDCEx() to get the image of background window
Bind1      = BindWin1+ = Bind the window Use GetDCEx() and Modify the window to support transparency
Bind2      = BindWin2 = Bind the window and Use PrintWindow() to get the image of background window
Bind3      = BindWin2+ = Bind the window Use PrintWindow() and Modify the window to support transparency
Bind4      = BindWin3 = Bind the window and Use PrintWindow(,,3) to get the image of background window
OK         = OK = Create New FindText Code for Testing
OK2        = OK = Restore this ScreenShot then Capturing
Cancel     = Cancel = Close the Window Don't Do Anything
Cancel2    = Cancel = Close the Window Don't Do Anything
ClearAll   = ClearAll = Clean up all saved ScreenShots
OpenDir    = OpenDir = Open the saved screenshots directory
SavePic    = SavePic = Select a range and save as a picture
SavePic2   = SavePic = Save the trimmed original image as a picture
LoadPic    = LoadPic = Load a picture as Capture image
ClipText   = = Displays the Text data from clipboard
Offset     = = Displays the results of GetOffset2 or GetRange
SelectBox  = = Select a screenshot to display in the upper left corner of the screen
s1  = FindText
s2  = Gray|GrayDiff|Color|ColorPos|MultiColor
s3  = Capture Image To Text
s4  = Capture Image To Text and Find Text Tool
s5  = Direction keys to fine tune\nFirst click RButton(or Ctrl)\nMove the mouse away\nSecond click RButton(or Ctrl)
s6  = Unbind Window using
s7  = Drag a range with LButton(or Ctrl)\nCoordinates are copied to clipboard
s8  = Found|Time|ms|Pos|Result|value can be get from|Wait 3 seconds for appear|Wait indefinitely for disappear
s9  = Success
s10 = The Capture Position|Perspective binding window\nRight click to finish capture
s11 = Please Set Gray Difference First !
s12 = Please select the core color first !
s13 = Please convert the image to black or white first !
s14 = Can't be used in ColorPos mode, because it can cause position errors
s15 = Are you sure about the scope of your choice ?\n\nIf not, you can choose again
s16 = Please add colors to the color list first !
s17 = The picture you want to open was not found !
s18 = Capture|ScreenShot
s19 = Are you sure to delete all screenshots ?
    )"
    Lang1:=[], Lang2:=[]
    Loop Parse, s, `n, `r
      if InStr(v:=A_LoopField, "=")
        r:=StrSplit(StrReplace(v "==","\n","`n"), "=", "`t ")
        , Lang1[r[1]]:=r[2], Lang2[r[1]]:=r[3]
  }
  return getLang=1 ? Lang1 : getLang=2 ? Lang2 : Lang1[text]
}

;---------------------------------
; Gui-V1-V2 Compatibility Library  By FeiYue
;---------------------------------

GuiNew(args*) {
  return new this.GuiCreate(args*)
}

GuiFromHwnd(hwnd:="AllGuiObj", RecurseParent:=0) {
  static init, AllGuiObj
  if !VarSetCapacity(init) && (init:="1")
    AllGuiObj:=[]
  if (hwnd=="AllGuiObj")
    return AllGuiObj
  if (RecurseParent)
    While hwnd && !AllGuiObj.HasKey(hwnd)
      hwnd:=DllCall("GetParent", "Ptr",hwnd, "Ptr")
  return AllGuiObj[hwnd]
}

GuiCtrlFromHwnd(hwnd) {
  return this.GuiFromHwnd(hwnd,1)[hwnd]
}

GuiOnEvent(EventName, args*) {
  return this.GuiFromHwnd(WinExist())["_" EventName].Call(0,args*)
}

GuiClose(args*) {
  return FindText().GuiOnEvent("Close",args*)
}

GuiEscape(args*) {
  return FindText().GuiOnEvent("Escape",args*)
}

GuiSize(args*) {
  return FindText().GuiOnEvent("Size",args*)
}

GuiContextMenu(args*) {
  return FindText().GuiOnEvent("ContextMenu",args*)
}

GuiDropFiles(args*) {
  return FindText().GuiOnEvent("DropFiles",0,args*)
}

Class GuiCreate
{  ;// GuiCreate Class Begin

__New(opts:="", title:="", args*) {
  local
  Gui, New, % opts " +Hwndhwnd +LabelFindTextClass.Gui", % title
  this.Hwnd:=hwnd, this.ClassNN:=[]
  FindText().GuiFromHwnd()[hwnd]:=this
}

__Delete() {
  this.Destroy()
}

Destroy() {
  local
  if !(hwnd:=this.Hwnd)
    return
  this.Hwnd:="", FindText().GuiFromHwnd().Delete(hwnd)
  Try Gui, % hwnd ":Destroy"
  For k,v in this
    (v.Hwnd && v.Hwnd:=""), this[k]:=""
}

OnEvent(EventName, Callback, AddRemove:=1) {
  if IsObject(Callback)
    this["_" EventName]:=Callback
}

Opt(opts) {
  Gui, % this.Hwnd ":" RegExReplace(opts,"i)[+\-\s]Label\S*")
}

Add(type, opts:="", text:="") {
  local
  static init, type2class
  if !VarSetCapacity(init) && (init:="1")
    type2class:=[]
  type:=(type="DropDownList"?"DDL":type="Picture"?"Pic":type)
  name:=RegExMatch(opts,"i)(^|[+\-\s])V(?!Scroll\b|ertical\b)\K\S*",r)?r:""
  opts:=RegExReplace(opts,"i)(^|[+\-\s])V(?!Scroll\b|ertical\b)\S*")
  if IsObject(text)
  {
    s:=""
    For k,v in text
      s.="|" v
    text:=Trim(s, "|")
  }
  Gui, % this.Hwnd ":Add", % type, % opts " +Hwndhwnd", % text
  this.LastHwnd:=hwnd
  if type2class.HasKey(type)
    s:=type2class[type]
  else
  {
    WinGetClass, s, ahk_id %hwnd%
    type2class[type]:=s
  }
  this.ClassNN[s]:=n:=Floor(this.ClassNN[s])+1, classnn:=s . n
  obj:= new this.Control(this.Hwnd, hwnd, type, classnn, name)
  this[hwnd]:=obj, this[classnn]:=obj
  if (name) && !(name~="i)^(Destroy|OnEvent|Opt|Add"
  . "|SetFont|Show|Hide|Move|GetClientPos|GetPos|Maximize"
  . "|Minimize|Restore|Flash|Submit|Hwnd|Name|Title"
  . "|BackColor|MarginX|MarginY|MenuBar|FocusedCtrl)$")
    this[name]:=obj
  return obj
}

SetFont(opts:="", FontName:="") {
  Gui, % this.Hwnd ":Font", % opts, % FontName
}

Show(opts:="", args*) {
  Gui, % this.Hwnd ":Show", % opts
}

Hide() {
  Gui, % this.Hwnd ":Hide"
}

Move(x:="", y:="", w:="", h:="") {
  local
  this.GetPos(pX, pY, pW, pH)
  x:=(x=""?pX:x), y:=(y=""?pY:y), w:=(w=""?pW:w), h:=(h=""?pH:h)
  DllCall("MoveWindow", "Ptr",this.Hwnd, "int",x, "int",y, "int",w, "int",h, "int",1)
}

GetClientPos(ByRef x:="", ByRef y:="", ByRef w:="", ByRef h:="") {
  local
  VarSetCapacity(rect, 16, 0)
  , DllCall("GetClientRect",  "Ptr",this.Hwnd, "Ptr",&rect)
  , DllCall("ClientToScreen", "Ptr",this.Hwnd, "Ptr",&rect)
  , x:=NumGet(rect, 0, "int"), y:=NumGet(rect, 4, "int")
  , w:=NumGet(rect, 8, "int")-x, h:=NumGet(rect, 12, "int")-y
}

GetPos(ByRef x:="", ByRef y:="", ByRef w:="", ByRef h:="") {
  local
  VarSetCapacity(rect, 16, 0)
  , DllCall("GetWindowRect",  "Ptr",this.Hwnd, "Ptr",&rect)
  , x:=NumGet(rect, 0, "int"), y:=NumGet(rect, 4, "int")
  , w:=NumGet(rect, 8, "int")-x, h:=NumGet(rect, 12, "int")-y
}

Maximize() {
  Gui, % this.Hwnd ":Maximize"
}

Minimize() {
  Gui, % this.Hwnd ":Minimize"
}

Restore() {
  Gui, % this.Hwnd ":Restore"
}

Flash(k:=1) {
  Gui, % this.Hwnd ":Flash", % k ? "":"Off"
}

Submit(hide:=1) {
  local
  (hide && this.Hide()), arr:=[]
  For k,v in this
    if k is number
      if (v.Name!="")
        arr[v.Name]:=v.Value
  return arr
}

BackColor {
  get {
    return this._BackColor
  }
  set {
    this._BackColor:=value
    Gui, % this.Hwnd ":Color", % value
    return value
  }
}

MarginX {
  get {
    return this._MarginX
  }
  set {
    this._MarginX:=value
    Gui, % this.Hwnd ":Margin", % value
    return value
  }
}

MarginY {
  get {
    return this._MarginY
  }
  set {
    this._MarginY:=value
    Gui, % this.Hwnd ":Margin",, % value
    return value
  }
}

MenuBar {
  get {
    return this._MenuBar
  }
  set {
    this._MenuBar:=value
    Gui, % this.Hwnd ":Menu", % value
    return value
  }
}

Title {
  get {
    local
    VarSetCapacity(v, 260*2)
    DllCall("GetWindowText", "Ptr",this.Hwnd, "Str",v, "Int",260)
    return v
  }
  set {
    DllCall("SetWindowText", "Ptr",this.Hwnd, "Str",value)
    return value
  }
}

FocusedCtrl {
  get {
    local
    GuiControlGet, v, % this.Hwnd ":Focus"
    return this[v]
  }
}

Class Control
{  ;// Control Class Begin

__New(GuiHwnd, hwnd, type, classnn, name) {
  this.GuiHwnd:=GuiHwnd, this.Hwnd:=hwnd
  this.Type:=type, this.ClassNN:=classnn, this.Name:=name
}

Opt(opts) {
  GuiControl, % opts, % this.Hwnd
}

OnEvent(EventName, Callback, AddRemove:=1) {
  local
  r:=this.OnEvent_G.Bind(this, Callback)
  GuiControl, +g, % this.Hwnd, % r
}

OnEvent_G(Callback, args*) {
  if IsObject(Callback)
    return %Callback%(this, args*)
}

GetPos(ByRef x:="", ByRef y:="", ByRef w:="", ByRef h:="") {
  local
  GuiControlGet, p, Pos, % this.Hwnd
  x:=Floor(pX), y:=Floor(pY), w:=Floor(pW), h:=Floor(pH)
}

Move(x:="", y:="", w:="", h:="") {
  local
  s:=(x=""?"":" x" x) (y=""?"":" y" y) (w=""?"":" w" w) (h=""?"":" h" h)
  GuiControl, Move, % this.Hwnd, % s
}

Redraw() {
  GuiControl, MoveDraw, % this.Hwnd
}

Focus() {
  Try GuiControl, Focus, % this.Hwnd
}

UseTab(Name:="", Exact:="", index:="") {
  Gui, % this.GuiHwnd ":Tab", % Name, % index, % Exact?"Exact":""
}

SetFont(opts:="", FontName:="") {
  Gui, % this.GuiHwnd ":Font", % opts, % FontName
  GuiControl, Font, % this.Hwnd
}

Add(text) {
  local
  if IsObject(text)
  {
    s:=""
    For k,v in text
      s.="|" v
    text:=Trim(s, "|")
  }
  GuiControl,, % this.Hwnd, % text
}

Delete(N:="") {
  if (N="")
    GuiControl,, % this.Hwnd, |
  else
    this.Choose(N), this.Choose(0)
}

Choose(N) {
  if N is number
    GuiControl, Choose, % this.Hwnd, % N
  else
    GuiControl, ChooseString, % this.Hwnd, % N
}

Gui {
  get {
    return FindText().GuiFromHwnd(this.GuiHwnd)
  }
}

Enabled {
  get {
    local
    GuiControlGet, v, Enabled, % this.Hwnd
    return v
  }
  set {
    GuiControl, % "Enable" (!!value), % this.Hwnd
    return value
  }
}

Visible {
  get {
    local
    GuiControlGet, v, Visible, % this.Hwnd
    return v
  }
  set {
    GuiControl, % "Show" (!!value), % this.Hwnd
    return value
  }
}

Focused {
  get {
    local
    GuiControlGet, v, % this.GuiHwnd ":Focus"
    return (v=this.ClassNN)
  }
}

Value {
  get {
    local
    if (this.Type~="i)^(ListBox|DDL|ComboBox|Tab)$")
      this.Opt("+AltSubmit")
    GuiControlGet, v,, % this.Hwnd
    return v
  }
  set {
    if (this.Type~="i)^(ListBox|DDL|ComboBox|Tab)$")
      GuiControl, Choose, % this.Hwnd, % value
    else
      GuiControl,, % this.Hwnd, % value
    return value
  }
}

Text {
  get {
    local
    if (this.Type~="i)^(ListBox|DDL|ComboBox|Tab)$")
      this.Opt("-AltSubmit")
    GuiControlGet, v,, % this.Hwnd
    return v
  }
  set {
    if (this.Type~="i)^(ListBox|DDL|ComboBox|Tab)$")
      GuiControl, ChooseString, % this.Hwnd, % value
    else
      GuiControl,, % this.Hwnd, % value
    return value
  }
}

}  ;// Control Class End

}  ;// GuiCreate Class End

Script_End() {
}

}  ;// Class End

;================= The End =================

;