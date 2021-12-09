//
//
//
import java.util.HashMap;
import java.util.Map;



String[] lognames = {};
SignalGenerator sig = new SignalGenerator(eTickSquare, 50, 40, 100);

// units
UnitSpec unit_spec = new UnitSpec();
// Unit unit = new Unit(spec, INPUT, lognames);

// layers
Layer sense_layer = new Layer(1, new LayerSpec(), unit_spec, INPUT, "Input");
Layer input_layer = new Layer(3, new LayerSpec(), unit_spec, HIDDEN, "Hidden");
Layer hidden_layer = new Layer(3, new LayerSpec(), unit_spec, HIDDEN, "Output");

// connections
ConnectionSpec ffexcite_spec  = new ConnectionSpec();
Connection SI_conn = new Connection(sense_layer, input_layer, ffexcite_spec);
Connection IH_conn = new Connection(input_layer,  hidden_layer, ffexcite_spec);
Connection HI_conn = new Connection(hidden_layer,  input_layer, ffexcite_spec);

// network
int quart_num = 10;
NetworkSpec network_spec = new NetworkSpec(quart_num);
Layer[] layers =  {sense_layer, input_layer, hidden_layer};
Connection[] conns = {SI_conn, IH_conn};
Network netw = new Network(network_spec, layers, conns);

Map<String, FloatList> inputs = new HashMap<String, FloatList>();

boolean phase = true;
int cyc = 0;

void setup(){
	size(400, 600);
	// unit.show_config();
	ffexcite_spec.proj="full";
	ffexcite_spec.rnd_type="gaussian" ;
	ffexcite_spec.rnd_mean=0.25;
	ffexcite_spec.rnd_var=0.52;
	netw.build();

}

void update(){
	// unit.add_excitatory(sig.getOutput());
	// unit.calculate_net_in();
	// println(sig.getOutput());
	// float[] inp = zeros(1);
	FloatList inpvals = new FloatList();
	inpvals.append(sig.getOutput());
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
	translate(0, -50);
	pushMatrix();
	translate(10, 100);
	drawTimeSeries(sense_layer.getBuffers()[0].array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	translate(100,100);
	drawTimeSeries(input_layer.getBuffers()[2].array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	translate(100,200);
	drawTimeSeries(input_layer.getBuffers()[1].array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	translate(100,300);
	drawTimeSeries(input_layer.getBuffers()[0].array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	translate(200,100);
	drawTimeSeries(hidden_layer.getBuffers()[2].array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	translate(200,200);
	drawTimeSeries(hidden_layer.getBuffers()[1].array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	translate(200,300);
	drawTimeSeries(hidden_layer.getBuffers()[0].array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	float[][] tmp = zeros(3,3);
	tmp[0][1] = sense_layer.getOutput()[0];
	tmp[1] = input_layer.getOutput();
	tmp[2] = hidden_layer.getOutput();
	translate(10,650);
	pushMatrix();
	rotate(-HALF_PI);
	drawColGrid(0,0, 40, multiply(200, tmp));
	popMatrix();
	
	popMatrix();
  	
	

}
