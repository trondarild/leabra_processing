//
// sketch test for experimental task network
// 

class TestTaskNet{
    String modelname = "Task net test";
    int inputvecsize = 24; // ctx:3 reward:1 pos:2 color:4 number:10
    int behaviours = 2; // TODO update when calc number of discrete behaviours, including gating ones
    int outputvecsize = 4;

    String[] lognames = {};
    SignalGenerator sig = new SignalGenerator(eTickSquare, 50, 40, 100);

    // unit spec
    UnitSpec excite_unit_spec = new UnitSpec();
    UnitSpec inhib_unit_spec = new UnitSpec();

    // layer
    Layer input_layer;
    
    Layer striatum_d1_layer; // go - contains input, (learned, manually set) temporal combination patterns
    Layer striatum_d2_layer; // no go
    Layer gpi_snr_layer;
    Layer stn_layer; // input from dacc
    Layer gpe_layer;
    Layer thalamus_layer; // cogn and motor

    Layer acc_layer; // will handle effort and get tired - perhaps make inherited layer?
    Layer pfc_maintenance_layer; // 
    Layer pfc_gate_layer;
    Layer m1_layer; // output

    // connections
    ConnectionSpec ffexcite_spec  = new ConnectionSpec();
    ConnectionSpec inhib_spec  = new ConnectionSpec(); 

    Connection ID1_conn; // input to striatum D1 - go
    Connection D1GPi_conn; // D1 to GPi "direct"
    Connection GPiThal_conn; // GPi to thalamus
    Connection ThalPfcGate_conn; // Thalamus to PFC gate layer 4
    Connection PfcGateMaint_conn; // PFC gate to maintenance layer 2,3/5.6
    Connection PfcMaintM1_conn; // PFC maintenance to M1 output
    Connection PfcMaintD1_conn; // temporal context to keep track of sequence

    float[][] ID1_weights = zeros(inputvecsize, behaviours); // weights to trigger a particular D1 unit based on input
    int quart_num = 10;
    NetworkSpec network_spec = new NetworkSpec(quart_num);
    Network netw; // network model to contain layers and connections

    Map<String, FloatList> inputs = new HashMap<String, FloatList>();
    boolean phase = true;
    int cyc = 0;

    TestTaskNet(){
        // unit
        excite_unit_spec.adapt_on = false;
        excite_unit_spec.noisy_act=true;
        excite_unit_spec.act_thr=0.5;
        excite_unit_spec.act_gain=100;
        excite_unit_spec.tau_net=40;
        excite_unit_spec.g_bar_e=1.0;
        excite_unit_spec.g_bar_l=0.1;
        excite_unit_spec.g_bar_i=0.40;

        inhib_unit_spec.adapt_on = false;
        inhib_unit_spec.noisy_act = true;
        inhib_unit_spec.act_thr = 0.4;
        inhib_unit_spec.act_gain = 100;
        inhib_unit_spec.tau_net = 20;
        inhib_unit_spec.g_bar_e = 1.0;
        inhib_unit_spec.g_bar_l = 0.1;
        inhib_unit_spec.g_bar_i = 0.75;

        // connection spec
        ffexcite_spec.proj="full";
        ffexcite_spec.rnd_type="uniform" ;
        ffexcite_spec.rnd_mean=0.75;
        ffexcite_spec.rnd_var=0.0;

        inhib_spec.proj="full";	
        inhib_spec.rnd_type="uniform" ;	
        inhib_spec.rnd_mean=0.5;	
        inhib_spec.rnd_var=0.f;	
        inhib_spec.inhib = true;

        
        // layers
        input_layer = new Layer(inputvecsize, new LayerSpec(false), excite_unit_spec, INPUT, "Input");
        striatum_d1_layer = new Layer(behaviours, new LayerSpec(false), excite_unit_spec, HIDDEN, "StriatumD1");

        // connections
        ID1_conn = new Connection(input_layer,  striatum_d1_layer, ffexcite_spec);

        Layer[] layers =  {input_layer, striatum_d1_layer};
	    Connection[] conns = {ID1_conn};

        netw = new Network(network_spec, layers, conns);
        netw.build();
        
    }

    void tick(){
        FloatList inpvals = new FloatList();
        inpvals.set(inputvecsize - 1, 0.0); // set dim of list
        inpvals.set((int)random(0, inputvecsize), 0.5 * sig.getOutput());
        inputs.put("Input", inpvals);

        if(cyc++ % quart_num == 0)
            netw.set_inputs(inputs);
        netw.cycle();
    
        sig.tick();
    }

    void draw(){
        pushMatrix();
        
        pushMatrix();
        translate(10,10);
        text(modelname, 0, 0);
        popMatrix();

        float[][] tmp = zeros(2,inputvecsize);
        tmp[0] = input_layer.getOutput();
        tmp[1][0] = striatum_d1_layer.getOutput()[0];
        tmp[1][1] = striatum_d1_layer.getOutput()[1];
        
        translate(10,650);
        pushMatrix();
        rotate(-HALF_PI);
        drawColGrid(0,0, 15, multiply(200, tmp));
        popMatrix();
        
        popMatrix();
    }
}

/** Notes
2021-12-10: can use tonic DA to keep thresholds sufficiently low; this should be contingent
    on perceiving progress or novelty (could be a separate input, or integration of some input, wm sequence);
    as progress, novelty slows, ACC is perhaps disinhibited and compensates by exciting nucl. accumbens 
    (ref Andre 2019) 
    
*/
