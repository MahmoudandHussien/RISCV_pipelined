module sim();
reg clk,reset;
wire N,C,V;
//wire writeen;
//wire[31:0]addr,readdata;
RISC_32i dut(clk,reset,N,C,V);
initial begin
    reset=0;
    @(negedge clk);
    reset=1;
end
initial begin
    clk=0;
    forever begin
        #10;
        clk=~clk;
    end
end
initial begin
    repeat(100)
    begin
        @(negedge clk);
    end
    $stop;
end
endmodule