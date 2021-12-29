class TestAutoActivity {
    String modelname = "Test auto activity";
    int inputvecsize = 1; // ctx:3 reward:1 pos:2 color:4 number:10
    int behaviours = 2; // TODO update when calc number of discrete behaviours, including gating ones
    
    // unit spec
    UnitSpec excite_unit_spec = new UnitSpec();
    

    // layer
    Layer input_layer; 
    Layer hidden_layer; // go - contains input, (learned, manually set) temporal combination patterns
    
    // connections
    ConnectionSpec ffexcite_spec  = new ConnectionSpec();

    Connection IH_conn; // input to hidden
    Connection HH_conn; // hidden to hidden, autoactivity
    
    float[][] ID1_weights = zeros(inputvecsize, behaviours); // weights to trigger a particular D1 unit based on input
    int quart_num = 25;
    NetworkSpec network_spec = new NetworkSpec(quart_num);
    Network netw; // network model to contain layers and connections

    Map<String, FloatList> inputs = new HashMap<String, FloatList>();
    int inp_ix = 0;

    float inputval;

    TestAutoActivity() {
        // unit
        excite_unit_spec.adapt_on = false;
        excite_unit_spec.noisy_act=true;
        excite_unit_spec.act_thr=0.5;
        excite_unit_spec.act_gain=100;
        excite_unit_spec.tau_net=40;
        excite_unit_spec.g_bar_e=1.0;
        excite_unit_spec.g_bar_l=0.1;
        excite_unit_spec.g_bar_i=0.40;

        // connection spec
        ffexcite_spec.proj="full";
        ffexcite_spec.rnd_type="uniform" ;
        ffexcite_spec.rnd_mean=0.75;
        ffexcite_spec.rnd_var=0.0;

        // layers
        input_layer = new Layer(inputvecsize, new LayerSpec(false), excite_unit_spec, INPUT, "Input");
        hidden_layer = new Layer(2, new LayerSpec(false), excite_unit_spec, HIDDEN, "Hidden");

        // connections
        IH_conn = new Connection(input_layer, hidden_layer, ffexcite_spec);
        HH_conn = new Connection(hidden_layer, hidden_layer, ffexcite_spec);

        Layer[] layers = {input_layer, hidden_layer};
        Connection[] conns = {IH_conn, HH_conn};

        netw = new Network(network_spec, layers, conns);
        netw.build();
    }

    void setInput(float inp) { inputval = inp;}

    void tick() {
      if(netw.accept_input()) {
            float[] inp = {inputval};
            FloatList inpvals = arrayToList(inp);
            inputs.put("Input", inpvals);
            netw.set_inputs(inputs);
        }
        netw.cycle();

    }

    void draw() {
        pushMatrix();
        
        pushMatrix();
        translate(10,20);
        text(modelname, 0, 0);
        popMatrix();

        float[][] inp_viz = zeros(1,inputvecsize);
        inp_viz[0] = input_layer.getOutput();
        //printArray("input layer output", inp_viz[0]);
        
        float[][] h_viz = zeros(1, 2);
        h_viz[0] = hidden_layer.getOutput();
        translate(10,50);
        pushMatrix();
            //rotate(-HALF_PI);
            pushMatrix();
            text(input_layer.name, 0, 0);
            pushMatrix();
            translate(100, -10);
            drawColGrid(0,0, 10, multiply(200, inp_viz));
            popMatrix();
            popMatrix();

            translate(0, 20);
            pushMatrix();
            text(hidden_layer.name, 0,0);
            pushMatrix();
            translate(100, -10);
            drawColGrid(0,0, 10, multiply(200, h_viz));
            popMatrix();
            popMatrix();
        popMatrix();

        popMatrix();
    }

}
