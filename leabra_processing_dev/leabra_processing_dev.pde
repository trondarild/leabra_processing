//
//
//
import java.util.HashMap;
import java.util.Map;



// TestHiddenLayer test = new TestHiddenLayer();
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
TestDopa test = new TestDopa();

void setup(){
	size(600, 1000);
	// unit.show_config();
  frameRate(60);

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
