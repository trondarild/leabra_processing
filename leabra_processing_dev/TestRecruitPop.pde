class TestRecruitPop {
    String modelname = "Test recruitment population";

    int inputvecsize = 3; // ctx:3 reward:1 pos:2 color:4 number:10
    int hiddensize = 3; // TODO update when calc number of discrete behaviours, including gating ones
    int populationsize = 5;

    // unit spec
    UnitSpec excite_unit_spec = new UnitSpec();
    
    
    // layer
    Layer input_layer; 
    Layer hidden_layer; 
    Layer population_layer;
    Layer effort_layer;
    
    // connections
    ConnectionSpec ffexcite_spec  = new ConnectionSpec();
    ConnectionSpec full_spec_0  = new ConnectionSpec();
    ConnectionSpec full_spec_1  = new ConnectionSpec();
    ConnectionSpec full_spec_2  = new ConnectionSpec();
    ConnectionSpec full_spec_3  = new ConnectionSpec();
    ConnectionSpec full_spec_4  = new ConnectionSpec();
    Connection IH_conn; // input to context
    Connection PE_conn_0; // population to effort
    Connection PE_conn_1; // population to effort
    Connection PE_conn_2; // population to effort
    Connection PE_conn_3; // population to effort
    Connection PE_conn_4; // population to effort
    
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

    TestRecruitPop () {
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

        full_spec_0.proj="full";
        full_spec_0.pre_startix = 0;
        full_spec_0.pre_endix = 0;
        full_spec_0.post_startix = 0;
        full_spec_0.post_endix = 0;
        full_spec_1.proj="full";
        full_spec_1.pre_startix = 1;
        full_spec_1.pre_endix = 1;
        full_spec_1.post_startix = 0;
        full_spec_1.post_endix = 1;
        full_spec_2.proj="full";
        full_spec_2.pre_startix = 2;
        full_spec_2.pre_endix = 2;
        full_spec_2.post_startix = 0;
        full_spec_2.post_endix = 2;
        full_spec_3.proj="full";
        full_spec_3.pre_startix = 3;
        full_spec_3.pre_endix = 3;
        full_spec_3.post_startix = 0;
        full_spec_3.post_endix = 3;
        full_spec_4.proj="full";
        full_spec_4.pre_startix = 4;
        full_spec_4.pre_endix = 4;
        full_spec_4.post_startix = 0;
        full_spec_4.post_endix = 4;
        
        // layers
        input_layer = new Layer(inputvecsize, new LayerSpec(false), excite_unit_spec, INPUT, "Input");
        hidden_layer = new Layer(hiddensize, new LayerSpec(false), excite_unit_spec, HIDDEN, "Hidden");
        population_layer = new Layer(populationsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "Population");
        effort_layer  = new Layer(populationsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "Effort");
        // connections
        IH_conn = new Connection(input_layer, hidden_layer, ffexcite_spec);
        PE_conn_0 = new Connection(population_layer, effort_layer, full_spec_0);
        PE_conn_1 = new Connection(population_layer, effort_layer, full_spec_1);
        PE_conn_2 = new Connection(population_layer, effort_layer, full_spec_2);
        PE_conn_3 = new Connection(population_layer, effort_layer, full_spec_3);
        PE_conn_4 = new Connection(population_layer, effort_layer, full_spec_4);
        

        // network
        network_spec.do_reset = false; // since dont use learning, avoid resetting every quarter

        Layer[] layers = {input_layer, hidden_layer, population_layer, effort_layer};
        Connection[] conns = {IH_conn, 
            PE_conn_0,
            PE_conn_1,
            PE_conn_2,
            PE_conn_3,
            PE_conn_4
        };


        netw = new Network(network_spec, layers, conns);
        netw.build();

        
    }

    void setInput(float[] inp) { inputval = inp; }

    void tick() {
        float[] pop_act = populationEncode(
            input_layer.units[0].getOutput(),
            populationsize,
            0, 1,
            0.5
        );
        population_layer.force_activity(pop_act);
        // PE_conn.weights(w_effort);

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
        
        float[][] h_viz = zeros(1, hiddensize);
        h_viz[0] = hidden_layer.getOutput();

        float[][] p_viz = zeros(1, populationsize);
        p_viz[0] = population_layer.getOutput();

        float[][] e_viz = zeros(1, populationsize);
        e_viz[0] = effort_layer.getOutput();
        
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
            text(population_layer.name, 0,0);
            pushMatrix();
            translate(100, -10);
            drawColGrid(0,0, 10, multiply(200, p_viz));
            popMatrix();
            popMatrix();

            translate(0, 20);
            pushMatrix();
            text(effort_layer.name, 0,0);
            pushMatrix();
            translate(100, -10);
            drawColGrid(0,0, 10, multiply(200, e_viz));
            popMatrix();
            popMatrix();

            
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

    void handleMidi(int note, int vel){
        println("Note "+ note + ", vel " + vel);
        float scale = 1.0/127.0;
        if(note==81)
            inputval[0] = scale * vel; 
    }

}
