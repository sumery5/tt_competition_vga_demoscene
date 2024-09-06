/*
 * Copyright (c) 2024 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_sumery5_fiboscene(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

//(pix_y >= 200 
//(pix_y >= 240 
//(pix_y >= 280 
//(pix_y >= 320 
//(pix_y >= 360 

// Parametri SVGA 800x600 @60Hz
parameter H_DISPLAY = 640;
parameter H_FRONT_PORCH = 16;
parameter H_SYNC_PULSE = 96;
parameter H_BACK_PORCH = 48;
//parameter H_TOTAL = 1056;
//parameter H_TOTAL = 1056;
parameter H_TOTAL = H_DISPLAY + H_BACK_PORCH + H_FRONT_PORCH + H_SYNC_PULSE - 1;

parameter V_DISPLAY = 480;
parameter V_FRONT_PORCH = 33;
parameter V_SYNC_PULSE = 2;
parameter V_BACK_PORCH = 10;
//parameter V_TOTAL = 628;
  parameter V_TOTAL           = V_DISPLAY + V_FRONT_PORCH + V_BACK_PORCH + V_SYNC_PULSE - 1;

// Parametri per la nota
parameter NOTE_WIDTH = 20;
parameter NOTE_HEIGHT = 20;
parameter NOTE_SPACE = 11'd41;

reg [9:0] note_1x = H_DISPLAY; // Inizia fuori dallo schermo
reg [9:0] note_1y = 191; // Posizione verticale della nota (terza linea del pentagramma)

reg [9:0] note_2x = H_DISPLAY; // Inizia fuori dallo schermo
reg [9:0] note_2y = 210; // Posizione verticale della nota (terza linea del pentagramma)

reg [9:0] note_3x = H_DISPLAY; // Inizia fuori dallo schermo
reg [9:0] note_3y = 231; // Posizione verticale della nota (terza linea del pentagramma)

reg [9:0] note_4x = H_DISPLAY; // Inizia fuori dallo schermo
reg [9:0] note_4y = 251; // Posizione verticale della nota (terza linea del pentagramma)

reg [9:0] note_5x = H_DISPLAY; // Inizia fuori dallo schermo
reg [9:0] note_5y = 271; // Posizione verticale della nota (terza linea del pentagramma)

reg [9:0] note_6x = H_DISPLAY; // Inizia fuori dallo schermo
reg [9:0] note_6y = 290; // Posizione verticale della nota (terza linea del pentagramma)

reg [9:0] note_7x = H_DISPLAY; // Inizia fuori dallo schermo
reg [9:0] note_7y = 310; // Posizione verticale della nota (terza linea del pentagramma)

reg [9:0] note_8x = H_DISPLAY; // Inizia fuori dallo schermo
reg [9:0] note_8y = 330; // Posizione verticale della nota (terza linea del pentagramma)

reg [9:0] note_9x = H_DISPLAY; // Inizia fuori dallo schermo
reg [9:0] note_9y = 350; // Posizione verticale della nota (terza linea del pentagramma)

reg [10:0] frame_1counter = 0;
reg [10:0] note_1counter = 0;
reg valid_1signal;

reg [10:0] frame_2counter = 0;
reg [10:0] note_2counter = 0;
reg valid_2signal;

reg [10:0] frame_3counter = 0;
reg [10:0] note_3counter = 0;
reg valid_3signal;

reg [10:0] frame_4counter = 0;
reg [10:0] note_4counter = 0;
reg valid_4signal;

reg [10:0] frame_5counter = 0;
reg [10:0] note_5counter = 0;
reg valid_5signal;

reg [10:0] frame_6counter = 0;
reg [10:0] note_6counter = 0;
reg valid_6signal;

reg [10:0] frame_7counter = 0;
reg [10:0] note_7counter = 0;
reg valid_7signal;

reg [10:0] frame_8counter = 0;
reg [10:0] note_8counter = 0;
reg valid_8signal;

reg [10:0] frame_9counter = 0;
reg [10:0] note_9counter = 0;
reg valid_9signal;

reg starting1 = 0;
reg started1 = 0;

reg starting2 = 0;
reg started2 = 0;

reg starting3 = 0;
reg started3 = 0;

reg starting4 = 0;
reg started4 = 0;

reg starting5 = 0;
reg started5 = 0;

reg starting6 = 0;
reg started6 = 0;

reg starting7 = 0;
reg started7 = 0;

reg starting8 = 0;
reg started8 = 0;

reg starting9 = 0;
reg started9 = 0;

reg trigger1;
reg trigger2;
reg trigger3;
reg trigger4;
reg trigger5;
reg trigger6;
reg trigger7;
reg trigger8;
reg trigger9;

parameter FRAMES_PER_MOVE = 1; // Numero di frame prima di spostare la nota
parameter NOTE_MOVES = 42; // Numero di frame prima di spostare la nota
//parameter NOTE_MOVES = 640; // Numero di frame prima di spostare la nota
  
  // VGA signals
  wire hsync;
  wire vsync;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
  wire video_active;
  reg [9:0] pix_x;
  reg [9:0] pix_y;
wire display_active;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = {pwm_out,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
  assign uio_oe  = {1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  reg [3:0] counter;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );
  
  //wire [9:0] moving_x = pix_x + counter;

 // assign R = video_active ? {moving_x[5], pix_y[2]} : 2'b00;
//  assign G = video_active ? {moving_x[6], pix_y[2]} : 2'b00;
 // assign B = video_active ? {moving_x[7], pix_y[5]} : 2'b00;
  assign display_active = (pix_x < H_DISPLAY) && (pix_y < V_DISPLAY);

reg [10:0] global_frame_counter = 0;

reg [7:0] fib_reg [0:1];
reg [7:0] next_fib;
reg generating;           // Flag per indicare se la generazione è in corso
reg valid;
reg start;
// Contatori per la sincronizzazione
reg start_trigger;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        global_frame_counter <= 0;
        start <= 0;
        start_trigger <= 0;
    end else begin
      start <= start_trigger;
        if (global_frame_counter == NOTE_SPACE ) begin
            global_frame_counter <= 0;
            start_trigger <= 1;
        end else begin
            start_trigger <= 0;
            if (pix_x == H_TOTAL - 1 && pix_y == V_TOTAL - 1) begin
                global_frame_counter <= global_frame_counter + 1;
            end
        end
        
        //start <= start_trigger;
    end
end
//assign start = start_trigger;

reg [7:0] random_number;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fib_reg[0] <= 8'd1;
        fib_reg[1] <= 8'd1;
        random_number <= 8'd1;
        valid <= 1'b0;
        generating <= 1'b0;
          {trigger1, trigger2, trigger3, trigger4, trigger5, 
         trigger6, trigger7, trigger8, trigger9} <= 9'b0;
    end else begin
        if (start && !generating) begin
            generating <= 1'b1;
            valid <= 1'b0;
        end

        if (generating) begin
            next_fib <= fib_reg[0] + fib_reg[1];
            fib_reg[0] <= fib_reg[1];
            fib_reg[1] <= next_fib;
            random_number <= (next_fib % 9) + 1;
            valid <= 1'b1;
            generating <= 1'b0;

              // Generazione dei trigger basati su random_number
            case ((next_fib % 9) + 1)
                8'd1: begin
                    trigger1 <= 1'b1;
                    {trigger2, trigger3, trigger4, trigger5, trigger6, trigger7, trigger8, trigger9} <= 8'b0;
                end
                8'd2: begin
                    trigger2 <= 1'b1;
                    {trigger1, trigger3, trigger4, trigger5, trigger6, trigger7, trigger8, trigger9} <= 8'b0;
                end
                8'd3: begin
                    trigger3 <= 1'b1;
                    {trigger1, trigger2, trigger4, trigger5, trigger6, trigger7, trigger8, trigger9} <= 8'b0;
                end
                8'd4: begin
                    trigger4 <= 1'b1;
                    {trigger1, trigger2, trigger3, trigger5, trigger6, trigger7, trigger8, trigger9} <= 8'b0;
                end
                8'd5: begin
                    trigger5 <= 1'b1;
                    {trigger1, trigger2, trigger3, trigger4, trigger6, trigger7, trigger8, trigger9} <= 8'b0;
                end
                8'd6: begin
                    trigger6 <= 1'b1;
                    {trigger1, trigger2, trigger3, trigger4, trigger5, trigger7, trigger8, trigger9} <= 8'b0;
                end
                8'd7: begin
                    trigger7 <= 1'b1;
                    {trigger1, trigger2, trigger3, trigger4, trigger5, trigger6, trigger8, trigger9} <= 8'b0;
                end
                8'd8: begin
                    trigger8 <= 1'b1;
                    {trigger1, trigger2, trigger3, trigger4, trigger5, trigger6, trigger7, trigger9} <= 8'b0;
                end
                8'd9: begin
                    trigger9 <= 1'b1;
                    {trigger1, trigger2, trigger3, trigger4, trigger5, trigger6, trigger7, trigger8} <= 8'b0;
                end
                default: begin
                    {trigger1, trigger2, trigger3, trigger4, trigger5, 
                     trigger6, trigger7, trigger8, trigger9} <= 9'b0;
                end
            endcase

        end else begin
            valid <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
        starting1 <= 0;
    end else begin
        if (trigger1 == 1) begin
        starting1 <= 1;
        end else begin
        starting1 <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
        starting2 <= 0;
    end else begin
        if (trigger2 == 1) begin
        starting2 <= 1;
        end else begin
        starting2 <= 0;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
        starting3 <= 0;
    end else begin
        if (trigger3 == 1) begin
        starting3 <= 1;
        end else begin
        starting3 <= 0;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
        starting4 <= 0;
    end else begin
        if (trigger4 == 1) begin
        starting4 <= 1;
        end else begin
        starting4 <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
        starting5 <= 0;
    end else begin
        if (trigger5 == 1) begin
        starting5 <= 1;
        end else begin
        starting5 <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
        starting6 <= 0;
    end else begin
        if (trigger6 == 1) begin
        starting6 <= 1;
        end else begin
        starting6 <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
        starting7 <= 0;
    end else begin
        if (trigger7 == 1) begin
        starting7 <= 1;
        end else begin
        starting7 <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
        starting8 <= 0;
    end else begin
        if (trigger8 == 1) begin
        starting8 <= 1;
        end else begin
        starting8 <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
        starting9 <= 0;
    end else begin
        if (trigger9 == 1) begin
        starting9 <= 1;
        end else begin
        starting9 <= 0;
        end
    end
end

// Contatori per la sincronizzazione
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_1counter <= 0;
        note_1counter <= 0;
        valid_1signal <= 0;
        started1 <= 0;
        note_1y <= 0;
    end else begin
        note_1y <= note_1y;
        if (starting1 == 1 && started1 == 0 && started2 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0) begin
            started1 <= 1;
            note_1y <= 191;
        end else
        if (starting2 == 1 && started1 == 0 && started2 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0) begin
            started2 <= 1;
            note_1y <= 210;
        end else
        if (starting3 == 1 && started1 == 0 && started2 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0) begin
            started3 <= 1;
            note_1y <= 231;
        end else
        if (starting4 == 1 && started1 == 0 && started2 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0) begin
            started4 <= 1;
            note_1y <= 251;
        end else
        if (starting5 == 1 && started1 == 0 && started2 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0) begin
            started5 <= 1;
            note_1y <= 271;
        end else
        if (starting6 == 1 && started1 == 0 && started2 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0) begin
            started6 <= 1;
            note_1y <= 290;
        end else
        if (starting7 == 1 && started1 == 0 && started2 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0) begin
            started7 <= 1;
            note_1y <= 310;
        end else
        if (starting8 == 1 && started1 == 0 && started2 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0) begin
            started8 <= 1;
            note_1y <= 330;
        end else
        if (starting9 == 1 && started1 == 0 && started2 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0 && started3 == 0) begin
            started1 <= 1;
            note_1y <= 350;
        end 
        if (started1 == 1 || started2 == 1 || started3 == 1 || started4 == 1  || started5 == 1 || started6 == 1 || started7 == 1 || started8 == 1 || started9 == 1) begin
            if (note_1counter == NOTE_MOVES) begin
                note_1counter <= 0;
                frame_1counter <= 0;
                valid_1signal <= 1;
                started1 <= 0;
                started2 <= 0;
                started3 <= 0;
                started4 <= 0;
                started5 <= 0;
                started6 <= 0;
                started7 <= 0;
                started8 <= 0;
                started9 <= 0;
            end else if (frame_1counter == FRAMES_PER_MOVE) begin
                frame_1counter <= 0;
                valid_1signal <= 1;
                note_1counter <= note_1counter + 1;
            end
            
            if (pix_x == H_TOTAL - 1) begin
                if (pix_y == V_TOTAL - 1) begin
                    frame_1counter <= frame_1counter + 1;
                end
            end else begin
                valid_1signal <= 0;
            end
        end
    end
end

// Logica per inserire e muovere la nota
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        note_1x <= H_DISPLAY - NOTE_WIDTH;
    end else begin
        if (note_1counter == NOTE_MOVES) begin
            note_1x <= H_DISPLAY - NOTE_WIDTH; // Inserisci la nota a destra dello schermo
        end else if ((valid_1signal == 0) && (frame_1counter == FRAMES_PER_MOVE)) begin
            note_1x <= note_1x - 15; // Muovi la nota a sinistra
            end else begin
                note_1x <= note_1x;
                note_1y <= note_1y;
            end
    end
end
/*
// Contatori per la sincronizzazione
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_2counter <= 0;
        note_2counter <= 0;
        valid_2signal <= 0;
        started2 <= 0;
    end else begin
        if (starting2 == 1) begin
            started2 <= 1;
        end
        
        if (started2 == 1) begin
            if (note_2counter == NOTE_MOVES) begin
                note_2counter <= 0;
                frame_2counter <= 0;
                valid_2signal <= 1;
                started2 <= 0;
            end else if (frame_2counter == FRAMES_PER_MOVE) begin
                frame_2counter <= 0;
                valid_2signal <= 1;
                note_2counter <= note_2counter + 1;
            end
            
            if (pix_x == H_TOTAL - 1) begin
                if (pix_y == V_TOTAL - 1) begin
                    frame_2counter <= frame_2counter + 1;
                    note_2counter <= note_2counter;
                end
            end else begin
                valid_2signal <= 0;
            end
        end
    end
end

// Logica per inserire e muovere la nota
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        note_2x <= H_DISPLAY - NOTE_WIDTH;
    end else begin
        if (note_2counter == NOTE_MOVES) begin
            note_2x <= H_DISPLAY - NOTE_WIDTH; // Inserisci la nota a destra dello schermo
        end else if ((valid_2signal == 0) && (frame_2counter == FRAMES_PER_MOVE)) begin
            note_2x <= note_2x - 15; // Muovi la nota a sinistra
        end else begin
            note_2x <= note_2x;
        end
    end
end

// Contatori per la sincronizzazione
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_3counter <= 0;
        note_3counter <= 0;
        valid_3signal <= 0;
        started3 <= 0;
    end else begin
        if (starting3 == 1) begin
            started3 <= 1;
        end
        
        if (started3 == 1) begin
            if (note_3counter == NOTE_MOVES) begin
                note_3counter <= 0;
                frame_3counter <= 0;
                valid_3signal <= 1;
                started3 <= 0;
            end else if (frame_3counter == FRAMES_PER_MOVE) begin
                frame_3counter <= 0;
                valid_3signal <= 1;
                note_3counter <= note_3counter + 1;
            end
            
            if (pix_x == H_TOTAL - 1) begin
                if (pix_y == V_TOTAL - 1) begin
                    frame_3counter <= frame_3counter + 1;
                    note_3counter <= note_3counter;
                end
            end else begin
                valid_3signal <= 0;
            end
        end
    end
end

// Logica per inserire e muovere la nota
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        note_3x <= H_DISPLAY - NOTE_WIDTH;
    end else begin
        if (note_3counter == NOTE_MOVES) begin
            note_3x <= H_DISPLAY - NOTE_WIDTH; // Inserisci la nota a destra dello schermo
        end else if ((valid_3signal == 0) && (frame_3counter == FRAMES_PER_MOVE)) begin
            note_3x <= note_3x - 15; // Muovi la nota a sinistra
        end else begin
            note_3x <= note_3x;
        end
    end
end

// Contatori per la sincronizzazione
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_4counter <= 0;
        note_4counter <= 0;
        valid_4signal <= 0;
        started4 <= 0;
    end else begin
        if (starting4 == 1) begin
            started4 <= 1;
        end
        
        if (started4 == 1) begin
            if (note_4counter == NOTE_MOVES) begin
                note_4counter <= 0;
                frame_4counter <= 0;
                valid_4signal <= 1;
                started4 <= 0;
            end else if (frame_4counter == FRAMES_PER_MOVE) begin
                frame_4counter <= 0;
                valid_4signal <= 1;
                note_4counter <= note_4counter + 1;
            end
            
            if (pix_x == H_TOTAL - 1) begin
                if (pix_y == V_TOTAL - 1) begin
                    frame_4counter <= frame_4counter + 1;
                    note_4counter <= note_4counter;
                end
            end else begin
                valid_4signal <= 0;
            end
        end
    end
end

// Logica per inserire e muovere la nota
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        note_4x <= H_DISPLAY - NOTE_WIDTH;
    end else begin
        if (note_4counter == NOTE_MOVES) begin
            note_4x <= H_DISPLAY - NOTE_WIDTH; // Inserisci la nota a destra dello schermo
        end else if ((valid_4signal == 0) && (frame_4counter == FRAMES_PER_MOVE)) begin
            note_4x <= note_4x - 15; // Muovi la nota a sinistra
        end else begin
            note_4x <= note_4x;
        end
    end
end

// Contatori per la sincronizzazione
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_5counter <= 0;
        note_5counter <= 0;
        valid_5signal <= 0;
        started5 <= 0;
    end else begin
        if (starting5 == 1) begin
            started5 <= 1;
        end
        
        if (started5 == 1) begin
            if (note_5counter == NOTE_MOVES) begin
                note_5counter <= 0;
                frame_5counter <= 0;
                valid_5signal <= 1;
                started5 <= 0;
            end else if (frame_5counter == FRAMES_PER_MOVE) begin
                frame_5counter <= 0;
                valid_5signal <= 1;
                note_5counter <= note_5counter + 1;
            end
            
            if (pix_x == H_TOTAL - 1) begin
                if (pix_y == V_TOTAL - 1) begin
                    frame_5counter <= frame_5counter + 1;
                    note_5counter <= note_5counter;
                end
            end else begin
                valid_5signal <= 0;
            end
        end
    end
end

// Logica per inserire e muovere la nota
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        note_5x <= H_DISPLAY - NOTE_WIDTH;
    end else begin
        if (note_5counter == NOTE_MOVES) begin
            note_5x <= H_DISPLAY - NOTE_WIDTH; // Inserisci la nota a destra dello schermo
        end else if ((valid_5signal == 0) && (frame_5counter == FRAMES_PER_MOVE)) begin
            note_5x <= note_5x - 15; // Muovi la nota a sinistra
        end else begin
            note_5x <= note_5x;
        end
    end
end

// Contatori per la sincronizzazione
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_6counter <= 0;
        note_6counter <= 0;
        valid_6signal <= 0;
        started6 <= 0;
    end else begin
        if (starting6 == 1) begin
            started6 <= 1;
        end
        
        if (started6 == 1) begin
            if (note_6counter == NOTE_MOVES) begin
                note_6counter <= 0;
                frame_6counter <= 0;
                valid_6signal <= 1;
                started6 <= 0;
            end else if (frame_6counter == FRAMES_PER_MOVE) begin
                frame_6counter <= 0;
                valid_6signal <= 1;
                note_6counter <= note_6counter + 1;
            end
            
            if (pix_x == H_TOTAL - 1) begin
                if (pix_y == V_TOTAL - 1) begin
                    frame_6counter <= frame_6counter + 1;
                    note_6counter <= note_6counter;
                end
            end else begin
                valid_6signal <= 0;
            end
        end
    end
end

// Logica per inserire e muovere la nota
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        note_6x <= H_DISPLAY - NOTE_WIDTH;
    end else begin
        if (note_6counter == NOTE_MOVES) begin
            note_6x <= H_DISPLAY - NOTE_WIDTH; // Inserisci la nota a destra dello schermo
        end else if ((valid_6signal == 0) && (frame_6counter == FRAMES_PER_MOVE)) begin
            note_6x <= note_6x - 15; // Muovi la nota a sinistra
        end else begin
            note_6x <= note_6x;
        end
    end
end

// Contatori per la sincronizzazione
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_7counter <= 0;
        note_7counter <= 0;
        valid_7signal <= 0;
        started7 <= 0;
    end else begin
        if (starting7 == 1) begin
            started7 <= 1;
        end
        
        if (started7 == 1) begin
            if (note_7counter == NOTE_MOVES) begin
                note_7counter <= 0;
                frame_7counter <= 0;
                valid_7signal <= 1;
                started7 <= 0;
            end else if (frame_7counter == FRAMES_PER_MOVE) begin
                frame_7counter <= 0;
                valid_7signal <= 1;
                note_7counter <= note_7counter + 1;
            end
            
            if (pix_x == H_TOTAL - 1) begin
                if (pix_y == V_TOTAL - 1) begin
                    frame_7counter <= frame_7counter + 1;
                    note_7counter <= note_7counter;
                end
            end else begin
                valid_7signal <= 0;
            end
        end
    end
end

// Logica per inserire e muovere la nota
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        note_7x <= H_DISPLAY - NOTE_WIDTH;
    end else begin
        if (note_7counter == NOTE_MOVES) begin
            note_7x <= H_DISPLAY - NOTE_WIDTH; // Inserisci la nota a destra dello schermo
        end else if ((valid_7signal == 0) && (frame_7counter == FRAMES_PER_MOVE)) begin
            note_7x <= note_7x - 15; // Muovi la nota a sinistra
        end else begin
            note_7x <= note_7x;
        end
    end
end

// Contatori per la sincronizzazione
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_8counter <= 0;
        note_8counter <= 0;
        valid_8signal <= 0;
        started8 <= 0;
    end else begin
        if (starting8 == 1) begin
            started8 <= 1;
        end
        
        if (started8 == 1) begin
            if (note_8counter == NOTE_MOVES) begin
                note_8counter <= 0;
                frame_8counter <= 0;
                valid_8signal <= 1;
                started8 <= 0;
            end else if (frame_8counter == FRAMES_PER_MOVE) begin
                frame_8counter <= 0;
                valid_8signal <= 1;
                note_8counter <= note_8counter + 1;
            end
            
            if (pix_x == H_TOTAL - 1) begin
                if (pix_y == V_TOTAL - 1) begin
                    frame_8counter <= frame_8counter + 1;
                    note_8counter <= note_8counter;
                end
            end else begin
                valid_8signal <= 0;
            end
        end
    end
end

// Logica per inserire e muovere la nota
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        note_8x <= H_DISPLAY - NOTE_WIDTH;
    end else begin
        if (note_8counter == NOTE_MOVES) begin
            note_8x <= H_DISPLAY - NOTE_WIDTH; // Inserisci la nota a destra dello schermo
        end else if ((valid_8signal == 0) && (frame_8counter == FRAMES_PER_MOVE)) begin
            note_8x <= note_8x - 15; // Muovi la nota a sinistra
        end else begin
            note_8x <= note_8x;
        end
    end
end

// Contatori per la sincronizzazione
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_9counter <= 0;
        note_9counter <= 0;
        valid_9signal <= 0;
        started9 <= 0;
    end else begin
        if (starting9 == 1) begin
            started9 <= 1;
        end
        
        if (started9 == 1) begin
            if (note_9counter == NOTE_MOVES) begin
                note_9counter <= 0;
                frame_9counter <= 0;
                valid_9signal <= 1;
                started9 <= 0;
            end else if (frame_9counter == FRAMES_PER_MOVE) begin
                frame_9counter <= 0;
                valid_9signal <= 1;
                note_9counter <= note_9counter + 1;
            end
            
            if (pix_x == H_TOTAL - 1) begin
                if (pix_y == V_TOTAL - 1) begin
                    frame_9counter <= frame_9counter + 1;
                    note_9counter <= note_9counter;
                end
            end else begin
                valid_9signal <= 0;
            end
        end
    end
end

// Logica per inserire e muovere la nota
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        note_9x <= H_DISPLAY - NOTE_WIDTH;
    end else begin
        if (note_9counter == NOTE_MOVES) begin
            note_9x <= H_DISPLAY - NOTE_WIDTH; // Inserisci la nota a destra dello schermo
        end else if ((valid_9signal == 0) && (frame_9counter == FRAMES_PER_MOVE)) begin
            note_9x <= note_9x - 15; // Muovi la nota a sinistra
        end else begin
            note_9x <= note_9x;
        end
    end
end
*/
 // Logica per disegnare il pentagramma e la chiave di violino
