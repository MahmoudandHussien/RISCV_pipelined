module RISC_32i (
    input clk,rst_n,output N,C,V,output[31:0]addr,data,output we
);
    //wire declaration
    // D stands for decode stage , E for excute , W for write back , F for fetch , M for memory
    wire[31:0] InstrD,InstrF,RD1D,RD2D,RD1E,RD2E,SrcAE,SrcBE,ALUResultE,ALUResultM,WriteDataE,WriteDataM,ReadDataM,ReadDataW,PcF,PcFF,PcD,PcE,ALUResultW;//ff for input flipflop
    wire[31:0] PCPlus4F,PCPlus4D,PCPlus4E,PCPlus4M,PCPlus4W,ImmExtD,ImmExtE,PCtargetE,ResultW;
    wire [4:0] RS1E,RS2E,RDE,RDM,RDW;
    wire RegwriteD,MemwriteD,JumpD,BranchD,ALUSrcD,RegwriteE,MemwriteE,JumpE,BranchE,ALUSrcE,RegwriteM,MemwriteM,RegwriteW;
    wire[2:0]ALUControlD,ALUControlE;
    wire[1:0]ResultsrcD,ImmsrcD,ResultsrcE,ResultsrcM,ResultsrcW,ForwarAE,ForwarBE;
    wire StallF,StallD,FlushD,FlushE,PcsrcE,ZeroE; 
    //pcsrc logic
    assign PcsrcE=JumpE|(BranchE&ZeroE);
    //instatiations 
    //fetch stage
    mux_2_1 mux_pc(.in0(PCPlus4F),.in1(PCtargetE),.s(PcsrcE),.out(PcFF)); //mux 2-1 for pc selector
    pc_p PCFF(.clk(clk),.rst_n(rst_n),.en_n(StallF),.pc_next(PcFF),.pc(PcF)); // pc flipflop
    i_memory_p instruction_memory(.A(PcF),.data(0),.we(0),.clk(0),.RD(InstrF));//instruction memory
    pcPlus4_adder_p PCPLUS4(.pc(PcF),.pcPlus4(PCPlus4F));//PC PLUS4
    //decode stage
    decode_register DPIPE(.clk(clk),.rst_n(rst_n),.en_n(StallD),.CLR(FlushD),.instrF(InstrF),.PCF(PcF),.PCPulse4F(PCPlus4F),.instrD(InstrD),.PCD(PcD),.PCPulse4D(PCPlus4D));//Decode Pipeline
    regfile_p Regfile(.clk(clk),.rst_n(rst_n),.WE3(RegwriteW),.A1(InstrD[19:15]),.A2(InstrD[24:20]),.A3(RDW),.WD3(ResultW),.RD1(RD1D),.RD2(RD2D));//refister file
    control_p control_unit(.op(InstrD[6:0]),.funct3(InstrD[14:12]),.funct7_5(InstrD[30]),.MemWrite(MemwriteD),.AluSrc(ALUSrcD),.RegWrite(RegwriteD),.ResultSrc(ResultsrcD),.jump(JumpD),.Branch(BranchD),.ALUControl(ALUControlD),.immSrc(ImmsrcD));//control unit
    immExt_p Extend(.instr(InstrD[31:7]),.immSrc(ImmsrcD),.immExt(ImmExtD));//Immediate Extend
    //excute stage   
    excute_register EPIPE(.clk(clk),.rst_n(rst_n),.CLR(FlushE),.RegWriteD(RegwriteD),.ResultSrcD(ResultsrcD),.MemWriteD(MemwriteD),.JumpD(JumpD),.BranchD(BranchD),.ALUControlD(ALUControlD),.ALUSrcD(ALUSrcD),.RD1D(RD1D),.RD2D(RD2D),.PCD(PcD),.Rs1D(InstrD[19:15]),.Rs2D(InstrD[24:20]),.RdD(InstrD[11:7]),.ExtImmD(ImmExtD),.PCPulse4D(PCPlus4D),.RegWriteE(RegwriteE),.ResultSrcE(ResultsrcE),.MemWriteE(MemwriteE),.JumpE(JumpE),.BranchE(BranchE),.ALUControlE(ALUControlE),.ALUSrcE(ALUSrcE),.RD1E(RD1E),.RD2E(RD2E),.PCE(PcE),.Rs1E(RS1E),.Rs2E(RS2E),.RdE(RDE),.ExtImmE(ImmExtE),.PCPulse4E(PCPlus4E));// excute register
    mux3_1 mux_srca(.in0(RD1E),.in1(ResultW),.in2(ALUResultM),.s(ForwarAE),.out(SrcAE));// mux 3-1 srca
    mux3_1 mux_writedata(.in0(RD2E),.in1(ResultW),.in2(ALUResultM),.s(ForwarBE),.out(WriteDataE));// mux 3-1 write data
    mux_2_1 mux_srcb(.in0(WriteDataE),.in1(ImmExtE),.s(ALUSrcE),.out(SrcBE));// mux 2-1 for srcb
    pcTarget_adder_p pctarget(.pc(PcE),.immExt(ImmExtE),.pcTarget(PCtargetE));//pc target
    alu_p alu(.srcA(SrcAE),.srcB(SrcBE),.ALUControl(ALUControlE),.Result(ALUResultE),.Zero(ZeroE),.N(N),.C(C),.V(V));//alu
    //memory stage
    memory_register Mpipe(.clk(clk),.rst_n(rst_n),.RegWriteE(RegwriteE),.ResultSrcE(ResultsrcE),.MemWriteE(MemwriteE),.ALUResultE(ALUResultE),.WriteDataE(WriteDataE),.RdE(RDE),.PCPlus4E(PCPlus4E),.RegWriteM(RegwriteM),.ResultSrcM(ResultsrcM),.MemWriteM(MemwriteM),.ALUResultM(ALUResultM),.WriteDataM(WriteDataM),.RdM(RDM),.PCPlus4M(PCPlus4M));// decode register
    data_memory_p Datamemory(.clk(clk),.WE(MemwriteM),.A(ALUResultM),.WD(WriteDataM),.RD(ReadDataM));//datamemory

    // write back stage
    WriteBack_register Wpipe(.clk(clk),.rst_n(rst_n),.RegWriteM(RegwriteM),.ResultSrcM(ResultsrcM),.ALUResultM(ALUResultM),.ReadDataM(ReadDataM),.RdM(RDM),.PCPlus4M(PCPlus4M),.RegWriteW(RegwriteW),.ResultSrcW(ResultsrcW),.ALUResultW(ALUResultW),.ReadDataW(ReadDataW),.RdW(RDW),.PCPlus4W(PCPlus4W));
    mux3_1 mux_result(.in0(ALUResultW),.in1(ReadDataW),.in2(PCPlus4W),.s(ResultsrcW),.out(ResultW));
    //hazard unit 
    hazardUint hazard(.Rs1E(RS1E),.Rs2E(RS2E),.Rs1D(InstrD[19:15]),.Rs2D(InstrD[24:20]),.RdM(RDM),.RdW(RDW),.RdE(RDE),.RegWriteM(RegwriteM),.RegWriteW(RegwriteW),.ResultSrcE0(ResultsrcE),.PcSrcE(PcsrcE),.forwardAE(ForwarAE),.forwardBE(ForwarBE),.StallF(StallF),.StallD(StallD),.FlushE(FlushE),.FlushD(FlushD));
    // output logic 
    assign addr=ALUResultM;
    assign we=MemwriteM;
    assign data = WriteDataM ;
endmodule