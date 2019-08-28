;**********************************************************************
; This function attaches a single vertical Y axis in the
; center of the given plot.
;**********************************************************************
undef ("attach_vert_axis")
function attach_vert_axis(wks,plot,opts[1]:logical)
local vres, amres, xmin, xmax, ymin, ymax, vpx, vpy, vpw, vph, \
mj_length, mjo_length, mn_length, mno_length, font_height
begin

;---Retrieve information from original plot
  getvalues plot
    "vpXF"     : vpx
    "vpYF"     : vpy
    "vpWidthF" : vpw
    "vpHeightF": vph

    "trXMinF"  : xmin 
    "trXMaxF"  : xmax
    "trYMinF"  : ymin
    "trYMaxF"  : ymax

    "tmYLLabels" : labels
    "tmYLValues" : values

    "tmYLMinorValues" : mvalues

    "tmYLLabelFontHeightF"    : font_height

    "tmYLMajorLengthF"        : mj_length
    "tmYLMinorLengthF"        : mn_length
    "tmYLMajorOutwardLengthF" : mjo_length
    "tmYLMinorOutwardLengthF" : mno_length
  end getvalues

;---Turn off the dead center tickmark label
  nlabels = dimsizes(labels)
  if((nlabels % 2).eq.1) then
    labels((nlabels-1)/2) = ""
  end if

  vres              = True

;---Don't draw or advance frame
  vres@gsnDraw      = False
  vres@gsnFrame     = False

;---Make sure blank plot has same axis limits as original plot
  vres@trXMinF      = xmin 
  vres@trXMaxF      = xmax
  vres@trYMinF      = ymin
  vres@trYMaxF      = ymax

;---Make sure blank plot has same size as original plot
  vres@vpXF         = vpx
  vres@vpYF         = vpy
  vres@vpWidthF     = vpw
  vres@vpHeightF    = vph

;---Turn off top, bottom, and right axis.
  vres@tmYROn       = False
  vres@tmXTOn       = False
  vres@tmXBOn       = False
  vres@tmYRBorderOn = False
  vres@tmXTBorderOn = False
  vres@tmXBBorderOn = False

;---Make tickmarks cross the axis.
  vres@tmYLMajorLengthF        = mj_length
  vres@tmYLMinorLengthF        = mn_length
  vres@tmYLMajorOutwardLengthF = mjo_length/2.
  vres@tmYLMinorOutwardLengthF = mno_length/2.

  if (opts .and. isatt(opts,"hodo_axisColor")) then
      vres@tmBorderLineColor   = opts@hodo_axisColor
      vres@tmYLMajorLineColor  = opts@hodo_axisColor
      vres@tmYLMinorLineColor  = opts@hodo_axisColor
      vres@tmYLLabelFontColor  = opts@hodo_axisColor
  else
      ;vres@tmBorderLineColor       = "Gray40"
      ;vres@tmYLMajorLineColor      = "Gray40"
      ;vres@tmYLMinorLineColor      = "Gray40"

      vres@tmBorderLineColor       = "Black"
      vres@tmYLMajorLineColor      = "Black"
      vres@tmYLMinorLineColor      = "Black"

  end if

;---Make axis label font smaller
  vres@tmYLLabelFontHeightF    = 0.60 * font_height

;---Reset the labels w/o the "0" value labeled
  vres@tmYLMode                = "Explicit"
  vres@tmYLLabels              = labels
  vres@tmYLValues              = values
  vres@tmYLMinorValues         = mvalues

;---Create the blank plot with just a single vertical axis.
  vaxis = gsn_blank_plot(wks,vres)

;---Attach this axis to the original plot.
  amres                = True
  amres@amParallelPosF =  0.5     ; Shift right to center of plot
  vamid = gsn_add_annotation(plot,vaxis,amres)

  return(vamid)
end

;**********************************************************************
; This function attaches a single horizontal X axis in the
; center of the given plot.
;**********************************************************************
undef ("attach_horiz_axis")
function attach_horiz_axis(wks,plot,opts[1]:logical)
local vres, amres, xmin, xmax, ymin, ymax, vpx, vpy, vpw, vph, \
mj_length, mjo_length, mn_length, mno_length, font_height
begin

