static int DOPAMINE = 0; // default
static int SEROTONIN = 1;
static int NORADRENALIN = 2;
static int ACETYLCHOLINE = 3;
static int ADENOSINE = 4;

class LeakyIntegrator{
    String name;
    int type;
    LeakyIntegratorSpec spec;
    float store;
    float input;
    // float growth;
    // float accumulate;
    // float decaythreshold;
    // float decayfactor;
    Buffer buffer;
    
    LeakyIntegrator() {
        this.spec = new LeakyIntegratorSpec();
        this.type = DOPAMINE;
        buffer = new Buffer(spec.default_buf_size);
    }

    LeakyIntegrator(LeakyIntegratorSpec spec, int type){
        this.spec = spec;
        this.type = type;
        buffer = new Buffer(spec.default_buf_size);
    }

    Buffer getBuffer() {
        return buffer;
    }

    float getOutput() {
        return store;
    }

    void cycle(){
        this.spec.cycle(this);
        buffer.append(this.store);
    }

    void setInput(float inp){
        input = inp; 
    }


}

class LeakyIntegratorSpec {
    float growth = 0.9; // how much of input to use when integrating
    float accumulate = 0.9; // how much of store to retain when growing
    float decaythreshold = 0.1; // leak if input less than this
    float decayfactor = 0.1; // how much to in total of input and store to pass on
    int default_buf_size = 100;

    LeakyIntegratorSpec() {

    }

    void cycle(LeakyIntegrator a){
        float epsilon = this.growth;
        float lambda = this.accumulate;
        if(a.input < this.decaythreshold){
            epsilon = this.decayfactor;
            lambda = 0;
        }
        a.store += epsilon*(a.input - (1-lambda)*a.store);
    }
}
