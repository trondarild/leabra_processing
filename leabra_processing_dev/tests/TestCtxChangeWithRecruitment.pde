/**
    2022-01-13: using dACC populations for each context appears both
                inelegant, and not plausible -> requires always increasing
                amount of units; have to use dendrite-connections instead, so 
                can control flow of effort from single population to req. target 
*/
class TestCtxChangeWithRecruitment {
    String modelname = "Test context prediction error with recruitment";
    int inputvecsize = 3; // ctx:3 reward:1 pos:2 color:4 number:10
    int hiddensize = 3; // TODO update when calc number of discrete behaviours, including gating ones
    int populationsize = 5; // number of effort-units in dACC

    // unit spec
    UnitSpec excite_unit_spec = new UnitSpec();
    UnitSpec excite_auto_unit_spec = new UnitSpec();
    

    // layer
    Layer input_layer; 
    Layer context_layer; // go - contains input, learned, /manually set/ temporal combination patterns
    Layer predictionerror_layer; //
    Layer population_layer;
    Layer dACC_layer; // effort layer
    
    // connections
    ConnectionSpec ffexcite_spec  = new ConnectionSpec();
    ConnectionSpec full_weak_spec = new ConnectionSpec();
    ConnectionSpec onetoone_excite_spec = new ConnectionSpec();
    ConnectionSpec onetoone_excite_weak_spec = new ConnectionSpec();
    ConnectionSpec onetoone_inh_spec = new ConnectionSpec();
    ConnectionSpec[] pop_dacc_spec = new ConnectionSpec[hiddensize];

    Connection IC_conn; // input to context
    Connection IPE_conn; // input to CtxPredError
    Connection PePop_conn; // prediction error to population
    Connection[] PopACC_conn = new Connection[hiddensize]; // population to dACC 
    Connection dAccC_conn; // dACC to context effort
    Connection CPE_conn; // context to prediction error
    Connection CC_conn; // context self-sustaining

    int quart_num = 25;
    NetworkSpec network_spec = new NetworkSpec(quart_num);
    Network netw; // network model to contain layers and connections

    Map <String, FloatList> inputs = new HashMap<String, FloatList>();
    int inp_ix = 0;

    float[] inputval = zeros(inputvecsize);


    float[][] w_effort = {  {1,0,0,0,0},
                            {1,1,0,0,0},
                            {1,1,1,0,0},
                            {1,1,1,1,0},
                            {1,1,1,1,1},
                            };
    //float[][] w_effort = tileRows(hiddensize, w_effort_ptrn);

