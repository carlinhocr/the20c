;Zero Page

;Table to store the address of the filenames to load
pivot_LB = $d0 
pivot_HB = $d1 

graphTable_LB = $d2
graphTable_HB = $d3


graphTable = $0300

BUFFER_GRAPHICS_START=$1000
BUFFER_GRAPHICS_END=$3FFF

BUFFER_MUSIC_START=$4000
BUFFER_MUSIC_END=$6FFF

BUFFER_MUSIC2_START=$1000
BUFFER_MUSIC2_END=$3FFF