always @(posedge clk) begin
    if (display_active) begin
        // Disegna le linee del pentagramma
        if ((pix_y >= 200 && pix_y <= 202) ||
            (pix_y >= 240 && pix_y <= 242) ||
            (pix_y >= 280 && pix_y <= 282) ||
            (pix_y >= 320 && pix_y <= 322) ||
            (pix_y >= 360 && pix_y <= 362)) begin
            R <= 2'b11;
            G <= 2'b11;
            B <= 2'b11;
        end
        // Disegna la terza nota
else if ((started1 == 1) && (pix_x >= note_1x && pix_x < note_1x + NOTE_WIDTH) &&
         (pix_y >= note_1y && pix_y < note_1y + NOTE_HEIGHT)) begin
    R <= 2'b10;
    G <= 2'b11;
    B <= 2'b00;
end
else if ((started2 == 1) && (pix_x >= note_1x && pix_x < note_1x + NOTE_WIDTH) &&
         (pix_y >= note_1y && pix_y < note_1y + NOTE_HEIGHT)) begin
    R <= 2'b10;
    G <= 2'b11;
    B <= 2'b00;
end
else if ((started3 == 1) && (pix_x >= note_1x && pix_x < note_1x + NOTE_WIDTH) &&
    (pix_y >= note_1y && pix_y < note_1y + NOTE_HEIGHT)) begin
    R <= 2'b00;
    G <= 2'b11;
    B <= 2'b00;
