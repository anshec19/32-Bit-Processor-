module test_32bit;
    reg clk1, clk2;
    integer k;

    // Declare wires to observe pipeline registers
    wire [31:0] PC, IF_ID_IR, IF_ID_NPC;
    wire [31:0] ID_EX_A, ID_EX_B,ID_EX_IR, ID_EX_Imm;
    wire [2:0] ID_EX_type;
    wire [31:0] EX_MEM_ALUOut;
    wire [31:0] EX_MEM_IR;
    wire [2:0] EX_MEM_type;
    wire [31:0] MEM_WB_ALUOut,MEM_WB_IR;
    wire [2:0] MEM_WB_type;

    // Instantiate the Unit Under Test (UUT)
    processor_32bit uut (
        .clk1(clk1),
        .clk2(clk2)
    );

    // Connect the pipeline register signals
    assign PC = uut.PC;
    assign IF_ID_IR = uut.IF_ID_IR;
    assign IF_ID_NPC = uut.IF_ID_NPC;
    assign ID_EX_IR = uut.ID_EX_IR;
    assign ID_EX_A = uut.ID_EX_A;
    assign ID_EX_B = uut.ID_EX_B;
    assign ID_EX_Imm = uut.ID_EX_Imm;
    assign ID_EX_type = uut.ID_EX_type;
    assign EX_MEM_IR = uut.EX_MEM_IR;
    assign EX_MEM_ALUOut = uut.EX_MEM_ALUOut;
    assign EX_MEM_type = uut.EX_MEM_type;
    assign MEM_WB_IR = uut.MEM_WB_IR;
    assign MEM_WB_ALUOut = uut.MEM_WB_ALUOut;
    assign MEM_WB_type = uut.MEM_WB_type;

    // Clock generation
    initial begin
        clk1 = 0;
        clk2 = 0;
        repeat (50) begin // Generate two-phase clock
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end

    // Test scenario
   initial begin
        // Initialize memory with a test program
        uut.Mem[0] = 32'h2801000a; // ADDI R1, R0, 10
        uut.Mem[1] = 32'h28020014; // ADDI R2, R0, 20
        uut.Mem[2] = 32'h28030019; // ADDI R3, R0, 25
        uut.Mem[3] = 32'h0ce77800; // OR R7, R7, R7 -- dummy instruction
        uut.Mem[4] = 32'h0ce77800; // OR R7, R7, R7 -- dummy instruction
        uut.Mem[5] = 32'h00222000; // ADD R4, R1, R2
        uut.Mem[6] = 32'h0ce77800; // OR R7, R7, R7 -- dummy instruction
        uut.Mem[7] = 32'h00832800; // ADD R5, R4, R3
        uut.Mem[8] = 32'hfc000000; // HLT

        // Initialize control signals
        uut.HALTED = 0;
        uut.PC = 0;
        uut.TAKEN_BRANCH = 0;

        // Initialize registers with known values for testing
        uut.Reg[0] = 0;
        uut.Reg[1] = 0;
        uut.Reg[2] = 0;
        uut.Reg[3] = 0;
        uut.Reg[4] = 0;
        uut.Reg[5] = 0;

        // Run simulation for 300 ns
        #300;

        // Display final register values
        for (k = 0; k < 6; k = k + 1) begin
            $display("R%1d - %2d", k, uut.Reg[k]);
        end

        // Finish the simulation
        $finish;
    end

    // Monitor important signals
    initial begin
        $monitor("Time=%0t, PC=%0d, IF_ID_IR=%h, ID_EX_IR=%h, ID_EX_A=%d, ID_EX_B=%d, EX_MEM_IR=%h, MEM_WB_IR=%h",
                 $time, PC, IF_ID_IR, ID_EX_IR, ID_EX_A, ID_EX_B, EX_MEM_IR, MEM_WB_IR);
    end

    // Dump waveforms
    initial begin
        $dumpfile("processor32bits.vcd");
        $dumpvars(0, test_32bit);
    end
endmodule
