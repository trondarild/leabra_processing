/**

==Input==

1. ctx: 010 tctx:10 pos: 01 shp:1000 color:0100 num:0000 // choose stack attention to right
1. ctx: 010 tctx:10 pos: 10 shp:1000 color:0001 num:0000 // choose stack attention to left

NB: use tctx (temporal context) to differentiate between selecting stacks and selecting yes, no on task
NB: note that some value need to degrade to make more costly choice less likely

**Do numerical task**

Nb: repeating the same task should make it prepotent, such that effortful inhibition is necessary when task changes (cued by color change) 

Nb: May need temporal context here so not mix up choosing stack and doing task 

**Even number**
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:1000000000 out: 1000 // do num task: even num?
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:0010000000 out: 1000 -> 
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:0000100000 out: 1000
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:0000001000 out: 1000
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:0000000010 out: 1000
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:0100000000 out: 0100
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:0001000000 out: 0100
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:0000010000 out: 0100
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:0000000100 out: 0100
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:1000 num:0000000001 out: 0100

**Less than 5?**
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:0010 num:1000000000 out: 0100 // < 5?
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:0010 num:0100000000 out: 0100
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:0010 num:0010000000 out: 0100
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:0010 num:0001000000 out: 0100
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:0010 num:0000010000 out: 1000
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:0010 num:0000001000 out: 1000
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:0010 num:0000000100 out: 1000
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:0010 num:0000000010 out: 1000
1. ctx: 010 tctx: 01 pos: 00 shp:1000 color:0010 num:0000000001 out: 1000
*/


class DecDemandSketch {
    String modelname = "Test decision demand task";

    int inputvecsize = 27; // ctx:3 tctx:2 pos:2 shp:4 color:4 number:10 fb:2
    
    int ctxsize = 3; // task context
    int tctxsize = 2;
    int possize = 2;
    int shpsize = 4;
    int colsize = 4;
    int numsize = 10;
    int rulectxsize = 2; // use "even" or "<5" rule? input from color; increase to 1+2+4 for all tasks
    int rulesize = 4; // 10 + 10 rules, dept on rule ctx/color; but rules coded to goal pos (yes, no)
    int outsize = 4; // output target-positions for all tasks
    // unit spec
    UnitSpec excite_unit_spec = new UnitSpec();
    
    // layer
    Layer input_layer; 
    
    // representation layers
    Layer ctx_layer; // task context - only dec demand for now
    Layer tctx_layer; // codes temporal context - choose card stack or choose rule
    Layer pos_layer; // code position of stacks - will be affected by valence
    Layer shp_layer; // not used in dec demand task
    Layer col_layer; // code color of number
    Layer num_layer; // code number value
    
    

    // control layers
    Layer rulectx_layer; // uses context to inhibit inappropriate rules; should probl be disinhibition
    Layer rule_layer; // mappings to output

    Layer out_layer; // output target-positions; motor layer -> /not really/ BG gated
    
    // connections
    ConnectionSpec full_spec  = new ConnectionSpec();
    ConnectionSpec inhibition_spec; 
    ConnectionSpec ctx_con_spec;
    ConnectionSpec tctx_con_spec;
    ConnectionSpec pos_con_spec;
    ConnectionSpec shp_con_spec;
    ConnectionSpec col_con_spec;
    ConnectionSpec num_con_spec;
    ConnectionSpec rulectx_even_con_spec;
    ConnectionSpec rulectx_lt5_con_spec;
    ConnectionSpec out_even_con_spec;
    ConnectionSpec out_lt5_con_spec;

    Connection inp_ctx_conn; // input to task context
    Connection inp_tctx_conn; // input to temporal ctx
    Connection inp_pos_conn; // input to pos
    Connection inp_shp_conn; // input to shape -not used in this task
    Connection inp_col_conn; // input to color
    Connection inp_num_conn; // input to number
    Connection col_rulectx_even_conn; // colour to rulecontext TODO replace with effort-involving network
    Connection col_rulectx_lt5_conn;
    Connection rulectx_rule_conn; // inhibits inappropriate rules
    Connection num_rule_conn; // number to rules
    Connection rule_out_even_conn; // rule to out target
    Connection rule_out_lt5_conn; // rule to out target

    
    int quart_num = 25;
    NetworkSpec network_spec = new NetworkSpec(quart_num);
    Network netw; // network model to contain layers and connections

    Map <String, FloatList> inputs = new HashMap<String, FloatList>();
    int inp_ix = 0;

    float[] inputval = zeros(inputvecsize);

