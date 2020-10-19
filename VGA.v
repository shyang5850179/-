module VGA(clk_50MHz,res_n,com_keypad,keyin,led,blank,R,G,B,sync,psave,vertical,horizontal,clk_25M,sw);
input clk_50MHz,res_n,sw;
////////////////////////////////////////////////////// keypad
input [3:0] keyin;
output reg [7:0]led;
output reg [3:0]com_keypad;	
reg clk_scan_keypad;
reg clk_1Hz;
reg [18:0]scan_cnt_keypad;
reg [3:0]keyin_reg; 
reg [2:0]state_keypad;
reg keyin_flag;
reg [4:0]com_reg;
reg[24:0]cnt;
reg [3:0]delay;
///////////////////////////////////////////////////    vga
output reg [7:0] R;
output reg [7:0] G;
output reg [7:0] B;
output reg blank;
output sync=0;
output psave=1;
output reg vertical;
output reg horizontal;
output reg clk_25M;
reg [9:0]cnt_hor;
reg [8:0]cnt_ver;
reg [7:0] OR;
reg [7:0] OG;
reg [7:0] OB;
reg [2:0]state;
reg [9:0]cnt_horizontal;
reg [8:0]cnt_vertical;
////////////////////////////////////////////////////background
reg [7:0] BR;
reg [7:0] BG;
reg [7:0] BB;
///////////////////////////////////////
reg [9:0]move_x;
reg [8:0]move_y;
reg[3:0]nx;
reg[3:0]ny;
reg[3:0]chess_x;
reg[3:0]chess_y;
reg[9:0]cnt_chess_x;
reg[8:0]cnt_chess_y;
reg flag_finx;
reg [0:14]flag_chess_W [0:14];
reg [0:14]flag_chess_B [0:14];
reg [7:0] ORN;
reg [7:0] OGN;
reg [7:0] OBN;
reg flag_BW;
reg [0:14]flag_Dis_BW[0:14];
reg state_now;
reg flag_win;
reg[3:0]Enx;
reg[3:0]Eny;
always@(posedge clk_50MHz)
begin
	clk_25M=~clk_25M;
end
always@(posedge clk_25M)
begin
	if(cnt_hor<95) begin
		cnt_hor=cnt_hor+10'd1;			
		horizontal=1'd0;	
	end	
	else if((cnt_hor>94)&&(cnt_hor<795))begin
		cnt_hor=cnt_hor+10'd1;		
		horizontal=1'd1;	
		
	end
	else begin
		cnt_hor=10'd0;		
		horizontal=1'd0;	
		if(cnt_ver<523)
			cnt_ver=cnt_ver+10'b1;
		else
			cnt_ver=10'b0;
	end
end
always@(posedge clk_25M)	
begin
	if(cnt_ver<3) begin		
		vertical=1'd0;
			
	end	
	else if((cnt_ver>2)&&(cnt_ver<523))begin
				vertical=1'd1;
		
	end
	else begin		
		vertical=1'd0;	
	end
end
always@(negedge horizontal)	
begin	
	if((cnt_ver>34)&&(cnt_ver<515))		
		cnt_vertical=cnt_vertical+9'b1;			
	else
		cnt_vertical=9'd0;	
	
end

always@(posedge clk_25M)
begin	
	if((cnt_hor>135)&&(cnt_hor<776)) begin		
		blank=1'b1;		
		cnt_horizontal=cnt_horizontal+10'b1;
		R=OR;
		G=OG;
		B=OB;				
	end
	else  begin
		blank=1'd0;	
		cnt_horizontal=10'd0;		
	end
end

///////////////////////////////////////////////////
always@(posedge clk_50MHz)
begin 
	if(scan_cnt_keypad<250000)
		scan_cnt_keypad =scan_cnt_keypad + 18'd1;
	else begin
		clk_scan_keypad = ~clk_scan_keypad; scan_cnt_keypad = 18'd0;
	end
end
always@(posedge clk_50MHz)
begin 
	if(cnt<12500000)
		cnt =cnt + 25'd1;
	else begin
		clk_1Hz = ~clk_1Hz; cnt = 25'd0;
	end
