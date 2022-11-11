import Canvas from 'canvas';
import CanvasSketch from 'canvas-sketch';
import load from 'load-asset';
import fs from 'graceful-fs';

const safe_area = 15;

const sketch = ({width, height, canvas, data}) => {
  return ({ context, width, height, data }) => {
    context.drawImage(data, safe_area, safe_area, width - (safe_area * 2), height - (safe_area * 2));
  };
};

const start = async function (parent, img_url) {
  const canvas = Canvas.createCanvas();
  const settings = {
    canvas,
    dimensions: [210, 210],
    units: 'mm',
  };

  let img = await load(img_url);
  settings.parent = parent;
  settings.data = img;
  CanvasSketch.canvasSketch(sketch, settings);
};

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.photo-page').forEach(function(canvas_tag) {
    //TODO: Disable keyboard shortcuts
    const img_url = canvas_tag.dataset['url'];
    start(canvas_tag, img_url);
  });
});
