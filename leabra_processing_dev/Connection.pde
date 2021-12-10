/** Connections
*/
import java.lang.Math; // pow

class Link{
    Unit pre;
    Unit post;
    float wt = 0;
    float fwt = 0;
    float dwt = 0;
    int[] index;
    int key;
    Link(Unit pre_unit, Unit post_unit, float w0, float fw0, int[] index){
        this.pre = pre_unit;
        this.post = post_unit;
        this.wt = w0;
        this.fwt = fw0;
        this.dwt = 0.f;
        this.key = 0;
        this.index = index;
    }

}

class Connection{
    Layer pre;
    Layer post;
    ArrayList<Link> links = new ArrayList<Link>();
    float wt_scale_act;
    float wt_scale_rel_eff;
    ConnectionSpec spec;

    Connection( Layer pre_layer, Layer post_layer, ConnectionSpec spec){
        /* """
        Parameters:
            pre_layer   the layer sending its activity.
            post_layer  the layer receiving the activity.
        """
        */ 
        this.pre   = pre_layer;
        this.post  = post_layer;
        
        this.spec  = spec;
        if (this.spec == null)
            this.spec = new ConnectionSpec();

        this.wt_scale_act = 1.0;  // scaling relative to activity.
        this.wt_scale_rel_eff = 0;  // effective relative scaling weight, once other connections
                                      // are taken into account (computed by the network).

        this.spec.projection_init(this);

        pre_layer.from_connections.add(this);
        post_layer.to_connections.add(this);

        
    }

    float wt_scale(){
        //try:
        return this.wt_scale_act * this.wt_scale_rel_eff;
        // except TypeError as e:
        //     println("Error: did you correctly run the network.build() method?");
        //     raise e
    }

    float[][] weights(){
        // """Return a matrix of the links weights"""
        // TODO add support for general topologies
        float[][] W;
        if (this.spec.proj.toLowerCase() == "1to1"){
            //return np.array([[link.wt for link in this.links]])
            W = zeros(1, links.size());
            for (int i = 0; i < links.size(); ++i) {
                W[0][i] = links.get(i).wt;
            }
            return W;
        }
        else { // proj == 'full'
            W = zeros(this.pre.units.length, this.post.units.length);  // weight matrix
            // link_it = iter(this.links)  // link iterator
            // for i, pre_u in enumerate(this.pre.units):
            //     for j, post_u in enumerate(this.post.units):
            //         W[i, j] = next(link_it).wt
            int l = 0;
            for (int j = 0; j < pre.units.length; ++j) {
                for (int i = 0; i < post.units.length; ++i) {
                    W[j][i] = links.get(l++).wt;;
                }
                
            }
            return W;
        }
    }

    void weights(float[][] value){
        // """Override the links weights"""
        if (this.spec.proj.toLowerCase() == "1to1"){
            assert (value[0].length == this.links.size());
            //for wt, link in zip(value, this.links):
            for (int i = 0; i < value.length; ++i) {
                links.get(i).wt  = value[0][i];
                links.get(i).fwt = this.spec.sig_inv(value[0][i]);
            }
                
        }
        else{  // proj == 'full'
            // link_it = iter(this.links)  // link iterator
            assert (value.length * value[0].length == this.links.size());
            // for i, pre_u in enumerate(this.pre.units):
            //     for j, post_u in enumerate(this.post.units):
            //         link = next(link_it)
            //         link.wt = value[i][j]
            //         link.fwt = this.spec.sig_inv(value[i][j])
            int l = 0;
            for (int j = 0; j < pre.units.length; ++j) {
                for (int i = 0; i < post.units.length; ++i) {
                    links.get(i).wt  = value[j][i];
                    links.get(i).fwt = this.spec.sig_inv(value[j][i]);
                }
            }
        }
    }

    void learn(){
        this.spec.learn(this);
    }

    void cycle(){
        this.spec.cycle(this);
    }

    void compute_netin_scaling(){
        this.spec.compute_netin_scaling(this);
    }
}

class ConnectionSpec{
    String[] legal_proj = {"full", "1to1"};

    boolean inhib    = false;   // if True, inhibitory connection
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
    float sig_off  = 1.0;
    float sig_gain = 6.0;

    // netin scaling
    float wt_scale_abs = 1.0;  // absolute scaling weight: direct multiplier, strength of the connection
    float wt_scale_rel = 1.0;  // relative scaling weight, relative to other connections.


