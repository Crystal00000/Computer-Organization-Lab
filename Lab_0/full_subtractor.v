`timescale 1ns / 1ps


module Full_Subtractor(
    In_A, In_B, Borrow_in, Difference, Borrow_out
    );
    input In_A, In_B, Borrow_in;
    output Difference, Borrow_out;
    wire p, q, r;
    // implement full subtractor circuit, your code starts from here.
    // use half subtractor in this module, fulfill I/O ports connection.
    Half_Subtractor HSUB1 (
        .In_A(In_A), 
        .In_B(In_B), 
        .Difference(p), 
        .Borrow_out(q)
    );
    Half_Subtractor HSUB2 (
        .In_A(p), 
        .In_B(Borrow_in), 
        .Difference(Difference), 
        .Borrow_out(r)
    );

    or(Borrow_out, q, r);
    
endmodule
