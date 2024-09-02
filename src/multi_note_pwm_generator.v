

// PWM Generator

module multi_note_pwm_generator (
    input wire clk,           // Clock di ingresso a 25.175 MHz
    input wire reset,         // Reset asincrono attivo alto
    input [3:0] note_select,  // Selezione della nota
    output reg pwm_out        // Uscita PWM
);

// Parametri
parameter CLOCK_FREQ = 25_175_000;  // Frequenza del clock in Hz
parameter LUT_SIZE = 64;            // Dimensione della look-up table

// Tabella delle frequenze delle note
//localparam [11:0] NOTE_FREQUENCIES [0:11] = {
//    262, 277, 294, 311, 330, 349, 370, 392, 415, 440, 466, 494
  reg [9:0] NOTE_FREQUENCIES [0:8];
  
//localparam [9:0] NOTE_FREQUENCIES [0:8] = {
//    10'd330, 10'd349, 10'd392, 10'd440, 10'd494, 10'd523, 10'd587, 10'd659, 10'd698
//};
  
// Look-up table per la sinusoide (64 campioni, 15 bit)
reg [14:0] sine_lut [0:LUT_SIZE-1];
initial begin
  
    NOTE_FREQUENCIES[0] = 10'd330;
    NOTE_FREQUENCIES[1] = 10'd349;
    NOTE_FREQUENCIES[2] = 10'd392;
    NOTE_FREQUENCIES[3] = 10'd440;
    NOTE_FREQUENCIES[4] = 10'd494;
    NOTE_FREQUENCIES[5] = 10'd523;
    NOTE_FREQUENCIES[6] = 10'd587;
    NOTE_FREQUENCIES[7] = 10'd659;
    NOTE_FREQUENCIES[8] = 10'd698;
  
    sine_lut[0]  = 15'd16384; sine_lut[1]  = 15'd18063; sine_lut[2]  = 15'd19709; sine_lut[3]  = 15'd21306;
    sine_lut[4]  = 15'd22841; sine_lut[5]  = 15'd24300; sine_lut[6]  = 15'd25671; sine_lut[7]  = 15'd26943;
    sine_lut[8]  = 15'd28105; sine_lut[9]  = 15'd29149; sine_lut[10] = 15'd30067; sine_lut[11] = 15'd30853;
    sine_lut[12] = 15'd31503; sine_lut[13] = 15'd32012; sine_lut[14] = 15'd32378; sine_lut[15] = 15'd32596;
    sine_lut[16] = 15'd32665; sine_lut[17] = 15'd32586; sine_lut[18] = 15'd32359; sine_lut[19] = 15'd31984;
    sine_lut[20] = 15'd31466; sine_lut[21] = 15'd30808; sine_lut[22] = 15'd30013; sine_lut[23] = 15'd29087;
    sine_lut[24] = 15'd28036; sine_lut[25] = 15'd26867; sine_lut[26] = 15'd25588; sine_lut[27] = 15'd24210;
    sine_lut[28] = 15'd22745; sine_lut[29] = 15'd21204; sine_lut[30] = 15'd19602; sine_lut[31] = 15'd17951;
    sine_lut[32] = 15'd16268; sine_lut[33] = 15'd14568; sine_lut[34] = 15'd12865; sine_lut[35] = 15'd11174;
    sine_lut[36] = 15'd9510;  sine_lut[37] = 15'd7887;  sine_lut[38] = 15'd6320;  sine_lut[39] = 15'd4823;
    sine_lut[40] = 15'd3409;  sine_lut[41] = 15'd2091;  sine_lut[42] = 15'd881;   sine_lut[43] = 15'd0;
    sine_lut[44] = 15'd0;     sine_lut[45] = 15'd0;     sine_lut[46] = 15'd387;   sine_lut[47] = 15'd1589;
    sine_lut[48] = 15'd2900;  sine_lut[49] = 15'd4307;  sine_lut[50] = 15'd5798;  sine_lut[51] = 15'd7359;
    sine_lut[52] = 15'd8976;  sine_lut[53] = 15'd10636; sine_lut[54] = 15'd12324; sine_lut[55] = 15'd14025;
    sine_lut[56] = 15'd15725; sine_lut[57] = 15'd17409; sine_lut[58] = 15'd19063; sine_lut[59] = 15'd20673;
    sine_lut[60] = 15'd22225; sine_lut[61] = 15'd23706; sine_lut[62] = 15'd25103; sine_lut[63] = 15'd26404;
end

// Registri
reg [14:0] timer_count;  // Contatore del timer (15 bit)
reg [5:0] lut_index;     // Indice della look-up table (6 bit per LUT_SIZE = 64)
reg [14:0] pwm_count;    // Contatore PWM (15 bit)

// Calcolo dinamico del TIMER_MAX basato sulla nota selezionata
wire [14:0] TIMER_MAX;
assign TIMER_MAX = (CLOCK_FREQ / (NOTE_FREQUENCIES[note_select] * LUT_SIZE)) - 1;

// Logica del timer e PWM
always @(posedge clk or posedge reset) begin
    if (reset) begin
        timer_count <= 0;
        lut_index <= 0;
        pwm_count <= 0;
        pwm_out <= 0;
    end else begin
        // Incrementa il contatore del timer
        if (timer_count >= TIMER_MAX) begin
            timer_count <= 0;
            lut_index <= lut_index + 1;
			if (lut_index == 56) begin
			  lut_index <= 0; 
			end
            pwm_count <= 0;
        end else begin
            timer_count <= timer_count + 1;
            pwm_count <= pwm_count + 1;
        end

        // Genera l'uscita PWM
        pwm_out <= (pwm_count < sine_lut[lut_index]);
    end
end

endmodule
