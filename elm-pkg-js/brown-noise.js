exports.init = async function init(app) {
  console.log("brown-noise init", { app });
  if (!app.ports.noise) {
    console.warn("No port named 'noise' found!");
    return;
  }

  const overlay = document.createElement("div");
  overlay.setAttribute("style", "background: rgba(0, 0, 0, 0.3); position: absolute; top: 0; right: 0; bottom: 0; left: 0; display: flex; align-items: center; justify-content: center;");
  const button = document.createElement("button");
  button.appendChild(document.createTextNode("Start"));
  overlay.appendChild(button);
  document.body.appendChild(overlay);

  const audioContext = new AudioContext();

  let gainNode = audioContext.createGain();
  gainNode.connect(audioContext.destination);
  app.ports.noise.subscribe(function(message) {
    if (message === "Pause") {
      gainNode.gain = 0;
    }
    if (message === "Play") {
      gainNode.gain = 1;
    }
  });

  await audioContext.audioWorklet.addModule("brown-noise-processor.js");

  overlay.addEventListener("click", async () => {
    await audioContext.resume();
    const brownNoiseNode = new AudioWorkletNode(audioContext, "brown-noise-processor");
    brownNoiseNode.connect(gainNode);

    document.body.removeChild(overlay);
  });
}
