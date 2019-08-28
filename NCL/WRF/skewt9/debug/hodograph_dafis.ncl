;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" ; automatically loaded from 6.2.0 onward
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "./hodo_cartesian.ncl"

undef("hodograph")
function hodograph (wks[1]: graphic, wspd[*]:numeric, wdir[*]:numeric, z[*]:numeric, hRes[1]:logical)

; Nomenclature
;      wspd      - wind speed (any units)
;      wdir      - wind direction (degrees)
;                  meteorological: dir from which the wind blows
;                              eg: 90 deg means blowing from the east
;      hRes      - resources which affect plot appearance    
;
 begin
  debug = False
 
  if (hRes) then
      opts = hRes       ; if True over ride local/defaults with input
  end if

  nW     = dimsizes(wspd)       ; total number of elements
  rad    = 4.*atan(1.0)/180.    ; degress to radians
  nz     = dimsizes(z)

                                ; compute wind components
  u      = -wspd*sin(wdir*rad)  ; u component (zonal) 
  v      = -wspd*cos(wdir*rad)  ; v component (meridional)

 ;uAve   = avg(u)
 ;vAve   = avg(v)
 ;wAve   = avg(wspd) 
 ;wDir   = atan2(uAve,vAve)/rad +180. ; average wind direction [0,360]
 ;wStd   = stddev(wspd) 
 ;wNum   = num(.not.ismissing(wspd) ) ; total number of non-msg values
 ;nCalm  = num( wspd.eq.0.)*1.0       ; total calm reports (float)

  wMin   = 0.0
  wMax   = max( wspd ) ;- 10.

  maxLev   = 5  
  if (opts .and. isatt(opts,"hodo_maxLev")) then
      maxLev  = opts@hodo_maxLev
  end if

  maxAxis  = wMax
  if (opts .and. isatt(opts,"hodo_maxAxis")) then
      maxAxis = opts@maxAxis
  end if

  mnmxintw = nice_mnmxintvl( wMin, maxAxis, maxLev, True)
 ;print(mnmxintw)

  res = True
  res@gsnDraw           = False
  res@gsnFrame          = False
  res@gsnMaximize       = True
  
  BorderLineColor       = "Black"            ; light gray for default
  if (opts .and. isatt(opts,"hodo_borderColor")) then
      BorderLineColor   = opts@hodo_borderColor
  end if

  res@tmBorderLineColor = BorderLineColor
  res@tmXBOn            = True 
  res@tmXBBorderOn      = True          ; True is the default
  res@tmXBLabelsOn      = True          ; True is the default
  res@tmXBLabelFontColor= BorderLineColor
  res@tmXBMajorLineColor= BorderLineColor
  res@tmXBMinorLineColor= BorderLineColor

  res@tmYLOn            = True
  res@tmYLBorderOn      = True          ; True is the default
  res@tmYLLabelsOn      = True          ; True is the default
  res@tmYLLabelFontColor= BorderLineColor
  res@tmYLMajorLineColor= BorderLineColor
  res@tmYLMinorLineColor= BorderLineColor

  res@tmYROn            = True
  res@tmYRBorderOn      = True          ; True is the default

  res@tmXTOn            = True          ; turn off tick marks on each side
  res@tmXTBorderOn      = True          ; True is the default
                                        ; are perim border wanted
  if (opts .and. isatt(opts,"hodo_perim") .and. .not.opts@hodo_perim) then
      res@tmXBOn        = False
      res@tmXBBorderOn  = False
      res@tmXTOn        = False
      res@tmXTBorderOn  = False
      res@tmYLOn        = False
      res@tmYLBorderOn  = False
      res@tmYROn        = False
      res@tmYRBorderOn  = False
  end if

  spaceAxis       =  10.0                ; arbitrary 'extra' space
  spaceAxis       =  mnmxintw(2)*0.50   ; arbitrary 'extra' space

  res@trXMinF     = -mnmxintw(1) - spaceAxis 
  res@trXMaxF     =  mnmxintw(1) + spaceAxis
  res@trYMinF     = -mnmxintw(1) - spaceAxis
  res@trYMaxF     =  mnmxintw(1) + spaceAxis

  ;res@trXMinF	           = -40 ;max( wspd ) ;
  ;res@trXMaxF	           =  40 ;max( wspd ) ;  
  ;res@trYMinF             = -40 ;max( wspd ) ;
  ;res@trYMaxF             =  40 ;max( wspd ) ; 


  res@tiMainFontColor   = 1           ; default is 1   
  res@tiYAxisString     = "v-wind (m/s)"
  res@tiXAxisString     = "u-wind (m/s)"
  res@tiXAxisFontColor  = BorderLineColor
  res@tiYAxisFontColor  = BorderLineColor
  if (opts .and. isatt(opts,"hodo_axisTitle") .and. .not.opts@hodo_axisTitle) then
      delete(res@tiXAxisString)
      delete(res@tiYAxisString)
  end if

  if (opts .and. isatt(opts,"tiMainString") ) then
      res@tiMainString = opts@tiMainString
  end if
  if (opts .and. isatt(opts,"gsnLeftString") ) then
      res@gsnLeftString = opts@gsnLeftString
  end if
  if (opts .and. isatt(opts,"gsnCenterString") ) then
      res@gsnCenterString = opts@gsnCenterString
  end if
  if (opts .and. isatt(opts,"gsnRightString") ) then
      res@gsnRightString = opts@gsnRightString
  end if
  
  
  nCirc = 361                         ; do this once
  nCircles = toint(mnmxintw(1)/mnmxintw(2))
  xCirc = new ( nCirc, "float")
  yCirc = xCirc
  xCirc = 0.0
  yCirc = 0.0

  plot  = gsn_csm_xy(wks, xCirc, yCirc, res)    ; blank

  gsRes = True
  gsRes@gsLineColor       = BorderLineColor     ; light gray
  gsRes@gsLineThicknessF  = 0.5                 ; default = 1.0

  txRes = True                        ; set text resources
  txRes@txFontColor       = BorderLineColor
  txRes@txFontHeightF     = 0.0150

 ;txPos    = 145                      ; (math) degrees
 ;txShiftx = 0.90
 ;txShifty = 0.90
  txPos    = 270                      ; (math) degrees
  txShiftx = 0.00
  txShifty = 0.00
  txRes@txAngleF          = 0

  xcos  = cos(fspan(0, 360, nCirc)*rad)
  xsin  = sin(fspan(0, 360, nCirc)*rad)

  do n=1,nCircles           ; plot coordinates for circles
     xCirc =  n*mnmxintw(2)*xcos
     yCirc =  n*mnmxintw(2)*xsin
     plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xCirc,yCirc,gsRes)

     if (opts) then
         if(.not.isatt(opts,"hodo_labelCircle") .or. \
            isatt(opts,"hodo_labelCircle") .and. opts@hodo_labelCircle) then 
            labelCirc = ""+(n*mnmxintw(2))
           ;print("labelCirc="+labelCirc)
            plot@$unique_string("dum")$ = \
                   gsn_add_text(wks,plot,labelCirc    \
                                   ,xCirc(txPos)-txShiftx \
                                   ,yCirc(txPos)+txShifty,txRes)
         end if
     end if
  end do

