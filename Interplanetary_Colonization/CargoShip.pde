static final float CARGOSHIP_CAPACITY = 1000;
static final float CARGOSHIP_SPEED = 2;

class CargoShip {
    static final float CAPACITY = CARGOSHIP_CAPACITY;
    static final float SPEED = CARGOSHIP_SPEED;

    int x, y;
    int resourceIdx;
    Vec2f pos, destPos;
    PlanetCell dest;
    
    CargoShip(int resourceIdx, PlanetCell origin, PlanetCell dest) {
        this.resourceIdx = resourceIdx;
        this.dest = dest;
        this.destPos = new Vec2f(dest.x, dest.y);
        this.pos = new Vec2f(origin.x, origin.y);
        
        this.x = (int)this.pos.x;
        this.y = (int)this.pos.y;
    }
    
    void land() {
          // Transfer resources to destination upon arrival.
          // Move object reference to landedCargoShips for deletion from cargoShips.
          landedCargoShips.add(this);
          this.dest.resourceStockpile[this.resourceIdx] += CargoShip.CAPACITY;
    }
    
    void update() {
        // Update position.
        Vec2f dir = destPos.sub(pos).direction();
        pos = pos.add(dir.cMult(CargoShip.SPEED));
        
        // Clamp pos to destPos values so that the CargoShip doesn't overshoot.
        if (dir.x >= 0)
            this.x = (int)clamp(round(this.pos.x), 0, this.destPos.x);
        else
            this.x = (int)clamp(round(this.pos.x), this.destPos.x, GRID_WIDTH);
        if (dir.y >= 0)
            this.y = (int)clamp(round(this.pos.y), 0, this.destPos.y);
        else
            this.y = (int)clamp(round(this.pos.y), this.destPos.y, GRID_WIDTH);
        
        if (this.x == destPos.x && this.y == destPos.y) {
            this.land();
        }
        
        // Draw CargoShip object
        this.draw();
    }
    
    void draw() {
        fill(RESOURCE_COLORS[resourceIdx]);
        rect(this.x*CELL_WIDTH + CELL_WIDTH/4, this.y*CELL_HEIGHT + CELL_WIDTH/4, CELL_WIDTH/2, CELL_HEIGHT/2);
    }
}

class ColonyShip extends CargoShip {
    // Extends CargoShip so that both CargoShip and ColonyShip can be
    // stored in the global ArrayList<CargoShip>.
  
    ColonyShip(PlanetCell origin, PlanetCell dest) {
        super(-1, origin, dest);
    }
    
    void land() {
        // CargoShip.land() is overriden because ColonyShips add population rather than resources.
        landedCargoShips.add(this);
        this.dest.population += N_EMIGRANTS;
    }
    
    void draw() {
        fill(200, 200, 100);
        rect(this.x*CELL_WIDTH, this.y*CELL_HEIGHT + CELL_WIDTH, CELL_WIDTH, CELL_HEIGHT);
    }
}
