`timescale 1ns / 1ps

module hann_window_to_axism(
    input wire AXIS_ACLK,
    input wire AXIS_ARESETN,
    output wire M_AXIS_TVALID,
    output wire [31:0] M_AXIS_TDATA,
    output wire [1:0] M_AXIS_TSTRB,
    output wire M_AXIS_TLAST,
    input wire M_AXIS_TREADY
);
    reg m_axis_tvalid;
    reg m_axis_tlast;

    (* rom_style="block" *)
    reg [31:0] hann_window [255:0];
    reg [31:0] m_axis_tdata;

    initial
        $readmemb("hann_window.mem", hann_window, 0, 255);

    reg [7:0] packet_counter;

    always@(posedge AXIS_ACLK) begin
        if(!AXIS_ARESETN) begin
            m_axis_tvalid <= 1'b0;
            m_axis_tlast <= 1'b0;
            m_axis_tdata <= 32'b0;

            packet_counter <= 0;
        end else begin
            m_axis_tvalid <= 1'b1;
            m_axis_tlast <= 1'b0;

            if (M_AXIS_TREADY) begin
                if (packet_counter == 255) begin
                    m_axis_tlast <= 1'b1;
                    packet_counter <= 0;
                end else begin
                    packet_counter <= packet_counter + 1;
                end
            end

            m_axis_tdata <= hann_window[packet_counter];
        end
    end

    assign M_AXIS_TSTRB = 2'b1;
    assign M_AXIS_TVALID = m_axis_tvalid;
    assign M_AXIS_TLAST = m_axis_tlast;
    assign M_AXIS_TDATA = m_axis_tdata;
endmodule
