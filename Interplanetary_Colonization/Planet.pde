import java.util.Random;

class Planet {
    PlanetCell[][] cells; // Cells will be stored in a 2D array representing
                          // the bounding square of the circular planet.
                          // PlanetCells will be generated in a filled circle
                          // around the approximate center of the 2D array.
                          
    Planet(int centerX, int centerY, int radius) {
        // Generate PlanetCells.
        this.cells = new PlanetCell[2*radius - 1][2*radius - 1]; // Approximate bounding box of circle.
        
        // Create and fill a circle of PlanetCell objects in this.cells
        // ------------------------------------------------------------
        // This is done by comparing the Euclidean distance between 
        // each cell and the centerpoint and comparing it to the radius.
        for (int i = 0; i < this.cells.length; ++i) {
            int y = (centerY - (radius - 1)) + i; // Get y-coord of cell

            for (int j = 0; j < this.cells.length; ++j) {
                int x = (centerX - (radius - 1)) + j; // Get y-coord of cell
                
                // Check if distance from center <= radius.
                float distFromCenter = sqrt((float)pow(x - centerX, 2) + (float)pow(y - centerY, 2));
                if (x < 0 || y < 0 || x >= width || y >= width) {
                    // Don't simulate cells that are out of the bounds of the simulation.
                    this.cells[i][j] = null;
                } else if (distFromCenter <= radius) {
                    this.cells[i][j] = new PlanetCell(x, y, this);
                } else {
                    // This cell is not within the bounds of the circle.
                    this.cells[i][j] = null;
                }
            }
        }
    }
    
    int[] getCellCoords(PlanetCell cell) {
        // Grab the local indices (i, j) of a PlanetCell
        // in this planet. Returns null if not found.
        int[] out = {-1, -1};
        for (int i = 0; i < this.cells.length; ++i) {
            for (int j = 0; j < this.cells[i].length; ++j) {
                if (this.cells[i][j] == cell) {
                    out[0] = i;
                    out[1] = j;
                }
            }
        }
        
        if (out[0] != -1)
            return out;
        else
            return null;
    }
}

int N_PLANETCELL = 0; // Used to keep track of the number of PlanetCell instances.
class PlanetCell{
    Planet planet;
    int id;
    int x, y;
    float population;
    
    int[] shipmentInterval;                     // Counters for the approx. number of iterations between imports of each resources before shortages occur.
    float[] advFactors;                         // Production multipliers. A multiplier that is <1 introduces the need for imports.
    float[] resourceStockpile;
    float[] netChange = new float[N_RESOURCES]; // Tracks net output/consumption of each resource. Used to calculate imports.
    
    PlanetCell(int x, int y, Planet planet) {
        this.id = N_PLANETCELL++;

        this.x = x;
        this.y = y;
        this.planet = planet;

        this.population = 0;

        this.shipmentInterval = new int[N_RESOURCES];
        this.resourceStockpile = new float[N_RESOURCES];
        this.advFactors = new float[N_RESOURCES];        // Resource production multipliers.
        
        Random rng = new Random();
        for (int i = 0; i < N_RESOURCES; ++i) {
            // Initialize array fields.
            this.shipmentInterval[i] = 0;
            this.resourceStockpile[i] = 0;
            this.advFactors[i] = clamp((float)(PMULT_STDDEV*rng.nextGaussian() + PMULT_MEAN), 0, Float.MAX_VALUE);
        }
    }
    
    void updatePopulation() {
        // Population growth
        if (this.population < PLANETCELL_MAXPOP)
            this.population += POP_GROWTH_RATE*(1/ITERS_PER_YR)*this.population;
        else
            this.population = PLANETCELL_MAXPOP;
        
        // Find shortages, greatest shortage, & reset negative values to zero.
        float greatestShortage = 0;
        for (int i = 0; i < this.resourceStockpile.length; ++i) {
            if (this.resourceStockpile[i] < greatestShortage) {
                greatestShortage = this.resourceStockpile[i];
                this.resourceStockpile[i] = 0;
            }
        }
        
        // Population decline
        this.population += greatestShortage*(1/ITERS_PER_YR);
        
        // If population is under 1, round to 0
        if (this.population < 1)
            this.population = 0;
    }
    
