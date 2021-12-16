//
// test dendrite connection

class TestDendriteConnection{
    String modelname = "Task net test";
    int inputvecsize = 24; // ctx:3 reward:1 pos:2 color:4 number:10
    int behaviours = 4; // TODO update when calc number of discrete behaviours, including gating ones
    int contexts = 2;
    // unit spec
    UnitSpec excite_unit_spec = new UnitSpec();

    // layer
    
    Layer input_layer;
    Layer pfc_layer; // origin of dendrite connection
    Layer striatum_d1_layer; // go - contains input, (learned, manually set) temporal combination patterns

    // connections
    ConnectionSpec ffexcite_spec  = new ConnectionSpec();
    Connection ID1_conn; // input to striatum D1 - go
    Connection PfcIDendr_conn // pfc to inp-D1 dendrite, setting weights

    // network
    int quart_num = 25;
    NetworkSpec network_spec = new NetworkSpec(quart_num);
    Network netw; // network model to contain layers and connections

    Map<String, FloatList> inputs = new HashMap<String, FloatList>();

    TestDendriteConnection(){
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
        striatum_d1_layer = new Layer(behaviours, new LayerSpec(false), excite_unit_spec, HIDDEN, "StriatumD1");
        pfc_layer = new Layer(contexts, new LayerSpec(true), excite_unit_spec, HIDDEN, "Pfc");
    }

    void tick(){

    }

    void draw(){

    }
    
}