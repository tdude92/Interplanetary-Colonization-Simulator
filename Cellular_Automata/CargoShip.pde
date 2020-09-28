class CargoShip {
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

    void update() {
        // Update position.
        Vec2f dir = destPos.sub(pos).direction();
        pos = pos.add(dir.cMult(CARGOSHIP_SPEED));
        
        // Clamp pos to destPos values so that the CargoShip doesn't overshoot.
        if (dir.x >= 0)
            this.x = (int)clamp(round(this.pos.x), 0, this.destPos.x);
        else
            this.x = (int)clamp(round(this.pos.x), this.destPos.x, GRID_WIDTH);
        if (dir.y >= 0)
            this.y = (int)clamp(round(this.pos.y), 0, this.destPos.y);
        else
            this.y = (int)clamp(round(this.pos.y), this.destPos.y, GRID_WIDTH);
        
        // Transfer resources to destination upon arrival.
        // Move object reference to landedCargoShips for deletion from cargoShips.
        if (this.x == destPos.x && this.y == destPos.y) {
            landedCargoShips.add(this);
            this.dest.resourceStockpile[this.resourceIdx] += CARGOSHIP_CAPACITY;
        }
        
        // Draw CargoShip object
        this.draw();
    }
    
    void draw() {
        fill(RESOURCE_COLORS[this.resourceIdx]);
        rect(this.x*CELL_WIDTH, this.y*CELL_HEIGHT, CELL_WIDTH/2, CELL_HEIGHT/2);
    }
}
