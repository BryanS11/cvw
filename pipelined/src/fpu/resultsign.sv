`include "wally-config.vh"

module resultsign(
    input logic [2:0]   FrmM,
    input logic         PSgnM, ZSgnEffM,
    input logic         InvZM,
    input logic         ZInfM,
    input logic         InfIn,
    input logic         NegSumM,
    input logic [1:0] PostProcSelM,
    input logic [`NE+1:0] SumExp,
    input logic         SumZero,
    input logic         Mult,
    input logic         Round,
    input logic         Sticky,
    input logic         CvtResSgnM,
    output logic        ResSgn
);

    logic ZeroSgn;
    logic InfSgn;
    logic FmaResSgn;
    logic FmaResSgnTmp;
    logic Underflow;
    // logic ResultSgnTmp;

    // Determine the sign if the sum is zero
    //      if cancelation then 0 unless round to -infinity
    //      if multiply then Psgn
    //      otherwise psign
    assign Underflow = SumExp[`NE+1] | ((SumExp == 0) & (Round|Sticky));
    assign ZeroSgn = (PSgnM^ZSgnEffM)&~Underflow&~Mult ? FrmM[1:0] == 2'b10 : PSgnM;


    // is the result negitive
    //  if p - z is the Sum negitive
    //  if -p + z is the Sum positive
    //  if -p - z then the Sum is negitive
    assign FmaResSgnTmp = InvZM&(ZSgnEffM)&NegSumM | InvZM&PSgnM&~NegSumM | (ZSgnEffM&PSgnM);
    assign InfSgn = ZInfM ? ZSgnEffM : PSgnM;
    assign FmaResSgn = InfIn ? InfSgn : SumZero ? ZeroSgn : FmaResSgnTmp;

    always_comb
        case(PostProcSelM)
            2'b10: ResSgn = FmaResSgn; // fma
            2'b00: ResSgn = CvtResSgnM; // cvt
            2'b01: ResSgn = 0; // divide
            default: ResSgn = 1'bx; 
        endcase
endmodule