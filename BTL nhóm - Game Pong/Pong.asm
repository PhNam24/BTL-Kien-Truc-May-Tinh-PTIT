;Code được tham khảo từ : https://github.com/programmingdimension/8086-Assembly-Pong/blob/master/pong.asm
STACK SEGMENT PARA STACK
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
	
	WINDOW_WIDTH DW 140h                 ;chiều rộng của cửa sổ (320 pixels)
	WINDOW_HEIGHT DW 0C8h                ;chiều cao của cửa sổ (200 pixels)
	WINDOW_BOUNDS DW 6                   ;biến kiểm tra va chạm
	
	TIME_AUX DB 0                        ;biến kiểm tra thời gian
	GAME_ACTIVE DB 1                     ;biến kiểm tra trạng thái trò chơi (1 -> Yes, 0 -> No (game over))
	EXITING_GAME DB 0
	WINNER_INDEX DB 0                    ;chỉ số của người chiến thắng (1 -> player one, 2 -> player two)
	CURRENT_SCENE DB 0                   ;trạng thái màn hình hiện tại (0 -> main menu, 1 -> game)
	
	TEXT_PLAYER_ONE_POINTS DB '0','$'    ;điểm của người chơi thứ 1
	TEXT_PLAYER_TWO_POINTS DB '0','$'    ;điểm của người chơi thứ 2
	TEXT_GAME_OVER_TITLE DB 'CONGTATULATIONS!!!','$' ;title sau khi kết thúc trò chơi
	TEXT_GAME_OVER_WINNER DB 'Player 0 won','$' ;text lưu người chiến thắng
	TEXT_GAME_OVER_PLAY_AGAIN DB 'Press R to play again','$' ;tin nhắn tiếp tục trò chơi
	TEXT_GAME_OVER_MAIN_MENU DB 'Press E to exit to main menu','$' ;tin nhắn trở về menu
	TEXT_MAIN_MENU_TITLE DB 'MAIN MENU','$' ;title menu
	TEXT_MAIN_MENU_SINGLEPLAYER DB 'MULTIPLAYER - S KEY','$' ;chế độ chơi 2 người
	TEXT_MAIN_MENU_MULTIPLAYER DB 'SINGLEPLAYER - M KEY','$' ;chế độ chơi 1 người
	TEXT_MAIN_MENU_EXIT DB 'EXIT GAME - E KEY','$' ;tin nhắn thoát trò chơi
	
	BALL_ORIGINAL_X DW 0A0h              ;X vị trí của quả bóng khi bắt đầu trò chơi
	BALL_ORIGINAL_Y DW 64h               ;Y vị trí của quả bóng khi bắt đầu trò chơi
	BALL_X DW 0A0h                       ;vị trí X hiện tại (cột) của quả bóng
	BALL_Y DW 64h                        ;vị trí Y hiện tại (đường) của quả bóng
	BALL_SIZE DW 06h                     ;kích thước của quả bóng (quả bóng có chiều rộng và chiều cao bao nhiêu pixel)
	BALL_VELOCITY_X DW 05h               ;X Vận tốc X (ngang) của quả bóng
	BALL_VELOCITY_Y DW 02h               ;Y Vận tốc Y (dọc) của quả bóng
	
	PADDLE_LEFT_X DW 0Ah                 ;vị trí X hiện tại của thanh đánh bóng bên trái
	PADDLE_LEFT_Y DW 55h                 ;vị trí Y hiện tại của thanh đánh bóng bên trái
	PLAYER_ONE_POINTS DB 0              ;điểm hiện tại của người chơi bên trái (người chơi 1)
	
	PADDLE_RIGHT_X DW 130h               ;vị trí X hiện tại của thanh đánh bóng bên phải
	PADDLE_RIGHT_Y DW 55h                ;vị trí Y hiện tại của thanh đánh bóng bên trái
	PLAYER_TWO_POINTS DB 0             ;điểm hiện tại của người chơi bên phải (người chơi 2)
	
	PADDLE_WIDTH DW 06h                  ;chiều rộng thanh đánh bóng
	PADDLE_HEIGHT DW 25h                 ;chiều dài thanh đánh bóng
	PADDLE_VELOCITY DW 0Fh               ;vận tốc thanh đánh bóng

