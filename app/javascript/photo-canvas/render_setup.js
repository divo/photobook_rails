import Canvas from 'canvas';
import CanvasSketch from 'canvas-sketch';
import load from 'load-asset';

const render_setup = async (sketch, parent) => {
  const img_url = parent.dataset['url'];
  const name = parent.dataset['name'];
  const address = parent.dataset['address'];

  const canvas = Canvas.createCanvas();
  const settings = {
    canvas,
    dimensions: [210, 297],
    pixelsPerInch: 300,
    orientation: 'landscape',
    units: 'mm',
    hotkeys: false,
    scaleToFitPadding: 0,
    attributes: { antialias: true }
  };

  let img = await load(img_url);
  settings.parent = parent;
  settings.data = { img: img, name: name, address: address };
  CanvasSketch.canvasSketch(sketch, settings);
};

export default render_setup;
