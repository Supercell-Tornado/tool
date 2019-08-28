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
   print_clock("Current time:")
   UTC = systemfunc("date -u '+%H%M UTC %e %b %Y'| awk '{print toupper($0)}'")
  ;print(UTC)   ; 1648 UTC 18 FEB 2017

   
   split_utc = str_split_by_length(UTC, 2)
   hour      = stringtoint(split_utc(0)) - 2 
   
   split_day = str_split_by_length(UTC, 3)
   day       = split_day(3)
   mon       = split_day(4)
   
   split_year= str_split_by_length(UTC, 4)
   year      = split_year(4)
   
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

    wdir_wrong  = atan(u/v)/rad
    wdir   = wind_direction(u, v, 0)
    wdir1  = wdir(::-1)
    
    wspd   = sqrt(u^2+v^2)
    wspd1  = wspd(::-1)

    wspd0  = wspd*1.94384
    wspd01 = wspd0(::-1)
   

  out_path = diri + "confirmation.txt"
 write_table(out_path, "w", [/p1, z1, u, v, wdir_wrong, wdir1, wspd1/], \
    "%8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f")
   
    end

