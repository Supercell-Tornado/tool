;**************************************************
; skewt_9.ncl
;
; Concepts illustrated:
;   - Reading text file based on Wyoming sounding format
;   - Deriving various quantities
;   - Adding text to a modified skew-T 
;   - Creating a separate hodograph plot
;**************************************************
; Author: Stavros Dafis - April 2016 - NOA, Greece
;   - Updated in March 2017
;   - e-mail: sdafis@noa.gr
;**************************************************
; TSkew and hodograph of real data based on Wyoming sounding format.
;   - http://weather.uwyo.edu/cgi-bin/sounding
;**************************************************
load "./function/skewt_func_dafis.ncl"
load "./function/hodograph_dafis.ncl"
;**************************************************
begin
;   print_clock("Current time:")
;   UTC = systemfunc("date -u '+%H%M UTC %e %b %Y'| awk '{print toupper($0)}'")
;  ;print(UTC)   ; 1648 UTC 18 FEB 2017
;
;   
;   split_utc = str_split_by_length(UTC, 2)
;   hour      = stringtoint(split_utc(0)) - 2 
;   
;   split_day = str_split_by_length(UTC, 3)
;   day       = split_day(3)
;   mon       = split_day(4)
;   
;   split_year= str_split_by_length(UTC, 4)
;   year      = split_year(4)

   longitude  = 129.5
   latitude   = 33
   placename  = ""       ; 空白でも OK!  : 「 placename  = "" 」

   year       = 2017
   mon        = 08
   day        = 08
   hour       = 12
   minute     = 05

   station_latitude_letter  = "33~S~o~N~.00~S~'~N~"
   station_longitude_letter = "129~S~o~N~.50~S~'~N~"
;   station_elevation_letter = "15 m"
   additional_text = ""

; --- Read Data ----------------------------------------;
   diri = "./asciidata/"
   ascii_filename = "129.512_33.0105_1.asc"
   ascii_filepath = diri + ascii_filename

   ncol = numAsciiCol(ascii_filepath)    ; number of available parameters
   nlvl = numAsciiRow(ascii_filepath) -1 ; number of available measurements
   
   print("Number of observations: "+nlvl+" ")
   print("Number of columns: "+ncol+" ")
   
   Data = asciiread (ascii_filepath , (/nlvl,ncol/), "float") 
  ;printVarSummary(Data)
   
   print("				")
   print("		****************		")
   print(" Start computations - script version: 2017")
   print("		****************		")
   print("				")
   
; order: Surface is 'bottom'  eg: 1000,950,900,850,... 
; order for *1 values : 850,900,950,1000,.... 
                              
    p     = Data (:,0)    ; pressure     [mb / hPa]
    p1    = p(::-1)
  
    z     = Data (:,1)    ; hght [m]
    z1    = z(::-1)
   
    tc    = Data (:,2)    ; temperature  [C]
    tc1   = tc(::-1)
  
    tdc   = Data (:,3)    ; dew pt temp  [C]
    tdc1  = tdc(::-1)
   
    rh    = Data (:,4)    ; rel humidity [%]
    rh1   = rh(::-1)
   
    mix   = Data (:,5)    ; mixing ratio [g/kg] 
    mix1  = mix(::-1)
   
;    wdir  = Data (:,6)    ; meteorological wind dir 
;    wdir1 = wdir(::-1)
;    
;    wspd0 = Data (:,7)    ; wind speed   [knots]
;    wspd01= wspd0(::-1)
;  
;    wspd  = wspd0/1.94384 ; wind speed   [m/s]  !!!!!!!!!!!!!!!!!!!!!!
;    wspd1 = wspd(::-1)

    u     = Data(:,6)     ; u
    v     = Data(:,7)     ; v
     
    thta  = Data (:,8)    ; Potential Temp [K]
    thta1 = thta(::-1)
  
    thte  = Data (:,9)    ; Equivalent Potential Temp  [K] 
    thte1 = thte(::-1)
  
    thtv  = Data (:,10)   ; Virtual Potential Temp  [K] 
    thtv1 = thtv(::-1)
  
