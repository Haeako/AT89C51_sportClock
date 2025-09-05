ORG 0000h         
    LJMP SETUP            ; Nhảy tới hàm khởi tạo

ORG 0003h
    AJMP EXT0_ISR         ; Ngắt ngoài INT0 – Tăng số hoặc dừng

ORG 0013h
    AJMP EXT1_ISR         ; Ngắt ngoài INT1 – Giảm hoặc reset

ORG 001Bh         
    AJMP TIMER1_ISR       ; Ngắt Timer1 – Cộng thời gian

SETUP:
    SETB IT0              ; INT0 kích sườn xuống
    SETB IT1              ; INT1 kích sườn xuống
    CLR P3.0              ; Có thể dùng cho mục đích phụ

    SETB EX0              ; Cho phép ngắt ngoài 0
    SETB EX1              ; Cho phép ngắt ngoài 1
    SETB EA               ; Cho phép ngắt toàn cục

    MOV DPTR, #MASK       ; Bảng mã 7 đoạn hiển thị số
    MOV R7, #00           ; R7 = phần nguyên (giây)
    MOV R6, #01           ; R6 = phần thập phân (0.01s) ; khởi tạo trước giá trị 1 

    MOV TMOD, #10h        ; Timer1: Mode 1, Timer0: Mode 0

 ; Cài đặt Timer1 để tạo ngắt mỗi 10ms (tần số 12MHz)
    MOV TH1, #0D8h
    MOV TL1, #0F0h
    SETB ET1              ; Cho phép ngắt Timer1
    SETB TR1              ; Bắt đầu Timer1


MAIN:
    ; Hiển thị số thập phân hàng chục (R6 / 10)
    MOV P2, #00h  ; clear bus
    MOV A , R6
    MOV B, #10
    DIV AB                ; A = hàng chục, B = hàng đơn vị
    MOVC A , @A+DPTR
    MOV P2 , A
    MOV P1 , #11111011b   ; Chọn LED số thứ 1 (phải ngoài cùng)
    CALL DELAY_SCAN

    ; Hiển thị số thập phân hàng đơn vị (R6 % 10)
    MOV P2, #00h  ; clear bus
    MOV A, B
    MOVC A , @A+DPTR 
    MOV P2, A
    MOV P1 , #11110111b   ; Chọn LED số thứ 2

    CALL DELAY_SCAN

    ; Hiển thị phần nguyên hàng chục (R7 / 10)
    MOV P2, #00h  ; clear bus
    MOV A, R7
    MOV B, #10
    DIV AB                ; A = hàng chục, B = hàng đơn vị
    MOVC A, @A+DPTR
    MOV P2 , A
    MOV P1 , #11111110b   ; Chọn LED số thứ 3

    CALL DELAY_SCAN

    ; Hiển thị phần nguyên hàng đơn vị (R7 % 10)
    MOV P2, #00h ; clear bus
    MOV A, B
    MOVC A, @A+DPTR
    MOV P2 ,  A
    SETB P2.7             ; Bật dấu chấm thập phân (giữa giây và phần trăm giây)
    MOV P1 , #11111101b   ; Chọn LED số thứ 4

    CALL DELAY_SCAN

    SJMP MAIN             ; Lặp lại liên tục

TIMER1_ISR:
    CLR TF1               ; Xóa cờ tràn
    MOV TH1, #0D8h        ; Tải lại giá trị timer cho 10ms
    MOV TL1, #0F0h

    INC R6                ; Tăng phần thập phân (mỗi 10ms)
    CJNE R6, #100, DONE   ; Đủ 1 giây 
    MOV R6, #0
    INC R7                ; Tăng phần nguyên
    CJNE R7, #100, DONE   ; Giới hạn đến 99.99s
    MOV R7, #0
DONE:
    RETI

DELAY_SCAN:
    MOV TH0, #0FEh; Delay 5ms 
    MOV TL0, #00Ch
    SETB TR0
WAIT_FLAG:
    JNB TF0, WAIT_FLAG
    CLR TF0
    CLR TR0
    RET

EXT0_ISR:
    JNB P1.4, STOP_TIMER  ; Nếu nút ở P1.4 = 0 dừng/Chạy timer
    INC R7               ; tăng phần thập phân
    CJNE R7,  #100 , DONE
   MOV R7 , #00 ; R7 Vượt quá 99 , Reset về 0
   RETI
    
STOP_TIMER:
    CPL TR1               ; Đảo trạng thái Timer1 
    RETI
EXT1_ISR:
    JB P1.5, DEC_TIMER    ; Nếu nút P1.5 = 1 ,  giảm thời gian
    MOV R6, #00
    MOV R7, #00           ; Nếu không, reset về 00.00
    RETI

DEC_TIMER:
    ; Nếu  R7 != 0   -> giảm R7
    CJNE R7, #00, DEC_SEC
    ; Nếu R7 == 0 ; Trở về chương trình cũ
    RETI
DEC_SEC:
    DEC R7
    RETI

; ===== Bảng mã LED 7 đoạn từ 0-9 =====
MASK: DB 03Fh, 006h, 05Bh, 04Fh, 066h, 06Dh, 07Dh, 007h, 07Fh, 06Fh
END
