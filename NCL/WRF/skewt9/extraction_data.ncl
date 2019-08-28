; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Set parameters

 snd_lat =  35.00     ; latitude of model profile
 snd_lon =  131.5     ; longitude of model profile
 hodo_top_pres = 300. ; top of hodograph in hPa

 in_dir  = "/mnt/drobo/inokuchi/WRFV3.7.1/work/gustFNLnocuphys/"
 in_file = "wrfout_d01_2017-08-08_12:00:00"  ; WRF output file

;---Read in WRF data
 it=1

 in_path    = in_dir + in_file                   
 ncdf_in    = addfile(in_path+".nc","r")             ; add .nc extension      


;==========================================
 lat2d = ncdf_in->XLAT(0,:,:)
 lon2d = ncdf_in->XLONG(0,:,:)

 printVarSummary(lat2d)
 printMinMax(lat2d, 0)
 printMinMax(lon2d, 0)

; lat   = (/  33.0  /)   ; user specified coordinate pairs
; lon   = (/ 129.5  /)
;                                          ; return 2d subscripts

 lat   = 33.0
 lon   = 129.5

 nm = getind_latlon2d (lat2d,lon2d, lat, lon)

 print(nm)

 do k=0,dimsizes(lat)-1
    n = nm(k,0)
    m = nm(k,1)
    print(lat2d(n,m)+"   "+lon2d(n,m))
 end do
;==========================================
 stnlat_ygridnum    = n 
 stnlon_xgridstnnum = m
 print(stnlat_ygridnum)
 print(stnlon_xgridstnnum)
 stn_lat = lat2d(n,m)
 stn_lon = lon2d(n,m)
 print(stn_lat)
 print(stn_lon)
;==========================================
 out_dir  = "/mnt/drobo/inokuchi/WRFV3.7.1/work/gustFNLnocuphys/ncl/"
 out_file = stn_lon + "_" + stn_lat + "_" + it + ".asc"
 out_path = out_dir + out_file
;==========================================

;=======================================================================
; 特定時刻の空間データ取得
;=======================================================================

; -----------------------------------------------
 P_tot      = wrf_user_getvar(ncdf_in,"pressure",0)  ; model 3D pressure
 printVarSummary(P_tot)
 print("L_____ finished P_tot")
; -----------------------------------------------
 z_tot      = wrf_user_getvar(ncdf_in,"z",it)        ; model 3D height
 printVarSummary(z_tot)
 print("L_____ finished z_tot")
; -----------------------------------------------
 TC         = wrf_user_getvar(ncdf_in,"tc",it)       ; model temperature in Celsius
 printVarSummary(TC)
 print("L_____ finished TC")
; -----------------------------------------------
 TD         = wrf_user_getvar(ncdf_in,"td",it)       ; model dewpoint in Celsius
 printVarSummary(TD)
 print("L_____ finished TD")
; -----------------------------------------------
 rh         = wrf_user_getvar(ncdf_in,"rh",it)       ; Relative Humidity [%]
 printVarSummary(rh)
 print("L_____ finished rh")
;------------------------------------------------
; mix        =  ; mixing ratio
 mix_wrfout = ncdf_in->QVAPOR(it,:,:,:)              ; Water vapor mixing ratio [kg kg-1]
; mix        = mix_wrfout(:,:,:)
 mix        = mix_wrfout(:,:,:)*1000
 printVarSummary(mix)
 print("L_____ finished mix")
; -----------------------------------------------
 uvmet      = wrf_user_getvar(ncdf_in,"uvmet",it)    ; Earth-relative U and V winds on mass points
 printVarSummary(uvmet)
 print("L_____ finished uvmet")
; -----------------------------------------------
 U          = uvmet(0,:,:,:)                       ; Earth-relative U wind on mass points
 printVarSummary(U)
 print("L_____ finished U")
; -----------------------------------------------
 V          = uvmet(1,:,:,:)                       ; Earth-relative V wind on mass points
 printVarSummary(V)
 print("L_____ finished V")
; -----------------------------------------------
 th         = wrf_user_getvar(ncdf_in,"th",it)          ; Potential temperature [K]
 printVarSummary(th)
 print("L_____ finished th")
;------------------------------------------------
 eth        = wrf_user_getvar(ncdf_in,"eth",it)         ; Equivalent Potential Temperature [K]
 printVarSummary(eth)
 print("L_____ finished eth")
; -----------------------------------------------
 tv         = wrf_user_getvar(ncdf_in,"tv",it)          ; Virtual temperature [K]
 printVarSummary(tv)
 print("L_____ finished tv")
; -----------------------------------------------
 tk         = wrf_user_getvar(ncdf_in,"tk",it)
 printVarSummary(tk)
 print("L_____ finished tk")
; -----------------------------------------------
 thv        = (th(:,:,:)/tk(:,:,:))*tv(:,:,:)                              ; thv=theatav : vertual potential temperature
 printVarSummary(thv)
 print("L_____ finished thv")
; -----------------------------------------------

;=======================================================================
; 特定時刻の空間データ取得
;=======================================================================

 print("")
 print("*****************************************************\n")
 print("*****************************************************\n")
 print("*****************************************************\n")
 print("")
;=======================================================================
; 特定時刻の 特定 lon,latのデータ取得
;=======================================================================

 stn_P_tot = P_tot(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_P_tot)
 print("L_____ finished stn_P_tot")
 stn_z_tot = z_tot(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_z_tot)
 print("L_____ finished stn_z_tot")
 stn_TC    = TC(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_TC)
 print("L_____ finished stn_TC")
 stn_TD    = TD(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_TD)
 print("L_____ finished stn_TD")
 stn_rh    = rh(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_rh)
 print("L_____ finished stn_rh")
 stn_mix   = mix(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_mix)
 print("L_____ finished stn_mix")
 stn_U     = U(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_U)
 print("L_____ finished stn_U")
 stn_V     = V(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_V)
 print("L_____ finished stn_V")
 stn_th    = th(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_th)
 print("L_____ finished stn_th")
 stn_eth   = eth(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_eth)
 print("L_____ finished stn_eth")
 stn_tv    = tv(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_tv)
 print("L_____ finished stn_tv")
 stn_thv    = thv(:,stnlat_ygridnum,stnlon_xgridstnnum)
 printVarSummary(stn_thv)
 print("L_____ finished stn_thv")
;=======================================================================
; 特定時刻の 特定 lon,latのデータ取得
;=======================================================================

;=======================================================================
; ; 特定時刻の空間データファイル出力
;  write_table(out_path, "w", [/P_tot, z_tot, TC, TD, rh, U, V, th, eth, tv/], \
;              "%8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f")
;-----------------------------------------------------------------------
; 特定時刻の 特定 lon,latのデータファイル出力
 write_table(out_path, "w", [/stn_P_tot, stn_z_tot, stn_TC, stn_TD,\
            stn_rh, stn_mix, stn_U, stn_V, stn_th, stn_eth, stn_thv/], \
    "%8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f")
;=======================================================================

end
