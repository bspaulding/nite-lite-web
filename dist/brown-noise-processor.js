let lastOut = 0.0;

class BrownNoiseProcessor extends AudioWorkletProcessor {
  constructor(options) {
    super();
    console.log("BrownNoiseProcessor init with options", { options });
  }

  process(inputs, outputs, parameters) {
    console.log("BrownNoiseProcessor process");
    outputs[0].forEach(output => {
      for (var i = 0; i < output.length; i++) {
        var white = Math.random() * 2 - 1;
        output[i] = (lastOut + (0.02 * white)) / 1.02;
        lastOut = output[i];
        output[i] *= 3.5; // (roughly) compensate for gain
      }
    });
    return true;
  }
}


registerProcessor("brown-noise-processor", BrownNoiseProcessor);
