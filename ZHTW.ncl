load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;======================================================================
; Writing tradictional Chinese word with dots.
; 2018/08/13 Shen-Cha Hsu -- schsu81@gmail.com
; 2022/12/06 Shen-Cha Hsu -- schsu81@gmail.com 
;======================================================================
;
;----------------------------------------------------------------------
undef("transcode")
function transcode(from:integer,to:integer,in,opt:integer)
local from,to,in,opt,code,times,c10,out,i,iC
begin
   if (from.eq.to)then return in end if

   code = (/"0","1","2","3","4","5","6","7","8","9",\
            "A","B","C","D","E","F"/)

   NC = dimsizes(in)
   out = new(NC,"string","")
   do i=0,dimsizes(in)-1
     if (.not.ismissing(in(i)))then
       char = tochar(str_upper(""+in(i)))
       char = char(::-1)
       len  = dimsizes(char)

       times = 1
       c10   = 0
       do iC=0,len-1
       c10 = ind(char(iC).eq.code)*times + c10
       times = times*from
       end do
       delete(char)
       do while (c10.ne.0)
       out(i) = code(mod(c10,to)) + out(i)
       c10 = c10/to
       end do
     else
       out(i) = "0"
     end if
     do while (opt.gt.strlen(out(i)))
       out(i) = "0"+out(i)
     end do
   end do
   return out
end
;----------------------------------------------------------------------
 undef  ("utf82uni")
 function utf82uni(in)
 local in,utf8_02,uni_02,uni_16
 begin
   utf8_02 = tochar(transcode(10,2,""+in,8))
    uni_02 = ""+utf8_02(0,4:)+utf8_02(1,2:)+utf8_02(2,2:)
    uni_16 = transcode(2,10,uni_02,4)
   return uni_16
 end
;----------------------------------------------------------------------
; Check input string, if it include chinese font, return False
undef("fontCheck")
function fontCheck(wchar)
begin

    intChar = toint(tochar(tostring(wchar)))
    if(max(intChar).lt.128)then
        return False
    else
        return True
    end if
end
;----------------------------------------------------------------------
undef("rotateX")
function rotateX(para,orth,angle)
local X
begin
  X = para*cos(angle)-orth*sin(angle)
  return X
end 
;----------------------------------------------------------------------
undef("rotateY")
function rotateY(para,orth,angle)
local Y
begin
  Y = para*sin(angle)+orth*cos(angle)
  return Y
end 
;----------------------------------------------------------------------
undef("fontLenth")
function fontLenth(intChar,fontW)
local ArrLen,LW,lw
begin
       ;  a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t   u   v   w   x   y   z
  LW = (/.9 ,.7 ,.8 ,.8 ,.7 ,.7 ,.9 ,.8 ,.1 ,.6 ,.8 ,.6 ,.8 ,.7 ,.9 ,.7 ,.9 ,.8 ,.8 ,.8 ,.7 ,.8 ,.12,.8 ,.8 ,.8 /)
  lw = (/.7 ,.7 ,.6 ,.7 ,.7 ,.4 ,.7 ,.6 ,.2 ,.2 ,.7 ,.1 ,.9 ,.6 ,.7 ,.7 ,.7 ,.4 ,.6 ,.4 ,.6 ,.7 ,.9 ,.7 ,.7 ,.6 /) 
        ;     !  "  #  $  %  &  ,  (  )  *  +  ,  _  .  /  0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
  mw1 = (/.6,.1,.4,.7,.7,.9,.8,.1,.3,.3,.4,.7,.2,.3,.1,.3,.7,.7,.7,.7,.7,.7,.7,.7,.7,.7,.1,.1,.7,.7,.7,.6,.9/)
        ;  [  \  ]  ^  _  '
  mw2 = (/.3,.4,.3,.6,.8,.1/)
  
  ArrLen = dimsizes(intChar)
  Width   = 0.
  en_oper = 1.
  do i=0,ArrLen-1
    if (intChar(i).eq.126)then ;~ 
      j=i
      i=i+1
      do while (i.le.ArrLen-1 .and. intChar(i).ne.126)
       i=i+1
      end do

      if (i.eq.j+1)then
        Width   = Width + en_oper*0.6*fontW ; ~~
      elseif (""+tochar(intChar(j:i)) .eq. "~S~")then
        en_oper = 0.65
      elseif (""+tochar(intChar(j:i)) .eq. "~N~")then
        en_oper = 1.
      elseif (""+tochar(intChar(j:i)) .eq. "~B~")then
        en_oper = 0.65
      else
        Width = Width
      end if
    elseif (intChar(i).ge.128)then ; zhtw
        Width = Width + fontW
        i=i+2
    elseif (intChar(i).ge.32.and.intChar(i).le.64)then ;mw1
        Width = Width + en_oper*mw1(intChar(i)-32)*fontW
    elseif (intChar(i).le.90)then ;A-Z 65-90
        Width = Width + en_oper*LW(intChar(i)-65)*fontW
    elseif (intChar(i).le.96)then ;mw2 91-96
        Width = Width + en_oper*mw2(intChar(i)-91)*fontW
    elseif (intChar(i).le.122)then ;a-z 97-122
        Width = Width + en_oper*lw(intChar(i)-97)*fontW
    else
        Width = Width + en_oper*0.5*fontW
    end if
  end do
  return Width
