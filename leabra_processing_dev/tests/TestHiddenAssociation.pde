class TestHiddenAssociation {
    String modelname = "Hidden layer associator, ";
    
    int numpatterns = 5;
    int patternsize = 10;
    int hots = 3;
    int ctr = 0;
    float[][] sourcepatterns;
    float[][] targetpatterns;
    int inputvecsize = patternsize;
    int outputvecsize = patternsize;
    int hiddensize = hots * patternsize; //patternsize*patternsize;
    int decim = 15;
    int iters = decim*100;
    // units
    UnitSpec excite_unit_spec = new UnitSpec();

    // layers
    LayerSpec output_spec = new LayerSpec();
    Layer input_layer;
    Layer hidden_layer;
    Layer output_layer;

    // connections
    ConnectionSpec ffexcite_spec  = new ConnectionSpec();
    ConnectionSpec ffexcite_spec_learn  = new ConnectionSpec();
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
    Buffer sse = new Buffer(iters);
    Buffer hd = new Buffer(iters); // hamming distance
    Buffer trial_sse = new Buffer(numpatterns);
    
    float current_sse = 0;
    
    TestHiddenAssociation() {
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
        ffexcite_spec.rnd_var=0.0;
        

        ffexcite_spec_learn.proj="full";
        ffexcite_spec_learn.rnd_type="uniform" ;
        ffexcite_spec_learn.rnd_mean=0.075;
        ffexcite_spec_learn.rnd_var=0.2;
        ffexcite_spec_learn.lrate = 0.055;
        ffexcite_spec_learn.lrule = "leabra";




        // layers
        output_spec.g_i=1.5;
        output_spec.ff=1.0;
        output_spec.fb=0.5;
        output_spec.fb_dt=1/1.4;
        output_spec.ff0=0.1;
        

        input_layer = new Layer(inputvecsize, new LayerSpec(false), excite_unit_spec, INPUT, "Input");
        hidden_layer = new Layer(hiddensize, new LayerSpec(false), excite_unit_spec, OUTPUT, "Hidden");
        output_layer = new Layer(outputvecsize, output_spec, excite_unit_spec, OUTPUT, "Output");

        // connections
        input_hidden_conn = new Connection(input_layer, hidden_layer, ffexcite_spec);
        hidden_output_conn = new Connection(hidden_layer, output_layer, ffexcite_spec_learn);
        output_hidden_conn = new Connection(output_layer, hidden_layer, ffexcite_spec_learn);
        //input_output_conn = new Connection(input_layer, output_layer, ffexcite_spec_learn);
        
        // network
        
        Layer[] layers = {input_layer, hidden_layer, /* inh_hidden_layer, */ 
            output_layer};
        Connection[] conns = { input_hidden_conn, hidden_output_conn, 
             output_hidden_conn};


        netw = new Network(network_spec, layers, conns);
        netw.build();

        // create input outputs
        sourcepatterns = generateUniquePatterns(numpatterns, inputvecsize, hots);
        targetpatterns = generateUniquePatterns(numpatterns, outputvecsize, hots);
        
        for (int i = 0; i < iters; ++i) {
            float[] vals = runSim();
            sse.append(vals[0]);
            hd.append(vals[1]);
        }

        for (Map.Entry<String, FloatList> entry : netw.outputs.entrySet()) {
            String name = entry.getKey();
            FloatList act = entry.getValue();
            Layer layer = netw.get_layer(name);
            //for act, unit in zip(activities, this._get_layer(name).units):
            float[] pred = new float[act.size()]; 
            for (int i = 0; i < layer.units.length; ++i) 
                pred[i] = layer.units[i].act_m  ;  
            //hd += hammingDistanceThr(act.array(), pred, 0.2);
            printArray("act", act.array());
            printArray("pred", pred);
        }
    }

    float[] runSim() {
        float[] retval = zeros(2);
        if(netw.accept_input()){
            int ptrn_ix = ctr++ % numpatterns ;
            FloatList inpvals = arrayToList(sourcepatterns[ptrn_ix]);
            inputs.put("Input", inpvals);
            netw.set_inputs(inputs);

            FloatList targetvals = arrayToList(targetpatterns[ptrn_ix]);
            targets.put("Output", targetvals);
            netw.set_targets(targets);
            current_sse = netw.compute_sse();
            trial_sse.append(current_sse);
            //if (ptrn_ix==0){
            //    sse.append(mean(trial_sse.array()));
                // printMatrix("hidden weights", hidden_output_conn.weights());
            //}
        }
        current_sse = netw.trial();
        float current_hd = netw.compute_hamming();
        // sse.append(current_sse / sourcepatterns.length);
        // netw.cycle();
        retval[0] = current_sse/numpatterns;
        retval[1] = current_hd/numpatterns;
        return retval;
    }

    void tick() {

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
        
        //float[][] h_viz = zeros(1, hiddensize);
        //h_viz[0] = hidden_layer.getOutput();

        
        float[][] out_viz = zeros(1,inputvecsize);
        out_viz[0] = output_layer.getOutput();

        float[][] w_viz = hidden_output_conn.weights();
        //float[][] w_viz = hidden_output_conn.weights();
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

            // translate(0, 20);
            // pushMatrix();
            // text(hidden_layer.name, 0,0);
            // pushMatrix();
            // translate(100, -10);
            // drawColGrid(0,0, 10, multiply(200, h_viz));
            // popMatrix();
            // popMatrix();

            
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
            drawColGrid(0,0, 10, multiply(200, hidden_output_conn.weights()));
            popMatrix();
            popMatrix();

            int col_dist = 200;
            translate(col_dist, 0);
            pushMatrix();
            text("Weights", 0,0);
            pushMatrix();
            translate(100, -10);
            drawColGrid(0,0, 10, multiply(200, output_hidden_conn.weights()));
            popMatrix();
            popMatrix();

            translate(-col_dist, 20);
            pushMatrix();
            text("SSE: " + current_sse, 0,0);
            pushMatrix();
            translate(100, -10);
            //drawColGrid(0,0, 10, multiply(200, dacc_viz));
            drawTimeSeries(decimate(sse.array(), decim), 2.0, 1, 0);
            popMatrix();
            popMatrix();

            translate(0, 250);
            pushMatrix();
            text("HD: " , 0,0);
            pushMatrix();
            translate(100, -10);
            //drawColGrid(0,0, 10, multiply(200, dacc_viz));
            drawTimeSeries(decimate(hd.array(), decim), 2.0, 1, 0);
            popMatrix();
            popMatrix();
        popMatrix();

        popMatrix();
    }

    void handleKeyDown(char k){}
    void handleKeyUp(char k){}
    void handleMidi(float a, float b ){}

   
}
