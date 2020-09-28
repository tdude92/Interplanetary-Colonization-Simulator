class BuyRequest {
    PlanetCell buyer, seller;
    int[] nShipments, resourceIdx;
    BuyRequest(PlanetCell seller, PlanetCell buyer) {
        this.buyer = buyer;
        this.seller = seller;
        
        this.nShipments = new int[N_RESOURCES];
        for (int i = 0; i < this.nShipments.length; ++i) {
            this.nShipments[i] = 0;
        }
    }
}
