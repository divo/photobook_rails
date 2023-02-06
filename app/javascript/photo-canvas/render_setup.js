import Canvas from 'canvas';
import CanvasSketch from 'canvas-sketch';
import load from 'load-asset';

const render_setup = async (sketch, parent) => {
  const img_url = parent.dataset['imageUrl'];
  const name = parent.dataset['name'];
  const address = parent.dataset['address'];
  const country = parent.dataset['country'];

  const canvas = Canvas.createCanvas();
  const settings = {
    canvas,
    dimensions: [148, 210],
    orientation: 'landscape',
    units: 'mm',
    hotkeys: false,
    scaleToFitPadding: 0,
    attributes: { antialias: true }
  };

  let img = await load(img_url);
  settings.parent = parent;
  settings.data = { 
    img: img,
    name: name,
    address: address,
    country: country,
  };
  CanvasSketch.canvasSketch(sketch, settings);
};

export default render_setup;
