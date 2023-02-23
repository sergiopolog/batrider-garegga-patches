	CPU 68000
	PADDING OFF
	ORG	$000000
	BINCLUDE "original_combined_batrider.bin"


; #$07FF => inmediate hex value (constant)
; $00004000 => takes value stored at address 4000
; (a6) => takes value stored at address referenced by the value stored at register a6

FREE_OFFSET = $80000

; TODO:
;	- comprobar como se calcula el porcentaje en bgaregga step by step en el codigo de zakk (minimos y maximos correctos?)

; Rank Address values Garegga:
; $10C9D2 -> 4 byte: Main Rank
; $10C9D6 -> 4 byte: Per-frame increment rank
; $10C9DA -> 4 byte: Min. rank value (hard)
; $10C9DE -> 4 byte: Max. rank value / start rank (easy)

; Rank Address values Batrider:
; $20F9D0 -> 4 byte: Main Rank
; $20F9D4 -> 4 byte: Per-frame increment rank
; $20F9D8 -> 4 byte: Max. rank value / start rank (easy)
; $20F9DC -> 4 byte: Min. rank value (hard) ??????  -> not really, it has another weird value. Min value is 00000000

; FREE_OFFSET_1 = $80000
; FREE_OFFSET_END_1 = $80360
; FREE_SPACE_1 = $360

; FREE_OFFSET_2 = $87DF0
; FREE_OFFSET_END_2 = $87F60
; FREE_SPACE_2 = $170

; FREE_OFFSET_3 = $88150
; FREE_OFFSET_END_3 = $88360
; FREE_SPACE_3 = $210

; gap free space 1: $14AD80
; gap free space 2: $88146



; ROM/RAM Checks:

; routine for ROM0 and ROM1 check:	($15ACC) branches to: $15B50
; routine for Main RAM check:		($15AD0) branches to: $15C62
; routine for Text RAM check:		($15AD4) branches to: $15DE2
; routine for Color RAM check:		($15AD8) branches to: $15E4A
; routine for X RAM check:			($15ADC) branches to: $15EB2
; ....
; ended at ($15AE0) branching to: $15F2C



; ROM0 and ROM1 check routine: $15B50   ($1780A in Batrider)
; - Reset: D0, D1, D2, D3 and A0
; - Set #$24 to D7
; - Read.b and increase content from address in A0, to D2 (even bytes)
; - Substract.l: D0 = D0 - D2
; - Read.b and increase content from address in A0, to D3 (odd bytes)
; - Substract.l: D1 = D1 - D3
; - Decrement D7 -1, check if D7 != -1, if so, branch to third step in this routine
; - 


; $10A0
; $10CC
; trap #9 handler at $41E  (vector for trap #9 stored at $A4)


; Text ram starts at 500000, each char is two bytes size:  1st byte pallete, 2nd byte tile index
; Text Tile map memory indexes starts on bottom-left corner in tate (top-left in yoko) but first half-visible char is skipped and "second" char (completely visible) has the first index ($500000)
; Each column in tate (row in tate) is 128 bytes size ($80), from which first 78 ones ($4D) are used to show the 39 chars that fit in the whole column (2 bytes each), rest are placed outside visible screen
; Total effective size of the map is 128 byte per column * 30 rows = 3840 bytes ($F00)
; 30 chars in total width (heigh in yoko) for 240px:  1 char is 8px width
; 40 chars in total heigh (width in yoko) for 320px:  1 char is 8px heigh  but seems like there is an offset top and bottom of the screen (like half-char-wide at top and half-char-wide at bottom)


; Batrider is pretty similar but has some differences:
; Text ram starts at 200000, each char is two bytes size:  1st byte pallete, 2nd byte tile index
; Text Tile map memory indexes starts on bottom-left corner in tate (top-left in yoko), and first half-visible char has the first index ($200000)
; Each column in tate (row in tate) is 128 bytes size ($80), from which first 78 ones ($4D) are used to show the 39 chars that fit in the whole column (2 bytes each).  Rest are placed outside visible screen
; Total effective size of the map is 128 byte per column * 30 rows = 3840 bytes ($F00)
; 30 chars in total width (heigh in yoko) for 240px:  1 char is 8px width
; 40 chars in total heigh (width in yoko) for 320px:  1 char is 8px heigh  but seems like there is an offset top and bottom of the screen (like half-char-wide at top and half-char-wide at bottom)


; After the upper part of the screen info text is copied, copy ours
	ORG $108E
