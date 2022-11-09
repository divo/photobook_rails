import Canvas from 'canvas';
import CanvasSketch from 'canvas-sketch';
import load from 'load-asset';
import fs from 'graceful-fs';

const canvas = Canvas.createCanvas();

// How to share this across multiple images? Just pass it through
let img;

const settings = {
  canvas,
  dimensions: [ 600, 400 ],
};

const sketch = ({width, height, canvas}) => {
  return ({ context, width, height }) => {
    context.fillStyle = 'blue';
    context.fillRect(0, 0, width, height);
    context.drawImage(img, 0, 0);
  };
};

const start = async function (parent, img_url) {
  img = await load(img_url);
  settings.parent = parent;
  CanvasSketch.canvasSketch(sketch, settings).then(() => {
    const out = fs.createWriteStream('output.jpg');
    const stream = canvas.createJPEGStream();
    stream.pipe(out);
    out.on('finish', () => console.log('Done rendering'));
  });
}

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.photo-page').forEach(function(canvas_tag) {
    const img_url = canvas_tag.dataset['url'];
    start(canvas_tag, img_url);
  });
});
