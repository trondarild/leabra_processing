//
//
//
String[] lognames = {};
UnitSpec spec = new UnitSpec();
Unit unit = new Unit(spec, INPUT, lognames);
SignalGenerator sig = new SignalGenerator();

void setup(){
	size(300, 300);
  unit.show_config();
}

void draw(){
	background(51);
	circle(height/2, width/2, 50);
}