    void emigrate() {
        // Travel to another nearby PlanetCell.
        // Only called if this.population > EMIGRATION_POP.
        // Check neighbours for any cells such that cell.population < EMIGRATION_POP.
        // If no such neighbours are found, random chance to stay or emigrate to a random PlanetCell.
        
        ArrayList<PlanetCell> neighbours = new ArrayList<PlanetCell>();
        
        // Search for empty cells from greatest to least priority locations.
        
        // 1. this PlanetCell's neighbours.
        int[] thisCoords = this.planet.getCellCoords(this);
        
        // Check this cell's Moore neighbourhood.
        for (int i = -1; i <= 1; ++i) {
            for (int j = -1; j <= 1; ++j) {
                try {
                    PlanetCell dest = this.planet.cells[thisCoords[0] + i][thisCoords[1] + j];
                    if (dest != null && dest.population < EMIGRATION_POP) {
                        neighbours.add(dest);
                    }                
                } catch (ArrayIndexOutOfBoundsException e) {
                    continue;
                }
            }
        }

        if (neighbours.size() > 0) {
            // Pick random neighbour.
            neighbours.get(int(random(neighbours.size()))).population += N_EMIGRANTS;
            return;
        }
        
        // 3. Percent chance to travel to another planet.
        if (random(0, 1) < INTER_EMIGRATION_CHANCE)
            this.launchColonyShip(planetCells[int(random(planetCells.length))]);
    }
    
    void updateResources() {
        for (int i = 0; i < this.resourceStockpile.length; ++i) {
            float change = (this.advFactors[i]*this.population - this.population)*(1/ITERS_PER_YR);
            
            this.resourceStockpile[i] += change;
            this.netChange[i] = change;
        }
    }
    
    void importResources() {
        // Must be called after this.updateResources(), or else this.netChange will have incorrect values.
        for (int i = 0; i < this.resourceStockpile.length; ++i) {
            shipmentInterval[i] -= 1; // Count down one iteration if no imports are necessary for resource i.
            if (this.netChange[i] < 0 && shipmentInterval[i] <= 0) {
                shipmentInterval[i] = floor(CargoShip.CAPACITY/abs(this.netChange[i])); // Compute number of iterations it takes to burn through one shipment.
                                                                                        // Reset shipmentInterval[i] to this value.
                
                int neededShipments = ceil(abs(this.netChange[i])/CargoShip.CAPACITY);
                for (PlanetCell sender : planetCells) {
                    if (sender.resourceStockpile[i] > CargoShip.CAPACITY) { // Check if there are sufficient resources.
                        sender.launchShipment(i, this);
                        neededShipments -= 1;
                    }
                    
                    if (neededShipments == 0) // POTENTIAL BUG: If neededShipments starts at 0, this won't run.
                        break;                //                this shouldn't happen because of the ceil() in neededShipments.
                }
            }
        }
    }
    
    void drawCell() {
        if (this.population > 0) {
            float colorVal = 128 + 128*this.population/PLANETCELL_MAXPOP;
            fill(colorVal, colorVal, colorVal/2);
        } else {
            fill(140,48,8);
        }
        
        rect(this.x*CELL_WIDTH, this.y*CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT);
    }
    
    void launchShipment(int resourceIdx, PlanetCell receiver) {
        // NOTE: A cell should send at most one shipment to a receiver per iteration.
      
        // Set aside resources for shipment.
        this.resourceStockpile[resourceIdx] -= CargoShip.CAPACITY;
        
        // Instantiate CargoShip instance.
        cargoShips.add(new CargoShip(resourceIdx, this, receiver));
    }
    
    void launchColonyShip(PlanetCell receiver) {
        this.population -= N_EMIGRANTS;
        cargoShips.add(new ColonyShip(this, receiver));
    }
    
    void update() {
        if (this.population > 0) { // Don't update uninhabited cells.
            this.updatePopulation();
            
            if (this.population > EMIGRATION_POP && random(0, 1) < INTRA_EMIGRATION_CHANCE) {
                this.population -= N_EMIGRANTS;
                this.emigrate();
            }
            
            this.updateResources();
            this.importResources();
        }
        this.drawCell();
    }
}
