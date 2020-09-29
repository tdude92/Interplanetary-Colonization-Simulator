// CONSTANTS
final int FRAME_RATE = 30;
final int GRID_WIDTH = 100;
final int PLANET_MIN_R = 2;
final int PLANET_MAX_R = 4;                 // Minimum and maximum radius of a planet.
final int N_PLANETS = 10;                   // Number of planets to generate.
final int N_ADV_SHIFTS = 3;                // Number of times advantage factor values are shuffled. Try to keep between 0 & 5.
final float POP_GROWTH_RATE = 0.01;         // Yearly growth rate of PlanetCells.
final float STARTING_EFFICIENCY = 1;
final float ITERS_PER_YR = 10;             // Iterations per year.
final float PLANETCELL_MAXPOP = 1000;       // Max number of population units per PlanetCell.
static final float CARGOSHIP_CAPACITY = 100;   // Number of resource units a CargoShip can carry.
static final float CARGOSHIP_SPEED = 1;     // The number of cells a CargoShip can travel in one loop iteration.
final color[] RESOURCE_COLORS = {
    color(128, 128, 128),
    color(128, 128, 128)
    //color(0, 255, 0), // FOOD
    //color(0, 0, 255), // WATER
    //color(0, 255, 255), // ENERGY
    //color(255, 0, 0)  // RAW_MATERIALS
};
final int N_RESOURCES = RESOURCE_COLORS.length;


// Global Variables
ArrayList<CargoShip> cargoShips = new ArrayList<CargoShip>();       // Track each CargoShip
ArrayList<CargoShip> landedCargoShips = new ArrayList<CargoShip>(); // Track landed ships for deletion.
Planet[] planets = new Planet[N_PLANETS];                        // Store all planets.
int N_PLANETCELL = 0;                                            // Track number of PlanetCell objects.
float CELL_WIDTH, CELL_HEIGHT;

PlanetCell[] planetCells;                                        // Store all PlanetCells. Used to grab PlanetCells with an ID.

// Graphable global vars.

// UTILITY FUNCTIONS
float clamp(float x, float min, float max) {
    return max(min(x, max), min);
}

void updateCargoShips() {
    for (CargoShip cs : cargoShips)
        cs.update();
    
    for (CargoShip cs : landedCargoShips)
        cargoShips.remove(cs);
    
    landedCargoShips.clear();
}

void setup() {
    size(800, 800);
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
        planets[i].seed();
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
    
    // TODO: Update .seed() to only seed a couple cells?
    //planets[0].seed();
}

void draw() {
    background(7, 10, 20);
    noStroke();
    updateCargoShips();
    for (Planet planet : planets)
        planet.update();

    println(planets[4].cells[2][2].population);
    printArray(planets[4].cells[2][2].resourceStockpile);
    //println(N_PLANETCELL);

    println();
}
