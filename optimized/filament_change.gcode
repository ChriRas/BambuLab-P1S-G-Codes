; This code is mostly from DzzD and this PR: https://github.com/bambulab/BambuStudio/pull/1660
; The discussion is here: https://forum.bambulab.com/t/ideas-on-boosting-speed-for-multi-color-printing-with-ams/10037/136
M620 S[next_extruder]A
M204 S9000
{if toolchange_count > 1 && (z_hop_types[current_extruder] == 0 || z_hop_types[current_extruder] == 3)}
G17
G2 Z{z_after_toolchange + 0.4} I0.86 J0.86 P1 F10000 ; spiral lift a little from second lift
{endif}
G1 Z{max_layer_z + 3.0} F1200 ;** only requiered when printing by object ?! otherwise going + 0.5mm should be enought

M106 P1 S0
M106 P2 S0
;M104 S[nozzle_temperature_range_high] ;** Change temp to max without waiting, waiting would take age for nothing
;M104 S275 ;** Change temp to 275°c without waiting, waiting would take age for nothing

;** Go to cutting current filament position
;**G1 X20 Y50 F24000 ;**doing in two path to avoid problem on cutter actuator

G1 X20 F18000
G1 Y50 F18000
G1 Y-3

{if toolchange_count == 2}
; get travel path for change filament
M620.1 X[travel_point_1_x] Y[travel_point_1_y] F24000 P0
M620.1 X[travel_point_2_x] Y[travel_point_2_y] F24000 P1
M620.1 X[travel_point_3_x] Y[travel_point_3_y] F24000 P2
{endif}

M620.1 E{old_filament_e_feedrate * 3} T{new_filament_temp}

M104 S[new_filament_temp] ; Nozzle will change its temperature while filament is loaded/unloaded

T[next_extruder] ;Cut and change filament

M620.1 E{new_filament_e_feedrate * 3} T{new_filament_temp}

{if next_extruder < 255}
G92 E0 ;** reset extruder pos, perfect after T

{if flush_length_1 > 1}
; FLUSH_START 1
{if flush_length_1 > 23.7}
G1 E22.7 F{old_filament_e_feedrate * 1.5} ; do not need pulsatile flushing for start part
G1 E0.2 F120
G1 E{(flush_length_1 - 22.7) * 0.25} F{old_filament_e_feedrate * 1.5}
G1 E0.2 F120
G1 E{(flush_length_1 - 22.7) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.2 F120
G1 E{(flush_length_1 - 22.7) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.2 F120
G1 E{(flush_length_1 - 22.7) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.2 F120
{else}
G1 E{flush_length_1} F{old_filament_e_feedrate * 1.5}
{endif}
; FLUSH_END
{endif}

{if flush_length_2 > 1}
; FLUSH_START 2
G1 E{(flush_length_2 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
G1 E{(flush_length_2 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
G1 E{(flush_length_2 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
G1 E{(flush_length_2 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
; FLUSH_END 2
{endif}

{if flush_length_3 > 1}
; FLUSH_START 3
G1 E{(flush_length_3 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
G1 E{(flush_length_3 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
G1 E{(flush_length_3 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
G1 E{(flush_length_3 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
; FLUSH_END 3
{endif}

{if flush_length_4 > 1}
; FLUSH_START 4
G1 E{(flush_length_4 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
G1 E{(flush_length_4 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
G1 E{(flush_length_4 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
G1 E{(flush_length_4 - 1) * 0.25} F{new_filament_e_feedrate * 1.5}
G1 E0.25 F120
; FLUSH_END 4
{endif}

;**G1 E2 F{new_filament_e_feedrate} ;Compensate for filament spillage during waiting temperature
G1 E1 F30 ;Compensate for filament spillage during two second

M109 R[new_filament_temp]

M106 P1 S255
G92 E0
G1 E-[new_retract_length_toolchange] F1800

G1 Y255 F18000
G1 X80 F18000
G1 X60 F18000
G1 X80 F18000
G1 X60 F18000;shake to put down garbage
G1 X70 F18000
G1 X90 F18000

G1 Y255 F18000
G1 X100 F5000
G1 Y265 F5000
G1 X70 F18000
G1 X100 F18000
G1 X70 F18000
G1 X100 F18000
G1 X165 F18000;wipe and shake
G1 Y256 ; move Y to aside, prevent collision

G1 Z{max_layer_z + 3} F3000
{if layer_z <= (initial_layer_print_height + 0.001)}
M204 S[initial_layer_acceleration]
{else}
M204 S[default_acceleration]
{endif}
{else}
G1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F18000
{endif}
M621 S[next_extruder]A