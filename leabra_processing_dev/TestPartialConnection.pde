//
// Test of partial connection between layers
//
class TestPartialConnection {
    String modelname = "Test partial connection";
    int inputvecsize = 3; // ctx:3 reward:1 pos:2 color:4 number:10
    int hiddensize = 3; // TODO update when calc number of discrete behaviours, including gating ones
 

    // unit spec
    UnitSpec excite_unit_spec = new UnitSpec();
    
    // layer
    Layer input_layer; 
    Layer hidden_layer; 
    
    // connections
    ConnectionSpec edge_left_spec  = new ConnectionSpec();
    ConnectionSpec edge_right_spec  = new ConnectionSpec();
    ConnectionSpec middle_spec  = new ConnectionSpec();

    
    Connection IC_conn; // input to context
    
    int quart_num = 25;
    NetworkSpec network_spec = new NetworkSpec(quart_num);
    Network netw; // network model to contain layers and connections

    Map <String, FloatList> inputs = new HashMap<String, FloatList>();
    int inp_ix = 0;

    float[] inputval = zeros(inputvecsize);


    TestPartialConnection() {


    }

    void setInput(float[] inp) {

    }

    void tick() {

    }

    void draw() {

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

}