    float[][] decision_demand_inputs = {
        {0,1,0, 1,0, 0,1, 1,0,0,0, 1,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0}, // stack selection
        {0,1,0, 1,0, 1,0, 1,0,0,0, 0,1,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0}, //

        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 1,0,0,0,0,0,0,0,0,0, 0,0}, // even rule
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 0,0,1,0,0,0,0,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 0,0,0,0,1,0,0,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 0,0,0,0,0,0,1,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 0,0,0,0,0,0,0,0,1,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 0,1,0,0,0,0,0,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 0,0,0,1,0,0,0,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 0,0,0,0,0,1,0,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 0,0,0,0,0,0,0,1,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,1,0, 0,0,0,0,0,0,0,0,0,1, 0,0}, //

        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,0,1, 1,0,0,0,0,0,0,0,0,0, 0,0}, // < 5 rule
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,0,1, 0,1,0,0,0,0,0,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,0,1, 0,0,1,0,0,0,0,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,0,1, 0,0,0,1,0,0,0,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,0,1, 0,0,0,0,0,1,0,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,0,1, 0,0,0,0,0,0,1,0,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,0,1, 0,0,0,0,0,0,0,1,0,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,0,1, 0,0,0,0,0,0,0,0,1,0, 0,0},
        {0,1,0, 0,1, 0,0, 1,0,0,0, 0,0,0,1, 0,0,0,0,0,0,0,0,0,1, 0,0}

    };

    float[][] rule_weights = {
        {1,0,1,0,1,0,1,0,1,0}, // odd -> no
        {0,1,0,1,0,1,0,1,0,1}, // even -> yes
        {1,1,1,1,0,0,0,0,0,0}, // < 5 -> yes
        {0,0,0,0,0,1,1,1,1,1}, // < 5 -> no
    };

    float[][] rule_ctx_weights = { // inhibits rules based on colour ctx
        {0,0,1,1},
        {1,1,0,0}
    };

    

    DecDemandSketch () {
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
        full_spec.proj="full";
        full_spec.rnd_type="uniform" ;
        full_spec.rnd_mean=0.5;
        full_spec.rnd_var=0.0;

        ConnectionSpec onetoone_spec = new ConnectionSpec(full_spec);
        onetoone_spec.proj="1to1";

        ctx_con_spec  = new ConnectionSpec(onetoone_spec);
        ctx_con_spec.pre_startix = 0;
        ctx_con_spec.pre_endix = 2;
        ctx_con_spec.post_endix = 2;
        tctx_con_spec  = new ConnectionSpec(onetoone_spec);
        tctx_con_spec.pre_startix = 3;
        tctx_con_spec.pre_endix = 4;
        tctx_con_spec.post_endix = 1;
        pos_con_spec  = new ConnectionSpec(onetoone_spec);
        pos_con_spec.pre_startix = 5;
        pos_con_spec.pre_endix = 6;
        pos_con_spec.post_endix = 1;
        shp_con_spec  = new ConnectionSpec(onetoone_spec);
        shp_con_spec.pre_startix = 7;
        shp_con_spec.pre_endix = 10;
        shp_con_spec.post_endix = 3;
        col_con_spec  = new ConnectionSpec(onetoone_spec);
        col_con_spec.pre_startix = 11;
        col_con_spec.pre_endix = 14;
        col_con_spec.post_endix = 3;
        num_con_spec  = new ConnectionSpec(onetoone_spec);
        num_con_spec.pre_startix = 15;
        num_con_spec.pre_endix = 24;
        num_con_spec.post_endix = 9;

        rulectx_even_con_spec = new ConnectionSpec(full_spec);
        rulectx_even_con_spec.pre_startix = 2;
        rulectx_even_con_spec.pre_endix = 2;
        rulectx_even_con_spec.post_startix = 0;
        rulectx_even_con_spec.post_endix = 0;
        rulectx_lt5_con_spec = new ConnectionSpec(full_spec);
        rulectx_lt5_con_spec.pre_startix = 3;
        rulectx_lt5_con_spec.pre_endix = 3;
        rulectx_lt5_con_spec.post_startix = 1;
        rulectx_lt5_con_spec.post_endix = 1;

        out_even_con_spec = new ConnectionSpec(onetoone_spec);
        out_even_con_spec.pre_startix = 0;
        out_even_con_spec.pre_endix = 1;
        out_even_con_spec.post_startix = 0;
        out_even_con_spec.post_endix = 1;
        out_lt5_con_spec = new ConnectionSpec(onetoone_spec);
        out_lt5_con_spec.pre_startix = 2;
        out_lt5_con_spec.pre_endix = 3;
        out_lt5_con_spec.post_startix = 0;
        out_lt5_con_spec.post_endix = 1;

        inhibition_spec = new ConnectionSpec(full_spec);
        inhibition_spec.inhibit = true;

        // layers
        input_layer = new Layer(inputvecsize, new LayerSpec(false), excite_unit_spec, INPUT, "Input");
        
        ctx_layer = new Layer(ctxsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "ctx");
        tctx_layer = new Layer(tctxsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "tctx");
        pos_layer = new Layer(possize, new LayerSpec(false), excite_unit_spec, HIDDEN, "pos");
        shp_layer = new Layer(shpsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "shp");
        col_layer = new Layer(colsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "col");
        num_layer = new Layer(numsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "number");
        
        rulectx_layer = new Layer(rulectxsize, new LayerSpec(false), excite_unit_spec, HIDDEN, "rulectx");
        rule_layer = new Layer(rulesize, new LayerSpec(false), excite_unit_spec, HIDDEN, "rule");
        out_layer = new Layer(outsize, new LayerSpec(true), excite_unit_spec, HIDDEN, "out");
        
        // connections
        inp_ctx_conn = new Connection(input_layer, ctx_layer, ctx_con_spec);
        inp_tctx_conn = new Connection(input_layer, tctx_layer, tctx_con_spec);
        inp_pos_conn = new Connection(input_layer, pos_layer, pos_con_spec);
        inp_shp_conn = new Connection(input_layer, shp_layer, shp_con_spec);
        inp_col_conn = new Connection(input_layer, col_layer, col_con_spec);
        inp_num_conn = new Connection(input_layer, num_layer, num_con_spec);

        col_rulectx_even_conn = new Connection(col_layer, rulectx_layer, rulectx_even_con_spec);
        col_rulectx_lt5_conn = new Connection(col_layer, rulectx_layer, rulectx_lt5_con_spec);
        rulectx_rule_conn = new Connection(rulectx_layer, rule_layer, inhibition_spec);
        rulectx_rule_conn.weights(rule_ctx_weights);

        num_rule_conn = new Connection(num_layer, rule_layer, full_spec);
        num_rule_conn.weights(transpose(rule_weights));

        rule_out_even_conn = new Connection(rule_layer, out_layer, out_even_con_spec);
        rule_out_lt5_conn = new Connection(rule_layer, out_layer, out_lt5_con_spec);

        // network
        network_spec.do_reset = false; // since dont use learning, avoid resetting every quarter

        Layer[] layers = {
            input_layer, 
            ctx_layer,
            tctx_layer,
            pos_layer,
            shp_layer,
            col_layer,
            num_layer,
            rulectx_layer,
            rule_layer,
            out_layer
        };
        Connection[] conns = {
            inp_ctx_conn,
            inp_tctx_conn,
            inp_pos_conn,
            inp_shp_conn,
            inp_col_conn,
            inp_num_conn,
            col_rulectx_even_conn,
            col_rulectx_lt5_conn,
            rulectx_rule_conn,
            num_rule_conn,
            rule_out_even_conn,
            rule_out_lt5_conn
        };


        netw = new Network(network_spec, layers, conns);
        netw.build();
    }

    void setInput(float[] inp) { inputval = inp; }
    void setInputIx(int ix) { inputval = decision_demand_inputs[ix]; }

    void tick() {
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

            drawLayer(ctx_layer);
            drawLayer(tctx_layer);
            drawLayer(pos_layer);
            drawLayer(shp_layer);
            drawLayer(col_layer);
            drawLayer(num_layer);
            drawLayer(rulectx_layer);
            drawLayer(rule_layer);
            drawLayer(out_layer);
        popMatrix();

        popMatrix();

    }

    void handleKeyDown(char k){
        // float[] ctx = zeros(inputvecsize);
        // if (k=='z')
        //     ctx[0] = 1.f;
        // else if(k=='x')
        //     ctx[1] = 1.f;
        // else if(k=='c')
        //     ctx[2] = 1.f;
        if (k == UP)
            inp_ix = limitval(0, decision_demand_inputs.length, inp_ix++);
        else if (k == DOWN)
            inp_ix = limitval(0, decision_demand_inputs.length, inp_ix--);

        this.setInputIx(inp_ix);

    }

    void handleKeyUp(char k){
        //this.setInput(zeros(inputvecsize));
    }

    void handleMidi(int note, int vel){
        println("Note "+ note + ", vel " + vel);
        float scale = 1.0/127.0;
        float lenscale=1.0 * (decision_demand_inputs.length-1);
        if(note==1)
            this.setInputIx(limitval(0, decision_demand_inputs.length-1, 
                (int)(lenscale * scale * vel))); 
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
