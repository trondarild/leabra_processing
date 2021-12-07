//
//
//
String[] lognames = {};
UnitSpec spec = new UnitSpec();
Unit unit = new Unit(spec, INPUT, lognames);
SignalGenerator sig = new SignalGenerator(eTickSquare, 50, 25, 100);

void setup(){
	size(400, 400);
  unit.show_config();
}

void update(){
	unit.add_excitatory(sig.getOutput());
	unit.calculate_net_in();
	//println(sig.getOutput());
	sig.tick();
	unit.cycle("minus");
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
	

}