end


always@(posedge clk_scan_keypad or negedge res_n)
begin
	if(!res_n)
		begin	state_keypad=4'd0;end
	else
			case(state_keypad)			
				4'd0:begin com_keypad=4'b1110;state_keypad=4'd1;end
				4'd1:begin com_keypad=4'b1101;state_keypad=4'd2;end
				4'd2:begin com_keypad=4'b1011;state_keypad=4'd3;end
				4'd3:begin com_keypad=4'b0111;state_keypad=4'd0;end	
			endcase
end
always@(posedge clk_scan_keypad or negedge res_n)
begin
	if(!res_n) begin
		keyin_reg=4'd0;
		com_reg=4'd0;
		delay=4'd0;
		keyin_flag=1'b0;
	end	
	else if(delay<1) begin
			if(keyin<15) begin		
				keyin_reg=keyin;
				com_reg=com_keypad;	
				keyin_flag=1'b1;
				delay=4'd10;	
			end		
	end			
	else begin
		keyin_flag=1'b0;
		if(delay>0)
			delay=delay-4'd1;
		else
			delay=4'd0;
	end	
end
always@(posedge clk_scan_keypad or negedge res_n)
begin
	if(!res_n)begin	
		move_x=10'd150;
		move_y=9'd30;
		nx=4'd0;
		ny=4'd0;
		flag_chess_B[0]=15'd0;flag_chess_B[1]=15'd0;flag_chess_B[2]=15'd0;flag_chess_B[3]=15'd0;flag_chess_B[4]=15'd0;
		flag_chess_B[5]=15'd0;flag_chess_B[6]=15'd0;flag_chess_B[7]=15'd0;flag_chess_B[8]=15'd0;flag_chess_B[9]=15'd0;
		flag_chess_B[10]=15'd0;flag_chess_B[11]=15'd0;flag_chess_B[12]=15'd0;flag_chess_B[13]=15'd0;flag_chess_B[14]=15'd0;
		flag_chess_W[0]=15'd0;flag_chess_W[1]=15'd0;flag_chess_W[2]=15'd0;flag_chess_W[3]=15'd0;flag_chess_W[4]=15'd0;
		flag_chess_W[5]=15'd0;flag_chess_W[6]=15'd0;flag_chess_W[7]=15'd0;flag_chess_W[8]=15'd0;flag_chess_W[9]=15'd0;
		flag_chess_W[10]=15'd0;flag_chess_W[11]=15'd0;flag_chess_W[12]=15'd0;flag_chess_W[13]=15'd0;flag_chess_W[14]=15'd0;
		flag_BW=1'd0;
		flag_Dis_BW[0]=15'd0;flag_Dis_BW[1]=15'd0;flag_Dis_BW[2]=15'd0;flag_Dis_BW[3]=15'd0;flag_Dis_BW[4]=15'd0;
		flag_Dis_BW[5]=15'd0;flag_Dis_BW[6]=15'd0;flag_Dis_BW[7]=15'd0;flag_Dis_BW[8]=15'd0;flag_Dis_BW[9]=15'd0;
		flag_Dis_BW[10]=15'd0;flag_Dis_BW[11]=15'd0;flag_Dis_BW[12]=15'd0;flag_Dis_BW[13]=15'd0;flag_Dis_BW[14]=15'd0;
				
	end	
	else if((keyin_flag==1)&&(flag_win==0))begin		
				case({com_reg,keyin_reg})			
							8'b1110_1110:begin end
							8'b1110_1101:begin end
							8'b1110_1011:begin
													if(move_y==30) begin
														move_y=9'd450;
														ny=4'd14;
													end	
													else begin
														move_y=move_y-9'd30;
														ny=ny-4'd1;
													end	
												end
							8'b1110_0111:begin end							
					
							8'b1101_1110:begin end					
							8'b1101_1101:begin  
													if(move_x==570) begin
														move_x=10'd150;
														nx=4'd0;
													end	
													else begin
														move_x=move_x+10'd30;
														nx=nx+4'd1;		
													end
												end
							8'b1101_1011:begin
												if((flag_chess_B[ny][nx]==0)&&(flag_chess_W[ny][nx]==0))begin
													if(flag_BW==0)begin
														flag_chess_B[ny][nx]=1'b1;
														flag_BW=1'b1;
														flag_Dis_BW[ny][nx]=1'b0;
													end
													else begin
														flag_chess_W[ny][nx]=1'b1;
														flag_BW=1'b0;
														flag_Dis_BW[ny][nx]=1'b1;												
													end
												end
												else begin
														
												end
											end
							8'b1101_0111:begin 
													if(move_x==150) begin
														move_x=10'd570;
														nx=4'd14;
													end	
													else begin
														move_x=move_x-10'd30;	
														nx=nx-4'd1;
													end	
												end											
																		
							8'b1011_1110:begin end
							8'b1011_1101:begin end
							8'b1011_1011:begin
													if(move_y==450) begin
														move_y=9'd30;
														ny=4'd0;
													end	
													else begin
														move_y=move_y+9'd30;
														ny=ny+4'd1;
													end		
												end
							8'b1011_0111:begin end							
							
							8'b0111_1110:begin end
							8'b0111_1101:begin end
							8'b0111_1011:begin end
							8'b0111_0111:begin end								
							default:begin end
				endcase
	end
	else begin 	
	end		
