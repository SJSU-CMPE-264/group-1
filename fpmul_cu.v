module fpmul_cu (
    input wire clk,
    input wire rst,
    
    input wire Start,
    
    //output ctrl signals to dp
    output reg SA_LD,
    output reg EA_LD,
    output reg MA_LD,
    output reg SB_LD,
    output reg EB_LD,
    output reg MB_LD,
    output reg SP_LD,
    output reg EP_SET, //set to FF, necessary for exit conditions such as if abnormal
    output reg EP_RST, //set to 00
    output reg [1:0] EP_SEL, //at certain points, need to select either ep - 127, ep + 1, or ea + eb inputs
    output reg EP_LD,
    output reg MPH_SET,
    output reg MPH_RST,
    output reg [2:0] MPH_SEL, //sel between MP[47:24], {MPH[22:0], MPL[23]}, MPH + 1, and 0x800000
    output reg MPH_LD,
    output reg MPL_SEL, //sel between MP[23:0] or MPL << 1 for state 5
    output reg MPL_LD,
    output reg UF_RST,
    output reg UF_LD, 
    output reg OF_RST,
    output reg OF_LD,
    output reg P_RST,
    output reg P_LD,
    
    //status signals
    input wire NaN,
    input wire Inf,
    input wire Zero, 
    input wire MPH23,
    input wire Round,
    input wire Carry,
    input wire UFlow,
    input wire OFlow,
    input wire Dnf,
    
    //top-level outputs
    output reg Done
);

//states
localparam [3:0]
    S0 = 4'b0000,
    S1 = 4'b0001,
    S2 = 4'b0010,
    S3 = 4'b0011,
    S4 = 4'b0100,
    S5 = 4'b0101,
    S6 = 4'b0110,
    S7 = 4'b0111,
    S8 = 4'b1000,
    S9 = 4'b1001;
    
reg [3:0] CS, NS;
reg EP_RST_NEXT;

wire Normal;

assign Normal = ~(NaN | Inf | Zero); //1 if all operand flags are zero

//update CS
always @ (posedge clk)
begin
    if(rst) CS <= S0;
    else    CS <= NS;
end

//NS logic
always @ (*)
begin
    case(CS)
        S0: begin
            NS = S1;
        end
        S1: begin
            if(Start) NS = S2;
            else      NS = S1;
        end
        S2: begin
            NS = S3;
        end
        S3: begin
            NS = S4;
        end
        S4: begin
        	if (Normal&(~Dnf)) NS = S5;
            else        NS = S8;
        end
        S5: begin
            NS = S6;
        end
        S6: begin
            NS = S7;
        end
        S7: begin NS = S8;
        end
        S8: begin NS = S9;
        end
        S9: begin NS = S0;
        end
    endcase
end

//state machine logic
always @ (*)
begin
    //reset all ctrl signals
    SA_LD = 1'b0;
    EA_LD = 1'b0;
    MA_LD = 1'b0;
    SB_LD = 1'b0;
    EB_LD = 1'b0;
    MB_LD = 1'b0;
    SP_LD = 1'b0;
    EP_RST = 1'b0;
    EP_SET = 1'b0;
    EP_SEL = 2'b00;
    EP_LD = 1'b0;
    MPH_SET = 1'b0; // ds change
    MPH_SEL = 3'b000;
    MPH_RST = 1'b0;
    MPH_LD = 1'b0;
    MPL_SEL = 1'b0;
    MPL_LD = 1'b0;
    UF_RST = 1'b0;
    UF_LD = 1'b0;
    OF_RST = 1'b0;
    OF_LD = 1'b0;
    P_RST = 1'b0;
    P_LD = 1'b0;
    Done = 1'b0;
    
    case (CS)
        S0: begin
        //reset product, underflow/overflow, NaN, Inf and ZF
            OF_RST = 1'b1;
            UF_RST = 1'b1;
            P_RST = 1'b1;
            EP_RST_NEXT = 1'b0;
        end
        S1: begin //load in all operand registers
            SA_LD = 1'b1;
            EA_LD = 1'b1;
            MA_LD = 1'b1;
            SB_LD = 1'b1;
            EB_LD = 1'b1;
            MB_LD = 1'b1;
        end
        S2: begin
            SP_LD = 1'b1;
            EP_SEL = 2'b00; //select ep - 127 to load into ep reg
            EP_LD = 1'b1; 
        end
        S3: begin
            EP_SEL = 2'b10; //select ep - 127 to load into ep reg
            EP_LD = 1'b1; 
        end
        S4: begin
            if(NaN) begin
                EP_SET = 1'b1;
                MPH_SET = 1'b1;
            end
            else if (Inf) begin
                EP_SET = 1'b1;
                MPH_RST = 1'b1;
            end
            else if (Zero) begin
                EP_RST = 1'b1;
                MPH_RST = 1'b1;
            end
            else if (Dnf) begin
            	EP_RST = 1'b1;
            	MPH_RST = 1'b1;
            end
            else begin //end of 3-cycle multiplication cycle
                MPH_LD = 1'b1;
                MPL_LD = 1'b1;
            end
            
        end
        S5: begin
            if(MPH23) begin
                EP_SEL = 2'b01; //select ep + 1 to load into ep reg
                EP_LD = 1'b1;
            end
            else begin
                MPH_SEL = 3'b001; //select {MPH[22:0], MPL[23]} to load into mph reg
                MPH_LD = 1'b1;
                MPL_SEL = 1'b1; //select MPL << 1 to load into mpl reg
                MPL_LD = 1'b1;
            end
        end
        S6: begin
            if(Round && ~Carry) begin
                MPH_SEL = 3'b010; //select mph + 1 to load into mph reg
                MPH_LD = 1'b1;
                $display("carry = 0");
            end
            else if (Round && Carry) begin
                MPH_SEL = 3'b100; //select 0x800000 to load into mph reg
                EP_SEL = 2'b01; //select ep + 1 to load into ep reg
                MPH_LD = 1'b1;
                MPH_LD = 1'b1;
                $display("carry = 1");
            end
        end
        S7: begin
        if (~UFlow && ~OFlow) begin
            UF_RST = 1'b1;
            OF_RST = 1'b1;
        end
        else if (~UFlow && OFlow) begin
            UF_RST = 1'b1;
            OF_LD = 1'b1;
            EP_SET = 1'b1; //set ep[7:0] to 0xff
            MPH_RST = 1'b1;
            $display("overflow");
        end
        else if (UFlow & ~OFlow) begin
            UF_LD = 1'b1;
            OF_RST = 1'b1;
//            EP_RST = 1'b1; // ds change
            EP_RST_NEXT = 1'b1;
            MPH_RST = 1'b1;
            $display("underflow");
        end
        end
        S8: begin //package the product and load product abnormal flags
            P_LD = 1'b1;
            if (EP_RST_NEXT) begin
            EP_RST = 1'b1; // ds change
            $display("underflow or accidental");
            end
        end
        S9: begin //signal completion of the computation
            Done = 1'b1;
        end
        
        default: begin
        end
    endcase
end

endmodule