end 
;----------------------------------------------------------------------
undef("enSingleJustOrth")
function enSingleJustOrth(intChar,fontW)
local aa,str,ii,oJust
begin
  if (strlen(intChar).eq.1)then
    str   = (/str_get_dq(),"'","." ,"," ,"^","`"/)
    oJust = (/          .3, .3,-.15,-.15,.3 ,.3 /)
    ii    = ind(intChar.eq.str)
    if (.not.all(ismissing(ii)))then
      return oJust(ii)*fontW
    end if
  end if
  return 0.
end
;----------------------------------------------------------------------
undef("sc_add_zhtw_ndc")
procedure sc_add_zhtw_ndc(wks, plot, wchar, inx, iny, ftres)
local wks, plot, wchar, sx, sy, dum, sizeDM, id, offset, charArr, ArrLen,\
      tx_en, isen, pJust, oJust, en_pJust, en_oJust
begin
    res                   = True
    res@fontXoffsetF      = 0.
    res@fontYoffsetF      = 0.
    res@txJust            = "CenterCenter"
    res@txAngleF          = 0.
    res@txFontHeightF     = 0.015
    res@txFontColor       = "black"
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    res = ftres
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    fontZHTWen = (/"NOTOSANSCJKTC-REGULAR","NOTOSERIFCJKTC-REGULAR","MINGLIU","KAIU","MSJH"/)
    if (isatt(ftres,"FontZHTW"))then
    fontZHTW = ftres@FontZHTW
    fontZHTWzh = (/"思源黑體","思源宋體","新細明體","標楷體","微軟正黑體"/)
    fontZHTWid = ind(fontZHTWzh.eq.fontZHTW)
      if (ismissing(fontZHTWid))then
      print("Warning : cannot found the font name, reset to default.")
      fontZHTWid = 0
      end if
      delete(res@FontZHTW)
    else
    fontZHTWid = 0
    end if
    ZHTW_FILE = addfile("$SC_ROOT/font/"+fontZHTWen(fontZHTWid)+"_zhtw.nc","r") 
    ;ZHTW_FILE = addfile("./font/"+fontZHTWen(fontZHTWid)+"_zhtw.nc","r") 
    ZHTW_UNI  = ZHTW_FILE->Unicodes
    ZHTW_LSE  = ZHTW_FILE->LineSE
    ZHTW_PSE  = ZHTW_FILE->PointSE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    sizeDM = 256
    plres = True                                   
    ;plres@gsMarkerColor      = res@txFontColor        
    ;plres@gsMarkerIndex      = 1 
    ;plres@gsMarkerSizeF      = res@txFontHeightF/10.
    ;plres@gsMarkerThicknessF = res@txFontHeightF*1.
    plres@gsFillColor        = res@txFontColor
    plres@gsLineColor        = res@txFontColor
    if (isatt(res,"gsLineThicknessF"))then
      plres@gsLineThicknessF   = res@gsLineThicknessF 
    else
      plres@gsLineThicknessF   = 1 
    end if
    fontW  = res@txFontHeightF*1.20
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    resize = fontW/sizeDM
    ;dimDM = (/sizeDM, sizeDM/)
    ;lenDM = sizeDM/8*sizeDM
    ;charLen = 3
    intChar = toint(tochar(wchar))
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    txres = True                      
    txres@txFontColor   = res@txFontColor  
    txres@txFontHeightF = res@txFontHeightF
    txres@txAngleF      = res@txAngleF     
    txres@txJust        = res@txJust
