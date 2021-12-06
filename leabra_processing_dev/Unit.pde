/**
Implementation of a Leabra Unit, reproducing the behavior of emergent 8.0.

We implement only the rate-coded version. The code is intended to be as simple
as possible to understand. It is not in any way optimized for performance.
*/

// type of layer and correspondingly, unit behaviors
static int INPUT  = 0;
static int HIDDEN = 1;
static int OUTPUT = 2;

class Unit{
    UnitSpec spec;
    int genre = INPUT;
    
    String[] log_names = {"net", "I_net", "v_m", "act", "v_m_eq", "adapt"};
    float avg_ss;
    float avg_s;
    float avg_m;
    float avg_l;
    float avg_s_eff;
    ArrayList<Float> ex_inputs = new ArrayList<Float>();
    float g_e;
    float I_net;
    float I_net_r;
    float v_m;
    float v_m_eq;
    float act_ext = 0;
    float act = 0;
    float act_nd = 0;
    float act_m = 0;
    float adapt = 0;

    Unit(){
        /*        
        spec:  UnitSpec instance with custom values for the unit parameters.
               If None, default values will be used.
        
        */
        genre = HIDDEN;  // type of Unit

        // this.spec = spec;
        // if (this.spec == Null)
            this.spec = new UnitSpec();

        // this.log_names = {"net", "I_net", "v_m", "act", "v_m_eq", "adapt"};
        //this.logs  = {name: [] for name in this.log_names}

        this.reset();

        // averages of the activity
        this.avg_ss    = this.spec.avg_init; // super-short-term average
        this.avg_s     = this.spec.avg_init; // short-term average
        this.avg_m     = this.spec.avg_init; // medium-term average
        this.avg_l     = this.spec.avg_l_init;
        this.avg_s_eff = 0.0 ; // linear mixing of avg_s and avg_m

    }
    
    Unit(UnitSpec spec, int genre, String[] log_names){
        this.spec = spec;
        this.genre = genre;
        this.log_names = log_names;
        this.reset();

        // averages of the activity
        this.avg_ss    = this.spec.avg_init; // super-short-term average
        this.avg_s     = this.spec.avg_init; // short-term average
        this.avg_m     = this.spec.avg_init; // medium-term average
        this.avg_l     = this.spec.avg_l_init;
        this.avg_s_eff = 0.0 ; // linear mixing of avg_s and avg_m

    }
    
    void reset(){
        // """Reset the Unit state. Called at creation, and at every trial."""
        this.ex_inputs.clear();              // excitatory inputs for the next cycle
        this.g_e     = 0;                  // excitatory conductance
        this.I_net   = 0;                  // net current
        this.I_net_r = this.I_net;         // net current, equilibrium version (for v_m_eq)
        this.v_m     = this.spec.v_m_init; // membrane potential
        this.v_m_eq  = this.v_m;           // equilibrium membrane potential
                                          // (not reseted after a spike)
        this.act_ext = 0;               // externally forced activity (None for not forced)
        this.act     = 0;                  // current activity
        this.act_nd  = this.act;           // non-depressed activity # FIXME: not implemented yet
        this.act_m   = this.act;           // activity at the end of the minus phase

        this.adapt   = 0;     // adaptation current: causes the rate of activation
                              // to decrease over time
    }
};

class UnitSpec{
    /**
    Units specification.

    Each unit can have different parameters values. They don't change during
    cycles, and unless you know what you're doing, you should not change them
    after the Unit creation. The best way to proceed is to create the UnitSpec,
    modify it, and provide the spec when instantiating a Unit:

    >>> spec = UnitSpec(act_thr=0.35) // specifying parameters at instantiation
    >>> spec.bias = 0.5               // you can also do it afterward
    >>> u = Unit(spec=spec)           // creating a Unit instance

    */

