 ! EXAMPLE.BSL  - sample stimulus list description file
 
 PAUSE Ready?
 trial1 \d1 sample trial w/1 second duration
 
 ! BLOCK A:  2 repetitions of three tokens, randomized
 
 DEFBLOCK A a 2 randomize
 // repeat "heed" 2x for each repetition of the others; its color & duration by argument
 #T1 \d@3 @0 \e<ROW=-2><COL=4>Say <TXTCOLOR=@2>@1<TXTCOLOR=000000> for me
 heed 2 #T1 heed AF0000 1.5
 
 // template for remaining tokens:  set color by argument
 #T2 @0 \e<ROW=-2><COL=4>Say <TXTCOLOR=@2>@1<TXTCOLOR=000000> for me
 hid  #T2 hid 0000AF
 head #T2 head 00AF00
 ENDDEF
 
 BLOCK A 1 none
 
 ! BLOCK B:  2 repetitions of three tokens, not randomized
 
 DEFBLOCK B amn 2 none
 #T @0 \e<ROW=-2><COL=4>Say <TXTCOLOR=@2>@1<TXTCOLOR=000000> for me
 heed #T heed AF0000
 hid  #T hid 0000AF
 head #T head 00AF00
 ENDDEF
 
 BLOCK B 1 none
 
 ! BLOCK C:  bundle preceding instructional DUMMY token; reset rep offset
 
 DEFBLOCK C amn 1 none
 #D @0 \e<ROW=2><HCEN>Speak when color changes</HCEN><ROW=-2><TXTCOLOR=@2><HCEN>@1</HCEN><TXTCOLOR=000000>
 #T @0 acquisition \e<ROW=-2><TXTCOLOR=@2><HCEN>@1</HCEN><TXTCOLOR=000000>
 atu #D atu 0000AF #T atu 00AF00
 ENDDEF
 
 BLOCK C 1 none
 
 ! BLOCK PD: practice block
 
 // Create a block definition that takes one argument
 DEFBLOCK PD amn 2 none #D
 $1 @0 \e<ROW=-2><COL=4>Say <TXTCOLOR=@2>@1<TXTCOLOR=000000> for me
 heed $1 heed AF0000
 hid  $1 hid  0000AF
 head $1 head 00AF00
 ENDDEF
 
 // Redfines the above block as an actual trial with a random order
 REDEFBLOCK PD TD amn 2 randomize #T
 
 BLOCK PD 1 none
 
 ! BLOCK D: trial block
 BLOCK TD 1 none
 
 ! BLOCK S:
 
 // Create a block definition that takes two arguments
 DEFBLOCK S1 amn 1 randomize #T "<BOLD>@1</BOLD> @2"
 $1 @0 \e<ROW=-2><COL=4>Say $2 for me
 heed $1 heed heed
 hid  $1 hid  hid
 head $1 head head
 ENDDEF
 
 // Redfines the above block with a different stress pattern
 REDEFBLOCK S1 S2 amn 1 randomize #T "@1 <BOLD>@2</BOLD>"
 REDEFBLOCK S1 S3 amn 1 randomize #T "@1 @2"
  
 // Block 1 followed by block 2
 BLOCK [S1 S2] 1 none
 // Equivalent to 
 // BLOCK S1 1 none
 // BLOCK S2 1 none
 
 // Repeat each of the 3 blocks 3 times with a randomizer that randomizes
 // within each group of three blocks.
 BLOCK [S1 S2 S3] 3 blockrandom
 
  see BUILDBLOCK for further examples and explanation