;=========================================================================================
    ArrLen = dimsizes(intChar)
    dangle   = tofloat(res@txAngleF)                          
    angle    = dangle*0.017453292519943 ; degree to rad
   ;----------------------------------------------------------- 
    Width   = fontLenth(intChar,fontW)
    Just = (/"TopLeft"  ,"CenterLeft"  , "BottomLeft"  ,\
             "TopCenter","CenterCenter", "BottomCenter",\
             "TopRight" ,"CenterRight" , "BottomRight" /)

    iJust   = ind(Just.eq.res@txJust)
    if (ismissing(iJust))then
    iJust   := toint(res@txJust)
    end if

   ; start align point
    pJust = (/        0.,           0,           0,\  ; stringWidth
               -Width/2.,   -Width/2.,   -Width/2.,\
               -Width   ,   -Width   ,      -Width/)
   ;oJust always=-fontW

    sx = inx+res@fontXoffsetF + rotateX(pJust(iJust),-fontW,angle)
    sy = iny+res@fontYoffsetF + rotateY(pJust(iJust),-fontW,angle)
    delete([/pJust/])

   ;pJust always=fontW/2.
    pJust = onedtond(fontW/2.,9)
    oJust = (/    -fontW/2.,       0.,   fontW/2.,\  ; fontHeight
                  -fontW/2.,       0.,   fontW/2.,\
                  -fontW/2.,       0.,   fontW/2./)
    oJust = oJust+0.08*fontW 
;   ;-------------------------------------------------------------------
    fspace   = 0.0   ; count space for WCHAR
    tx_en    = ""
    isen     = False
    do i = 0,ArrLen-1
    if(intChar(i).ge.128)then
        if (isen)then ; En before zhtw
          en_pJust = fontLenth(toint(tochar(tx_en)),fontW)
          en_oJust = enSingleJustOrth(tx_en,fontW)
          if     (iJust/3.eq.0)then
            pJO = 0.10
          elseif (iJust/3.eq.1)then
            pJO = 0.5
          else
            pJO = 1.00
          end if
          tx = sx + rotateX(fspace+pJO*en_pJust,fontW+en_oJust,angle)
          ty = sy + rotateY(fspace+pJO*en_pJust,fontW+en_oJust,angle)
          gsn_text_ndc(wks,tx_en,tx,ty,txres)
          delete([/tx,ty/])
          fspace = fspace + en_pJust 
          tx_en  = ""
          isen   = False
        end if

        uni   = toint(utf82uni(intChar(i:i+2)))
        IND   = ind(uni.eq.ZHTW_UNI)
        if (ismissing(IND))then
          print("  ZHTW : not found '"+tochar(intChar(i:i+2))+"' (unicode="+uni+"), Skipped.")
        else
          do il=ZHTW_LSE(IND,0),ZHTW_LSE(IND,1)
            xy = tofloat(ZHTW_FILE->xy(ZHTW_PSE(il,0):ZHTW_PSE(il,1),:))*resize
            tx = sx + rotateX(fspace+pJust(iJust)+xy(:,0),fontW+oJust(iJust)+xy(:,1),angle)
            ty = sy + rotateY(fspace+pJust(iJust)+xy(:,0),fontW+oJust(iJust)+xy(:,1),angle)
            gsn_polygon_ndc (wks,tx,ty, plres)  
            gsn_polyline_ndc(wks,tx,ty, plres)  
            delete([/xy,tx,ty/])
          end do 
        end if
        fspace = fspace+fontW
        i = i+2 
    else
        isen  = True
        tx_en = tx_en+tochar(intChar(i))
    end if 
    end do

    if (isen)then
          en_pJust = fontLenth(toint(tochar(tx_en)),fontW)
          en_oJust = enSingleJustOrth(tx_en,fontW)
          if     (iJust/3.eq.0)then
            pJO = 0.10
          elseif (iJust/3.eq.1)then
            pJO = 0.5
          else
            pJO = 1.00
          end if
          tx = sx + rotateX(fspace+pJO*en_pJust,fontW+en_oJust,angle)
          ty = sy + rotateY(fspace+pJO*en_pJust,fontW+en_oJust,angle)
          gsn_text_ndc(wks,tx_en,tx,ty,txres)
          delete([/tx,ty/])
          fspace = fspace + en_pJust 
          tx_en  = ""
          isen   = False
    end if
