class TestRandomAssociator {
    String modelname = "Random associator";
    
    int numpatterns = 24;
    int patternsize = 10;
    int hots = 4;
    int ctr = 0;
    float[][] sourcepatterns;
    float[][] targetpatterns;
    int inputvecsize = patternsize;
    int hiddensize = 20;

    // units
    UnitSpec excite_unit_spec = new UnitSpec();

    // layers
    Layer input_layer;
    Layer hidden_layer;
    Layer output_layer;

    // connections
    ConnectionSpec ffexcite_spec  = new ConnectionSpec();
    Connection input_hidden_conn;
    Connection hidden_output_conn;
    Connection output_hidden_conn;

    // network
    int quart_num = 25;
    NetworkSpec network_spec = new NetworkSpec(quart_num);
    Network netw; // network model to contain layers and connections

    Map <String, FloatList> inputs = new HashMap<String, FloatList>();
    Map <String, FloatList> targets = new HashMap<String, FloatList>();
    int inp_ix = 0;

    float[] inputval = zeros(inputvecsize);
    Buffer sse = new Buffer(100);
    float current_sse = 0;
    
    TestRandomAssociator() {
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
        ffexcite_spec.rnd_mean=0.5;
        ffexcite_spec.rnd_var=0.20;
        ffexcite_spec.lrate = 0.04;

        // layers
        input_layer = new Layer(inputvecsize, new LayerSpec(false), excite_unit_spec, INPUT, "Input");
        hidden_layer = new Layer(hiddensize, new LayerSpec(false), excite_unit_spec, HIDDEN, "Hidden");
        output_layer = new Layer(inputvecsize, new LayerSpec(false), excite_unit_spec, OUTPUT, "Output");

        // connections
        input_hidden_conn = new Connection(input_layer, hidden_layer, ffexcite_spec);
        hidden_output_conn = new Connection(hidden_layer, output_layer, ffexcite_spec);
        output_hidden_conn = new Connection(output_layer, hidden_layer, ffexcite_spec);

        // network
        
        Layer[] layers = {input_layer, hidden_layer, output_layer};
        Connection[] conns = {input_hidden_conn, hidden_output_conn, output_hidden_conn};


        netw = new Network(network_spec, layers, conns);
        netw.build();

        // create input outputs
        sourcepatterns = generateUniquePatterns(numpatterns, patternsize, hots);
        targetpatterns = generateUniquePatterns(numpatterns, patternsize, hots);
        
    }

    void tick() {
        
        if(true){ // netw.accept_input()){
            int ptrn_ix = ctr++ % numpatterns ;
            FloatList inpvals = arrayToList(sourcepatterns[ptrn_ix]);
            inputs.put("Input", inpvals);
            netw.set_inputs(inputs);

            FloatList targetvals = arrayToList(targetpatterns[ptrn_ix]);
            targets.put("Output", targetvals);
            netw.set_targets(targets);
            current_sse = netw.compute_sse();
            sse.append(current_sse);
        }
        current_sse = netw.trial();
        sse.append(current_sse);
        //netw.cycle();
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
        
        float[][] h_viz = zeros(1, hiddensize);
        h_viz[0] = hidden_layer.getOutput();

        float[][] out_viz = zeros(1,inputvecsize);
        out_viz[0] = output_layer.getOutput();

        float[][] w_viz = hidden_output_conn.weights();
        // w_viz[0] = hidden_layer.weights();

        
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

            translate(0, 20);
            pushMatrix();
            text(output_layer.name, 0,0);
            pushMatrix();
            translate(100, -10);
            drawColGrid(0,0, 10, multiply(200, out_viz));
            popMatrix();
            popMatrix();

            translate(0, 20);
            pushMatrix();
            text("Weights", 0,0);
            pushMatrix();
            translate(100, -10);
            drawColGrid(0,0, 10, multiply(200, w_viz));
            popMatrix();
            popMatrix();

            translate(0, 20);
            pushMatrix();
            text("SSE: " + current_sse, 0,0);
            pushMatrix();
            translate(100, -10);
            //drawColGrid(0,0, 10, multiply(200, dacc_viz));
            drawTimeSeries(sse.array(), 6.0, 1, 0);
            popMatrix();
            popMatrix();
        popMatrix();

        popMatrix();
    }

    void handleKeyDown(char k){}
    void handleKeyUp(char k){}

   
}