DATA ENDS

CODE SEGMENT PARA 'CODE'

	MAIN PROC FAR
	ASSUME CS:CODE,DS:DATA,SS:STACK      ;đưa code, dữ liệu và phân đoạn ngăn xếp các thanh ghi tương ứng
	PUSH DS                              ;đẩy DS vào ngăn xếp
	SUB AX,AX                            ;clear AX
	PUSH AX                              ;đẩy AX vào ngăn xếp
	MOV AX,DATA                          ;lưu DATA vào AX
	MOV DS,AX                            ;lưu AX vào DS
	POP AX                               ;đẩy top của ngăn xếp vào thanh ghi AX
	POP AX                               ;đẩy top của ngăn xếp vào thanh ghi AX
		
		CALL CLEAR_SCREEN                ;đặt cấu hình chế độ video ban đầu
		
		CHECK_TIME:                      ;vòng kiểm tra thời gian
			
			CMP EXITING_GAME,01h
			JE START_EXIT_PROCESS
			
			CMP CURRENT_SCENE,00h
			JE SHOW_MAIN_MENU
			
			CMP GAME_ACTIVE,00h
			JE SHOW_GAME_OVER
			
			MOV AH,2Ch 					 ;lấy thời gian hệ thống
			INT 21h    					 ;CH = giờ CL = phút DH = giây DL = 1/100 giây
			
			CMP DL,TIME_AUX  			 ;kiểm tra xem thời gian hiện tại có bằng thời gian trước đó không?
			JE CHECK_TIME    		     	 ;nếu giống thì kiểm tra lại
			
			;nếu đến đây, tức là đã kiểm tra xong
  
			MOV TIME_AUX,DL              ;cập nhật thời gian
			
			CALL CLEAR_SCREEN            ;xóa màn hình bằng cách khởi động lại chế độ video
			
			CALL MOVE_BALL               ;di chuyển quả bóng
			CALL DRAW_BALL               ;vẽ bóng
			
			CALL MOVE_PADDLES            ;di chuyển hai thanh bóng (kiểm tra cách nhấn phím)
			CALL DRAW_PADDLES            ;vẽ hai thanh đập với vị trí đã được cập nhật
			
			CALL DRAW_UI                 ;vẽ giao diện người dùng trò chơi
			
			JMP CHECK_TIME               ;kiểm tra lại thời gian
			
			SHOW_GAME_OVER:
				CALL DRAW_GAME_OVER_MENU
				JMP CHECK_TIME
				
			SHOW_MAIN_MENU:
				CALL DRAW_MAIN_MENU
				JMP CHECK_TIME
				
			START_EXIT_PROCESS:
				CALL CONCLUDE_EXIT_GAME
				
		RET		
	MAIN ENDP
	
	MOVE_BALL PROC NEAR                  ;xử lý chuyển động của quả bóng
		
;	Di chuyển quả bóng theo chiều ngang
		MOV AX,BALL_VELOCITY_X    
		ADD BALL_X,AX                   
		
;       Kiểm tra xem bóng đã qua đường biên trái chưa (BALL_X < 0 + WINDOW_BOUNDS)
;       If is colliding, restart its position		
		MOV AX,WINDOW_BOUNDS
		CMP BALL_X,AX                    ;BALL_X được so sánh với biên trái của màn hình (0 + WINDOW_BOUNDS)          
		JL GIVE_POINT_TO_PLAYER_TWO      ;nếu nhỏ hơn, cho người chơi hai 1 điểm và đặt lại vị trí bóng
		