;-------------------------------------------------------------------
  
    rad   = 4.*atan(1.0)/180.    ; degress to radians
;    u     = -wspd*sin(wdir*rad)  ; u component (zonal) 
;    v     = -wspd*cos(wdir*rad)  ; v component (meridional)

;    wdir   = atan(u/v)/rad
    wdir   = wind_direction(u, v, 0)
    wdir1  = wdir(::-1)
    
    wspd   = sqrt(u^2+v^2)
    wspd1  = wspd(::-1)

    wspd0  = wspd*1.94384
    wspd01 = wspd0(::-1)
   
;******************************************************************
; create plot
;******************************************************************
  ; pltTyp = "x11"
  ; pltTyp = "pdf"
    pltTyp = "png"
  
    pltTyp@wkWidth  = 800     ; large  
    pltTyp@wkHeight = 800 
  
    imagedir = "./image/"

    wks  = gsn_open_wks (pltTyp, imagedir + "./ema_"+longitude+"_"+latitude+"_"+ mon +"_"+ day +"_"+ hour +"_"+ minute )
    gsn_define_colormap(wks,"WhViBlGrYeOrReWh")
  
; --- Create background skew-T and plot sounding----------------
  
    skewtOpts                 = True
    skewtOpts@DrawColAreaFill = True    ; default is False
    skewtOpts@DrawMixRatio    = True 
   ;skewtOpts@tiMainString    = "Thessaloniki 23/03/2017 12z" 
   
    dataOpts           = True     ; options describing data and ploting
    dataOpts@Wthin     = 1        ; plot every n-th wind barb
    dataOpts@colTemperature  = "red"
    dataOpts@colDewPt        = "chartreuse3"
    dataOpts@colCape         = "chocolate3"
    dataOpts@colWindP        = "blue"
    dataOpts@colWindZ        = "black"                                        
    dataOpts@colWindH        = "black" 
   
    dataOpts@lineThicknessDewPt = 4.5
    dataOpts@lineThicknessTemperature = 4.5
    dataOpts@linePatternCape    = 17
    dataOpts@xpWind             = 45
   
    dataOpts@ThermoInfo = False
  
    skewtOpts@vpWidthF  = 0.70
    skewtOpts@vpHeightF = 0.85
    ;skewtOpts@vpXF     = 0.01 
     
    skewtOpts@tiMainString    = " Lon "+longitude+" Lat "+latitude+" at "+tostring(hour)+":"+minute+" UTC - "+day+" "+mon+" "+year+""
    skewtOpts@tiMainFontHeightF    = 0.018
    skewtOpts@tiMainFont    = "helvetica-bold"
    skewtOpts@tiMainPosition = "Right"
  
    skewtOpts@DrawFahrenheit  = False   ; default is True
    skewtOpts@DrawColAreaColor  = 3      ; Light Grey for WhViBlGrYeOrReWh color table
  
    skewtOpts@lineThicknessMixRatio     = 5
  
    skewt_bkgd = skewT_BackGround (wks, skewtOpts)
    skewt_data = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                      , wspd,wdir, dataOpts)
  
    draw (skewt_bkgd)
  
