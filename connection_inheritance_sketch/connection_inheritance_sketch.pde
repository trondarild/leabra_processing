//
//

void setup(){
  size(400, 400);
  frameRate(10);
}

void draw(){
  background(51);
  fill(200);
  circle(width/2, height/2, 100);
}

// float srs = link.post.avg_s_eff * link.pre.avg_s_eff;
// float srm = link.post.avg_m * link.pre.avg_m;
           
interface Connectable {
  float avg_s_eff();
  float avg_m();
  float act_ext();
  void add_inhibitory(float a);
  void add_excitatory(float a);
  float act();
  
  float avg_l_lrn();
  float avg_l();
}

class Unit implements Connectable {
  float avg_s_eff;
  float avg_m;
  
  float avg_s_eff(){return avg_s_eff;}
  float avg_m() {return avg_m;}
  float act_ext(){return 0;}
  void add_inhibitory(float a){}
  void add_excitatory(float a){}
  float act() {return 0;}
  float avg_l_lrn() {return 0;}
  float avg_l() {return 0;}
}

class LeakyIntegrator implements Connectable {
  float avg_s_eff;
  float avg_m;
  
  float avg_s_eff(){return avg_s_eff;}
  float avg_m() {return avg_m;}
  float act_ext(){return 0;}
  void add_inhibitory(float a){}
  void add_excitatory(float a){}
  float act() {return 0;} // same as output
float avg_l_lrn() {return 0;}
float avg_l() {return 0;}
}

interface ConnectableComposite {
   Connectable[] units(); 
   float avg_act_p_eff();
}

class Layer implements ConnectableComposite {
  
  Unit[] units;
  
  Connectable[] units() {return units;}
  float avg_act_p_eff() {return 0;}
}

abstract class Connection implements Connectable {
  ArrayList<Link> links = new ArrayList<Link>();
  
  ConnectableComposite pre;
  ConnectableComposite post;
  float wt_scale_act;
  String name;
  
  float avg_s_eff() {return 0;}
  float avg_m(){return 0;}
  float act_ext(){return 0;}
  float wt_scale(){return 0;}
  float act() {return 0;} // not used?
    float avg_l_lrn() {return 0;}
    float avg_l() {return 0;}
  
  
    
  abstract Link createLink(Connectable pre, Connectable post, float w0, float fw0, int[] ix);
}



class Reservoir implements ConnectableComposite {
  LeakyIntegrator[] units;
  Connectable[] units() {return units;}
  float avg_act_p_eff() {return 0;}
}

class LayerConnection extends Connection {
   LayerConnection( ){}
   Link createLink(Connectable pre, Connectable post, float w0, float fw0, int[] ix){
     return new UnitLink(pre, post, w0, fw0, ix);
   }
   
   void add_inhibitory(float a){} // todo
   void add_excitatory(float a){} // not used
}


abstract class Link { // TODO turn into abstract class? 
  float dwt;
  float fwt;
  
  abstract Connectable pre();
  abstract Connectable post();
  float wt() {return 0;}
  void wt(float a){};
}

class UnitLink extends Link {
  Unit pre;
  Unit post;
  UnitLink(Connectable pre, Connectable post, float w0, float fw0, int[] ix){
    this.pre =(Unit) pre;
    this.post = (Unit) post;
  }
  Connectable pre(){return pre;}
  Connectable post(){return post;}
  float wt() {return 0;}
  
}


class DendriteLink extends Link {
  Unit pre;
  Connection post;
  
  Connectable pre(){return pre;}
  Connectable post(){return post;}
  float wt() {return 0;}
}

class IntegratorLink extends Link {
  /**
  2022-01-13 Note Reservoir may be both pre and post
  */
  Unit unit;
  LeakyIntegrator integrator;
  
  Connectable pre;
  Connectable post;
  
  IntegratorLink(Connectable pre, Connectable post, float w0, float fw0, int[] ix){
    unit = (Unit)pre;
    integrator = (LeakyIntegrator)post;
    pre = unit;
    post = integrator;
  }
  

  
  Connectable pre(){return pre;}
  Connectable post(){return post;}
  float wt() {return 0;}
}


class ConnectionSpec{
    String[] legal_proj = {"full", "1to1"};

    boolean inhibit    = false;   // if True, inhibitory connection
    String proj     = "full";  // connection pattern between units.
                            // Can be 'Full' or '1to1'. In the latter case,
                            // the layers must have the same size.

    // random initialization
    String rnd_type = "uniform"; // shape of the weight initialization
    float rnd_mean = 0.5;       // mean of the random variable for weights init.
    float rnd_var  = 0.25;      // variance (or ±range for uniform)

