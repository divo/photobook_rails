import Canvas from 'canvas';
import CanvasSketch from 'canvas-sketch';
import load from 'load-asset';
import fs from 'graceful-fs';

const canvas = Canvas.createCanvas();

// How to share this across multiple images? Just pass it through
let img;
const safe_area = 15;

const settings = {
  canvas,
  dimensions: [ 210, 210],
  units: 'mm'
};

const sketch = ({width, height, canvas}) => {
  return ({ context, width, height }) => {
    //context.fillStyle = 'white';
    //context.fillRect(0, 0, width, height);
    context.drawImage(img, safe_area, safe_area, width - (safe_area * 2), height - (safe_area * 2));
  };
};

const start = async function (parent, img_url) {
  img = await load(img_url);
  settings.parent = parent;
  CanvasSketch.canvasSketch(sketch, settings)
};

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.photo-page').forEach(function(canvas_tag) {
    const img_url = canvas_tag.dataset['url'];
    start(canvas_tag, img_url);
  });
});