end

////////////////////////////////////////////////// background
always@(posedge clk_25M or negedge res_n)
begin
	if(!res_n) begin			
	end
	
	else if((cnt_horizontal>149)&&(cnt_horizontal<571)&&(cnt_vertical>29)&&(cnt_vertical<451))begin		
		if((cnt_horizontal==150+30*chess_x)||(cnt_vertical==30+30*chess_y))begin
			BR=8'b00000000;
			BG=8'b00000000;
			BB=8'b00000000;
		end
		else begin
			BR=8'd155;
			BG=8'd74;
			BB=8'd18;
		end
	end
	else begin
		BR=8'd155;
		BG=8'd74;
		BB=8'd18;
	end
end
always@(posedge clk_1Hz or negedge res_n) begin
	if(!res_n)begin
		ORN=8'd0;
		OGN=8'd0;
		OBN=8'd0;
		state_now=1'b0;
	end
	else begin
		case(state_now)
			1'b0:begin
					if(flag_BW==0) begin
						ORN=8'd0;
						OGN=8'd0;
						OBN=8'd0;
						state_now=1'b1;
					end
					else begin
						ORN=8'd255;
						OGN=8'd255;
						OBN=8'd255;
						state_now=1'b1;
					end					
			end
			1'b1:begin
					ORN=BR;
					OGN=BG;
					OBN=BB;
					state_now=1'b0;
			end
			default:begin end
		endcase	
	end
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge clk_25M or negedge res_n)begin
	if(!res_n) begin
	end
	else if((((cnt_horizontal-move_x)*(cnt_horizontal-move_x)+(cnt_vertical-move_y)*(cnt_vertical-move_y))<225)&&(flag_win==0)) begin
			OR=ORN;
			OG=OGN;
			OB=OBN;		
	end
		else if((flag_chess_B[chess_y][chess_x]==1)||(flag_chess_W[chess_y][chess_x]==1))begin
		if(((cnt_horizontal-(150+30*chess_x))*(cnt_horizontal-(150+30*chess_x))+(cnt_vertical-(30+30*chess_y))*(cnt_vertical-(30+30*chess_y)))<225) begin
			if(flag_Dis_BW[chess_y][chess_x]==0) begin
				OR=8'b00000000;
				OG=8'b00000000;
				OB=8'b00000000;
			end	
			else begin
				OR=8'b11111111;
				OG=8'b11111111;
				OB=8'b11111111;
			end
			
		end
		else begin
			OR=BR;
			OG=BG;
			OB=BB;
		end
	end
	else  begin
		OR=BR;
		OG=BG;
		OB=BB;		
	end
