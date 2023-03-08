class Decayable {
    float value;
    float decay;
    float min;
    float max;

    public Decayable(float value, float decay, float min, float max) {
        this.value = value;
        this.decay = decay;
        this.min = min;
        this.max = max;
    }

    public void update(float newValue) {
        if (newValue > this.value) {
            this.value = min(newValue, this.max);
        } else {
            this.value = max(this.value - this.decay, this.min);
        }
    }
}