// SHARING IS CARING!

// CONSTANTS
final int FRAME_RATE = 30;
final int GRID_WIDTH = 400;
final int PLANET_MIN_R = 2;                  // Minimum radius
final int PLANET_MAX_R = 7;                  // Maximum radius
final int N_PLANETS = 20;
final int EFFICIENCY_VARIATIONS = 4;         // Number of times to shuffle around production multiplier values (Higher value means PlanetCells are more varied in output multipliers).
final float POP_GROWTH_RATE = 0.1;           // Per year
final float STARTING_EFFICIENCY = 1.1;       // The starting value for production multipliers before applying swaps (from EFFICIENCY_VARIATIONS)
final float ITERS_PER_YR = 4;                // How many iterations amounts to a year.
final float PLANETCELL_MAXPOP = 1000;
final float EMIGRATION_POP = 300;            // Minimum population of a PlanetCell for emigration to occur.
final float N_EMIGRANTS = 20;                // Number of emigrants per ColonyShip
final float INTRA_EMIGRATION_CHANCE = 0.05;  // Chance for intraplanetary emigration.
final float INTER_EMIGRATION_CHANCE = 0.005; // Chance for interplanetary emigration to occur if intraplanetery emigration fails (due to every cell being populated)
final color[] RESOURCE_COLORS = {            
    color(0, 128, 0), // FOOD
    color(0, 0, 128), // WATER
    color(0, 128, 128), // ENERGY
    color(128, 0, 0)  // RAW_MATERIALS
};
final int N_RESOURCES = RESOURCE_COLORS.length;

// Global Variables
long ITER_CTR = 0; // TODO: DELETE THIS
float CELL_WIDTH, CELL_HEIGHT;
ArrayList<CargoShip> cargoShips = new ArrayList<CargoShip>();
ArrayList<CargoShip> landedCargoShips = new ArrayList<CargoShip>();  // List of CargoShips to delete after updating each element of cargoShips
Planet[] planets = new Planet[N_PLANETS];
PlanetCell[] planetCells;

// Utility functions
float clamp(float x, float min, float max) {
    // Clamp x between min and max.
    return max(min(x, max), min);
}

void seedMooreNeighbourhood(PlanetCell[] cells) {
    // Add population to a PlanetCell and its Moore neighbourhood.
    PlanetCell center = cells[int(random(N_PLANETCELL))];
    Planet planet = center.planet;
    
    int[] centerCoords = planet.getCellCoords(center);
    
    for (int i = -1; i <= 1; ++i) {
        for (int j = -1; j <= 1; ++j) {
            try {
                planet.cells[centerCoords[0] + i][centerCoords[1] + j].population = random(50, 400);
            } catch (Exception e) {
                continue;
            }
        }
    }
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
        // will be minimal overlaps.
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

    // Initialize planetCells array
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
    seedMooreNeighbourhood(planetCells); // Add population to some cells.
}

void draw() {
    background(7, 10, 20);
    noStroke();
    
    updateCargoShips();
    for (PlanetCell cell : planetCells)
        cell.update();
}