;---Retrieve information from original plot
  getvalues plot
    "vpXF"     : vpx
    "vpYF"     : vpy
    "vpWidthF" : vpw
    "vpHeightF": vph

    "trYMinF"  : ymin
    "trYMaxF"  : ymax
    "trXMinF"  : xmin 
    "trXMaxF"  : xmax

    "tmXBLabelFontHeightF"    : font_height

    "tmXBLabels" : labels
    "tmXBValues" : values

    "tmXBMinorValues" : mvalues

    "tmXBMajorLengthF"        : mj_length
    "tmXBMinorLengthF"        : mn_length
    "tmXBMajorOutwardLengthF" : mjo_length
    "tmXBMinorOutwardLengthF" : mno_length
  end getvalues

;---Turn off the dead center tickmark label
  nlabels = dimsizes(labels)
  if((nlabels % 2) .eq. 1) then
    labels((nlabels-1)/2) = ""
  end if

  vres           = True

;---Don't draw or advance frame
  vres@gsnDraw      = False
  vres@gsnFrame     = False

;---Make sure blank plot has same size as original plot
  vres@vpXF         = vpx
  vres@vpYF         = vpy
  vres@vpWidthF     = vpw
  vres@vpHeightF    = vph

;---Make sure blank plot has same axis limits as original plot
  vres@trXMinF      = xmin 
  vres@trXMaxF      = xmax
  vres@trYMinF      = ymin
  vres@trYMaxF      = ymax


;---Turn off left, right, and top axis.
  vres@tmYLOn       = False
  vres@tmYROn       = False
  vres@tmXTOn       = False
  vres@tmYLBorderOn = False
  vres@tmYRBorderOn = False
  vres@tmXTBorderOn = False

;---Make tickmarks cross the axis.
  vres@tmXBMajorLengthF       = mj_length
  vres@tmXBMinorLengthF       = mn_length
  vres@tmXBMajorOutwardLengthF= mjo_length/2.
  vres@tmXBMinorOutwardLengthF= mno_length/2.

  if (opts .and. isatt(opts,"hodo_axisColor")) then
      vres@tmBorderLineColor   = opts@hodo_axisColor
      vres@tmXBMajorLineColor  = opts@hodo_axisColor
      vres@tmXBMinorLineColor  = opts@hodo_axisColor
      vres@tmXBLabelFontColor  = opts@hodo_axisColor
  else
      vres@tmBorderLineColor       = "Gray40"
      vres@tmXBMajorLineColor      = "Gray40"
      vres@tmXBMinorLineColor      = "Gray40"
  end if

;---Make axis label font smaller
  vres@tmXBLabelFontHeightF   = 0.60 * font_height

;---Reset the labels w/o the "0" value labeled
  vres@tmXBMode                = "Explicit"
  vres@tmXBLabels              = labels
  vres@tmXBValues              = values
  vres@tmXBMinorValues         = mvalues

;---Create the blank plot with just a single horizontal axis.
  haxis = gsn_blank_plot(wks,vres)

;---Attach this axis to the original plot.
  amres                  = True
  amres@amOrthogonalPosF = -0.5     ; Shift up to center of plot
  hamid = gsn_add_annotation(plot,haxis,amres)

  return(hamid)
end

;**********************************************************************
; This function removes the existing axes from an NCL plot and
; reattaches a cartesian-style axis.
;**********************************************************************
undef ("cartesian_axis")
function cartesian_axis(wks,plot,hcart)
begin
  setvalues plot
;;; "tiMainString"      : "Cartesian Coordinate System"

;---Turn off all default axes.
    "tmXBBorderOn"      : False
    "tmXTBorderOn"      : False
    "tmYLBorderOn"      : False
    "tmYRBorderOn"      : False
    "tmXBOn"            : False
    "tmXTOn"            : False
    "tmYLOn"            : False
    "tmYROn"            : False
    "tmXUseBottom"      : False
    "tmYUseLeft"        : False

;---Turn off all labels
    "tmXBLabelsOn"      : False
    "tmXTLabelsOn"      : False
    "tmYLLabelsOn"      : False
    "tmYRLabelsOn"      : False
  end setvalues

;---Attach single X and Y axis in center of plot.
  hid = attach_horiz_axis(wks,plot,hcart)
  vid = attach_vert_axis(wks,plot,hcart)

;---Be sure to return the ids of the axes we just attached.
  plot@haxis = hid
  plot@vaxis = vid
  return(plot)
end
