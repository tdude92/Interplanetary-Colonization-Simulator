// CONSTANTS
final int N_PLANETS = 5;                    // Number of planets to generate.
final int RM2CASH_RATE = 2;                 // Exchange rate of raw materials against currency.
static final int CARGOSHIP_CAPACITY = 10;   // Number of resource units a CargoShip can carry.
static final float CARGOSHIP_SPEED = 1;     // The number of cells a CargoShip can travel in one loop iteration.

// Global Variables
ArrayList<CargoShip> cargoShips = new ArrayList<CargoShip>();   // Track each CargoShip
float[][] priceTable;                                           // Track sell prices from every seller.

void setup() {
    CargoShip x = new CargoShip(Resource.FOOD, null, null);
    println(x.SPEED);
}