    // learning
    String lrule    = "" ;   // the learning rule to use (None or 'leabra')
    float lrate    = 0.01;    // learning rate

    // xcal learning
    float m_lrn    = 1.0;     // weighting of the error driven learning
    float d_thr    = 0.0001;  // threshold value for XCAL check-mark function
    float d_rev    = 0.1;     // reversal value for XCAL check-mark function
    float sig_off  = 1.0;     // sigmoid offset
    float sig_gain = 6.0;     // sigmoid gain (noradrenalin?)  

    // netin scaling
    float wt_scale_abs = 1.0;  // absolute scaling weight: direct multiplier, strength of the connection
    float wt_scale_rel = 1.0;  // relative scaling weight, relative to other connections.

    // partial 
    int pre_startix = 0;
    int pre_endix = -1; // use all
    int post_startix = 0;
    int post_endix = -1; // use all;


    ConnectionSpec(){
        // TODO add params, get, set
    }

    ConnectionSpec(ConnectionSpec c) {
        // copy constructor
        // 
        
        this.inhibit = c.inhibit; 
        this.proj = c.proj;    
        this.rnd_type = c.rnd_type;
        this.rnd_mean = c.rnd_mean;
        this.rnd_var = c.rnd_var; 
        this.lrule = c.lrule;   
        this.lrate = c.lrate;   
        this.m_lrn = c.m_lrn;   
        this.d_thr = c.d_thr;   
        this.d_rev = c.d_rev;   
        this.sig_off = c.sig_off; 
        this.sig_gain = c.sig_gain;
        this.wt_scale_abs = c.wt_scale_abs;
        this.wt_scale_rel = c.wt_scale_rel;
        this.pre_startix = c.pre_startix;
        this.pre_endix = c.pre_endix;
        this.post_startix = c.post_startix;
        this.post_endix = c.post_endix;
    }

    void cycle(Connection connection){
        // """Transmit activity."""
        for (Link link : connection.links){
            if (link.post().act_ext() ==0){ // activity not forced
                float scaled_act = this.wt_scale_abs * connection.wt_scale() * link.wt() * link.pre().act();
                if(this.inhibit) // TAT 2021-12-10: support for inhibitory projections
                    link.post().add_inhibitory(scaled_act);
                else
                    link.post().add_excitatory(scaled_act);
            }
        }
    }

    float rnd_wt(){
        // """Return a random weight, according to the specified distribution"""
        if (this.rnd_type == "uniform")
            return random(this.rnd_mean - this.rnd_var,
                                  this.rnd_mean + this.rnd_var);
        else if (this.rnd_type == "gaussian" ){
            float val = randomGaussian();
            return val * sqrt(this.rnd_var) + this.rnd_mean;
        }
        return 0;
    }

    void full_projection(Connection connection){
        // TODO adapt to dendrite connection

        // creating unit-to-unit links
        connection.links.clear();
        //for i, pre_u in enumerate(connection.pre.units):
        //    for j, post_u in enumerate(connection.post.units):
        int pre_end = this.pre_endix == -1 ? connection.pre.units().length-1 : this.pre_endix;
        int post_end = this.post_endix == -1 ? connection.post.units().length-1 : this.post_endix;
        // TODO: add assert here
        for (int j = pre_startix; j <= pre_end; ++j) {
            for (int i = post_startix; i <= post_end; ++i) {
                Connectable pre_u = connection.pre.units()[j];
                Connectable post_u = connection.post.units()[i];
                float w0 = this.rnd_wt();
                float fw0 = this.sig_inv(w0);
                int[] ix = {j, i};
                connection.links.add(connection.createLink(pre_u, post_u, w0, fw0, ix));
            }
        }
    }

    void onetoone_connection(Connection connection){        
        // TODO adapt to dendrite connection
        // creating unit-to-unit links
        connection.links.clear();
        // assert (connection.pre.units.length == connection.post.units.length);
        // TODO: add assert, checking valid start, ends
        int pre_end = this.pre_endix == -1 ? connection.pre.units().length-1 : this.pre_endix;
        int post_end = this.post_endix == -1 ? connection.post.units().length-1 : this.post_endix;
        
        assert (pre_end-this.pre_startix + 1 == post_end-this.post_startix + 1) : 
            connection.name + ": " + (pre_end-this.pre_startix + 1) 
            + " != " + (post_end-this.post_startix + 1);
        // for i, (pre_u, post_u) in enumerate(zip(connection.pre.units, connection.post.units)):
        // for (int i = 0; i < connection.pre.units.length; ++i) {
        for (int i = 0; i <= pre_end-this.pre_startix; ++i) {
            Connectable pre_u = connection.pre.units()[pre_startix + i];
            Connectable post_u = connection.post.units()[post_startix + i];
            float w0 = this.rnd_wt();
            float fw0 = this.sig_inv(w0);
            int[] ix = {pre_startix+i, post_startix+i};
            connection.links.add(connection.createLink(pre_u, post_u, w0, fw0, ix));
        }
            
    }

