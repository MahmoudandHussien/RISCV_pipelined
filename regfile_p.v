module regfile_p (
    input clk ,rst_n ,WE3,
    input [4:0] A1 ,A2 ,A3, 
    input [31:0] WD3,
    output [31:0] RD1 ,RD2
);
reg [31:0] reg_file [31:0];  // memory def.
initial  begin
    reg_file[0]=0;
end
always @(negedge clk) begin // negative edge write operation
    if(WE3) begin
        // sync write port
        reg_file[A3] <= WD3; 
    end
end
// async read ports
assign RD1 = (rst_n == 1'b0)? 0 : reg_file[A1];
assign RD2 = (rst_n == 1'b0)? 0 : reg_file[A2];
    
endmodule