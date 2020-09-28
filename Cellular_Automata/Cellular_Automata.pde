// CONSTANTS
final int FRAME_RATE = 30;
final int GRID_WIDTH = 400;
final int PLANET_MIN_R = 3;
final int PLANET_MAX_R = 6;                 // Minimum and maximum radius of a planet.
final int N_PLANETS = 40;                   // Number of planets to generate.
final int N_ADV_SHIFTS = 1;                // Number of times advantage factor values are shuffled. Try to keep between 0 & 5.
final float TAX_RATE = 0.1;                 // PlanetCell tax revenue = population*TAX_RATE
final float POP_GROWTH_RATE = 0.01;         // Yearly growth rate of PlanetCells.
final float ITERS_PER_YR = 2;             // Iterations per year.
final float PLANETCELL_MAXPOP = 1000;       // Max number of population units per PlanetCell.
static final float CARGOSHIP_CAPACITY = 10;   // Number of resource units a CargoShip can carry.
static final float CARGOSHIP_SPEED = 1;     // The number of cells a CargoShip can travel in one loop iteration.

// Global Variables
ArrayList<CargoShip> cargoShips = new ArrayList<CargoShip>();    // Track each CargoShip
Planet[] planets = new Planet[N_PLANETS];                        // Store all planets.
int N_PLANETCELL = 0;                                            // Track number of PlanetCell objects.
float CELL_WIDTH, CELL_HEIGHT;

PlanetCell[] planetCells;                                        // Store all PlanetCells. Used to grab PlanetCells with an ID.
float totalCash = 0;                                             // Total money in the universe.
float[] totalStock = new float[Resource.COUNT];                  // Total resource for sale on the market.
float[] marketPrices = new float[Resource.COUNT];

// UTILITY FUNCTIONS
float clamp(float x, float min, float max) {
    return max(min(x, max), min);
}

void computeMarketPrices() {
    // TODO: Write comment explaining this.
    for (int i = 0; i < Resource.COUNT; ++i) {
        if (totalStock[i] > 0) {
            marketPrices[i] = (totalCash/5) / totalStock[i];
            marketPrices[i] *= CARGOSHIP_CAPACITY; // So that marketPrices price per shipment.
        } else {
            marketPrices[i] = Float.NaN;
        }
    }

    // Reset values of totalCash and totalStock
    // since their values are calculated by
    // finding the sum of the total cash and resource
    // stock of each PlanetCell.
    totalCash = 0;
    for (int i = 0; i < Resource.COUNT; ++i)
        totalStock[i] = 0;
}

void setup() {
    size(800, 800);
    background(7, 10, 20);
    frameRate(FRAME_RATE);

    // Compute cell dimensions.
    CELL_WIDTH = (float)width/GRID_WIDTH;
    CELL_HEIGHT = (float)height/GRID_WIDTH;

    // Generate planets.
    int[][] planetCoords = new int[N_PLANETS][2];
    for (int i = 0; i < N_PLANETS; ++i) {
        int x = int(random(0, GRID_WIDTH));
        int y = int(random(0, GRID_WIDTH));

        // Store position into planetCoords.
        planetCoords[i][0] = x;
        planetCoords[i][1] = y;
    }
    for (int i = 0; i < N_PLANETS; ++i) {
        int x = planetCoords[i][0];
        int y = planetCoords[i][1];
        
        // Find distance to closest planet.
        // The maximum radius of this planet will be
        // half of this distance to ensure that there
        // are no overlaps.
        int minDist = Integer.MAX_VALUE;
        for (int j = 0; j < N_PLANETS; ++j) {
            // Check distance to every other planet to find smallest distance.
            if (j != i) {
                int x0 = planetCoords[j][0];
                int y0 = planetCoords[j][1];

                int dist = int(sqrt(pow(x - x0, 2) + pow(y - y0, 2)));
                if (dist < minDist)
                    minDist = dist;
            }
        }
        int radius = (int)clamp(random(PLANET_MIN_R, minDist/2), PLANET_MIN_R, PLANET_MAX_R);
        planets[i] = new Planet(x, y, radius);
    }

    // Initialize planetCells
    planetCells = new PlanetCell[N_PLANETCELL];
    for (Planet planet : planets) {
        for (int i = 0; i < planet.cells.length; ++i) {
            for (int j = 0; j < planet.cells[i].length; ++j) {
                PlanetCell cell = planet.cells[i][j];
                if (cell != null)
                    planetCells[cell.id] = cell;
            }
        }
    }

    // Initialize totalStock
    for (int i = 0; i < Resource.COUNT; ++i)
        totalStock[i] = 0;
    
    // TODO: Update .seed() to only seed a couple cells?
    planets[0].seed();
}

void draw() {
    //println(N_PLANETCELL);
    noStroke();
    for (Planet planet : planets)
        planet.update();
    //println(totalCash);
    //printArray(totalStock);
    //println();
    
    computeMarketPrices();
    //printArray(marketPrices);
    //println();

    //println(planets[0].cells[2][2].population);
    //printArray(planets[0].cells[2][2].resourceStockpile);
    //println();

    //printArray(planets[0].cells[2][2].incomingShipments);
    //println(planets[0].cells[2][2].cash);
    //println();
}