    ConnectionSpec(){
        // TODO add params, get, set
    }

    void cycle(Connection connection){
        // """Transmit activity."""
        for (Link link : connection.links){
            if (link.post.act_ext ==0){ // activity not forced
                float scaled_act = this.wt_scale_abs * connection.wt_scale() * link.wt * link.pre.act;
                if(this.inhib) // TAT 2021-12-10: support for inhibitory projections
                    link.post.add_inhibitory(scaled_act);
                else
                    link.post.add_excitatory(scaled_act);
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
        // creating unit-to-unit links
        connection.links.clear();
        //for i, pre_u in enumerate(connection.pre.units):
        //    for j, post_u in enumerate(connection.post.units):
        for (int j = 0; j < connection.pre.units.length; ++j) {
            for (int i = 0; i < connection.post.units.length; ++i) {
                Unit pre_u = connection.pre.units[j];
                Unit post_u = connection.post.units[i];
                float w0 = this.rnd_wt();
                float fw0 = this.sig_inv(w0);
                int[] ix = {j, i};
                connection.links.add(new Link(pre_u, post_u, w0, fw0, ix));
            }
        }
    }

    void onetoone_connection(Connection connection){        
        // creating unit-to-unit links
        connection.links.clear();
        assert (connection.pre.units.length == connection.post.units.length);
        // for i, (pre_u, post_u) in enumerate(zip(connection.pre.units, connection.post.units)):
        for (int i = 0; i < connection.pre.units.length; ++i) {
            Unit pre_u = connection.pre.units[i];
            Unit post_u = connection.post.units[i];
            float w0 = this.rnd_wt();
            float fw0 = this.sig_inv(w0);
            int[] ix = {i, i};
            connection.links.add(new Link(pre_u, post_u, w0, fw0, ix));
        }
            
    }

    void compute_netin_scaling(Connection connection){
        /* """Compute Netin Scaling

        See https://grey.colorado.edu/emergent/index.php/Leabra_Netin_Scaling for details.
        """ */
        float pre_act_avg = connection.pre.avg_act_p_eff;
        int pre_size = connection.pre.units.length;
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
            link.wt = max(0.0, min(1.0, link.wt)); // clipping weights after change
    }

    void apply_dwt(Connection connection){
        for (Link link : connection.links){
            // print('before  wt={}  fwt={}  dwt={}'.format(link.wt, link.fwt, link.dwt))
            link.dwt *= (link.dwt > 0) ? (1 - link.fwt) : link.fwt;
            link.fwt += link.dwt;
            link.wt = this.sig(link.fwt);
            // print('after   wt={}  fwt={}  dwt={}'.format(link.wt, link.fwt, link.dwt))

            link.dwt = 0.0;
        }
    }

    void learning_rule(Connection connection){
        // """Leabra learning rule."""
        int i=0;
        for (Link link : connection.links){
            float srs = link.post.avg_s_eff * link.pre.avg_s_eff;
            float srm = link.post.avg_m * link.pre.avg_m;
            // print('{}:{} erro {}\n  ru_avg_s_eff={}\n  su_avg_s_eff={}\n  srs={}\n  ru_avg_m={}\n  su_avg_m={}\n  srm={}'.format(connection.post.name, i, this.m_lrn  * this.xcal(srs, srm), link.post.avg_s_eff, link.pre.avg_s_eff, srs, link.post.avg_m, link.pre.avg_m, srm))
            // print('{}:{} hebb {}\n  avg_l_lrn={}\n  xcal={}\n  srs={}\n  avg_l={}'.format(connection.post.name, i, link.post.avg_l_lrn * this.xcal(srs, link.post.avg_l), link.post.avg_l_lrn, this.xcal(srs, link.post.avg_l), srs, link.post.avg_l))
            link.dwt += (  this.lrate * ( this.m_lrn * this.xcal(srs, srm)
                         + link.post.avg_l_lrn() * this.xcal(srs, link.post.avg_l)));
            i++;
        }
    }

    float xcal(float x, float th){
        if (x < this.d_thr)
            return 0;
        else if (x > th * this.d_rev)
            return (x - th);
        else
            return (-x * ((1 - this.d_rev)/this.d_rev));
    }

    float sig(float w){
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
        if   (w <= 0.0) return 0.0;
        else if (w >= 1.0) return 1.0;
        return 1 / (1 + pow(((1 - w) / w) , (1 / this.sig_gain)) / this.sig_off);
    }

}
