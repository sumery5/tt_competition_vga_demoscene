

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
  
end

// Registri
reg [11:0] timer_count;  // Contatore del timer (15 bit)
reg [5:0] lut_index;     // Indice della look-up table (6 bit per LUT_SIZE = 64)
//reg [14:0] pwm_count;    // Contatore PWM (15 bit)
reg [3:0] note_select_reg;

// Calcolo dinamico del TIMER_MAX basato sulla nota selezionata
wire [11:0] TIMER_MAX;
assign TIMER_MAX = (CLOCK_FREQ / (NOTE_FREQUENCIES[note_select_reg] * LUT_SIZE)) - 1;

// Logica del timer e PWM
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        timer_count <= 0;
        lut_index <= 0;
        //pwm_count <= 0;
        pwm_out <= 0;
        note_select_reg <= 0;
    end else begin
        // Incrementa il contatore del timer
        if (timer_count >= TIMER_MAX) begin
            timer_count <= 0;
            lut_index <= lut_index + 1;
			if (lut_index == (LUT_SIZE-1)) begin
			  lut_index <= 0;
			end
            //pwm_count <= 0;
            note_select_reg <= note_select;
        end else begin
            timer_count <= timer_count + 1;
            //pwm_count <= pwm_count + 1;
        end

        // Genera l'uscita PWM
        // Genera l'uscita PWM
        if(timer_count < ((TIMER_MAX/LUT_SIZE)*lut_index)) begin
          pwm_out <= 1;
        end else begin
          pwm_out <= 0;
        end ;
    end
end
endmodule
