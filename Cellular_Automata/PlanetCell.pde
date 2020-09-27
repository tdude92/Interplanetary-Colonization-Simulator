class Planet {
    boolean populated;    // True if every PlanetCell on a planet object is populated.
    float[] advFactors;
    PlanetCell[][] cells; // Cells will be stored in a 2D array representing
                          // the bounding box of the circular planet.
                          // PlanetCells will be generated in a filled circle
                          // around the center of the 2D array.

    Planet(int centerX, int centerY, int radius) {
        // 1. Generate PlanetCells.
        this.cells = new PlanetCell[2*radius - 1][2*radius - 1]; // Approximate bounding box of circle.
        
        // Create and fill a circle of PlanetCell objects in this.cells
        // ------------------------------------------------------------
        // This is done by comparing the Euclidean distance between 
        // each cell and the centerpoint and comparing it to the radius.
        for (int i = 0; i < this.cells.length; ++i) {
            int x = (centerX - radius + 1) + i; // Get x-coord of cell

            for (int j = 0; j < this.cells.length; ++j) {
                int y = (centerY - radius + 1) + j; // Get y-coord of cell
                
                // Check if distance from center <= radius.
                float distFromCenter = sqrt((float)pow(x - centerX, 2) + (float)pow(y - centerY, 2));
                if (x < 0 || y < 0 || x >= width || y >= width) {
                    // Don't simulate cells that are out of the bounds of the simulation.
                    this.cells[j][i] = null;
                } else if (distFromCenter <= radius) {
                    this.cells[j][i] = new PlanetCell(x, y, this);
                } else {
                    // This cell is not within the bounds of the circle.
                    this.cells[j][i] = null;
                }
            }
        }

        // 2. Initialize advantage factors.
    }

    void update() {
        // TODO: Implement Planet update method.
        for (PlanetCell[] row : this.cells) {
            for (PlanetCell cell : row) {
                if (cell != null)
                    cell.draw();
            }
        }
    }
}

class PlanetCell {
    Planet planet;
    int x, y;
    int pop;
    int cash;
    int[] resourceStockpile;
    int[] incomingShipments;
    ArrayList<BuyRequest> launchBacklog;

    PlanetCell(int x, int y, Planet planet) {
        this.x = x;
        this.y = y;
        this.planet = planet;

        this.pop = 0;
        this.cash = 0;
        this.resourceStockpile = new int[Resource.COUNT];
        this.incomingShipments = new int[Resource.COUNT];
        this.launchBacklog = new ArrayList<BuyRequest>();

        N_PLANETCELL++;
    }

    // TODO: Implement methods.
    void update() {}
    void scheduleLaunch() {}
    void getCash() {}

    void draw() {
        // TODO: Change colour brightness based on population.
        fill(148, 91, 71);
        rect(this.x*CELL_WIDTH, this.y*CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT);
    }
}