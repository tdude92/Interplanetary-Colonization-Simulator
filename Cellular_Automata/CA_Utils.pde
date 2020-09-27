int clamp(float x, int min, int max) {
    return (int)max(min(x, max), min);
}