end
;==============================================================================
undef("sc_add_zhtw")
procedure sc_add_zhtw(wks,plot,wchar,x,y,ftres)
begin
  datatondc(plot, x, y, x, y)
  sc_add_zhtw_ndc(wks,plot,wchar,x,y,ftres)
end
;==============================================================================
; loop to write 1-d wide-char array 
undef("fontArray")
procedure fontArray(wks, plot, wchar, xarr, yarr, ftres)
begin
    do i = 0, dimsizes(wchar)-1
        if (dimsizes(yarr).eq.1) then
            sc_add_zhtw_ndc(wks, plot, wchar(i), xarr(i), yarr, ftres)
        else if (dimsizes(xarr).eq.1) then
            sc_add_zhtw_ndc(wks, plot, wchar(i), xarr, yarr(i), ftres)
        else
            sc_add_zhtw_ndc(wks, plot, wchar(i), xarr(i), yarr(i), ftres)
        end if end if
    end do
end
;==============================================================================
; fontTitle retrive tiMainString, gsnLeftString, gsnRightString, tiXAxisString,
; tiYAxisString and check if it includes chinese font, then attach it to plot
undef("fontTitle")
procedure fontTitle(wks, plot, res)
local Just,opt
begin
hasMainString   = isatt(res,"tiMainString")   .and.fontCheck(res@tiMainString)
hasLeftString   = isatt(res,"gsnLeftString")  .and.fontCheck(res@gsnLeftString)
hasCenterString = isatt(res,"gsnCenterString").and.fontCheck(res@gsnCenterString)
hasRightString  = isatt(res,"gsnRightString") .and.fontCheck(res@gsnRightString)
hasXAxisString  = isatt(res,"tiXAxisString")  .and.fontCheck(res@tiXAxisString)
hasYAxisString  = isatt(res,"tiYAxisString")  .and.fontCheck(res@tiYAxisString)
hasXBLabels     = isatt(res,"tmXBLabels")     .and.fontCheck(res@tmXBLabels)
hasYLLabels     = isatt(res,"tmYLLabels")     .and.fontCheck(res@tmYLLabels)
opt             = True
if (isatt(res,"FontZHTW") )then
  opt@FontZHTW = res@FontZHTW
end if
;;--
    getvalues plot
        "vpXF"          : vpx
        "vpYF"          : vpy
        "vpWidthF"      : vpw
        "vpHeightF"     : vph
        "tmXBValues"    : XBV
        "tmYLValues"    : YLV
        "tmXBMajorLengthF": tXBML
        "tmYLMajorLengthF": tYLML
        "tmXTMajorOutwardLengthF" : tXTMOL
    end getvalues
