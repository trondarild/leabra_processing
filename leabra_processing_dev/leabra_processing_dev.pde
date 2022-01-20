//
// main branch
//
import java.util.HashMap;
import java.util.Map;

import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; 

MidiBus myBus; 
int midiDevice  = 0;

//TestHiddenLayer test = new TestHiddenLayer();
//TestInhibition test = new TestInhibition();
//TestTaskNet test = new TestTaskNet();
//TestForceActivity test = new TestForceActivity();
//TestDendriteConnection test = new TestDendriteConnection();
//TestAutoActivity test = new TestAutoActivity();
//TestCtxPredError test = new TestCtxPredError();
//TestRandomAssociator test = new TestRandomAssociator();
//TestCtxRuleInh test = new TestCtxRuleInh();
//TestEnsnRecruitment test = new TestEnsnRecruitment();
//TestPartialConnection test = new TestPartialConnection();
//TestDopa test = new TestDopa();
//TestIntegrator test = new TestIntegrator();
//TestReservoir test = new TestReservoir();
//TestDopaReservoir test = new TestDopaReservoir();
//TestPopulationCode test = new TestPopulationCode();
//TestSimpleAssociation test = new TestSimpleAssociation();
TestHiddenAssociation test = new TestHiddenAssociation();

void setup(){
	size(600, 1000);
	// unit.show_config();
  frameRate(60);
  MidiBus.list(); 
  myBus = new MidiBus(this, midiDevice, 1); 

}

void update(){
	test.tick();
}

void draw(){
	update();
	background(51);
	
	test.draw();
}

void keyPressed() {
  // if (key == ' ') {
  //   test.setInput(1.0);
  // }
  test.handleKeyDown(key); 
}

void keyReleased() {
  // if(key== ' ')
  //   test.setInput(0.0);
  test.handleKeyUp(key);
}

void midiMessage(MidiMessage message, long timestamp, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);

  test.handleMidi(note, vel);
  /* if (vel > 0 ) {
   currentColor = vel*2;
  }
  
  float valx = map(vel, 0, 128, 0, width);
  float valy = map(vel, 0, 128, 0, height);
  float col = map(vel, 0, 129, 0, 255);
  
  if(note==1){
    x=(int)valx;
  }
  if(note==2){
    y=(int)valy;
  }
  if(note==84)
    ellipse_col = (int)col; */
}
