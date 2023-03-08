class Slice {
    public float[] values;
    public Decayable alpha;
    public Decayable weight;

    public Slice(
        int specSize,
        Decayable alpha,
        Decayable weight
    ) {
        this.values = new float[specSize];
        this.alpha = alpha;
        this.weight = weight;
    }

    public void update(float newAlpha, float newWeight) {
        this.alpha.update(newAlpha);
        this.weight.update(newWeight);
    }

    public void display() {

    }
}