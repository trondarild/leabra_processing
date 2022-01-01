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
TestCtxPredError test = new TestCtxPredError();

void setup(){
	size(600, 1000);
	// unit.show_config();

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