;------------------------------------------------------------------------------------
  
   fmsg = default_fillvalue(typeof(tc))   ; get default missing 
  
   nlvls= dimsizes(p)
   plcl = fmsg             ; p (hPa) Lifting Condensation Lvl (lcl)
   tlcl = fmsg             ; temperature (C) of lcl
  
   ptlcl_skewt(p(0),tc(0),tdc(0),plcl,tlcl) 
  
   plcl1 = decimalPlaces(plcl,0,True)
   tlcl1 = decimalPlaces(tlcl,1,True)
   print("LCL level: "+plcl1+" hPa / "+tlcl1+" oC")
        
   shox  = showal_skewt(p,tc,tdc)           ; Showwalter Index
   shox1 = decimalPlaces(shox,1,True)
   print("Showalter Index: "+shox1+"")
  
   pwat  = pw_skewt(tdc,p)                  ; precipitable water (cm)
   pwat1 = decimalPlaces(pwat,1,True)
   print("Precipitable water: "+pwat1*10+" mm")
  
   iprnt   = 0   ; debug only (>0)
   nlLcl   = 0   ; LCL                          
   nlLfc   = 0   ; LFC
   nlCross = 0   ; EL
  
   cape = cape_thermo(p,tc,plcl,iprnt)       ; MUCAPE (J/kg)
  
   tpar = cape@tparcel                      ; temp of the parcel
   nlLcl= cape@jlcl
   nlLfc= cape@jlfc
   nlCross= cape@jcross
  
   nlLfc = where(nlLfc.ge.0,nlLfc,1)
                                             ; Equillibrium Level
   EL_p = p(nlCross)                         ; hPa
   EL_z = z(nlCross) /1000                   ; in km
   EL   = decimalPlaces(EL_z,1,True)
   print("EL = "+EL+" km")
   
   LFC_p = p(nlLfc)                         ; LFC in hPa
   LFC_z = z(nlLfc) /1000                   ; in km
   LFC   = decimalPlaces(LFC_z,2,True)
   print("LFC = "+LFC+" km")
   
   cape1 = decimalPlaces(cape,0,True)
   print("MUCAPE: "+cape1+" J/kg")
   
;-------------------------------------------------------------------------------------------
   
  ;Calculated below:
   
  ;KO-Index = 0.5 * (ThetaE700 + ThetaE500) - 0.5 * (ThetaE1000 + ThetaE850)
  ;TT = T850 + TD850 - 2 * (T500) 
  ;KI = (T850 - T500) + TD850 - (T700 - TD700)
  ;Mixing ratio 0-500m
  ;SWEAT = 12 * (TD850) + 20 * (TTI - 49) + 2 * (WS850) + (WS500) + 125 * (sin(WD500 - WD850) + 0.2) 
  ;SI = T500 - T500Parcel (showalter index)
  ;Lifted Index
  ;850-600 Lapse Rate 
  ;Thompson Index = KI - LI  (>35 interested)
  ; TQ = (T850 + Td850) ? 1.7・(T700). 
  ; Freezing level
  ;BRN = (CAPE / 0-6km Shear) 
  ;EHI = (CAPE * SRH) / 160'000
  ;STP = (CAPE / 1000) * ((2000 - Hohe LCL AGL) / 1500) * (1km SRH / 100) * (0..6km Windshear / 20)
  ;SCP = (Most Unstable CAPE / 1000) * (3km SRH / 100) * (BRN Shear / 40)
   
  ;To be done:
  ;850 Wet Bulb Theta-E
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;************************************* Thermodynamic info **********************************************
;
;-------------------------------------------------------------------------------------------------------
   i0 = closest_val(10.,z)
   u0 = u(i0(0))  
   v0 = v(i0(0))
   
   i6 = closest_val(6000.,z)
   u6 = u(i6(0))               
   v6 = v(i6(0)) 
   
   i3 = closest_val(3000.,z)
   u3 = u(i3(0))               
   v3 = v(i3(0))
   
   i1 = closest_val(1000.,z)
   u1 = u(i1(0))               
   v1 = v(i1(0))  
   
   u06 = u6 - u0
   v06 = v6 - v0
   
   u03 = u3 - u0
   v03 = v3 - v0
   shear_03 = sqrt(u03^2 + v03^2)
   shear03 = decimalPlaces(shear_03,1,True)
   
   u01 = u1 - u0
   v01 = v1 - v0
   shear_01 = sqrt(u01^2 + v01^2)
   shear01 = decimalPlaces(shear_01,1,True)
   
   
   shear_06 = sqrt(u06^2 + v06^2)
   shear06 = decimalPlaces(shear_06,1,True)
   
   BRN0 = (cape / (0.5*(shear06)^2)) 
   
   BRN  = decimalPlaces(BRN0,1,True)               ; Bulk Richardson Number
   print("BRN: "+BRN+" ") 
   
   ;------------------------------------------------------------------------
   i850 = closest_val(850.,p1)
   tc850 = tc1(i850)
   tdc850 = tdc1(i850)
   
   i500 = closest_val(500.,p1)
   tc500 = tc1(i500)
   
   i700 = closest_val(700.,p1)
   tc700 = tc1(i700)
   tdc700 = tdc1(i700)
   
  ;K-Index = ( T850 - T500 ) + TD850 - ( T700 - TD700 )
   
   KI0 = tc850 - tc500 + tdc850 - tc700 + tdc700
   KI  = decimalPlaces(KI0,0,True)           ; K-index (approximation at height)
   print("K-index: "+KI+" oC") 
   
  ;TOTL= ( T850 - T500 ) + ( TD850 - T500 )
   
   TT0 = tc850 + tdc850 - 2 * (tc500)
   TT = decimalPlaces(TT0,0,True)           ; Total Totals (approximation at height)
   print("TotalTotals: "+TT+" oC") 
   
   ;---------------------------------------------------------------------------------
   
   imix2 = closest_val(1000.,z)
   mix2  = mix(0:imix2)
   mixing0 = avg(mix(0:imix2))
   mixing  = decimalPlaces(mixing0,1,True)
   print("Mixing ratio: "+mixing+" g/kg ")    ;Mixing ratio 0-1000m (PBL)
   ;---------------------------------------------------------------------------------
   
  ;KO-Index = 0.5 * (ThetaE700 + ThetaE500) - 0.5 * (ThetaE1000 + ThetaE850)
   
   ithe7 = closest_val(700.,p1)
    the7 = thte1(ithe7)
   
   ithe5 = closest_val(500.,p1)
    the5 = thte1(ithe5)
   
   ithe8 = closest_val(850.,p1)
    the8 = thte1(ithe8)
   
   ithe1 = closest_val(950.,p1)
    the1 = thte1(ithe1)
   
   ko0 = 0.5*(the7 + the5) - 0.5*(the1 + the8)
   ko = decimalPlaces(ko0,1,True)
   
   print("KO-Index: "+ko+" K")             ; KO-Index (smaller than 2 indicates storms)
   