;-------------------------- Add a cross at the center of the plot ---------------------
gsRescros = True
  gsRescros@gsMarkerSizeF = 1000.0 
  gsRescros@gsMarkerIndex = 2    ;  "+"
  gsRescros@gsMarkerColor = "red"
  gsRescros@gsMarkerThicknessF = 2.0
  plot@$unique_string("dum")$ = gsn_add_polymarker(wks,plot, 0.0 , 0.0 ,gsRescros)

;======================================================================================
;--------------------------------------------------------------------------------------
; Resources for markers of wind speed: 
 gsRes = True
  
  ;if (opts .and. isatt(opts,"hodo_markerSize")) then
     ; gsRes@gsMarkerSizeF = opts@hodo_markerSize
 ; end if

  gsRes@gsMarkerIndex = 1      ;  solid circle
  gsRes@gsMarkerColor = "red"
  gsRes@gsMarkerSizeF = 0.05 
;------------------------------
; Plot data near the surface

  i0 = closest_val(10.,z)
  u0 = u(i0(0))  
  v0 = v(i0(0))
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u0,v0,gsRes) 

;-----------------------------------------------------------------------------
; Plot data at 1 km

  i1 = closest_val(1000.,z)
  u1 = u(i1(0))               ; if I want all the values 0-1km -> 0:i1(0)
  v1 = v(i1(0))
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u1,v1,gsRes) 

