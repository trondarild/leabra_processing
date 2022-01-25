//
//
//
import java.util.HashMap;
import java.util.Map;



String[] lognames = {};
SignalGenerator sig = new SignalGenerator(eTickSquare, 50, 40, 100);

// units
UnitSpec unit_spec = new UnitSpec();
UnitSpec excite_unit_spec = new UnitSpec();
UnitSpec inhib_unit_spec = new UnitSpec();
UnitSpec unit_spec_bias = new UnitSpec();
// Unit unit = new Unit(spec, INPUT, lognames);

int numunits = 4;
// layers

Layer input_layer; // = new Layer(numunits, new LayerSpec(false), excite_unit_spec, INPUT, "Input");
Layer inhib_layer; // = new Layer(2, new LayerSpec(false), unit_spec, HIDDEN, "Hidden");
Layer hidden_layer; // = new Layer(numunits, new LayerSpec(false), inhib_unit_spec, HIDDEN, "Output");

// connections
ConnectionSpec ffexcite_spec  = new ConnectionSpec();
ConnectionSpec ffinhib_spec  = new ConnectionSpec(); 
ConnectionSpec fbinhib_spec  = new ConnectionSpec(); 
ConnectionSpec inhib_spec  = new ConnectionSpec(); 
ConnectionSpec inhibinhib_spec  = new ConnectionSpec(); 
Connection IH_conn; // = new Connection(input_layer,  hidden_layer, ffexcite_spec);
Connection Ii_conn; // = new Connection(input_layer,  inhib_layer,  ffinhib_spec);
Connection Hi_conn; // = new Connection(hidden_layer, inhib_layer,  fbinhib_spec);
Connection iH_conn; // = new Connection(inhib_layer,  hidden_layer, inhib_spec);
Connection ii_conn; // = new Connection(inhib_layer,  inhib_layer,  inhibinhib_spec);

// network
int quart_num = 20;
NetworkSpec network_spec = new NetworkSpec(quart_num);
Layer[] layers =  {input_layer, inhib_layer, hidden_layer};
Connection[] conns = {IH_conn}; //,
 //Ii_conn,
 //Hi_conn,
 //iH_conn,
 //ii_conn};
Network netw; // = new Network(network_spec, layers, conns);

Map<String, FloatList> inputs = new HashMap<String, FloatList>();

boolean phase = true;
int cyc = 0;

void setup(){
	size(400, 600);
	// unit specs
	unit_spec_bias.bias = 0.1;

	excite_unit_spec.adapt_on = false;
	excite_unit_spec.noisy_act=true;
 	excite_unit_spec.act_thr=0.5;
 	excite_unit_spec.act_gain=100;
 	excite_unit_spec.tau_net=40;
 	excite_unit_spec.g_bar_e=1.0;
 	excite_unit_spec.g_bar_l=0.1;
 	excite_unit_spec.g_bar_i=0.40;

	inhib_unit_spec.adapt_on = false;
 	inhib_unit_spec.noisy_act = true;
 	inhib_unit_spec.act_thr = 0.4;
 	inhib_unit_spec.act_gain = 100;
 	inhib_unit_spec.tau_net = 20;
 	inhib_unit_spec.g_bar_e = 1.0;
 	inhib_unit_spec.g_bar_l = 0.1;
 	inhib_unit_spec.g_bar_i = 0.75;

	// layer spec


	// connection spec
	// unit.show_config();
	ffexcite_spec.proj="1to1";
	ffexcite_spec.rnd_type="uniform" ;
	ffexcite_spec.rnd_mean=0.25;
	ffexcite_spec.rnd_var=0.2;

	ffinhib_spec.proj="full";
	ffinhib_spec.rnd_type="gaussian" ;
	ffinhib_spec.rnd_mean=0.25;
	ffinhib_spec.rnd_var=0.2;

	fbinhib_spec.proj="full";
	fbinhib_spec.rnd_type="uniform" ;	
	fbinhib_spec.rnd_mean=0.25;	
	fbinhib_spec.rnd_var=0.2;	

	// inhib proj
	inhib_spec.proj="full";	
	inhib_spec.rnd_type="uniform" ;	
	inhib_spec.rnd_mean=0.5;	
	inhib_spec.rnd_var=0.f;	
	inhib_spec.inhib = true;
	
	inhibinhib_spec.proj="full";	
	inhibinhib_spec.rnd_type="uniform" ;	
	inhibinhib_spec.rnd_mean=0.2;	
	inhibinhib_spec.rnd_var=0.f;	

	input_layer = new Layer(numunits, new LayerSpec(false), excite_unit_spec, INPUT, "Input");
	inhib_layer = new Layer(2, new LayerSpec(false), unit_spec, HIDDEN, "Hidden");
	hidden_layer = new Layer(numunits, new LayerSpec(false), inhib_unit_spec, HIDDEN, "Output");

	IH_conn = new Connection(input_layer,  hidden_layer, ffexcite_spec);
	Ii_conn = new Connection(input_layer,  inhib_layer,  ffinhib_spec);
	Hi_conn = new Connection(hidden_layer, inhib_layer,  fbinhib_spec);
	iH_conn = new Connection(inhib_layer,  hidden_layer, inhib_spec);
	ii_conn = new Connection(inhib_layer,  inhib_layer,  inhibinhib_spec);

	Layer[] layers =  {input_layer, inhib_layer, hidden_layer};
	Connection[] conns = {IH_conn,
	Ii_conn,
	Hi_conn,
	iH_conn,
	ii_conn};
	netw = new Network(network_spec, layers, conns);

	netw.build();

}

void update(){
	// unit.add_excitatory(sig.getOutput());
	// unit.calculate_net_in();
	// println(sig.getOutput());
	// float[] inp = zeros(1);
	FloatList inpvals = new FloatList();
	inpvals.set(numunits-1, 0.0); // set dim of list
	inpvals.set((int)random(0, numunits), 0.5 * sig.getOutput());
	inputs.put("Input", inpvals);
	// inp[1] = random(0.475, 0.525);
  	// inp[2] = sig.getOutput()+0.25;
	// input_layer.add_excitatory(inp);
  	//input_layer.cycle("plus");	
  	// if(phase){
  	// 	input_layer.cycle("minus");
	// 	hidden_layer.cycle("minus");
	// 	unit.cycle("minus");
	// }
    // else{
  	// 	input_layer.cycle("plus");
	// 	hidden_layer.cycle("plus");
	// 	unit.cycle("plus");
	// }
	// phase = !phase;
	if(cyc++ % quart_num == 0)
		netw.set_inputs(inputs);
	netw.cycle();
  
  
  
	sig.tick();
	
  
	// IH_conn.cycle();
  	//HI_conn.cycle();
	//unit.show_config();
}

void draw(){
	update();
	background(51);
	//circle(height/2, width/2, 50);
	// pushMatrix();
	// translate(100,100);
	// drawTimeSeries(sig.getBuffer().array(), 2, 1, 0);
	// popMatrix();
	

	

	pushMatrix();
	float[][] tmp = zeros(3,numunits);
	tmp[0] = input_layer.getOutput();
	tmp[1][0] = inhib_layer.getOutput()[0];
	tmp[1][1] = inhib_layer.getOutput()[1];
	tmp[2] = hidden_layer.getOutput();
	translate(10,200);
	pushMatrix();
	rotate(-HALF_PI);
	drawColGrid(0,0, 40, multiply(200, tmp));
	popMatrix();
	
	popMatrix();
  	
	

}