;-------------------------------------------------------------------------------------
;SWEAT = 12*(TD850)+20*(TTI -49)+2*(WS850)+(WS500)+ 125*(sin(WD500-WD850)+ 0.2)
   
   iws85 = closest_val(850.,p1)
   ws850 = wspd01(iws85)              ; in knots
   wd850 = wdir1(iws85)*3.14/180      ; in radians
   
   iws50 = closest_val(500.,p1)
   ws500 = wspd01(iws50)
   wd500 = wdir1(iws50)*3.14/180      ; in radians
   
   S0 = 125*(sin(wd500 - wd850) + 0.2)
   S1 = where(wdir1(iws85).ge.130 .and. wdir1(iws85).le.250 .or. wdir1(iws50).ge.210 .and. wdir1(iws50).le.310, S0, 0)
   S = where(S1.gt.0, S1, 0)
   
   Tot = 20*(TT-49)
   Tot = where(TT.lt.49,0,Tot)
   
   Dew850 = 12*tdc850
   Dew850 = where(Dew850.ge.1,Dew850,0)
   
   sweat0 = Dew850 + Tot + 2*(ws850) + ws500 + S
   
   sweat = decimalPlaces(sweat0,0,True)
   
   print("SWEAT: "+sweat+" ")                  ; SWEAT index
;-------------------------------------------------------------------------------------

