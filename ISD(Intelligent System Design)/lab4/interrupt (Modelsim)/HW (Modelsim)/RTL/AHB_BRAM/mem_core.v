module MEM_CORE // cpu명령어 저장+ram 역할(데이터 저장도 가능)
#(parameter MEMWIDTH = 9,
  parameter filename = "code.hex")	
(
  input wire HCLK,
  input wire APhase_HSEL,
  input wire APhase_HWRITE,
  input wire [1:0] APhase_HTRANS,
  input wire [2:0] APhase_HSIZE, //몇 바이트로 쓸지 core에서 받아옴
  input wire [31:0] APhase_HWADDR,
  input wire [31:0] HWDATA,
  input wire [31:0] HADDR,
  
  output reg [31:0] HRDATA,
  output wire HREADY_MEM
);

  integer i;
  assign HREADY_MEM = 1'b1; // Always ready
	
// Memory Array
  reg [7:0] memory[0:((1<<MEMWIDTH)-1)]; //2^9=512 -> 1byte(8bit) x 512 = 512바이트트

// Load program data from file
  initial
    begin
    for (i=0;i<(1<<MEMWIDTH);i=i+1)
     begin
      memory[i] = 8'h00; //Initialize all data to 0
     end
     if (filename != "")
       begin //code. hex 를 읽어와서 512개의 메모리 주소에 한개씩  채워짐, 첫줄에 00 , 두번째 다음 줄의 data write
        $readmemh(filename, memory); // Then read in program code
       end //있는줄만 채워넣고, 없으면 00임 why? 위에서 00으로 선언했기때문,
    end //cpu가  부팅 후 fetch할 코드가 위치한 곳
 

// Decode the bytes lanes depending on HSIZE & HADDR[1:0]
// hsize 가 000 1byte, 001 2(half), 010 4byte(word)
  wire tx_byte = ~APhase_HSIZE[1] & ~APhase_HSIZE[0];
  wire tx_half = ~APhase_HSIZE[1] &  APhase_HSIZE[0];
  wire tx_word =  APhase_HSIZE[1];
  
  wire byte_at_00 = tx_byte & ~APhase_HWADDR[1] & ~APhase_HWADDR[0];
  wire byte_at_01 = tx_byte & ~APhase_HWADDR[1] &  APhase_HWADDR[0];
  wire byte_at_10 = tx_byte &  APhase_HWADDR[1] & ~APhase_HWADDR[0];
  wire byte_at_11 = tx_byte &  APhase_HWADDR[1] &  APhase_HWADDR[0];
  
  wire half_at_00 = tx_half & ~APhase_HWADDR[1];
  wire half_at_10 = tx_half &  APhase_HWADDR[1];
  
  wire word_at_00 = tx_word;
  
  wire byte0 = word_at_00 | half_at_00 | byte_at_00;
  wire byte1 = word_at_00 | half_at_00 | byte_at_01;
  wire byte2 = word_at_00 | half_at_10 | byte_at_10;
  wire byte3 = word_at_00 | half_at_10 | byte_at_11;
// cpu가 write 트랜잭션을 하면, 바이트 단위로 해당 주소에 저장
  // hsize와 haddr[1:0] 조합으로 어떤 바이트를 쓸지 결정
  /*
  예1. HSIZE = 3'b000 (byte), ADDR = 0x00000001
  tx_byte = 1
  byte_at_01 = 1
  → byte0~3 = 0100
  → memory[addr+1] = HWDATA[15:8]

  예2. HSIZE = 3'b010 (word), ADDR = 0x00000000
  tx_word = 1
  word_at_00 = 1
  → byte0~3 = 1111
  → 4바이트 전체 write됨
  */
  always @ (posedge HCLK)
  begin 
    if(APhase_HSEL & APhase_HWRITE & APhase_HTRANS[1])
	 begin
      if(byte0)
        memory[APhase_HWADDR + 0] <= HWDATA[ 7: 0];
      if(byte1)
        memory[APhase_HWADDR + 1] <= HWDATA[15: 8];
      if(byte2)
        memory[APhase_HWADDR + 2] <= HWDATA[23:16];
      if(byte3)
        memory[APhase_HWADDR + 3] <= HWDATA[31:24];
    end

    HRDATA <= {memory[HADDR+3], memory[HADDR+2], memory[HADDR+1], memory[HADDR+0]};
  end // memcore에서 hex file에서 hrdata를 가져옴 0x50000000을 읽어오고 이걸 core.v로 전달 이후
      // core에서 haddr로 변환하여 하위 모듈에 전송하여 이후 전송되는 hrdata를 저장함 4바이트 단위로 묶어서 hrdata로 전달
endmodule 
// BRAM 주소이고 HADDR은 0x00000000, 0x00000004, 0x00000008 식으로 증가하면서 명령어 읽어옴
// 즉 RAM주소로, LED에 write할때만 사용하는 led slave 주소인 0x50000000은 아님
// 메모리 주소가 0x00에 code.hex의 00 02 00 20을 읽어오고 이를 역순으로 정렬함(리틀엔디안)
// 0x00주소에 0x20000200 여기가 초기 sp값(stack pointer)
// 0x04주소에 0x00000081 
// 그리고 code.hex의 129번째부터는 명령어임 리틀엔디안이라서 0x4906 (16비트,2바이트단위)-> LDR R1, 0x5000000
// cortex-M은 부팅하면 SP= memory[0x00], PC=memory[0x04]부터 실행
// 아니 주소가 왜 특별한가?
// 0x0000	부팅 시 SP로 로딩됨 (Stack Pointer)
// 0x0004	부팅 시 PC로 로딩됨 (Reset Handler)

/* test_SoC.v → clk 주면
 → AHBLITE_SYS.v 내부 코어가 실행
   → code.hex = 이 어셈블리 파일의 바이너리
     → 메모리에서 fetch
       → 0x50000000 주소로 HWDATA=0x55 전송
       → LED 켜짐
       → 반복
*/