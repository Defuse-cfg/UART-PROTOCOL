
// Functional Coverage Class
class uart_coverage;
    virtual uart_if vif;

    covergroup burst_id_cg @(posedge vif.clk);
        coverpoint vif.burst_id;
    endgroup

    covergroup data_in_cg @(posedge vif.clk);
        coverpoint vif.data_in;
    endgroup

    covergroup data_out_cg @(posedge vif.clk);
        coverpoint vif.data_out;
    endgroup

    covergroup functional_cg @(posedge vif.clk);
        coverpoint vif.burst_id;
        coverpoint vif.data_in;
        coverpoint vif.valid;
        cross vif.burst_id, vif.data_in, vif.valid;
    endgroup

    function new(virtual uart_if vif_input);
        vif = vif_input;
        burst_id_cg = new();
        data_in_cg = new();
        data_out_cg = new();
        functional_cg = new();
    endfunction

    function void report_coverage();
        $display("--------------------------------------------------");
        $display("[COVERAGE] - Burst ID Coverage: %0.2f%%", burst_id_cg.get_coverage());
        $display("[COVERAGE] - Data In Coverage: %0.2f%%", data_in_cg.get_coverage());
        $display("[COVERAGE] - Data Out Coverage: %0.2f%%", data_out_cg.get_coverage());
        $display("[COVERAGE] - Functional Coverage: %0.2f%%", functional_cg.get_coverage());
        $display("--------------------------------------------------");
    endfunction
endclass