; Showalter index = t500 - tparcel500
   
   g_adiab = 0.0095          ;g = DT/DZ = -9.5 C/km
      g_td = 0.002           ;g = DTd/DZ = -2.0 C/km
     g_wet = 0.0065          ;g = DT/DZ = -6.5 C/km
   
   iz850   = closest_val(850.,p1)
   iz500   = closest_val(500.,p1)
   z850    = z1(iz850)             ; in meters
   z500    = z1(iz500)
   
   ip = closest_val(5650.,z)       ; approximation
   tpar500    = cape@tparcel(ip)   ; temp of the parcel at 500hPa                   
   tparcel500 = tpar500
   
  ;tparcel500 = - g_adiab*(z500 - z850) + tc850
  ;print(tparcel500) 
   swi0 = tc500 - tparcel500
   swi = decimalPlaces(swi0,0,True)            ; Showalter index (needs calculations)
   
   ;print("Showalter index: "+swi+" ")
   
   ;-----------------------------------------------------------------------------------
   
   iz0 = closest_val(500.,z)
   tc0 = avg(tc(0:iz0))       ; a parcel with avg Temp in first 500m
   z0  = z(iz0)
   
   if (z0.le.600) then
       tparcel500_li = - 0.0070*(z500 - z0) + tc0
       LI0 = tc500 - tparcel500_li                     ; Lifted Index (needs calculations)
       LI = decimalPlaces(LI0,1,True) 
       print("Lifted index: "+LI+" oC")
   else
       LI = -999
       print("Lifted index: -nan oC")
   end if
;----------------------------------------------
;---Thompson Index = KI - LI  (>35 interested)
   
   Thompson = KI - LI
   Thompson = where(Thompson.le.60,Thompson,KI)
   print("Thompson index: "+Thompson+" oC")         ; Thompson Index 
   
;--------------------------------------------------------------------------------------
;  850-600 Lapse Rate 
   
   iz6   = closest_val(600.,p1)
   tc600 = tc1(iz6)
   z600  = z1(iz6)
   
   g0_68 = -((tc600 - tc850)/(z600 - z850))*1000   ; in km
   
   g_68  = decimalPlaces(g0_68,1,True) 
   print("850 - 600 hPa lapse rate: "+g_68+" oC/km")        ;850-600 Lapse Rate
   
;--------------------------------------------------------------------------------------
;  TQ = (T850 + Td850) ? 1.7・(T700). 
   
   TQ0 = (tc850 + tdc850) - 1.7*(tc700)
   
   TQ = decimalPlaces(TQ0,0,True)                         ; TQ Index for low-topped convection
   
   print("TQ Index: "+TQ+" oC")
   
;-------------------------------------------------------------------------------------------
;  Freezing point
   
   frz_lvl1 = where(tc.lt.1 ,0,10)
   frz_lvl = minind(frz_lvl1)
   
  ;frz_lvl = local_min_1d(tc, False, -0.25, 0)
   
  ;print("Freezing level: "+frz_lvl1+" ") 
   
   zfrz = z(frz_lvl)                    ; Freezing level 
   pfrz = p(frz_lvl)
   
   print("Freezing level: "+zfrz+" m / near "+pfrz+" hPa ")
   
  ;iwb = closest_val(0,tc1)
  ;twb = wetbulb(p1, tc1, tdc1)    ; ===> 9.3C
  ;print("Wet bulb: "+twb+" ")
   
  ;print("Wet bulb 0°C: "+zwb0+" km / at "+pwb0+" hPa ")          ; Wet bulb 0°C
   
   z_surf = closest_val(6,z)
   t_surf = tc(z_surf)
   
   print("Surface temp: "+t_surf+" oC")
   
   ;exit
;------------------------------------------------------------------------------------------
; Thickness 1000-500, 1000-850, 1000-700
   
   z1000 = closest_val(1000,p1)
   zz500 = closest_val(500,p1)
   
   hei1000 = z1(z1000)
   hei500  = z1(zz500)
   
   z70  = closest_val(700,p1)
   z700 = z1(z70)
   
   th10_500 = hei500 - hei1000
   th10_850 = z850 - hei1000
   th10_700 = z700 - hei1000
   
   print("Thickness 1000-500: "+th10_500+" gpm")            ; Thickness
   print("Thickness 1000-850: "+th10_850+" gpm")
   print("Thickness 1000-700: "+th10_700+" gpm")
   
   temp850 = tc1(iz850)
   temp700 = tc1(z70)
   temp500 = tc1(zz500)
   
   print("T850: "+temp850 +" oC")            ; Temperature
   print("T700: "+temp700 +" oC")
   print("T500: "+temp500 +" oC")
   
