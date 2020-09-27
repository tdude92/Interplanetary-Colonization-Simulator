// CONSTANTS
final int gridWidth = 400;
final int PLANET_MIN_R = 4;
final int PLANET_MAX_R = 7;                // Minimum and maximum radius of a planet.
final int N_PLANETS = 30;                    // Number of planets to generate.
final int RM2CASH_RATE = 2;                 // Exchange rate of raw materials against currency.
static final int CARGOSHIP_CAPACITY = 10;   // Number of resource units a CargoShip can carry.
static final float CARGOSHIP_SPEED = 1;     // The number of cells a CargoShip can travel in one loop iteration.

// Global Variables
ArrayList<CargoShip> cargoShips = new ArrayList<CargoShip>();   // Track each CargoShip
Planet[] planets = new Planet[N_PLANETS];                       // Store all planets.
float[][] priceTable;                                           // Track sell prices from every seller.
int N_PLANETCELL = 0;                                           // Track number of PlanetCell objects.
float CELL_WIDTH, CELL_HEIGHT;

void setup() {
    size(800, 800);
    background(0);

    // Compute cell dimensions.
    CELL_WIDTH = (float)width/gridWidth;
    CELL_HEIGHT = (float)height/gridWidth;

    // Generate planets.
    int[][] planetCoords = new int[N_PLANETS][2];
    for (int i = 0; i < N_PLANETS; ++i) {
        int x = int(random(0, gridWidth));
        int y = int(random(0, gridWidth));

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
        int radius = clamp(random(PLANET_MIN_R, minDist/2), PLANET_MIN_R, PLANET_MAX_R);
        planets[i] = new Planet(x, y, radius);
    }
    noLoop();
}

void draw() {
    noStroke();
    for (Planet planet : planets)
        planet.update();
}
