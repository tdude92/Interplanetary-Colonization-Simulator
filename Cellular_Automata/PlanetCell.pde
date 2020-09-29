// TODO: Determine planet radius for generation.

class Planet {
    boolean populated;    // True if every PlanetCell on a planet object is populated.
    PlanetCell[][] cells; // Cells will be stored in a 2D array representing
                          // the bounding box of the circular planet.
                          // PlanetCells will be generated in a filled circle
                          // around the center of the 2D array.

    Planet(int centerX, int centerY, int radius) {
        // Generate PlanetCells.
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

        this.populated = false;
    }

    void seed() {
        // Add population to planet.
        for (int i = 0; i < this.cells.length; ++i) {
            for (int j = 0; j < this.cells[i].length; ++j) {
                PlanetCell cell = this.cells[i][j];
                if (cell != null) {
                    cell.population += random(20, 500);
                }
            }
        }
    }

    void update() {
        for (PlanetCell[] row : this.cells) {
            for (PlanetCell cell : row) {
                if (cell != null)
                    cell.update();
            }
        }
    }
}

class PlanetCell {
    Planet planet;
    int id;
    int x, y;
    float population;
    float[] advFactors; // Advantage factors.
    float[] resourceStockpile;
    ArrayList<BuyRequest> launchBacklog = new ArrayList<BuyRequest>();

    PlanetCell(int x, int y, Planet planet) {
        this.id = N_PLANETCELL++;


        this.x = x;
        this.y = y;
        this.planet = planet;

        this.population = 0;

        this.resourceStockpile = new float[N_RESOURCES];
        this.advFactors = new float[N_RESOURCES];        // Resource production multipliers.
        for (int i = 0; i < N_RESOURCES; ++i) {
            // Initialize array fields.
            this.resourceStockpile[i] = 0;
            this.advFactors[i] = STARTING_EFFICIENCY;
        }

        // Set advantage factors.
        for (int i = 0; i < N_ADV_SHIFTS; ++i) {
            int res1;
            int res2 = int(random(0, N_RESOURCES));

            do {
                // Sample a resource index until res1 != res2.
                res1 = int(random(0, N_RESOURCES));
            } while (res1 == res2);

            // A population unit is able to provide for itself if it can produce
            // one of each resource (or an equivalent amount that can be traded).
            // By initializing all factors to 1 and not increasing or decreasing
            // the total sum of advFactors, we ensure that on unit is always able
            // to produce sufficient resources.
            this.advFactors[res1] -= 0.2;
            this.advFactors[res2] += 0.2;
        }
    }

    void update() {
        if (this.population > 0) { // Don't update uninhabited cells
            // 1. Apply natural disaster/innovation effects.
            
            // 2. Update population
            // Population growth
            if (this.population < 1000)
                this.population += POP_GROWTH_RATE*(1/ITERS_PER_YR)*this.population;
            else
                this.population = 1000;

            // Find shortages & greatest shortage & reset values to zero.
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

            // 3. Calculate net change in resource stockpiles and place buy requests.
            for (int i = 0; i < this.resourceStockpile.length; ++i) {
                float change = (this.advFactors[i]*this.population - this.population)*(1/ITERS_PER_YR);
                this.resourceStockpile[i] += change;
                
                if (change < 0) {
                    // Import goods to relieve shortages.
                    int neededShipments = ceil(abs(change)/CARGOSHIP_CAPACITY);
                    for (PlanetCell sender : planetCells) {
                        if (sender.resourceStockpile[i] > CARGOSHIP_CAPACITY) { // Must be able to send at least one shipment.
                            int nShipments = int(sender.resourceStockpile[i]/CARGOSHIP_CAPACITY);

                            // Make sure this object is only requesting as much as it needs.
                            nShipments = min(nShipments, neededShipments);
                            
                            sender.sell(this, i, nShipments);
                            neededShipments -= nShipments;
                        }

                        if (neededShipments < 0)
                            break;
                    }
                }
            }
            
            // 4. Launch ships from launchBacklog
            for (BuyRequest br : launchBacklog) {
                for (int i = 0; i < N_RESOURCES; ++i) {
                    if (br.nShipments[i] > 0) {
                        cargoShips.add(new CargoShip(i, br.sender, br.receiver));
                        br.nShipments[i] -= 1;
                    }
                }
            }
        }
        this.draw();
    }

    void sell(PlanetCell receiver, int resourceIdx, int nShipments) {
        // Set aside resources for shipment.
        this.resourceStockpile[resourceIdx] -= nShipments*CARGOSHIP_CAPACITY;

        // Schedule launch into launchBacklog.
        ArrayList<BuyRequest> emptyBR = new ArrayList<BuyRequest>(); // Store empty BuyRequests for deletion.
        boolean found = false; // Set to true if a BuyRequest exists for the receiver.
        for (BuyRequest br : launchBacklog) {
            if (br.receiver == receiver) {
                br.nShipments[resourceIdx] += nShipments;
                found = true;
            }
            
            int totalShipments = 0;
            for (int i = 0; i < N_RESOURCES; ++i) {
                totalShipments += br.nShipments[i];
            }
            if (totalShipments == 0)
                emptyBR.add(br);
        }
        if (!found) {
            BuyRequest br = new BuyRequest(this, receiver);
            br.nShipments[resourceIdx] += nShipments;
            launchBacklog.add(br);
        }
        
        // Delete empty BuyRequests
        for (BuyRequest br : emptyBR)
            launchBacklog.remove(br);
    }

    void draw() {
        if (this.population > 0) {
            float colorVal = 255*this.population/PLANETCELL_MAXPOP;
            fill(colorVal, colorVal, colorVal/2);
        } else {
            fill(140,48,8);
        }
        
        rect(this.x*CELL_WIDTH, this.y*CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT);
    }
}