;******************************************************************************************************
; Storm Relative Helicity
; SREH0-3km & SREH0-1km
   
   pp0 = closest_val(0.,z)
   u1000 = u(pp0(0))  
   v1000 = v(pp0(0))
   
   pp1 = closest_val(400.,z)
   u950 = u(pp1(0))  
   v950 = v(pp1(0))
   
   pp2 = closest_val(900.,z)
   u900 = u(pp2(0))  
   v900 = v(pp2(0))
   
   pp3 = closest_val(1450.,z)
   u850 = u(pp3(0))  
   v850 = v(pp3(0))
   
   pp4 = closest_val(1900.,z)
   u800 = u(pp4(0))  
   v800 = v(pp4(0))
   
   pp5 = closest_val(2200.,z)
   u750 = u(pp5(0))  
   v750 = v(pp5(0))
   
   pp6 = closest_val(3000.,z)
   u700 = u(pp6(0))  
   v700 = v(pp6(0))
   
   pp7 = closest_val(3600.,z)
   u650 = u(pp7(0))  
   v650 = v(pp7(0))
   
   pp8 = closest_val(4000.,z)
   u600 = u(pp8(0))  
   v600 = v(pp8(0))
   
   pp9 = closest_val(4800.,z)
   u550 = u(pp9(0))  
   v550 = v(pp9(0))
   
   pp10 = closest_val(5600.,z)
   u500 = u(pp10(0))  
   v500 = v(pp10(0))
   
   pp11 = closest_val(6100.,z)
   u450 = u(pp11(0))  
   v450 = v(pp11(0))
   
   pp12 = closest_val(7300.,z)
   u400 = u(pp12(0))  
   v400 = v(pp12(0))
   
   umean  = (u1000+u950+u900+u850+u800+u750+u700+u650+u600+u550+u500+u450+u400)/13.0
   vmean  = (v1000+v950+v900+v850+v800+v750+v700+v650+v600+v550+v500+v450+v400)/13.0
   ushear = u500-u1000
   vshear = v500-v1000
   shear  = sqrt(ushear*ushear+vshear*vshear)
   umotion= ((umean+(7.5/(shear))*vshear))
   vmotion= ((vmean-(7.5/(shear))*ushear))
   
   srh1 = ((u950-umotion)*(v1000-vmotion)-(u1000-umotion)*(v950-vmotion))
   srh2 = ((u900-umotion)*(v950-vmotion)-(u950-umotion)*(v900-vmotion))
   srh3 = ((u850-umotion)*(v900-vmotion)-(u900-umotion)*(v850-vmotion))
   srh4 = ((u800-umotion)*(v850-vmotion)-(u850-umotion)*(v800-vmotion))
   srh5 = ((u750-umotion)*(v800-vmotion)-(u800-umotion)*(v750-vmotion))
   srh6 = ((u700-umotion)*(v750-vmotion)-(u750-umotion)*(v700-vmotion))
   
   srh3km = srh1+srh2+srh3+srh4+srh5+srh6
   srh1km = srh1+srh2
   
   srh3km = decimalPlaces(srh3km,1,True) 
   srh1km = decimalPlaces(srh1km,1,True) 
   
   print("SREH0-3: "+srh3km+" m2/s2")
   print("SREH0-1: "+srh1km+" m2/s2")
   
;------------------------------------------------------------------------
;--- EHI
   
   EHI0 = (cape*srh3km)/160000                      ; Energy Helicity Index
   EHI  = decimalPlaces(EHI0,0,True)
   print("EHI: "+EHI+" ") 
;------------------------------------------------------------------------
;---Significant tornado parameter
   
   stp  = (cape/1500)*((2000-plcl)/1000)*(srh1km/150)*(shear06/20)
   stp  = decimalPlaces(stp,0,True)
   ;print(stp)
   
;------------------------------------------------------------------------
;--- Supercell Composite Parameter
   
   SCP = (cape / 1000) * (srh3km / 100) * (BRN0 / 40)
   SCP  = decimalPlaces(SCP,0,True)
   print("SCP: "+SCP+"")
   
;************************************************************************************

