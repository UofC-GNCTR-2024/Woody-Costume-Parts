/*Fillet modules*/ {
    module myfillet(r=1.0,steps=3,include=true) {
      if(include) for (k=[0:$children-1]) {
        children(k);
      }
      for (i=[0:$children-2] ) {
        for(j=[i+1:$children-1] ) {
        fillet_two(r=r,steps=steps) {
          children(i);
          children(j);
          intersection() {
            children(i);
            children(j);
          }
        }
        }
      }
    }

    module fillet_two(r=1.0,steps=3) {
      for(step=[1:steps]) {
        hull() {
           render() intersection() {
            children(0);
            offset_3d(r=r*step/steps) children(2);
          }
           render() intersection() {
            children(1);
            offset_3d(r=r*(steps-step+1)/steps) children(2);
          }
        }
      }
    }

    module offset_3d(r=1.0) {
      for(k=[0:$children-1]) minkowski() {
        children(k);
        sphere(r=r,$fn=8);
      }
    }

}
