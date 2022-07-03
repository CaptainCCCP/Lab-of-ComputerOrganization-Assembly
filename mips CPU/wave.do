onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /test/launch/MAIN/clk
add wave -noupdate -radix hexadecimal /test/launch/MAIN/rst
add wave -noupdate -radix hexadecimal /test/launch/MAIN/instruction
add wave -noupdate -radix hexadecimal /test/launch/MAIN/IFU/pc
add wave -noupdate -radix hexadecimal /test/launch/MAIN/IFU/pcnew
add wave -noupdate -radix hexadecimal /test/launch/MAIN/GPR/rw
add wave -noupdate -radix hexadecimal /test/launch/MAIN/GPR/busW
add wave -noupdate -radix hexadecimal -childformat {{{/test/launch/MAIN/GPR/regi[31]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[30]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[29]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[28]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[27]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[26]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[25]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[24]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[23]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[22]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[21]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[20]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[19]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[18]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[17]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[16]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[15]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[14]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[13]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[12]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[11]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[10]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[9]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[8]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[7]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[6]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[5]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[4]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[3]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[2]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[1]} -radix hexadecimal} {{/test/launch/MAIN/GPR/regi[0]} -radix hexadecimal}} -expand -subitemconfig {{/test/launch/MAIN/GPR/regi[31]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[30]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[29]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[28]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[27]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[26]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[25]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[24]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[23]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[22]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[21]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[20]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[19]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[18]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[17]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[16]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[15]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[14]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[13]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[12]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[11]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[10]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[9]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[8]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[7]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[6]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[5]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[4]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[3]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[2]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[1]} {-radix hexadecimal} {/test/launch/MAIN/GPR/regi[0]} {-radix hexadecimal}} /test/launch/MAIN/GPR/regi
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3248 ns} {4187 ns}
