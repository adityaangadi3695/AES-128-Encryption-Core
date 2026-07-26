//======================================================================
// tb_aes_fips_trace.v
// Highly Structured FIPS-197 Appendix B Datapath Verifier
//======================================================================
`timescale 1ns/1ps

module tb_aes_fips_trace;

    localparam [2:0] S_IDLE=3'd0, S_LOAD=3'd1, S_RUN=3'd2, S_FINAL=3'd3, S_DONE=3'd4;

    //--------------------------------------------------------------
    // FIPS-197 Appendix B expected intermediate values (MSB-first)
    //--------------------------------------------------------------
    localparam [127:0] R0_START = 128'h193de3bea0f4e22b9ac68d2ae9f84808;

    localparam [127:0] SBOX_R1 =128'hd42711aee0bf98f1b8b45de51e415230;
    localparam [127:0] SROW_R1 =128'hd4bf5d30e0b452aeb84111f11e2798e5;
    localparam [127:0] MCOL_R1 =128'h046681e5e0cb199a48f8d37a2806264c;
    localparam [127:0] ARK_R1  =128'ha49c7ff2689f352b6b5bea43026a5049;

    localparam [127:0] SBOX_R2 =128'h49ded28945db96f17f39871a7702533b;
    localparam [127:0] SROW_R2 =128'h49db873b453953897f02d2f177de961a;
    localparam [127:0] MCOL_R2 =128'h584dcaf11b4b5aacdbe7caa81b6bb0e5;
    localparam [127:0] ARK_R2  =128'haa8f5f0361dde3ef82d24ad26832469a;

    localparam [127:0] SBOX_R3 =128'hac73cf7befc111df13b5d6b545235ab8;
    localparam [127:0] SROW_R3 =128'hacc1d6b8efb55a7b1323cfdf457311b5;
    localparam [127:0] MCOL_R3 =128'h75ec0993200b633353c0cf7cbb25d0dc;
    localparam [127:0] ARK_R3  =128'h486c4eee671d9d0d4de3b138d65f58e7;

    localparam [127:0] SBOX_R4 =128'h52502f2885a45ed7e311c807f6cf6a94;
    localparam [127:0] SROW_R4 =128'h52a4c89485116a28e3cf2fd7f6505e07;
    localparam [127:0] MCOL_R4 =128'h0fd6daa9603138bf6fc0106b5eb31301;
    localparam [127:0] ARK_R4  =128'he0927fe8c86363c0d9b1355085b8be01;

    localparam [127:0] SBOX_R5 =128'he14fd29be8fbfbba35c89653976cae7c;
    localparam [127:0] SROW_R5 =128'he1fb967ce8c8ae9b356cd2ba974ffb53;
    localparam [127:0] MCOL_R5 =128'h25d1a9adbd11d168b63a338e4c4cc0b0;
    localparam [127:0] ARK_R5  =128'hf1006f55c1924cef7cc88b325db5d50c;

    localparam [127:0] SBOX_R6 =128'ha163a8fc784f29df10e83d234cd503fe;
    localparam [127:0] SROW_R6 =128'ha14f3dfe78e803fc10d5a8df4c632923;
    localparam [127:0] MCOL_R6 =128'h4b868d6d2c4a8980339df4e837d218d8;
    localparam [127:0] ARK_R6  =128'h260e2e173d41b77de86472a9fdd28b25;

    localparam [127:0] SBOX_R7 =128'hf7ab31f02783a9ff9b4340d354b53d3f;
    localparam [127:0] SROW_R7 =128'hf783403f27433df09bb531ff54aba9d3;
    localparam [127:0] MCOL_R7 =128'h1415b5bf461615ec274656d7342ad843;
    localparam [127:0] ARK_R7  =128'h5a4142b11949dc1fa3e019657a8c040c;

    localparam [127:0] SBOX_R8 =128'hbe832cc8d43b86c00ae1d44dda64f2fe;
    localparam [127:0] SROW_R8 =128'hbe3bd4fed4e1f2c80a642cc0da83864d;
    localparam [127:0] MCOL_R8 =128'h00512fd1b1c889ff54766dcdfa1b99ea;
    localparam [127:0] ARK_R8  =128'hea835cf00445332d655d98ad8596b0c5;

    localparam [127:0] SBOX_R9 =128'h87ec4a8cf26ec3d84d4c46959790e7a6;
    localparam [127:0] SROW_R9 =128'h876e46a6f24ce78c4d904ad897ecc395;
    localparam [127:0] MCOL_R9 =128'h473794ed40d4e4a5a3703aa64c9f42bc;
    localparam [127:0] ARK_R9  =128'heb40f21e592e38848ba113e71bc342d2;

    localparam [127:0] SBOX_R10=128'he9098972cb31075f3d327d94af2e2cb5;
    localparam [127:0] SROW_R10=128'he9317db5cb322c723d2e895faf090794;
    localparam [127:0] ARK_R10 =128'h3925841d02dc09fbdc118597196a0b32;

    //--------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------
    reg          clk = 1'b0;
    reg          reset_n, start;
    reg  [127:0] plaintext, key;
    wire [127:0] ciphertext;
    wire         ciphertext_valid, busy;

    aes_top uut (
        .clk(clk), .reset_n(reset_n), .start(start),
        .plaintext(plaintext), .key(key),
        .ciphertext(ciphertext), .ciphertext_valid(ciphertext_valid), .busy(busy)
    );

    always #5 clk = ~clk;

    // Taps into datapath
    wire [2:0]   fsm  = uut.u_controller.current_state;
    wire [3:0]   rnum = uut.round_num;
    wire [127:0] streg= uut.state_reg_out;
    wire [127:0] sb   = uut.sb_out;
    wire [127:0] sr   = uut.sr_out;
    wire [127:0] mc   = uut.mc_out;
    wire [127:0] ark  = uut.ark_out;

    integer cyc;
    reg     stop;
    reg     r0_done;

    //--------------------------------------------------------------
    // Print Utility Tasks
    //--------------------------------------------------------------
    task print_header;
        begin
            $display("================================================================================");
            $display("|                 AES-128 FIPS-197 COMPLIANCE TESTBENCH                        |");
            $display("================================================================================");
            $display("| Plaintext        : %032h                                |", plaintext);
            $display("| Key              : %032h                                |", key);
            $display("| Exp. Ciphertext  : 3925841d02dc09fbdc118597196a0b32                                |");
            $display("================================================================================");
        end
    endtask

    task print_table_header;
        begin
            $display("+-----------------+----------------------------------+----------------------------------+--------+");
            $display("| OPERATION       | EXPECTED STATE                   | OBSERVED STATE                   | STATUS |");
            $display("+-----------------+----------------------------------+----------------------------------+--------+");
        end
    endtask

    task print_table_footer;
        begin
            $display("+-----------------+----------------------------------+----------------------------------+--------+\n");
        end
    endtask

    // The spaces in the string literal ensure perfect column alignment without %s formatting issues
    task check;
        input [119:0] stage_name; // 15 chars wide
        input [127:0] exp;
        input [127:0] obs;
        reg [47:0] status_str;
        begin
            if (exp === obs) begin
                status_str = "[PASS]";
            end else begin
                status_str = "[FAIL]";
                stop = 1'b1;
            end
            $display("| %0s | %032h | %032h | %0s |", stage_name, exp, obs, status_str);
        end
    endtask

    //--------------------------------------------------------------
    // FIPS Check & Trace (Sampled mid-cycle at negedge)
    //--------------------------------------------------------------
    always @(negedge clk) begin
        if (reset_n && fsm != S_IDLE && !stop) begin
            cyc = cyc + 1;

            if (fsm == S_RUN && rnum == 4'd1 && !r0_done) begin
                r0_done = 1'b1;
                $display("[ CYCLE %02d | STATE: S_LOAD  ] Initial AddRoundKey (Round 0)", cyc - 1);
                print_table_header();
                check("AddRoundKey    ", R0_START, streg);
                print_table_footer();
            end

            if (fsm == S_RUN && !stop) begin
                $display("[ CYCLE %02d | STATE: S_RUN   ] Round %0d", cyc, rnum);
                print_table_header();
                case (rnum)
                4'd1: begin check("SubBytes       ",SBOX_R1,sb); if(!stop) check("ShiftRows      ",SROW_R1,sr);
                            if(!stop) check("MixColumns     ",MCOL_R1,mc); if(!stop) check("AddRoundKey    ",ARK_R1,ark); end
                4'd2: begin check("SubBytes       ",SBOX_R2,sb); if(!stop) check("ShiftRows      ",SROW_R2,sr);
                            if(!stop) check("MixColumns     ",MCOL_R2,mc); if(!stop) check("AddRoundKey    ",ARK_R2,ark); end
                4'd3: begin check("SubBytes       ",SBOX_R3,sb); if(!stop) check("ShiftRows      ",SROW_R3,sr);
                            if(!stop) check("MixColumns     ",MCOL_R3,mc); if(!stop) check("AddRoundKey    ",ARK_R3,ark); end
                4'd4: begin check("SubBytes       ",SBOX_R4,sb); if(!stop) check("ShiftRows      ",SROW_R4,sr);
                            if(!stop) check("MixColumns     ",MCOL_R4,mc); if(!stop) check("AddRoundKey    ",ARK_R4,ark); end
                4'd5: begin check("SubBytes       ",SBOX_R5,sb); if(!stop) check("ShiftRows      ",SROW_R5,sr);
                            if(!stop) check("MixColumns     ",MCOL_R5,mc); if(!stop) check("AddRoundKey    ",ARK_R5,ark); end
                4'd6: begin check("SubBytes       ",SBOX_R6,sb); if(!stop) check("ShiftRows      ",SROW_R6,sr);
                            if(!stop) check("MixColumns     ",MCOL_R6,mc); if(!stop) check("AddRoundKey    ",ARK_R6,ark); end
                4'd7: begin check("SubBytes       ",SBOX_R7,sb); if(!stop) check("ShiftRows      ",SROW_R7,sr);
                            if(!stop) check("MixColumns     ",MCOL_R7,mc); if(!stop) check("AddRoundKey    ",ARK_R7,ark); end
                4'd8: begin check("SubBytes       ",SBOX_R8,sb); if(!stop) check("ShiftRows      ",SROW_R8,sr);
                            if(!stop) check("MixColumns     ",MCOL_R8,mc); if(!stop) check("AddRoundKey    ",ARK_R8,ark); end
                4'd9: begin check("SubBytes       ",SBOX_R9,sb); if(!stop) check("ShiftRows      ",SROW_R9,sr);
                            if(!stop) check("MixColumns     ",MCOL_R9,mc); if(!stop) check("AddRoundKey    ",ARK_R9,ark); end
                default: ;
                endcase
                print_table_footer();
            end

            if (fsm == S_FINAL && !stop) begin
                $display("[ CYCLE %02d | STATE: S_FINAL ] Round 10 (Final, MixColumns Skipped)", cyc);
                print_table_header();
                check("SubBytes       ",SBOX_R10,sb); 
                if(!stop) check("ShiftRows      ",SROW_R10,sr);
                if(!stop) check("AddRoundKey    ",ARK_R10,ark);
                print_table_footer();
            end

            if (stop) begin
                $display("================================================================================");
                $display("                             [!] TEST FAILED [!]                                ");
                $display("================================================================================");
                $display("-> Pipeline divergence located at CYCLE %0d, ROUND %0d", cyc, rnum);
                $display("-> Use table above to isolate failing module.");
                $display("================================================================================");
                $finish;
            end
        end
    end

    //--------------------------------------------------------------
    // Stimulus
    //--------------------------------------------------------------
    initial begin
        cyc = 0; stop = 1'b0; r0_done = 1'b0;
        reset_n = 1'b0; start = 1'b0;
        plaintext = 128'h3243f6a8885a308d313198a2e0370734;
        key       = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        
        print_header();
        
        repeat (3) @(negedge clk);
        reset_n = 1'b1;
        @(negedge clk);
        start = 1'b1; @(negedge clk); start = 1'b0; 

        repeat (40) @(negedge clk);
        if (!stop) begin
            $display("================================================================================");
            $display("|                              TEST PASSED                                     |");
            $display("================================================================================");
            $display("| Obs. Ciphertext  : %032h                                |", ciphertext);
            $display("| Total Cycles     : %0d                                                           |", cyc);
            $display("================================================================================");
        end
        $finish;
    end

endmodule