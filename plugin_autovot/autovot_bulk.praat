
### this praat script is a modified version of the autovot.praat script.
### This script enables you to run AutoVOT on multiple files within a give folder.
### This script should be placed inside your plugin_autovot folder, which should be placed inside your "Praat Prefs" folder.
###
### 
### The Output_folder is where you store the generated textgrids.
### interval_tier asks you to specify in which tier the plosives are labeled
### interval_mark asks you to specify the VOTs of which labeled segments should be measured.
### A audio file might contain different types of plosives, such as p, t, and k.
### The autoVOT plugin could only measure VOTs of one type of plosives.
###
### A workaround is to relabel all the p,t,k to the same name, such as "vot", and then put "vot" as the interval_mark.
### This could be done via Praat script or rPraat package in R. Check my tutorial for details https://github.com/gaozhiyan/MFA_and_AutoVOT_Tutorial
###
###
### Zhiyan Gao, Jan 20, 2020
##############################################
form vot measurement
comment File Folders
	sentence Sound_folder /Users/zhiyangao/Desktop/test/wav/
	sentence TextGrid_folder /Users/zhiyangao/Desktop/test/textgrid/
	sentence Output_folder /Users/zhiyangao/Desktop/test/output/
comment Algorithm parameters
	natural min_vot_length 15
	natural max_vot_length 200
	word interval_tier vot
	word interval_mark vot
endform
clearinfo

 
#Read in list of sound files
myStrings = Create Strings as file list... sounds 'sound_folder$'/*.wav
nSounds = Get number of strings
item = 0

#check if TextGrid file exists for each sound and call treatment
for iSound from 1 to nSounds
	select myStrings
	sound_name$ = Get string... iSound
	textGrid_name$ = sound_name$ - "wav" + "TextGrid"
	sound$ = sound_folder$ + "/" + sound_name$
	textGrid$ = textGrid_folder$ + "/" + textGrid_name$
### the following line defines the segment (e.g., whether it is p, t, or k)
### depending on the first character of the sound_name.

	##interval_mark$ = left$(sound_name$,1)

	if fileReadable(textGrid$)
		call treatment
	endif
endfor

#subroutine treatment
procedure treatment
		Read from file... 'sound$'

		sound = selected ("Sound")
		Read from file... 'textGrid$'
		textgrid = selected ("TextGrid")
	
# get tier names


vot_classifier_model$ = "models/vot_predictor.amanda.max_num_instances_1000.model"



selectObject: sound
sound_name$ = selected$( "Sound")
sound_filename$ = temporaryDirectory$ + "/" + sound_name$ + ".wav"
#appendInfoLine: "Saving ", name$, " as ", sound_filename$
#if channel$ = "mono"
#	converted_sound = Convert to mono
#else
	converted_sound = Extract one channel... 'mono'
#endif
current_rate = Get sample rate
if current_rate <> 16000
	#appendInfoLine: "Resampling Sound object to 16000 Hz."
	Resample... 16000 50
	Save as WAV file: sound_filename$
	Remove
else
	Save as WAV file: sound_filename$
endif
removeObject: 'converted_sound'

selectObject: textgrid
textgrid_name$ = selected$( "TextGrid")




textgrid_filename$ = temporaryDirectory$  + "/" + textgrid_name$ + ".TextGrid"
new_textgrid_filename$ = temporaryDirectory$ + "/" + textgrid_name$ + "_vad.TextGrid"
#appendInfoLine: "Saving ", name$, " as ", textgrid_filename$
Save as text file: textgrid_filename$
selectObject: sound, textgrid

# call vot prediction
log_filename$ = temporaryDirectory$  + "/cmd_line.log"
exec_name$ = "export PATH=$PATH:/Users/zhiyangao/Library/Preferences/Praat\ Prefs/plugin_autovot/;  auto_vot_decode.py "
exec_params$ = "--min_vot_length " +  string$(min_vot_length) 
exec_params$ = exec_params$ + " --max_vot_length " +  string$(max_vot_length) 
exec_params$ = exec_params$ + " --window_tier " + "'" + interval_tier$ + "'"
exec_params$ = exec_params$ + " --window_mark " + "'" + interval_mark$ + "'"
cmd_line$ = exec_name$ + exec_params$
cmd_line$ = cmd_line$ + " " + sound_filename$ + " " + textgrid_filename$ 
cmd_line$ = cmd_line$ + " " + vot_classifier_model$
cmd_line$ = cmd_line$ + " > " + log_filename$ + " 2>&1"

system 'cmd_line$'



# read new TextGrid
system cp 'textgrid_filename$' 'new_textgrid_filename$'
Read from file... 'new_textgrid_filename$'
textgrid_obj_name$ = "TextGrid " + textgrid_name$ + "_vad"
selectObject: textgrid_obj_name$
Remove tier: 3
Save as text file: output_folder$ + "/" + textgrid_name$ + "_new.TextGrid"
Remove

# remove unecessary files
deleteFile: sound_filename$
deleteFile: textgrid_filename$
deleteFile: new_textgrid_filename$
select sound
plus textgrid
Remove
item = item+1
endproc
select all
Remove
appendInfoLine: "Total Number of files processed: " + string$(item)
