//Rotate -> Priority -> Rotate
//author: dongjun_luo@hotmail.com
module round_robin_arbiter (
	rst_an,
	clk,
	req,
	grant
);

parameter N = 4;
	
input		rst_an;
input		clk;
	input	[N-1:0]	req;
	output	[N-1:0]	grant;

        reg		rotate_ptr;
	reg	[N-1:0]	shift_req;
	reg	[N-1:0]	shift_grant;
	reg	[N-1:0]	grant_comb;
	reg	[N-1:0]	grant;

// shift req to round robin the current priority
always @ (*)
begin
	case (rotate_ptr)
		1'b0: shift_req[N-1:0] = req[N-1:0];
		1'b1: shift_req[N-1:0] = {req[0],req[N-1:1]};
	endcase
end

// simple priority arbiter
always @ (*)
begin
	shift_grant[N-1:0] = N'b0;
	if (shift_req[0])	shift_grant[0] = 1'b1;
	else if (shift_req[1])	shift_grant[1] = 1'b1;
end

// generate grant signal
always @ (*)
begin
	case (rotate_ptr)
		1'b0: grant_comb[N-1:0] = shift_grant[N-1:0];
		1'b1: grant_comb[N-1:0] = {shift_grant[N-2:0],shift_grant[N-1]};
	endcase
end

always @ (posedge clk or negedge rst_an)
begin
	if (!rst_an)	grant[N-1:0] <= N'b0;
	else		grant[N-1:0] <= grant_comb[N-1:0] & ~grant[N-1:0];
end

// update the rotate pointer
// rotate pointer will move to the one after the current granted
always @ (posedge clk or negedge rst_an)
begin
	if (!rst_an)
		rotate_ptr[ <= 1'b0;
	else 
		case (1'b1) // synthesis parallel_case
			grant[0]: rotate_ptr <= 1'd1;
			grant[1]: rotate_ptr <= 1'd2;
		endcase
end
endmodule