;================== TSkew plot ========================
    txress = True                        
    txress@txFontColor       = "Black"
    txress@txFontHeightF     = 0.0138
    txress@txFont      = "helvetica"
   
    gsn_text_ndc(wks,"MUCAPE = "+cape1+" J/kg",0.892,.90,txress)
    gsn_text_ndc(wks,"PBL mixing = "+mixing+" g/kg ",0.895,.879,txress)
    gsn_text_ndc(wks,"LCL level = "+plcl1+" hPa ",0.886,.859,txress)
    gsn_text_ndc(wks,"LCL temp = "+tlcl1+" ~S~o~N~C",0.887,.839,txress)
    gsn_text_ndc(wks,"PWAT = "+pwat1*10+" mm",0.882,.819,txress)
    gsn_text_ndc(wks,"TQ index = "+TQ+" ~S~o~N~C",0.882,.799,txress)
    gsn_text_ndc(wks,"K-index = "+KI+" ~S~o~N~C",0.882,.779,txress)
    gsn_text_ndc(wks,"EL = "+EL+" km",0.887,.759,txress)
    gsn_text_ndc(wks,"SWI = "+shox1+" ~S~o~N~C",0.882,.739,txress)
    gsn_text_ndc(wks,"SWEAT = "+sweat+"",0.882,.719,txress)
    gsn_text_ndc(wks,"KO-index = "+ko+" K",0.882,.699,txress)
    gsn_text_ndc(wks,"Total Totals = "+TT+" ~S~o~N~C",0.882,.679,txress)
    gsn_text_ndc(wks,"Lifted index = "+LI+" ~S~o~N~C",0.882,.659,txress)
    gsn_text_ndc(wks,"LR 850-600 = "+g_68+" ~S~o~N~C/km",0.882,.639,txress)
   
    gsn_text_ndc(wks,"Thompson index = "+Thompson+" ~S~o~N~C",0.88,.619,txress)
   
    txrex = True                        
    txrex@txFontColor       = "Blue"
    txrex@txFontHeightF     = 0.0138
    txrex@txFont      = "helvetica"
   
    gsn_text_ndc(wks,"Th1000-500 = "+th10_500+" gpm",0.88,.58,txrex)
    gsn_text_ndc(wks,"Th1000-850 = "+th10_850+" gpm",0.88,.56,txrex)
    gsn_text_ndc(wks,"Th1000-700 = "+th10_700+" gpm",0.88,.54,txrex)
    gsn_text_ndc(wks,"Freezing level = "+zfrz+" m",0.88,.52,txrex)
    gsn_text_ndc(wks,"T850 = "+temp850+" ~S~o~N~C",0.88,.50,txrex)
    gsn_text_ndc(wks,"T700 = "+temp700+" ~S~o~N~C",0.88,.48,txrex)
    gsn_text_ndc(wks,"T500 = "+temp500+" ~S~o~N~C",0.88,.46,txrex)
   
    txrez = True                        
    txrez@txFontColor       = "Chocolate4"
    txrez@txFontHeightF     = 0.0138
    txrez@txFont     = "helvetica"
   
   gsn_text_ndc(wks,"Shear 0-6km = "+shear06+" m/s",0.88,.42,txrez)
   gsn_text_ndc(wks,"Shear 0-3km = "+shear03+" m/s",0.88,.40,txrez)
   gsn_text_ndc(wks,"Shear 0-1km = "+shear01+" m/s",0.88,.38,txrez)
   gsn_text_ndc(wks,"SREH0-3km = "+srh3km+" m~S~2~N~/s~S~2~N~ ",0.88,.36,txrez)
   gsn_text_ndc(wks,"SREH0-1km = "+srh1km+" m~S~2~N~/s~S~2~N~ ",0.88,.34,txrez)
  
   gsn_text_ndc(wks,"EHI0-3km = "+EHI+" ",0.87,.32,txrez)
   gsn_text_ndc(wks,"STP = "+stp+" ",0.89,.30,txrez)
   gsn_text_ndc(wks,"BRN = "+BRN+" ",0.89,.28,txrez)
   gsn_text_ndc(wks,"SCP = "+SCP+" ",0.89,.26,txrez)
    
    txrer = True                        
    txrer@txFontColor       = "Black"
    txrer@txFontHeightF     = 0.010
    txrer@txFont     = "helvetica-bold"
   
   gsn_text_ndc(wks,"   "+placename+"",0.90,.16,txrer)
   gsn_text_ndc(wks,"   Station latitude: "+station_latitude_letter+" ",0.90,.14,txrer)
   gsn_text_ndc(wks,"Station longitude: "+station_longitude_letter+" ",0.90,.12,txrer)
