//
//
//
import java.util.HashMap;
import java.util.Map;



// TestHiddenLayer test = new TestHiddenLayer();
// TestInhibition test = new TestInhibition();
TestTaskNet test = new TestTaskNet();

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
