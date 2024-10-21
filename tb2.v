module tb();

reg clk;
reg req0;
reg req1;
reg rst_an;
wire grant0;
wire grant1;

integer file;  // File descriptor

// Instantiate the round_robin_arbiter module
round_robin_arbiter dut (
	.req({req1,req0}),
	.grant({grant1,grant0}),
	.clk(clk),
	.rst_an(rst_an)
);

initial begin
	clk = 0;
	req1 = 0;
	req0 = 0;
	rst_an = 1'b1;

	// Open the text file for writing output values
	file = $fopen("output.txt", "w");
	if (!file) begin
		$display("Error opening file.");
		$finish;
	end

	// Reset the system
	#10 rst_an = 0;
	#10 rst_an = 1;

	repeat (1) @ (posedge clk);
	req0 <= 1;
	req1 <= 0;
	repeat (1) @ (posedge clk);
	req0 <= 1;
	req1 <= 0;
	repeat (1) @ (posedge clk);
	req0 <= 1;
	req1 <= 1;
	repeat (1) @ (posedge clk);
	req0 <= 1;
	req1 <= 0;
	repeat (1) @ (posedge clk);
	req0 <= 1;
	req1 <= 0;
	repeat (1) @ (posedge clk);
	req0 <= 1;
	req1 <= 0;
	repeat (1) @ (posedge clk);
	req0 <= 1;
	req1 <= 0;
	repeat (1) @ (posedge clk);

	#10  $finish;
end

// Clock signal generation
always #1 clk = ~clk;

// Monitor and write output to file on every clock cycle
always @ (posedge clk) begin
	$fwrite(file, "Time: %0t, req0: %b, req1: %b, grant0: %b, grant1: %b\n", 
		$time, req0, req1, grant0, grant1);
end

// Close the file when the simulation finishes
initial begin
	#100;  // Wait for the simulation to run
	$fclose(file);  // Close the file
end

endmodule