;~~~~~~~~~~~~~~~~~~~~Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasMainString)then
;        ftres@fontJust = "BottomCenter"
        ftres        := opt
        getvalues plot
          "tiMainString"           : str 
          "tiMainAngleF"           : ftres@txAngleF
          "tiMainConstantSpacingF" : ftres@txConstantSpacingF
          "tiMainDirection"        : ftres@txDirection
          "tiMainFont"             : ftres@txFont
          "tiMainFontAspectF"      : ftres@txFontAspectF
          "tiMainFontColor"        : ftres@txFontColor
          "tiMainFontHeightF"      : ftres@txFontHeightF
          "tiMainFontQuality"      : ftres@txFontQuality
          "tiMainFontThicknessF"   : ftres@txFontThicknessF          
          "tiMainJust"             : ftres@txJust
        end getvalues
        setvalues plot
            "tiMainString": ""
        end setvalues
        sc_add_zhtw_ndc(wks, plot, str, vpx+vpw/2., vpy+4*tXTMOL, ftres)
        delete(str)
    end if
    if ((hasLeftString.or.hasCenterString.or.hasRightString).and.(.not.isatt(res,"amOn").or.res@amOn))then
        print("Warning : Resource 'amOn' should set to False when subtitle include chinese character.")
    end if
    if(hasLeftString)then
        ftres              := opt
        ftres@txFontHeightF = 0.020
        ftres@txJust        = "BottomLeft"
        sc_add_zhtw_ndc(wks, plot,res@gsnLeftString, vpx, vpy+tXTMOL, ftres)
    end if
    if(hasCenterString)then
        ftres              := opt
        ftres@txFontHeightF = 0.020
        ftres@txJust        = "BottomCenter"
        sc_add_zhtw_ndc(wks, plot,res@gsnCenterString, vpx+vpw/2., vpy+tXTMOL, ftres)
    end if
    if(hasRightString)then
        ftres              := opt
        ftres@txFontHeightF = 0.020
        ftres@txJust        = "BottomRight"
        sc_add_zhtw_ndc(wks, plot,res@gsnRightString, vpx+vpw, vpy+tXTMOL, ftres)
    end if
;~~~~~~~~~~~~~~~X Axis String and Labels~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasXAxisString)then
        ftres        := opt
        getvalues plot
          "tiXAxisString"           : str 
          "tiXAxisAngleF"           : ftres@txAngleF
          "tiXAxisConstantSpacingF" : ftres@txConstantSpacingF
          "tiXAxisDirection"        : ftres@txDirection
          "tiXAxisFont"             : ftres@txFont
          "tiXAxisFontAspectF"      : ftres@txFontAspectF
          "tiXAxisFontColor"        : ftres@txFontColor
          "tiXAxisFontHeightF"      : ftres@txFontHeightF
          "tiXAxisFontQuality"      : ftres@txFontQuality
          "tiXAxisFontThicknessF"   : ftres@txFontThicknessF          
          "tiXAxisJust"             : ftres@txJust
          "tiXAxisOffsetXF"         : ftres@tiXAxisOffsetXF
          "tiXAxisOffsetYF"         : ftres@tiXAxisOffsetYF
        end getvalues
        setvalues plot
            "tiXAxisString"  : ""
        end setvalues
        XBV_NDC := XBV
        YLV_NDC := YLV
        datatondc(plot, XBV, onedtond(YLV(0), dimsizes(XBV)), XBV_NDC, YLV_NDC)
        xx = vpx+vpw/2.+ftres@tiXAxisOffsetXF
        yy = YLV_NDC(0)-6*tXBML +ftres@tiXAxisOffsetYF
        sc_add_zhtw_ndc(wks, plot, str, xx, yy, ftres)
        delete(str)
        delete(xx)
        delete(yy)
    end if 
    if(hasXBLabels)then