; Original code in batrider:
;	trap    #$9                                         4E49
;	jsr     $7940.l                                     4EB9 0000 7940
;	jsr     $12640.l                                    4EB9 0001 2640
;	trap    #$4                                         4E44
;	rts                                                 4E75
	jmp custom_values_display	;						4EF9 000525D0
	dc.w 0						;						0000
	jsr $00012640				;					    4EB9 0001 2640
	trap #4						;						4E44
	rts							;						4E75	

; At $1AAC: sets the base multiplier for rank.
; If start is pressed it takes the value stored at: $1AC0 (value of 100)
; If not, it takes the value at: $1ABE (value of C0). Replace this to 100 to simulate starting with start button
	ORG $1ABE
	dc.w $0100

; Jump to our custom rom/ram test code
;	ORG $159CA
;	jmp test_rom_ram_0

; SET ROM0 and ROM1 as OK even if checks are bad:
	ORG $017A2C
	bra $177CE

; The extent of the JAM! / dc.b sets constants values on the place they are (DONE)
	ORG $17F15
	dc.b $4A
	dc.b $41
	dc.b $4D
	dc.b $21
	dc.b 0
	

	ORG FREE_OFFSET
; this do the same as original code in batrider at $108E, and it's called after doing all the stuff at 'custom_values_display':
copy_to_txtmem_tail:
	dc.w $4E49 ; trap #9
	jsr $7940
	jsr $12640
	trap #4
	rts

; Convert a number to base-10 ASCII and write it to text ram
; IN
; d1: The number to display
; d0: The 'format code' to use for the digits
; a5: Start address of output string
; After return, a5 will point to the character AFTER the end of the displayed
; string
write_ascii_to_txt:
	clr.w d2
	clr.w d3
ascii_loop_start:
	divu #$A,d1
	addq.b #1,d2
	move.l d1,d3
	swap d3
	addi.b #$30,d3
	eor.w d0,d3
	move.w d3, -(sp)
	swap d1
	clr.w d1
	swap d1
	tst.w d1
	bne ascii_loop_start
	bra copy_loop_start
copy_loop_head:
	move.w (sp)+,d3
	move.w d3,(a5)
	lea $80(a5),a5
copy_loop_start:
	dbf d2,copy_loop_head
	rts

write_asciihex_to_txt:
	clr.w d3
	clr.w d2
	clr.w d4
	tst.l d1
	beq value_is_zero
write_hex_start:
	move.b d1,d3
	and.b #$F,d3 
	addq.b #1,d2
	lsr.l #4,d1
write_hex_resume:
	cmp.b #$9,d3
	bgt add_hex
	addi.b #$30,d3
	bra after_hex
add_hex:
	addi.b #$37,d3
after_hex:
	or.w d0,d3
	move.w d3, -(sp)
	cmp.b #$8,d2
	bne write_hex_start 
purge_loop_head:
	move.w (sp)+,d3
	cmp.b #$30, d3
	bne purge_done
purge_loop_start:
	dbf d2,purge_loop_head
	rts
purge_done:
	move.w d3, -(sp)
	bra copy_loop_start
value_is_zero:
	moveq #$0,d3
	or.w d0,d3
	move.w d3,(a5)
	rts
digit_is_zero:
	btst #$F,d4
	beq write_hex_start
	bra write_hex_resume

; After the main program writes a bunch of the txt hud (scores, etc)
; There's a jump here. This writes autofire rates and rank display
custom_values_display:
	btst #2, ($500002)	; check bit 2 of value at $500002. If 1 (dip enabled) show rank display (dip switch stage select)
	beq custom_values_end
; Overall rank. This is a big number that normally overflows a DIV 10
; operation. Divide by 1000 first, then convert+print the quotient first
; then the remainder
rank_display:
	lea ($200648),a5
	move.w #$C400,d0 ; Set pallete color: C4 (light blue)
	clr.l d1
	move.l ($20F9D0),d1 
	jsr write_asciihex_to_txt
	clr.l d1
	move.l ($20F9D4),d1
	lea ($200046),a5
	jsr write_ascii_to_txt
; Calculate rank percentage
	tst ($20F9D0)
	beq copy_to_txtmem_tail 
	jsr calculate_min_rank	; get min rank value of "normal course"
	move.l d4,d1			; min rank to D1
	sub.l ($20F9D0),d1		; perform:  D1 = D1 - current_rank
	move.l d4,d3	 		; min rank to D3
;   sub.l #$200000, d3		; (not needed) perform: D3 = D3 - $200000
	divu #1000,d3			; Divide D3 = D3/1000   (D3/$3E8)
	swap d3					; 
	clr.w d3				; 
	swap d3 				; remove upper word from D3
	divu d3,d1
	swap d1
	clr.w d1
	swap d1
	divu #10,d1
