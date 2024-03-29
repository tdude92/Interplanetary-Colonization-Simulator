// Used for computing CargoShip movement.
class Vec2f {
    float x, y;
    
    Vec2f(Vec2f v) {
        this.x = v.x;
        this.y = v.y;
    }
    Vec2f(float x, float y) {
        this.x = x;
        this.y = y;
    }
    
    float magnitude() {
        return sqrt(pow(x, 2) + pow(y, 2));
    }

    Vec2f direction() {
        return new Vec2f(this.cMult(1/this.magnitude()));
    }

    Vec2f add(Vec2f v) {
        return new Vec2f(this.x + v.x, this.y + v.y);
    }
    
    Vec2f sub(Vec2f v) {
        return new Vec2f(this.x - v.x, this.y - v.y);
    }
    
    Vec2f mult(Vec2f v) { // Element-wise multiplication
        return new Vec2f(v.x*this.x, v.y*this.y);
    }
    
    Vec2f cMult(float c) { // Scalar multiplication
        return new Vec2f(c*this.x, c*this.y);
    }
}