;------------------------------------------------------------------------------
; Plot data at 2 km

  i2 = closest_val(2000.,z)
  u2 = u(i2(0))               
  v2 = v(i2(0)) 
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u2,v2,gsRes) 

;-------------------------------------------------------------------------------
; Plot data at 3 km

  i3 = closest_val(3000.,z)
  u3 = u(i3(0))               
  v3 = v(i3(0)) 
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u3,v3,gsRes) 

;-------------------------------------------------------------------------------
; Plot data at 4 km

  i4 = closest_val(4000.,z)
  u4 = u(i4(0))               
  v4 = v(i4(0)) 
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u4,v4,gsRes) 

;-------------------------------------------------------------------------------
; Plot data at 5 km

  i5 = closest_val(5000.,z)
  u5 = u(i5(0))               
  v5 = v(i5(0)) 
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u5,v5,gsRes) 

;-------------------------------------------------------------------------------
; Plot data at 6 km

  i6 = closest_val(6000.,z)
  u6 = u(i6(0))               
  v6 = v(i6(0)) 
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u6,v6,gsRes) 

;-------------------------------------------------------------------------------
; Plot data at 7 km

  i7 = closest_val(7000.,z)
  u7 = u(i7(0))               
  v7 = v(i7(0)) 
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u7,v7,gsRes) 

;-------------------------------------------------------------------------------
; Plot data at 8 km

  i8 = closest_val(8000.,z)
  u8 = u(i8(0))               
  v8 = v(i8(0)) 
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u8,v8,gsRes) 

;-------------------------------------------------------------------------------
; Plot data at 9 km

  i9 = closest_val(9000.,z)
  u9 = u(i9(0))               
  v9 = v(i9(0)) 
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u9,v9,gsRes) 

;-------------------------------------------------------------------------------
; Plot data at 10 km

  i10 = closest_val(9500.,z)
  u10 = u(i10(0))               
  v10 = v(i10(0)) 
  plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,u10,v10,gsRes) 

;-------------------------------------------------------------------------------
; if (opts .and. isatt(opts,"hodo_markerIndex")) then
   ;   gsRes@gsMarkerSizeF = opts@hodo_markerIndex
 ; end if
 ;plot@$unique_string("dum")$ = gsn_add_polymarker(wks,plot,  u  ,  v  ,gsRes)

  
;--------------------- Add a line to joint the wind speed values --------------------------------
  resuv = True
  resuv@gsLineThicknessF = 1.8
  resuv@gsLineColor = "Black"
  plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,u(i0(0):i10(0)),v(i0(0):i10(0)),resuv)
;------------------------------------------------------------------------------------------------
; Attach some text strings next to the markers.
  txres               = True
  txres@txJust        = "TopRight"
  txres@txFontHeightF = 0.013 

txid = gsn_add_text(wks,plot,"sfc",u0,v0,txres)
txid = gsn_add_text(wks,plot,"1km",u1,v1,txres)
txid = gsn_add_text(wks,plot,"2km",u2,v2,txres)
txid = gsn_add_text(wks,plot,"3km",u3,v3,txres)
txid = gsn_add_text(wks,plot,"4km",u4,v4,txres)
txid = gsn_add_text(wks,plot,"5km",u5,v5,txres)
txid = gsn_add_text(wks,plot,"6km",u6,v6,txres)
txid = gsn_add_text(wks,plot,"7km",u7,v7,txres)
txid = gsn_add_text(wks,plot,"8km",u8,v8,txres)
txid = gsn_add_text(wks,plot,"9km",u9,v9,txres)
txid = gsn_add_text(wks,plot,"10km",u10,v10,txres)

