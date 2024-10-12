module control_p (
    input [6:0] op,
    input [2:0] funct3,
    input funct7_5, 
    output reg MemWrite,AluSrc,RegWrite,
    output reg [1:0]ResultSrc,
    output reg jump , Branch,
    output reg [2:0]ALUControl,
    output reg [1:0] immSrc
);
reg [1:0] ALUOp;
//main decoder
always @(*) begin
    jump = 1'b0;
    casex (op)
        3:begin //lw
            RegWrite = 1'b1;
            immSrc = 2'b00;
            AluSrc = 1'b1;
            MemWrite = 1'b0;
            ResultSrc = 2'b01;
            Branch = 1'b0;
            ALUOp = 2'b00;
        end
        35:begin //sw
            RegWrite = 1'b0;
            immSrc = 2'b01;
            AluSrc = 1'b1;
            MemWrite = 1'b1;
            ResultSrc = 2'bxx;
            Branch = 1'b0;
            ALUOp = 2'b00;
        end 
        51:begin //R-type
            RegWrite = 1'b1;
            immSrc = 2'bxx;
            AluSrc = 1'b0;
            MemWrite = 1'b0;
            ResultSrc = 2'b00;
            Branch = 1'b0;
            ALUOp = 2'b10;
        end 
        99:begin //beq
            RegWrite = 1'b0;
            immSrc = 2'b10;
            AluSrc = 1'b0;
            MemWrite = 1'b0;
            ResultSrc = 2'bxx;
            Branch = 1'b1;
            ALUOp = 2'b01;
        end
        19:begin //I-type
            RegWrite = 1'b1;
            immSrc = 2'b00;
            AluSrc = 1'b1;
            MemWrite = 1'b0;
            ResultSrc = 2'b00;
            Branch = 1'b0;
            ALUOp = 2'b10;
        end
        111:begin
            RegWrite = 1'b1;
            immSrc = 2'b11;
            AluSrc = 1'bx;
            MemWrite = 1'b0;
            ResultSrc = 2'b10;
            Branch = 1'b0;
            ALUOp = 2'bxx;
            jump = 1'b1;
        end
        default:begin
            RegWrite = 1'b0;
            immSrc = 2'b00;
            AluSrc = 1'b0;
            MemWrite = 1'b0;
            ResultSrc = 2'b00;
            Branch = 1'b0;
            ALUOp = 2'b00;
            jump = 1'b0;
        end 
    endcase
end
// ALU decoder
always @(*) begin
    casex ({ALUOp , funct3 , op[5] , funct7_5})
        7'b00xxxxx, 7'b1000000,7'b1000001,7'b1000010: ALUControl = 3'b000; //add
        7'b01xxxxx , 7'b1000011: ALUControl = 3'b001; // sub
        7'b10010xx: ALUControl = 3'b101; //slt
        7'b10110xx: ALUControl = 3'b011; //or
        7'b10111xx: ALUControl = 3'b010; //and
        default: ALUControl = 3'b000; 
    endcase
end
/*
wire PCSrc_pre;
assign PCSrc_pre = Zero & Branch;
assign PCSrc = PCSrc_pre | jump;
*/
    
endmodule