;Zero Page

noteDuration=$44
noteIndex=$45
octaveOffset=$46
noteFreqLow=$47
noteFreqHigh=$48
musicNote=$49
musicOctave=$4a
; notesParseLow=$4b
; notesParseHigh=$4c
waveFormV1=$4d
waveFormV2=$4e
waveFormV3=$4f
; soundLowByte=$50
; soundHighByte=$51
soundDelay=$52
musicalNotesLow=$53
musicalNotesHigh=$54
musicalDurationLow=$55
musicalDurationHigh=$56
; totalMusicalBytes=$57
sidLocationLow=$58
sidLocationHigh=$59
sidNotesLowV1=$5a
sidNotesHighV1=$5b
sidNotesLowV2=$5c
sidNotesHighV2=$5d
sidNotesLowV3=$5e
sidNotesHighV3=$5f

;RAM

;SOUND SID 6581

SID_BASE = $7300

SID_V1FL = SID_BASE + 0
SID_V1FH = SID_BASE + 1
SID_V1PWL = SID_BASE + 2
SID_V1PWLH = SID_BASE + 3
SID_V1CTRL = SID_BASE + 4
SID_V1AD = SID_BASE + 5
SID_V1SR = SID_BASE + 6

SID_V2FL = SID_BASE + 7
SID_V2FH = SID_BASE + 8
SID_V2PWL = SID_BASE + 9
SID_V2PWLH = SID_BASE + $A
SID_V2CTRL = SID_BASE + $B
SID_V2AD = SID_BASE + $C
SID_V2SR = SID_BASE + $D

SID_V3FL = SID_BASE + $E
SID_V3FH = SID_BASE + $F
SID_V3PWL = SID_BASE + $10
SID_V3PWLH = SID_BASE + $11
SID_V3CTRL = SID_BASE + $12
SID_V3AD = SID_BASE + $13
SID_V3SR = SID_BASE + $14

SID_FILTER_FCL = SID_BASE + $15
SID_FILTER_FCH = SID_BASE + $16
SID_FILTER_RF = SID_BASE + $17
SID_FILTER_MV = SID_BASE + $18

SID_POTX = SID_BASE + $19
SID_POTY = SID_BASE + $1A
SID_OSC3_RANDOM = SID_BASE + $1B
SID_ENV3 = SID_BASE + $1C

