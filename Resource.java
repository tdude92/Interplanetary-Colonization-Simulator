enum Resource {
    FOOD(0),
    WATER(1),
    ENERGY(2),
    RAW_MATERIALS(3);

    public static final int COUNT = Resource.values().length;
    public final int IDX;

    Resource(int idx) {
        this.IDX = idx;
    }
};