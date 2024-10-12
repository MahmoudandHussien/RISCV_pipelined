module alu_p (
    input [31:0] srcA , srcB,    // operands 
    input [2:0]ALUControl,       // control signals
    output reg [31:0] Result,    // alu output result
    output   Zero, N,
    output reg C ,V             // Status Flags
);
always @(*) begin
    V = 1'b0;
    case (ALUControl)
        3'b000: begin
            {C , Result} = srcA + srcB; // addition
            if ((srcA[31] != Result[31]) && (srcA[31] == srcB[31])) begin
                V = 1'b1;
            end
        end 
        3'b001:begin
            {C , Result} = srcA - srcB; // subtraction
            if ((srcA[31] != Result[31]) && (srcA[31] != srcB[31])) begin
                V = 1'b1;
            end
        end 
        3'b010: {C , Result} = srcA & srcB; // and
        3'b011: {C , Result} = srcA | srcB; // or
        3'b101: begin  // slt
            if (srcA < srcB) 
                {C , Result} = {1'b0,32'h00000001};
            else
                {C , Result} = {1'b0,32'h00000000};
        end
        default:begin
            {C , Result} = 0;
            V = 1'b0;
        end 
    endcase
end

assign N = Result[31];
assign Zero = (Result == 32'h00000000)? 1'b1 : 1'b0;

endmodule