end
else if ((started4 == 1) && (pix_x >= note_1x && pix_x < note_1x + NOTE_WIDTH) &&
    (pix_y >= note_1y && pix_y < note_1y + NOTE_HEIGHT)) begin
    R <= 2'b11;
    G <= 2'b00;
    B <= 2'b11;
end
else if ((started5 == 1) && (pix_x >= note_1x && pix_x < note_1x + NOTE_WIDTH) &&
    (pix_y >= note_1y && pix_y < note_1y + NOTE_HEIGHT)) begin
    R <= 2'b11;
    G <= 2'b11;
    B <= 2'b00;
end
else if ((started6 == 1) && (pix_x >= note_1x && pix_x < note_1x + NOTE_WIDTH) &&
    (pix_y >= note_1y && pix_y < note_1y + NOTE_HEIGHT)) begin
    R <= 2'b00;
    G <= 2'b00;
    B <= 2'b11;
end
else if ((started7 == 1) && (pix_x >= note_1x && pix_x < note_1x + NOTE_WIDTH) &&
    (pix_y >= note_1y && pix_y < note_1y + NOTE_HEIGHT)) begin
    R <= 2'b11;
    G <= 2'b00;
    B <= 2'b00;
end
else if ((started8 == 1) && (pix_x >= note_1x && pix_x < note_1x + NOTE_WIDTH) &&
    (pix_y >= note_1y && pix_y < note_1y + NOTE_HEIGHT)) begin
    R <= 2'b00;
    G <= 2'b11;
    B <= 2'b11;
