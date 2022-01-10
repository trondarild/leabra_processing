//
// Reservoir models aggregates of neuromodulaters in 
// intercellular tissue, that affects non-synaptic 
// receptors
//
// ref: 



class Reservoir {
    String name;
    int size;
    int type; // type of neuromodulator
    
    ReservoirSpec spec;
    LeakyIntegrator[] units;
    Buffer[] buffers;

    // TODO: make special connections for reservoirs
    // ArrayList<Connection> from_connections = new ArrayList<Connection>();
    // ArrayList<Connection> to_connections = new   ArrayList<Connection>();

    Reservoir(int size, int type, String name) {
        this.name = name;
        this.size = size;
        this.type = type;
        this.spec = new ReservoirSpec();
        LeakyIntegratorSpec unit_spec = new LeakyIntegratorSpec();

        units = new LeakyIntegrator[size];
        for (int i = 0; i < units.length; ++i) {
            units[i] = new LeakyIntegrator(unit_spec, type);
            units[i].name = this.name + "_" + i;
        }
        buffers = new Buffer[size];

    }

    Reservoir(int size, ReservoirSpec spec, LeakyIntegratorSpec unit_spec, int type, String name){
        /**
        size - number of leaky integrators
        spec - custom values
        unit_spec - custom values for units
        type - which neuromodulator - this affects receiving neural units
        name - name of reservoir
        */
        this.name = name;
        this.size = size;
        this.spec = spec;
        this.type = type;
        if(this.spec == null) this.spec = new ReservoirSpec();

        units = new LeakyIntegrator[size];
        for (int i = 0; i < units.length; ++i) {
            units[i] = new LeakyIntegrator(unit_spec, type);
            units[i].name = this.name + "_" + i;
        }
        buffers = new Buffer[size];
    }

    void cycle() {
        for (int i = 0; i < this.size; ++i) {
            units[i].cycle();
            buffers[i] = units[i].getBuffer();
        }
    }

    void setInput(float[] inp) {
        assert(inp.length == units.length) : inp.length + " != " + units.length;
        for (int i = 0; i < inp.length; ++i) {
            units[i].setInput(inp[i]);
        }
    }

    float[] getOutput() {
        float[] retval = zeros(this.size);
        for (int i = 0; i < this.size; ++i) {
            retval[i] = units[i].getOutput();
        }
        return retval;
    }

}

class ReservoirSpec {
    // TODO is this needed?
}
