class CargoShip {
    static final int CAPACITY = CARGOSHIP_CAPACITY;
    static final float SPEED  = CARGOSHIP_SPEED;

    Resource resourceType;
    Vec2f pos, destPos;
    PlanetCell dest;

    CargoShip(Resource resourceType, PlanetCell origin, PlanetCell dest) {
        this.resourceType = resourceType;
        this.dest = dest;
        //this.destPos = Vec2f(dest.x, dest.y);
        //this.pos = Vec2f(origin.x, origin.y);
    }

    void update() {
        // TODO: Implement this.
    }
}