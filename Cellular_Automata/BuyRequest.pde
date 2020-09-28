class BuyRequest {
    PlanetCell buyer, seller;
    int nShipments, resourceIdx;
    BuyRequest(PlanetCell seller, PlanetCell buyer, int nShipments, int resourceIdx) {
        this.buyer = buyer;
        this.seller = seller;
        this.nShipments = nShipments;
        this.resourceIdx = resourceIdx;
    }

    void launchShipment() {}
}