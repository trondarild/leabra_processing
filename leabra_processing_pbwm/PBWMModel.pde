// 
// class that builds up the layers, populations of the model
//
class PBWM{
    int behaviours; // the number of behavioural pathways to be supported (also out neurons)
    int num_neurons = 1; // number of neurons per layers
    // units
    UnitSpec unit_spec = new UnitSpec();
    
    // layers, populations
    LayerSpec layer_spec = new LayerSpec();
    Layer matrix_go_layer; // striatal matrix - D1 population
    Layer matrix_nogo_layer; // striatal matrix - D2 population
    Layer gpe_layer; // GPe
    Layer gpi_thal_layer; // GPi-thalamus layer
    Layer cin_layer; // Cholinergic Interneuron

    Layer pfc_maint_layer; // PFC maintenance
    Layer pfc_maint_deep_layer; // PFC maintenance deep?
    Layer pfc_out_layer; // PFC out
    Layer pfc_out_deep_layer; // PFC out deep?

    // connections
    ConnectionSpec con_spec = new ConnectionSpec();

    // network

    PBWM(int behaviours){
        this.behaviours = behaviours;
        
        // create layers
        matrix_go_layer = new Layer(behaviours, new LayerSpec(), unit_spec, HIDDEN, "Hidden");
        matrix_nogo_layer = new Layer(behaviours, new LayerSpec(), unit_spec, HIDDEN, "Hidden");
        gpe_layer = new Layer(behaviours, new LayerSpec(), unit_spec, HIDDEN, "Hidden");
        gpi_thal_layer = new Layer(behaviours, new LayerSpec(), unit_spec, HIDDEN, "Hidden");
        cin_layer = new Layer(behaviours, new LayerSpec(), unit_spec, HIDDEN, "Hidden");
        pfc_maint_layer = new Layer(behaviours, new LayerSpec(), unit_spec, HIDDEN, "Hidden");
        // pfc_maint_deep_layer = new Layer(behaviours, new LayerSpec(), unit_spec, HIDDEN, "Hidden");
        pfc_out_layer = new Layer(behaviours, new LayerSpec(), unit_spec, HIDDEN, "Hidden");
        // pfc_out_deep_layer = new Layer(behaviours, new LayerSpec(), unit_spec, HIDDEN, "Hidden");

        
    }

    // gets
    Layer[] getLayers(){
        Layer[] retval = new Layer[9];
        int i = 0;
         
        retval[i++] = matrix_go_layer;
        retval[i++] = matrix_nogo_layer;
        retval[i++] = gpe_layer;
        retval[i++] = gpi_thal_layer;
        retval[i++] = cin_layer;
        retval[i++] = pfc_maint_layer;
        retval[i++] = pfc_maint_deep_layer;
        retval[i++] = pfc_out_layer;
        retval[i++] = pfc_out_deep_layer;
        return retval;
    }

    void cycle(){
        // TODO: in simplified version, just add
        // layers and connections to an ext. network?
        // and call cycle on network externally?
    }

    void gateSend(){}

    void recGateAct(){}
}
