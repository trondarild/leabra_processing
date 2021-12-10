//
//
//
import java.util.HashMap;
import java.util.Map;



TestHiddenLayer test = new TestHiddenLayer();


void setup(){
	size(400, 600);
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