end
always@(posedge clk_25M or negedge res_n)begin
	if(!res_n)begin
		chess_x=4'd0;
		chess_y=4'd0;
	end
	else begin
		if((cnt_horizontal==(165+(30*chess_x)))&&(cnt_horizontal>134)&&(cnt_horizontal<586))
			if(chess_x==14)
				chess_x=4'd0;
			else
				chess_x=chess_x+4'd1;
		if((cnt_vertical==(45+(30*chess_y)))&&(cnt_vertical>14)&&(cnt_vertical<466))
			if(chess_y==14)
				chess_y=4'd0;
			else
				chess_y=chess_y+4'd1;
	end
end
always@(posedge clk_25M or negedge res_n) begin
	if(!res_n) begin
		flag_win=1'b0;
		Enx=4'd0;
		Eny=4'd0;
	end
	else begin
		if(((flag_chess_B[Eny][Enx]+flag_chess_B[Eny][Enx+1]+flag_chess_B[Eny][Enx+2]+flag_chess_B[Eny][Enx+3]+flag_chess_B[Eny][Enx+4])==5)||
			((flag_chess_B[Eny][Enx]+flag_chess_B[Eny+1][Enx]+flag_chess_B[Eny+2][Enx]+flag_chess_B[Eny+3][Enx]+flag_chess_B[Eny+4][Enx])==5)||
			((flag_chess_B[Eny][Enx]+flag_chess_B[Eny+1][Enx+1]+flag_chess_B[Eny+2][Enx+2]+flag_chess_B[Eny+3][Enx+3]+flag_chess_B[Eny+4][Enx+4])==5)||
			((flag_chess_B[Eny][Enx+4]+flag_chess_B[Eny+1][Enx+3]+flag_chess_B[Eny+2][Enx+2]+flag_chess_B[Eny+3][Enx+1]+flag_chess_B[Eny+4][Enx])==5)||
			((flag_chess_B[Eny+4][Enx]+flag_chess_B[Eny+4][Enx+1]+flag_chess_B[Eny+4][Enx+2]+flag_chess_B[Eny+4][Enx+3]+flag_chess_B[Eny+4][Enx+4])==5)||
			((flag_chess_B[Eny][Enx+4]+flag_chess_B[Eny+1][Enx+4]+flag_chess_B[Eny+2][Enx+4]+flag_chess_B[Eny+3][Enx+4]+flag_chess_B[Eny+4][Enx+4])==5)||
				
			((flag_chess_W[Eny][Enx]+flag_chess_W[Eny][Enx+1]+flag_chess_W[Eny][Enx+2]+flag_chess_W[Eny][Enx+3]+flag_chess_W[Eny][Enx+4])==5)||
			((flag_chess_W[Eny][Enx]+flag_chess_W[Eny+1][Enx]+flag_chess_W[Eny+2][Enx]+flag_chess_W[Eny+3][Enx]+flag_chess_W[Eny+4][Enx])==5)||
			((flag_chess_W[Eny][Enx]+flag_chess_W[Eny+1][Enx+1]+flag_chess_W[Eny+2][Enx+2]+flag_chess_W[Eny+3][Enx+3]+flag_chess_W[Eny+4][Enx+4])==5)||
			((flag_chess_W[Eny][Enx+4]+flag_chess_W[Eny+1][Enx+3]+flag_chess_W[Eny+2][Enx+2]+flag_chess_W[Eny+3][Enx+1]+flag_chess_W[Eny+4][Enx])==5)||
			((flag_chess_W[Eny+4][Enx]+flag_chess_W[Eny+4][Enx+1]+flag_chess_W[Eny+4][Enx+2]+flag_chess_W[Eny+4][Enx+3]+flag_chess_W[Eny+4][Enx+4])==5)||
			((flag_chess_W[Eny][Enx+4]+flag_chess_W[Eny+1][Enx+4]+flag_chess_W[Eny+2][Enx+4]+flag_chess_W[Eny+3][Enx+4]+flag_chess_W[Eny+4][Enx+4])==5)
				)begin
				flag_win=1'b1;
			end
		else begin
			if(Enx==10)begin
				Enx=4'd0;
				if(Eny==10)begin
					Eny=4'd0;
				end
				else begin
					Eny=Eny+4'd1;
				end
			end
			else begin
				Enx=Enx+4'd1;
			end
		end	
	end
end

endmodule