    // time step constants
    float tau_net    = 1.4;     // net input integration time constant (net = g_e * g_bar_e)
    float tau_v_m    = 3.3;     // v_m integration time constant
    // input channels parameters
    float g_l        = 1.0;     // leak current (constant)
    float g_bar_e    = 1.0;     // excitatory maximum conductance
    float g_bar_l    = 0.1;     // leak maximum conductance
    float g_bar_i    = 1.0;     // inhibitory maximum conductance
    // reversal potential
    float e_rev_e    = 1.0 ;    // excitatory
    float e_rev_l    = 0.3 ;    // leak
    float e_rev_i    = 0.25;    // inhibitory
    // activation function parameters
    float act_thr    = 0.5 ;    // threshold 2021-12-05 TAT: modulate via dopa D1 D2, adeno A1 A2
    float c_act_thr = 0; // let original vary, this be constant; logistic(0) = 0.5
    float act_gain   = 100 ;    // gain
    boolean noisy_act  = true;    // If True, uses the noisy activation function
    float act_sd     = 0.01;    // standard deviation of the noisy gaussian //FIXME: variance or sd?
    float act_min    = 0.0 ;    // clamp ranges (min, max) for the activation value.
    float act_max    = 0.95;    
    // spiking behavior
    float spk_thr    = 1.2;     // spike threshold for resetting v_m // FIXME: actually used?
    float v_m_init   = 0.4;     // init value for v_m
    float v_m_r      = 0.3;     // reset value for v_m
    float v_m_min    = 0.0;     // clamp ranges (min, max) for v_m
    float v_m_max    = 2.0;     
    // adapt behavior
    boolean adapt_on   = false  ; // if True, enable the adapt behavior
    float dt_adapt   = 1/144. ; // time-step constant for adapt update
    float v_m_gain   = 0.04   ; // gain on v_m driving the adaptation variable
    float spike_gain = 0.00805; // value to add to the adaptation variable after spiking
    // bias //FIXME: not implemented.
    float bias       = 0.0;
    // average parameters
    float avg_init   = 0.15;
    float avg_ss_dt  = 0.5;
    float avg_s_dt   = 0.5;
    float avg_m_dt   = 0.1;
    float avg_l_dt   = 0.1 ;// computed once every trial //FIXME tau
    float avg_l_init = 0.4;
    float avg_l_min  = 0.2;
    float avg_l_gain = 2.5;
    float avg_m_in_s = 0.1;
    float avg_lrn_min = 0.0001; // minimum avg_l_lrn value.
    float avg_lrn_max = 0.5;    // maximum avg_l_lrn value
    // dopa and adenosine
    float r_d1 = 0.0;
    float r_d2 = 0.0;
    float r_a1 = 0.0;
    float r_a2 = 0.0;

    float[][] nxx1_conv;
    

    UnitSpec(){
        // TODO add params 
    }
    UnitSpec(UnitSpec cp){
        // TODO copy constructor
    }

    float avg_l_lrn(Unit unit){
        if (unit.genre != HIDDEN)  // no self-organization for non-hidden layers
            return 0.0;
        float avg_fact = (this.avg_lrn_max - this.avg_lrn_min)/(this.avg_l_gain - this.avg_l_min);
        return this.avg_lrn_min + avg_fact * (unit.avg_l - this.avg_l_min);
    }

    float dt_net(){
        return 1.0 / this.tau_net;
    }

    float dt_v_m(){
        return 1.0 / this.tau_v_m;
    }

    UnitSpec copy(){
        return new UnitSpec(this);
    }

    float xx1(float v_m){
        // """Compute the x/(x+1) activation function."""
        float X = this.act_gain * max(v_m, 0.0);
        return X / (X + 1);
    }

    float noisy_xx1(float v_m){
        /*
        """Compute the noisy x/(x+1) activation function.

        The noisy x/(x+1) function is the convolution of the x/(x+1) function
        with a Gaussian with a `self.spec.act_sd` standard deviation. Here, we
        precompute the convolution as a look-up table, and interpolate it with
        the desired point every time the function is called.
        """
        */
        // TODO
        return 0;
    }

    void calculate_net_in(Unit unit, float dt_integ){
        /** """Calculate the net input for the unit. To execute before cycle().

        If the activity of the unit is forced, then normal external inputs are ignored, and
        net_in is set to the forced activity.
        """
        */
        if (unit.act_ext != 0){  // forced activity
            assert (unit.ex_inputs.size() == 0);  // avoiding mistakes
            return; // see self.force_activity
        }

        float net_raw = 0.0;
        if (unit.ex_inputs.size() > 0){
            // computing net_raw, the total, instantaneous, excitatory input for the neuron
            
            net_raw = sumArray(unit.ex_inputs);
            unit.ex_inputs.clear();
        }

        // updating net
        unit.g_e += dt_integ * this.dt_net() * (net_raw - unit.g_e);  // eq 2.16
    }

}