;       Kiểm tra xem bóng đã qua đường biên phải chưa (BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS)
;       If is colliding, restart its position		
		MOV AX,WINDOW_WIDTH
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_X,AX	                ;BALL_X được so sánh với biên phải của màn hình (BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS)  
		JG GIVE_POINT_TO_PLAYER_ONE     ;nếu lớn hơn, cho người chơi một 1 điểm và đặt lại vị trí bóng
		JMP MOVE_BALL_VERTICALLY
		
		GIVE_POINT_TO_PLAYER_ONE:		 ;cho người chơi một 1 điểm và đặt lại vị trí bóng
			INC PLAYER_ONE_POINTS       ;tăng điểm của người chơi 1 
			CALL RESET_BALL_POSITION     ;đặt lại vị trí bóng vào giữa màn hình
			
			CALL UPDATE_TEXT_PLAYER_ONE_POINTS ;cập nhật điểm cho người chơi 1
			
			CMP PLAYER_ONE_POINTS,05h   ;kiểm tra xem người chơi đã đạt 5 điểm chưa
			JGE GAME_OVER                ;nếu điểm người chơi này là 5 hoặc nhiều hơn, trò chơi kết thúc
			RET
		
		GIVE_POINT_TO_PLAYER_TWO:        ;cho người chơi hai 1 điểm và đặt lại vị trí bóng
			INC PLAYER_TWO_POINTS      ;tăng điểm của người chơi 2
			CALL RESET_BALL_POSITION     ;đặt lại vị trí bóng vào giữa màn hình
			
			CALL UPDATE_TEXT_PLAYER_TWO_POINTS ;cập nhật điểm cho người chơi 2
			
			CMP PLAYER_TWO_POINTS,05h  ;kiểm tra xem người chơi đã đạt 5 điểm chưa
			JGE GAME_OVER                ;nếu điểm người chơi này là 5 hoặc nhiều hơn, trò chơi kết thúc
			RET
			
		GAME_OVER:                       ;có người chơi đạt 5 điểm
			CMP PLAYER_ONE_POINTS,05h    ;kiểm tra xem người chơi nào có 5 điểm trở lên
			JNL WINNER_IS_PLAYER_ONE     ;nếu người chơi 1 có ít nhất 5 điểm là người chiến thắng
			JMP WINNER_IS_PLAYER_TWO     ;nếu không thì người chơi thứ hai là người chiến thắng
			
			WINNER_IS_PLAYER_ONE:
				MOV WINNER_INDEX,01h     ;cập nhật chỉ số người chiến thắng với chỉ số người chơi một
				JMP CONTINUE_GAME_OVER
			WINNER_IS_PLAYER_TWO:
				MOV WINNER_INDEX,02h     ;cập nhật chỉ số người chiến thắng với chỉ số người chơi hai
				JMP CONTINUE_GAME_OVER
				
			CONTINUE_GAME_OVER:
				MOV PLAYER_ONE_POINTS,00h   ;reset điểm người chơi 1
				MOV PLAYER_TWO_POINTS,00h   ;reset điểm người chơi 2
				CALL UPDATE_TEXT_PLAYER_ONE_POINTS
				CALL UPDATE_TEXT_PLAYER_TWO_POINTS
				MOV GAME_ACTIVE,00h            ;dừng trò chơi
				RET	

;	Di chuyển quả bóng theo chiều dọc		
		MOVE_BALL_VERTICALLY:		
			MOV AX,BALL_VELOCITY_Y
			ADD BALL_Y,AX             
		
;       Kiểm tra xem bóng đã vượt qua biên trên chưa (BALL_Y < 0 + WINDOW_BOUNDS)
;       If is colliding, reverse the velocity in Y
		MOV AX,WINDOW_BOUNDS
		CMP BALL_Y,AX                    ;BALL_Y được so sánh với biên trên của màn hình (0 + WINDOW_BOUNDS)
		JL NEG_VELOCITY_Y                ;nếu nhỏ hơn thì hoàn nguyên vận tốc trong Y

