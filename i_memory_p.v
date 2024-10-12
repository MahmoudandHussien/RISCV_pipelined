module i_memory_p (
    input [31:0] A,data,input we,clk,
    output [31:0]RD
);

reg [7:0]i_mem[1023:0]; // up to 1024 inst per program
initial
	begin
    $readmemh("program.txt",i_mem);
    end
    always @ (posedge clk)
	begin
		// Write
		if (we)
			i_mem[A] <= data;
	end
assign RD =  {i_mem[A] , i_mem[A+1] , i_mem[A+2], i_mem[A+3]};
endmodule