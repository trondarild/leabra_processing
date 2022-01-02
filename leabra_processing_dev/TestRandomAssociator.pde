class TestRandomAssociator {
    String name = "Random associator";
    
    int numpatterns = 24;
    int patternsize = 10;
    int hots = 4;
    int ctr = 0;
    float[][] sourcepatterns;
    float[][] targetpatterns;

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

    // network
    int quart_num = 25;
    NetworkSpec network_spec = new NetworkSpec(quart_num);
    Network netw; // network model to contain layers and connections

    Map <String, FloatList> inputs = new HashMap<String, FloatList>();
    Map <String, FloatList> targets = new HashMap<String, FloatList>();
    int inp_ix = 0;

    float[] inputval = zeros(inputvecsize);
    
    
    TestRandomAssociator() {
        
    }

    void tick() {
        
        if(netw.accept_input()){
            int ptrn_ix = numpatterns % ctr++;
            FloatList inpvals = arrayToList(sourcepatterns[ptrn_ix]);
            inputs.put("Input", inpvals);
            netw.set_inputs(inputs);

            FloatList targetvals = arrayToList(targetpatterns[ptrn_ix]);
            targets.put("Output", targetvals);
            netw.set_targets(targets);
        }
        netw.cycle();
    }

    void draw() {
        
    }

   
}