;**********************************************************************************************************
;======================================================================================
; Storm motion 
;--------------
istormu = avg(u(0:i6(0)))*0.9
istormv = avg(v(0:i6(0)))*0.9

s_motion = sqrt(istormu^2 + istormv^2)   ; in radians
smotion = decimalPlaces(s_motion,1,True) ; in radians

;Radians are converted to degrees by multiplying by DperR (180 / p = 57.29578), and degrees
;are converted to radians by multiplying by RperD (p / 180 = 0.01745329).
;Dirgeo is the direction with respect to true north, (0=north,90=east,180=south,270=west) that the wind 
;is coming from.

DperR = 180/3.14159
RperD = 3.14159/180

;If it equals 2.36 radians (135 degrees) then your software uses the programming language 
;convention and you can use these formulas unchanged.
;test = atan2(1,-1)
;printMinMax(test,True)

dir_motion = ((atan2(-istormu,-istormv))* DperR) + 23   ; in degrees (Bernard Oker adds 30°)
dirmotion = decimalPlaces(dir_motion,1,True)

ustorm = -smotion*sin(dirmotion*RperD)   ; in radians
vstorm = -smotion*cos(dirmotion*RperD)   ; in radians

print("Storm motion speed: "+smotion+" m/s")
print("Storm motion speed: "+dirmotion+" degrees")

;Storm motion marker
gsRessm = True
gsRessm@gsMarkerIndex = 1      ;  solid circle
gsRessm@gsMarkerColor = "blue"
gsRessm@gsMarkerSizeF = 0.04 
plot@$unique_string("dum")$  = gsn_add_polymarker(wks,plot,ustorm,vstorm,gsRessm) 

txrestorm = True
txrestorm@txJust        = "TopRight"
txrestorm@txFontHeightF = 0.01 
txrestorm@txFontColor = "Blue"
txid = gsn_add_text(wks,plot,"SRM",ustorm,vstorm,txrestorm)

;Add a line from sfc to SRM
  resst = True
  resst@gsLineThicknessF = 1.5
  resst@gsLineColor = "blue"

 i00 = closest_val(0.,z)  ; surface
 u00 = u(i00(0))                
 v00 = v(i00(0))

;ypts = (/ 0, vstorm /)
;xpts = (/ 0, ustorm /)
;do i=2,1
;k=i+5
;plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xpts(i:k),ypts(i:k),resst)
;end do

;plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,ustorm(i00(0):),vstorm(i00(0):),resst)


;----------------------------------------------------------------------------------------------------
;*****************************************************************************************************
; Bulk shear 

u01 = u1 - u0
v01 = v1 - v0

u03 = u3 - u0
v03 = v3 - v0

u06 = u6 - u0
v06 = v6 - v0

u18 = u8 - u1
v18 = v8 - v1

shear_01 = sqrt(u01^2 + v01^2)
shear01 = decimalPlaces(shear_01,1,True)
print("Bulk shear 0-1km: "+shear01+" m/s")  

shear_03 = sqrt(u03^2 + v03^2)
shear03 = decimalPlaces(shear_03,1,True)
print("Bulk shear 0-3km: "+shear03+" m/s")  

shear_06 = sqrt(u06^2 + v06^2)
shear06 = decimalPlaces(shear_06,1,True)
print("Bulk shear 0-6km: "+shear06+" m/s")  

shear_18 = sqrt(u18^2 + v18^2)
shear18 = decimalPlaces(shear_18,1,True)
print("Bulk shear 1-8km: "+shear18+" m/s") 

;******************************************************************************************************

;-----------------------------------------------------------------------------
  if (isatt(hRes,"gsnDraw")) then 
      if (hRes@gsnDraw) then 
          draw(plot)
      end if
  else 
      draw(plot)
  end if
  if (isatt(hRes,"gsnFrame")) then 
      if (hRes@gsnFrame) then 
          frame (wks)
      end if
  else 
      frame (wks)
  end if

  return (plot)

 end