end
else if ((started9 == 1) && (pix_x >= note_1x && pix_x < note_1x + NOTE_WIDTH) &&
    (pix_y >= note_1y && pix_y < note_1y + NOTE_HEIGHT)) begin
    R <= 2'b11;
    G <= 2'b10;
    B <= 2'b00;
end
        // Sfondo nero
        else begin
            R <= 2'b00;
            G <= 2'b00;
            B <= 2'b00;
        end
    end else begin
        R <= 2'b00;
        G <= 2'b00;
        B <= 2'b00;
    end
end

//assign valid_3signal = &counter;

  always @(posedge vsync) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end
  
  
  wire [3:0] note_select;
  wire [8:0] started_vect;
  wire pwm_out;
  
  assign started_vect[0] = started1;
  assign started_vect[1] = started2;
  assign started_vect[2] = started3;
  assign started_vect[3] = started4;
  assign started_vect[4] = started5;
  assign started_vect[5] = started6;
  assign started_vect[6] = started7;
  assign started_vect[7] = started8;
  assign started_vect[8] = started9;
  
  
  //Instance PWM Generator
    multi_note_pwm_generator pwm_gen_instance (
      .clk(clk),               // Connect clock input
      .reset(rst_n),           // Connect reset input
      .note_select(note_select), // Connect note selection input
      .pwm_out(pwm_out)        // Connect PWM output
    );
  //Instance Edge Decoder
    edge_decoder edge_dec_instance (
      .clk(clk),                // Connect clock input
      .reset(rst_n),            // Connect reset input
      .in_signals(started_vect),  // Connect 10 input signals
      .event_num(note_select)     // Connect 4-bit output representing detected event
    );
  
endmodule


