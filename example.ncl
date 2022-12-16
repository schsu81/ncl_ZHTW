load "$SC_ROOT/lib/ZHTW.ncl"

begin
wks = gsn_open_wks("x11","bb")

res = True
res@gsnDraw = False
res@gsnFrame=False


   res = True
   res@trXMaxF  = 1
   res@trXMinF  = 0
   res@trYMaxF  = 1
   res@trYMinF  = 0
   res@tiMainString    = "標題"
   res@tiXAxisString   = "X軸 海浬 英呎 (note)[units]"
   ;res@tiYAxisOffsetYF = 0.15
   res@tiYAxisString   = "Y軸 theta (note)[~S~o~N~C]"

   res@amOn            = False ; should be off when gsn*String are zhtw font
   res@gsnLeftString   = "左"
   res@gsnCenterString = "中"
   res@gsnRightString  = "右"

plt = gsn_csm_xy(wks,(/0,0./),(/0,1./),res)

res@FontZHTW = "微軟正黑體"
fontTitle(wks, plt, res)

ftres = True
ftres@gsLineThicknessF = 1 ; default : 1, 
                           ; 0 to close outline.

sc_add_zhtw(wks, plt, "繁1aA體2bB測9zZ試0ijk", 0.5, 0.9, ftres)
ftres@FontZHTW = "思源黑體" ; default
sc_add_zhtw(wks, plt, "NCL會寫繁體字,思源黑體",0.5, 0.850, ftres)
ftres@FontZHTW = "思源宋體"
sc_add_zhtw(wks, plt, "NCL會寫繁體字,思源宋體",0.5, 0.800, ftres)
ftres@FontZHTW = "新細明體"
sc_add_zhtw(wks, plt, "NCL會寫繁體字,新細明體",0.5, 0.750, ftres)
ftres@FontZHTW = "標楷體"
sc_add_zhtw(wks, plt, "NCL會寫繁體字,標楷體", 0.5, 0.700, ftres)
ftres@FontZHTW = "微軟正黑體"
sc_add_zhtw(wks, plt, "NCL會寫繁體字,微軟正黑體", 0.5, 0.650, ftres)

sc_add_zhtw(wks, plt, "對Left齊", 0.2, 0.600, ftres)
ftres@txJust = "CenterRight"
sc_add_zhtw(wks, plt, "對Right齊", 0.8, 0.600, ftres)
delete(ftres@txJust)

sc_add_zhtw(wks, plt, "角0度", 0.2, 0.200, ftres)
ftres@txAngleF = 30.
sc_add_zhtw(wks, plt, "角30度", 0.4, 0.200, ftres)
ftres@txAngleF = 60.
sc_add_zhtw(wks, plt, "角60度", 0.6, 0.200, ftres)
ftres@txAngleF = 90.
sc_add_zhtw(wks, plt, "角90度", 0.8, 0.200, ftres)


drawNDCGrid(wks)
draw(plt)
frame(wks)


end


