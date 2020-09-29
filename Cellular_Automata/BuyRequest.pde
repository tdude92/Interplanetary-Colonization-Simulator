class BuyRequest {
    PlanetCell receiver, sender;
    int[] nShipments, resourceIdx;
    BuyRequest(PlanetCell sender, PlanetCell receiver) {
        this.receiver = receiver;
        this.sender = sender;
        
        this.nShipments = new int[N_RESOURCES];
        for (int i = 0; i < this.nShipments.length; ++i) {
            this.nShipments[i] = 0;
        }
    }
}