;   gsn_text_ndc(wks,"Station elevation: "+station_elevation_letter+" ",0.89,.10,txrer)
   
    txrer1 = True                        
    txrer1@txFontColor       = "Black"
    txrer1@txFontHeightF     = 0.012
    txrer1@txFont     = "helvetica-bold"
   gsn_text_ndc(wks," Thermodynamic parameters ",0.88,.935,txrer1)
   
   gsn_text_ndc(wks," "+additional_text+" ",0.86,.03,txrer1)
    
   ;*************************************************************************************
   draw (skewt_data)
   
   ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ;-----------------------------------------------------------------------------------
   
   ;------------------ Hodograph area ----------------------------------------------------
   
    wks_type = "png" 
    wks_type@wkWidth = 1600  
    wks_type@wkHeight = 1600
    xwks  = gsn_open_wks (wks_type , imagedir + "./hodo_"+longitude+"_"+latitude+"_"+ mon +"_"+ day +"_"+ hour +"_"+ minute)
   
   ;gsn_define_colormap(xwks,"WhViBlGrYeOrReWh")
   
     xres                      = True 
     ;xres@gsnMaximize          = True    ; Maximize plot in window.
     xres@gsnDraw              = False   ; Don't draw plot
     xres@gsnFrame             = False   ; Don't advance frame
   
     xres@gsnLeftString        = ""
     xres@gsnRightString       = ""
     xres@xyMarkLineMode       = "MarkLines"  ; markers and lines
     xres@xyMarkers            = 1           ; filled dot
     ;xres@xyMarkerSizeF        = 0.02
     ;xres@xyMarkerThicknessF   = 0.55
   
     xres@tiMainString         = " Lon "+longitude+" Lat "+latitude+" at "+tostring(hour)+":"+minute+" UTC - "+day+" "+mon+" "+year+""
     xres@tiMainFontHeightF    = 0.010
     xres@tiMainFont           = "helvetica-bold"
     xres@tiYAxisString        = "V-Wind"
     xres@tiXAxisString        = "U-Wind"
     
     ;popts          = True                 ; local and default options
     ;circFr = popts@circFr
     ;SpdMax = popts@SpdMax
     ;zMax   = popts@zMax
   
     ;SpdMaxNumCircles = floattointeger(SpdMax/circFr)
     ;SpdMaxNum        = circFr*SpdMaxNumCircles   ; number of circles
   
     ;extraSpace             = max((/3.,circFr/3./))    ; Extra space beyond
     ;xres@trXMinF           = -SpdMaxNum-extraSpace  ; min X 
     ;xres@trXMaxF           =  SpdMaxNum+extraSpace  ; max X
     ;xres@trYMinF           = -SpdMaxNum-extraSpace  ; min Y
     ;xres@trYMaxF           =  SpdMaxNum+extraSpace  ; max Y
   
     xres@trXMinF	           = max( wspd ) ;-40
     xres@trXMaxF	           = max( wspd ) ; 40 
     xres@trYMinF             = max( wspd ) ;-40
     xres@trYMaxF             = max( wspd ) ; 40
   
   plot = hodograph(xwks,wspd,wdir,z,xres)
   
   
   frame(wks)  ; Tskew plot
   
   ;============== Hodograph ===============================
    draw (plot)
    frame(xwks)
   
   
   print("				")
   print("		****************		")
   print(" Finish computations - script version: 2017")
   
   print("		****************		")
   print("				")
   
   print("Total CPU time: " + get_cpu_time()+" seconds")
   
    end