    void compute_netin_scaling(Connection connection){
        /* """Compute Netin Scaling

        See https://grey.colorado.edu/emergent/index.php/Leabra_Netin_Scaling for details.
        
        TODO: add support for partial connection
        
        """ */
        float pre_act_avg = connection.pre.avg_act_p_eff();
        // int pre_size = connection.pre.units.length;
        int pre_size = this.pre_endix==-1 ? connection.pre.units().length : this.pre_endix - this.pre_startix + 1;
        int n_links = connection.links.size();

        float sem_extra = 2.0; // constant
        int pre_act_n = max(1, int(pre_act_avg * pre_size + 0.5)); // estimated number of active units

        if (n_links == pre_size)
            connection.wt_scale_act = 1.0 / pre_act_n;
        else{
            int post_act_n_max = min(n_links, pre_act_n);
            float post_act_n_avg = max(1, pre_act_avg * n_links + 0.5);
            float post_act_n_exp = min(post_act_n_max, post_act_n_avg + sem_extra);
            connection.wt_scale_act = 1.0 / post_act_n_exp;
        }
    }

    void projection_init(Connection connection){
        if (this.proj == "full")
            this.full_projection(connection);
        if (this.proj == "1to1")
            this.onetoone_connection(connection);
    }

    void learn(Connection connection){
        if (this.lrule != ""){
            this.learning_rule(connection);
            this.apply_dwt(connection);
        }
        for (Link link : connection.links)
            link.wt(max(0.0, min(1.0, link.wt()))); // clipping weights after change
    }

    void apply_dwt(Connection connection){
        for (Link link : connection.links){
            // print('before  wt={}  fwt={}  dwt={}'.format(link.wt, link.fwt, link.dwt))
            link.dwt *= (link.dwt > 0) ? (1 - link.fwt) : link.fwt;
            link.fwt += link.dwt;
            // print(link.name + " dwt: " + link.dwt + ";");
            link.wt(this.sig(link.fwt));
            // print('after   wt={}  fwt={}  dwt={}'.format(link.wt, link.fwt, link.dwt))

            link.dwt = 0.0;
            
        }
        // println();
    }

    void learning_rule(Connection connection){
        // """Leabra learning rule."""
        
        
        for (Link link : connection.links){
            float srs = link.post().avg_s_eff() * link.pre().avg_s_eff();
            float srm = link.post().avg_m() * link.pre().avg_m();
            // print('{}:{} erro {}\n  ru_avg_s_eff={}\n  su_avg_s_eff={}\n  srs={}\n  ru_avg_m={}\n  su_avg_m={}\n  srm={}'.format(connection.post.name, i, this.m_lrn  * this.xcal(srs, srm), link.post.avg_s_eff, link.pre.avg_s_eff, srs, link.post.avg_m, link.pre.avg_m, srm))
            // print('{}:{} hebb {}\n  avg_l_lrn={}\n  xcal={}\n  srs={}\n  avg_l={}'.format(connection.post.name, i, link.post.avg_l_lrn * this.xcal(srs, link.post.avg_l), link.post.avg_l_lrn, this.xcal(srs, link.post.avg_l), srs, link.post.avg_l))
            link.dwt += (  this.lrate * ( this.m_lrn * this.xcal(srs, srm)
                         + link.post().avg_l_lrn() * this.xcal(srs, link.post().avg_l())));
            
        }
    }

    float xcal(float x, float th){
        // """ extended contrastive attractor learning """
        if (x < this.d_thr)
            return 0;
        else if (x > th * this.d_rev)
            return (x - th);
        else 
            return (-x * ((1 - this.d_rev)/this.d_rev));
    }

    float sig(float w){
        // """ Sigmoid function to increase contrast """
        // Note TAT: this may reflect noradrenalin, and 
        // should be require a noradr input 
        // (perhaps the sig_gain factor)
        return 1 / 
            (1 + 
                (this.sig_off * pow(
                    (
                        (1 - w) / w
                    ), this.sig_gain)
                )
            );
    }

    float sig_inv(float w){
        // """ Inverse sigmoid """
        if   (w <= 0.0) return 0.0;
        else if (w >= 1.0) return 1.0;
        return 1 / (1 + pow(((1 - w) / w) , (1 / this.sig_gain)) / this.sig_off);
    }



}