;       Kiểm tra xem bóng đã vượt qua biên dưới chưa (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
;       If is colliding, reverse the velocity in Y		
		MOV AX,WINDOW_HEIGHT	
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_Y,AX                    ;BALL_Y được so sánh với biên dưới của màn hình (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
		JG NEG_VELOCITY_Y		         ;nếu lớn hơn thì hoàn nguyên vận tốc trong Y
		
;       Kiểm tra xem quả bóng có va chạm với thanh bên phải không
		; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		; BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_RIGHT_X + PADDLE_WIDTH 
		; && BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT
		
		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_X
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;nếu không có va chạm, hãy kiểm tra va chạm thanh bên trái
		
		MOV AX,PADDLE_RIGHT_X
		ADD AX,PADDLE_WIDTH
		CMP BALL_X,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;nếu không có va chạm, hãy kiểm tra va chạm thanh bên trái
		
		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_Y
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;nếu không có va chạm, hãy kiểm tra va chạm thanh bên trái
		
		MOV AX,PADDLE_RIGHT_Y
		ADD AX,PADDLE_HEIGHT
		CMP BALL_Y,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;nếu không có va chạm, hãy kiểm tra va chạm thanh bên trái
		
;       Nếu đến đây, quả bóng đang va chạm với thanh bên phải

		JMP NEG_VELOCITY_X

;       Kiểm tra xem quả bóng có va chạm với thanh bên trái không
		CHECK_COLLISION_WITH_LEFT_PADDLE:
		; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		; BALL_X + BALL_SIZE > PADDLE_LEFT_X && BALL_X < PADDLE_LEFT_X + PADDLE_WIDTH 
		; && BALL_Y + BALL_SIZE > PADDLE_LEFT_Y && BALL_Y < PADDLE_LEFT_Y + PADDLE_HEIGHT
		
		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_LEFT_X
		JNG EXIT_COLLISION_CHECK  ;nếu không có va chạm, dừng lại việc kiểm tra
		
		MOV AX,PADDLE_LEFT_X
		ADD AX,PADDLE_WIDTH
		CMP BALL_X,AX
		JNL EXIT_COLLISION_CHECK  ;nếu không có va chạm, dừng lại việc kiểm tra
		
		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_LEFT_Y
		JNG EXIT_COLLISION_CHECK  ;nếu không có va chạm, dừng lại việc kiểm tra
		
		MOV AX,PADDLE_LEFT_Y
		ADD AX,PADDLE_HEIGHT
		CMP BALL_Y,AX
		JNL EXIT_COLLISION_CHECK  ;nếu không có va chạm, dừng lại việc kiểm tra
		
;       Nếu đến đây, quả bóng đang va chạm với thanh bên trái	

		JMP NEG_VELOCITY_X
		
		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y   ;đảo ngược vận tốc theo Y của quả bóng(BALL_VELOCITY_Y = - BALL_VELOCITY_Y)
			RET
		NEG_VELOCITY_X:
			NEG BALL_VELOCITY_X              ;đảo ngược vận tốc ngang của quả bóng
			RET                              
			
		EXIT_COLLISION_CHECK:
			RET
	MOVE_BALL ENDP
	
	MOVE_PADDLES PROC NEAR               ;quá trình chuyển động của thanh đập
		
;       chuyển động của thanh đập trái
		
		;kiểm tra xem có phím nào đang được nhấn không (nếu không kiểm tra thanh còn lại)
		MOV AH,01h
		INT 16h
		JZ CHECK_RIGHT_PADDLE_MOVEMENT ;ZF = 1, JZ -> Jump If Zero
		
		;kiểm tra phím nào đang được nhấn (AL = ASCII character)
		MOV AH,00h
		INT 16h
		
		;nếu nó là 'w' hoặc 'W' di chuyển lên
		CMP AL,77h ;'w'
		JE MOVE_LEFT_PADDLE_UP
		CMP AL,57h ;'W'
		JE MOVE_LEFT_PADDLE_UP
		
		;nếu nó là 's' hoặc 'S' di chuyển xuống
		CMP AL,73h ;'s'
		JE MOVE_LEFT_PADDLE_DOWN
		CMP AL,53h ;'S'
		JE MOVE_LEFT_PADDLE_DOWN
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		MOVE_LEFT_PADDLE_UP:
			MOV AX,PADDLE_VELOCITY
			SUB PADDLE_LEFT_Y,AX
			
			MOV AX,WINDOW_BOUNDS
			CMP PADDLE_LEFT_Y,AX
			JL FIX_PADDLE_LEFT_TOP_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_TOP_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
		MOVE_LEFT_PADDLE_DOWN:
			MOV AX,PADDLE_VELOCITY
			ADD PADDLE_LEFT_Y,AX
			MOV AX,WINDOW_HEIGHT
			SUB AX,WINDOW_BOUNDS
			SUB AX,PADDLE_HEIGHT
			CMP PADDLE_LEFT_Y,AX
			JG FIX_PADDLE_LEFT_BOTTOM_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_BOTTOM_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		
;       chuyển động của thanh đập phải
		CHECK_RIGHT_PADDLE_MOVEMENT:
		
			;nếu nó là 'o' hoặc 'O' di chuyển lên
			CMP AL,6Fh ;'o'
			JE MOVE_RIGHT_PADDLE_UP
			CMP AL,4Fh ;'O'
			JE MOVE_RIGHT_PADDLE_UP
			
			;nếu nó là 'l' hoặc 'L' di chuyển xuống
			CMP AL,6Ch ;'l'
			JE MOVE_RIGHT_PADDLE_DOWN
			CMP AL,4Ch ;'L'
			JE MOVE_RIGHT_PADDLE_DOWN
			JMP EXIT_PADDLE_MOVEMENT
			

			MOVE_RIGHT_PADDLE_UP:
				MOV AX,PADDLE_VELOCITY
				SUB PADDLE_RIGHT_Y,AX
				
				MOV AX,WINDOW_BOUNDS
				CMP PADDLE_RIGHT_Y,AX
				JL FIX_PADDLE_RIGHT_TOP_POSITION
				JMP EXIT_PADDLE_MOVEMENT
				
				FIX_PADDLE_RIGHT_TOP_POSITION:
					MOV PADDLE_RIGHT_Y,AX
					JMP EXIT_PADDLE_MOVEMENT
			
			MOVE_RIGHT_PADDLE_DOWN:
				MOV AX,PADDLE_VELOCITY
				ADD PADDLE_RIGHT_Y,AX
				MOV AX,WINDOW_HEIGHT
				SUB AX,WINDOW_BOUNDS
				SUB AX,PADDLE_HEIGHT
				CMP PADDLE_RIGHT_Y,AX
				JG FIX_PADDLE_RIGHT_BOTTOM_POSITION
				JMP EXIT_PADDLE_MOVEMENT
				
				FIX_PADDLE_RIGHT_BOTTOM_POSITION:
					MOV PADDLE_RIGHT_Y,AX
					JMP EXIT_PADDLE_MOVEMENT
		
		EXIT_PADDLE_MOVEMENT:
		
			RET
		
	MOVE_PADDLES ENDP
	
	RESET_BALL_POSITION PROC NEAR        ;reset vị trí bóng về vị trí ban đầu
		
		MOV AX,BALL_ORIGINAL_X
		MOV BALL_X,AX
		
		MOV AX,BALL_ORIGINAL_Y
		MOV BALL_Y,AX
		
		NEG BALL_VELOCITY_X
		NEG BALL_VELOCITY_Y
		
		RET
	RESET_BALL_POSITION ENDP
	
	DRAW_BALL PROC NEAR                  
		
		MOV CX,BALL_X                    ;đặt cột ban đầu (X)
		MOV DX,BALL_Y                    ;đặt dòng ban đầu (Y)
		
		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch                   			 ;đặt cấu hình để viết một pixel
			MOV AL,0Fh 					 ;chọn màu trắng làm màu
			MOV BH,00h 					 ;đặt số trang 
			INT 10h    					 ;thực hiện cấu hình
			
			INC CX     					 ;CX = CX + 1
			MOV AX,CX          	  		 ;CX - BALL_X > BALL_SIZE (Y -> đi đến dòng tiếp theo,N -> tiếp tục đến cột tiếp theo
			SUB AX,BALL_X
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
			MOV CX,BALL_X 				 ;thanh ghi CX quay trở lại cột ban đầu
			INC DX       				 ;tiến lên một dòng
			
			MOV AX,DX             		 ;DX - BALL_Y > BALL_SIZE (Y -> thoát khỏi thủ tục này,N -> tiếp tục đến dòng tiếp theo
			SUB AX,BALL_Y
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
		
		RET
	DRAW_BALL ENDP
	
	DRAW_PADDLES PROC NEAR
		
		MOV CX,PADDLE_LEFT_X 			 ;đặt cột ban đầu (X)
		MOV DX,PADDLE_LEFT_Y 			 ;đặt dòng ban đầu (Y)
		
		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH,0Ch 					 ;đặt cấu hình để viết một pixel
			MOV AL,0Fh 					 ;chọn màu trắng làm màu
			MOV BH,00h 					 ;đặt số trang
			INT 10h    					 ;thực hiện cấu hình
			
			INC CX     				 	 ;CX = CX + 1
			MOV AX,CX         			 ;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> đi đến dòng tiếp theo,N -> tiếp tục đến cột tiếp theo
			SUB AX,PADDLE_LEFT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			MOV CX,PADDLE_LEFT_X 		 ;thanh ghi CX quay trở lại cột ban đầu
			INC DX       				 ;tiến lên một dòng
			
			MOV AX,DX            	     ;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y -> tiến lên một dòng,N -> tiếp tục đến dòng tiếp theo
			SUB AX,PADDLE_LEFT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			
		MOV CX,PADDLE_RIGHT_X 			 ;đặt cột ban đầu (X)
		MOV DX,PADDLE_RIGHT_Y 			 đặt dòng ban đầu (Y)
		
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH,0Ch 					 ;đặt cấu hình để viết một pixel
			MOV AL,0Fh 					 ;chọn màu trắng làm màu
			MOV BH,00h 					 ;đặt số trang
			INT 10h    					 ;thực hiện cấu hình
			
			INC CX     					 ;CX = CX + 1
			MOV AX,CX         			 ;CX - PADDLE_RIGHT_X > PADDLE_WIDTH (Y -> Wđi đến dòng tiếp theo,N -> tiếp tục đến cột tiếp theo
			SUB AX,PADDLE_RIGHT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
			MOV CX,PADDLE_RIGHT_X		 ;thanh ghi CX quay trở lại cột ban đầu
			INC DX       				 ;tiến lên một dòng
			
			MOV AX,DX            	     ;DX - PADDLE_RIGHT_Y > PADDLE_HEIGHT (Y -> thoát khỏi thủ tục này,N -> tiếp tục đến dòng tiếp theo
			SUB AX,PADDLE_RIGHT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
		RET
	DRAW_PADDLES ENDP
	
	DRAW_UI PROC NEAR
		
;       Draw the points of the left player (player one)
		
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,04h                       ;set row 
		MOV DL,06h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_PLAYER_ONE_POINTS    ;give DX a pointer to the string TEXT_PLAYER_ONE_POINTS
		INT 21h                          ;print the string 
		
;       Draw the points of the right player (player two)
		
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,04h                       ;set row 
		MOV DL,1Fh						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_PLAYER_TWO_POINTS    ;give DX a pointer to the string TEXT_PLAYER_ONE_POINTS
		INT 21h                          ;print the string 
		
		RET
	DRAW_UI ENDP
	
	UPDATE_TEXT_PLAYER_ONE_POINTS PROC NEAR
		
		XOR AX,AX
		MOV AL,PLAYER_ONE_POINTS ;given, for example that P1 -> 2 points => AL,2
		
		;now, before printing to the screen, we need to convert the decimal value to the ascii code character 
		;we can do this by adding 30h (number to ASCII)
		;and by subtracting 30h (ASCII to number)
		ADD AL,30h                       ;AL,'2'
		MOV [TEXT_PLAYER_ONE_POINTS],AL
		
		RET
	UPDATE_TEXT_PLAYER_ONE_POINTS ENDP
	
	UPDATE_TEXT_PLAYER_TWO_POINTS PROC NEAR
		
		XOR AX,AX
		MOV AL,PLAYER_TWO_POINTS ;given, for example that P2 -> 2 points => AL,2
		
		;now, before printing to the screen, we need to convert the decimal value to the ascii code character 
		;we can do this by adding 30h (number to ASCII)
		;and by subtracting 30h (ASCII to number)
		ADD AL,30h                       ;AL,'2'
		MOV [TEXT_PLAYER_TWO_POINTS],AL
		
		RET
	UPDATE_TEXT_PLAYER_TWO_POINTS ENDP
	
	DRAW_GAME_OVER_MENU PROC NEAR        ;draw the game over menu
		
		CALL CLEAR_SCREEN                ;clear the screen before displaying the menu

;       Shows the menu title
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,04h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_GAME_OVER_TITLE      ;give DX a pointer 
		INT 21h                          ;print the string

;       Shows the winner
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,06h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		CALL UPDATE_WINNER_TEXT
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_GAME_OVER_WINNER      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the play again message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,08h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 

		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_GAME_OVER_PLAY_AGAIN      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the main menu message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Ah                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 

		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_GAME_OVER_MAIN_MENU      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Waits for a key press
		MOV AH,00h
		INT 16h

;       If the key is either 'R' or 'r', restart the game		
		CMP AL,'R'
		JE RESTART_GAME
		CMP AL,'r'
		JE RESTART_GAME
;       If the key is either 'E' or 'e', exit to main menu
		CMP AL,'E'
		JE EXIT_TO_MAIN_MENU
		CMP AL,'e'
		JE EXIT_TO_MAIN_MENU
		RET
		
		RESTART_GAME:
			MOV GAME_ACTIVE,01h
			RET
		
		EXIT_TO_MAIN_MENU:
			MOV GAME_ACTIVE,00h
			MOV CURRENT_SCENE,00h
			RET
			
	DRAW_GAME_OVER_MENU ENDP
	
	DRAW_MAIN_MENU PROC NEAR
		
		CALL CLEAR_SCREEN
		
;       Shows the menu title
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,04h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_TITLE      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the singleplayer message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,06h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_SINGLEPLAYER      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the multiplayer message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,08h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_MULTIPLAYER      ;give DX a pointer 
		INT 21h                          ;print the string
		
;       Shows the exit message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Ah                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_EXIT      ;give DX a pointer 
		INT 21h                          ;print the string	
		
		MAIN_MENU_WAIT_FOR_KEY:
;       Waits for a key press
			MOV AH,00h
			INT 16h
		
;       Check whick key was pressed
			CMP AL,'S'
			JE START_SINGLEPLAYER
			CMP AL,'s'
			JE START_SINGLEPLAYER
			CMP AL,'M'
			JE START_MULTIPLAYER
			CMP AL,'m'
			JE START_MULTIPLAYER
			CMP AL,'E'
			JE EXIT_GAME
			CMP AL,'e'
			JE EXIT_GAME
			JMP MAIN_MENU_WAIT_FOR_KEY
			
		START_SINGLEPLAYER:
			MOV CURRENT_SCENE,01h
			MOV GAME_ACTIVE,01h
			RET
		
		START_MULTIPLAYER:
			JMP MAIN_MENU_WAIT_FOR_KEY ;TODO
		
		EXIT_GAME:
			MOV EXITING_GAME,01h
			RET

	DRAW_MAIN_MENU ENDP
	
	UPDATE_WINNER_TEXT PROC NEAR
		
		MOV AL,WINNER_INDEX              ;if winner index is 1 => AL,1
		ADD AL,30h                       ;AL,31h => AL,'1'
		MOV [TEXT_GAME_OVER_WINNER+7],AL ;update the index in the text with the character
		
		RET
	UPDATE_WINNER_TEXT ENDP
	
	CLEAR_SCREEN PROC NEAR               ;clear the screen by restarting the video mode
	
			MOV AH,00h                   ;set the configuration to video mode
			MOV AL,13h                   ;choose the video mode
			INT 10h    					 ;execute the configuration 
		
			MOV AH,0Bh 					 ;set the configuration
			MOV BH,00h 					 ;to the background color
			MOV BL,00h 					 ;choose black as background color
			INT 10h    					 ;execute the configuration
			
			RET
			
	CLEAR_SCREEN ENDP
	
	CONCLUDE_EXIT_GAME PROC NEAR         ;goes back to the text mode
		
		MOV AH,00h                   ;set the configuration to video mode
		MOV AL,02h                   ;choose the video mode
		INT 10h    					 ;execute the configuration 
		
		MOV AH,4Ch                   ;terminate program
		INT 21h

	CONCLUDE_EXIT_GAME ENDP

CODE ENDS
END