    TestCtxChangeWithRecruitment() {
        // unit
        excite_unit_spec.adapt_on = false;
        excite_unit_spec.noisy_act=true;
        excite_unit_spec.act_thr=0.5;
        excite_unit_spec.act_gain=100;
        excite_unit_spec.tau_net=40;
        excite_unit_spec.g_bar_e=1.0;
        excite_unit_spec.g_bar_l=0.1;
        excite_unit_spec.g_bar_i=0.40;

        excite_auto_unit_spec.adapt_on = false;
        excite_auto_unit_spec.noisy_act=true;
        excite_auto_unit_spec.act_thr=0.5;
        excite_auto_unit_spec.act_gain=100;
        excite_auto_unit_spec.tau_net=40;
        excite_auto_unit_spec.g_bar_e=1.0;
        excite_auto_unit_spec.g_bar_l=0.1;
        excite_auto_unit_spec.g_bar_i=0.40;
        excite_auto_unit_spec.bias = 0.05; // 0.0075; // bias incr from 0
        excite_auto_unit_spec.g_l = 0.9; // leak reduced from 1.0
        excite_auto_unit_spec.e_rev_l = 0.3;

        // layers
        input_layer = new Layer(inputvecsize, new LayerSpec(false), excite_unit_spec, INPUT, "Input");
        predictionerror_layer = new Layer(hiddensize, new LayerSpec(false), excite_unit_spec, HIDDEN, "Pred error");
        context_layer = new Layer(hiddensize, new LayerSpec(true), excite_auto_unit_spec, HIDDEN, "Context");
        population_layer = new Layer(hiddensize*populationsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "Population");
        dACC_layer = new Layer(hiddensize*populationsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "dACC");
       
        // connection spec
        ffexcite_spec.proj="full";
        ffexcite_spec.rnd_type="uniform" ;
        ffexcite_spec.rnd_mean=0.5;
        ffexcite_spec.rnd_var=0.0;

        full_weak_spec.proj="full";
        full_weak_spec.rnd_type="uniform" ;
        full_weak_spec.rnd_mean=0.1;
        full_weak_spec.rnd_var=0.0;

        onetoone_excite_spec.proj = "1to1";
        onetoone_excite_spec.rnd_type = "uniform";
        onetoone_excite_spec.rnd_mean = 0.5;
        onetoone_excite_spec.rnd_var = 0.0;

        onetoone_excite_weak_spec.proj = "1to1";
        onetoone_excite_weak_spec.rnd_type = "uniform";
        onetoone_excite_weak_spec.rnd_mean = 0.1;
        onetoone_excite_weak_spec.rnd_var = 0.0;

        onetoone_inh_spec.proj = "1to1";
        onetoone_inh_spec.inhibit = true;
        onetoone_inh_spec.rnd_type = "uniform";
        onetoone_inh_spec.rnd_mean = 0.5;
        onetoone_inh_spec.rnd_var = 0.0;

        for (int i = 0; i < hiddensize; ++i) {
            pop_dacc_spec[i] = new ConnectionSpec(full_weak_spec);
            pop_dacc_spec[i].pre_startix = i*populationsize;
            pop_dacc_spec[i].pre_endix = i*populationsize + populationsize-1;
            pop_dacc_spec[i].post_startix = i*populationsize;
            pop_dacc_spec[i].post_endix = i*populationsize + populationsize-1;
            println("start= " + (i*populationsize) + "; end: " + (i*populationsize + populationsize-1));

            PopACC_conn[i] = new Connection(population_layer, dACC_layer, pop_dacc_spec[i]);
            PopACC_conn[i].weights(w_effort);
        }
        
        
        // connections
        //IC_conn = new Connection(input_layer, context_layer, onetoone_excite_weak_spec);
        IPE_conn = new Connection(input_layer, predictionerror_layer, onetoone_excite_spec);
        //PePop_conn = new Connection(predictionerror_layer, popu); // prediction error to population - handle separately for now
        //PopACC_conn = new Connection(population_layer, dACC_layer, ffexcite_spec);
        //PopACC_conn.weights(w_effort);
        dAccC_conn = new Connection(dACC_layer, context_layer, full_weak_spec); // - effort
        CPE_conn = new Connection(context_layer, predictionerror_layer, onetoone_inh_spec);
        CC_conn = new Connection(context_layer, context_layer, onetoone_excite_spec);

         
        // network
        network_spec.do_reset = false; // since dont use learning, avoid resetting every quarter

        Layer[] layers = {input_layer, context_layer, dACC_layer, population_layer};
        Connection[] conns = {/*IC_conn,*/ 
            IPE_conn, 
            PopACC_conn[0], 
            PopACC_conn[1], 
            PopACC_conn[2], 
            dAccC_conn, 
            CPE_conn, CC_conn};
        


        netw = new Network(network_spec, layers, conns);
              
                    
        netw.build();
    }

    void setInput(float[] inp) { inputval = inp;}

    void tick() {
        // pop code prediction error to get graded effort
        float[] pop_act = zeros(hiddensize*populationsize);
        for (int i = 0; i < hiddensize; ++i) {
             float[] subpop = populationEncode(
                predictionerror_layer.units[i].getOutput(),
                populationsize,
                0, 1,
                0.25
            );    
            pop_act = setSubArray(subpop, pop_act, i*populationsize);
        }
        printArray(pop_act);
        
        population_layer.force_activity(pop_act);

        if(netw.accept_input()) {
            float[] inp = inputval;
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


            drawLayer(context_layer);
            drawLayer(predictionerror_layer);
            drawLayer(population_layer);
            drawLayer(dACC_layer);
        popMatrix();

        popMatrix();
    }

    void handleKeyDown(char k){
        float[] ctx = zeros(inputvecsize);
        if (k=='z')
            ctx[0] = 1.f;
        else if(k=='x')
            ctx[1] = 1.f;
        else if(k=='c')
            ctx[2] = 1.f;

        this.setInput(ctx);

    }

    void handleKeyUp(char k){
        this.setInput(zeros(inputvecsize));
    }

    void handleMidi(float note, float vel){
        println("Note "+ note + ", vel " + vel);
        float scale = 1.0/127.0;
        if(note==81)
            inputval[0] = scale * vel; 
        if(note==82)
            inputval[1] = scale * vel; 
    }
    
    void drawLayer(Layer layer){
        float[][] viz = {layer.getOutput()};
        

        translate(0, 20);
        pushMatrix();
        text(layer.name, 0,0);
        pushMatrix();
        translate(100, -10);
        drawColGrid(0,0, 10, multiply(200, viz));
        popMatrix();
        popMatrix();
            
    }
}