;        ftres@fontJust = "TopCenter"
        ftres        := opt
        getvalues plot
          "tmXBLabels"                : str
          "tmXBLabelAngleF"           : ftres@txAngleF
          "tmXBLabelConstantSpacingF" : ftres@txConstantSpacingF
          "tmXBLabelDirection"        : ftres@txDirection
          "tmXBLabelFont"             : ftres@txFont
          "tmXBLabelFontAspectF"      : ftres@txFontAspectF
          "tmXBLabelFontColor"        : ftres@txFontColor
          "tmXBLabelFontHeightF"      : ftres@txFontHeightF
          "tmXBLabelFontQuality"      : ftres@txFontQuality
          "tmXBLabelFontThicknessF"   : ftres@txFontThicknessF          
          "tmXBLabelJust"             : ftres@txJust
        end getvalues
        setvalues plot
            "tmXBLabels"  : onedtond("", dimsizes(res@tmXBLabels))
        end setvalues
        XBV_NDC := XBV
        YLV_NDC := XBV
        datatondc(plot, XBV, onedtond(YLV(0), dimsizes(XBV)), XBV_NDC, YLV_NDC)
        fontArray(wks, plot, str, XBV_NDC, YLV_NDC(0)-2*tXBML, ftres)
        delete(str)
    end if
;~~~~~~~~~~~~~~~Y Axis String and Labels~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasYAxisString)then
        ftres        := opt
;        ftres@fontJust = "CenterRight"
        getvalues plot
          "tiYAxisString"           : str 
          "tiYAxisAngleF"           : ftres@txAngleF
          "tiYAxisConstantSpacingF" : ftres@txConstantSpacingF
          "tiYAxisDirection"        : ftres@txDirection
          "tiYAxisFont"             : ftres@txFont
          "tiYAxisFontAspectF"      : ftres@txFontAspectF
          "tiYAxisFontColor"        : ftres@txFontColor
          "tiYAxisFontHeightF"      : ftres@txFontHeightF
          "tiYAxisFontQuality"      : ftres@txFontQuality
          "tiYAxisFontThicknessF"   : ftres@txFontThicknessF          
          "tiYAxisJust"             : ftres@txJust
          "tiYAxisOffsetXF"         : ftres@tiYAxisOffsetXF
          "tiYAxisOffsetYF"         : ftres@tiYAxisOffsetYF
        end getvalues
        setvalues plot
            "tiYAxisString"  : ""
        end setvalues
        XBV_NDC := YLV
        YLV_NDC := YLV
        datatondc(plot, onedtond(XBV(0), dimsizes(YLV)), YLV, XBV_NDC, YLV_NDC)
        xx = XBV_NDC(0)-8*tYLML +ftres@tiYAxisOffsetXF
        yy = vpy-vph/2.         +ftres@tiYAxisOffsetYF
        sc_add_zhtw_ndc(wks, plot, str, xx,yy, ftres)
        delete(str)
        delete(xx)
        delete(yy)
    end if
    if(hasYLLabels)then
;        ftres@fontJust = "CenterRight"
        ftres        := opt
        getvalues plot
          "tmYLLabels"                : str
          "tmYLLabelAngleF"           : ftres@txAngleF
          "tmYLLabelConstantSpacingF" : ftres@txConstantSpacingF
          "tmYLLabelDirection"        : ftres@txDirection
          "tmYLLabelFont"             : ftres@txFont
          "tmYLLabelFontAspectF"      : ftres@txFontAspectF
          "tmYLLabelFontColor"        : ftres@txFontColor
          "tmYLLabelFontHeightF"      : ftres@txFontHeightF
          "tmYLLabelFontQuality"      : ftres@txFontQuality
          "tmYLLabelFontThicknessF"   : ftres@txFontThicknessF          
          "tmYLLabelJust"             : ftres@txJust
        end getvalues
        setvalues plot
            "tmYLLabels"  : onedtond("", dimsizes(res@tmYLLabels))
        end setvalues
        XBV_NDC := YLV
        YLV_NDC := YLV
        datatondc(plot, onedtond(XBV(0), dimsizes(YLV)), YLV, XBV_NDC, YLV_NDC)
        fontArray(wks, plot, str, XBV_NDC(0)-2*tYLML, YLV_NDC, ftres)
        delete(str)
    end if 
end
