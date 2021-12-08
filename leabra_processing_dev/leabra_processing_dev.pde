//
//
//
String[] lognames = {};
UnitSpec spec = new UnitSpec();
Unit unit = new Unit(spec, INPUT, lognames);
Layer input_layer = new Layer(2, new LayerSpec(), spec, INPUT, "Input");
Layer hidden_layer = new Layer(2, new LayerSpec(), spec, HIDDEN, "Hidden");
SignalGenerator sig = new SignalGenerator(eTickSquare, 50, 40, 100);

ConnectionSpec ffexcite_spec  = new ConnectionSpec();


Connection IH_conn = new Connection(input_layer,  hidden_layer, ffexcite_spec);

void setup(){
	size(400, 400);
	// unit.show_config();
	ffexcite_spec.proj="full";
	ffexcite_spec.rnd_type="uniform" ;
	ffexcite_spec.rnd_mean=0.25;
	ffexcite_spec.rnd_var=0.2;

}

void update(){
	unit.add_excitatory(sig.getOutput());
	unit.calculate_net_in();
	//println(sig.getOutput());
	float[] inp = zeros(2);
	inp[0] = sig.getOutput();
	inp[1] = random(1.0);
	input_layer.add_excitatory(inp);
	input_layer.cycle("minus");
	sig.tick();
	unit.cycle("minus");
	IH_conn.cycle();
	//unit.show_config();
}

void draw(){
	update();
	background(51);
	//circle(height/2, width/2, 50);
	pushMatrix();
	translate(100,100);
	drawTimeSeries(sig.getBuffer().array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	translate(100,200);
	drawTimeSeries(unit.getBuffer().array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	translate(200,100);
	drawTimeSeries(input_layer.getBuffers()[0].array(), 2, 1, 0);
	popMatrix();

	pushMatrix();
	translate(200,200);
	drawTimeSeries(input_layer.getBuffers()[1].array(), 2, 1, 0);
	popMatrix();
	

}