; d1[0-15].d1[16-32]%
	lea ($200048), a5		; set start cursor position for the percentaje rank value to be printed
	move.l d1,d4			; save full value (integer and decimal part) into d4, to restore it later			 
	swap d1					
	clr.w d1				; remove decimal part d1[16-32]
	swap d1
	jsr write_ascii_to_txt	; write only integer part of the percentaje value
	swap d4					; restore decimal value from d4, previosly lost in d1...
	move.w d4,d1 			; ...and set it again to d1
	move.w #$C42E,(a5)		; write directly a dot character ($2E) with light blue palette ($C4)
	lea $80(a5), a5			; increases one row the cursor position after writting the dot (+ $80) as the dot was not written by the subroutine
	jsr write_ascii_to_txt	; write only decimal part of the percentaje value
	move.w #$C425,(a5)		; write directly a percentaje character ($25) with light blue palette ($C4)
	lea $80(a5),a5			; increases one row the cursor position after writting the percentaje (+ $80) as the dot was not written by the subroutine
	move.w #$0000,(a5)		; write directly an "empty" character ($00) with "trassparent" palette ($00)
	lea $80(a5),a5			; increases one row the cursor position after writting the "empty" (+ $80) as the dot was not written by the subroutine
	move.w #$0000,(a5)		; write directly another "empty" character ($00) with "trassparent" palette ($00)
	move.l ($100D92),d1
	jsr write_rank_adjust  
custom_values_end:
	jmp copy_to_txtmem_tail

; Gets the min rank value of "normal course", considered as 0.0%.
; Value could vary depending on dip switch settings
; OUT
; d4: The rank min value 
calculate_min_rank:
	lea ($c7e), A5
	moveq #$0, D4
	move.b $20f9fa.l, D4	; read difficulty dip switch value: easy, normal, hard, veryhard = $00, $01, $02, $03
	add.w D4, D4 			; double the value of dip switch value (to jump between words, not bytes)
	move.w (A5,D4.w), D4	; read proper value from rank-start-table using dip value as index
	mulu.w $20f9ce.l, D4	; multiply rank-start-table value selected with rank-base-multiplier (100 or C0 depending on booting game with Start button or not)
	lea ($c86), A5			; point to rank-start-multipler-table
	moveq #$2, D5			; we consider lowest rank the "normal course" start rank value (same as "training")
	mulu.w (A5,D5.w), D4	; multiply the previous value with the selected value in rank-start-multipler-table
	rts



rank_adjust_z:
	andi.l #$30000,d7
	bne sub_rank_adj
	add.l d0, ($100D92)
	clr.w ($100D88)
sub_rank_adj:
	sub.l d0,($20F9D0)
	move.l ($20F9D0),d0
	cmp.l ($20F9DC),d0
	bcs below_min_rank
	cmp.l ($20F9D8),d0
	bcs rank_adjust_rts
	move.l ($20F9D8),($20F9D0)
	rts
below_min_rank:
	move.l ($20F9DC),($20F9D0)
rank_adjust_rts:
	andi.l #$20000,d7
	beq real_adj_rts
	addq.w #1,($100D88)
	cmp.w #120,($100D88)
	beq rank_display_expired
real_adj_rts:
	rts

write_rank_adjust:
	move.l ($100D92),d1
	clr.l ($100D92)
	tst.l d1
	bne rank_write_not_zero
	rts
rank_write_not_zero:
	lea ($200646),a5
start_rank_adj:
	cmp.l #$FFFFFFFF,d1
	beq clear_rank_digits
	move.w #$C400,d0
	tst.l d1
	bpl rank_pos
	neg.l d1
	move.w #$CC00,d0
rank_pos:       
	cmp.l ($100D82), d1
	bne clear_rank_digits
	move.w ($100D86),d0
	eor.w #$C00,d0
clear_rank_digits:
	move.w #$0000,(a5)
	move.w #$0000,$80(a5)
	move.w #$0000,$100(a5)
	move.w #$0000,$180(a5)
	move.w #$0000,$200(a5)
	move.w #$0000,$280(a5)
	move.w #$0000,$300(a5)
	move.w #$0000,$380(a5)
	move.w #$0000,$400(a5)
	cmp.l #$FFFFFFFF, d1
	beq clear_rank_rts 
	cmp.l #$0,d1
	beq clear_rank_rts
	move.l d1,($100D82)
	move.w d0, ($100D86)
       ; clr.w ($100D88)
	jsr write_asciihex_to_txt
clear_rank_rts:
	rts
rank_display_expired:
	clr.w ($100D88)
	clr.l ($100D82)
	move.l #$FFFFFFFF, ($100D92)
	rts
