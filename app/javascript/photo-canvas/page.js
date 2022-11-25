import Canvas from 'canvas';
import CanvasSketch from 'canvas-sketch';
import load from 'load-asset';

const safe_area = 15; // mm!

const sketch = ({width, height, canvas, data}) => {
  return ({ context, width, height, data, canvas }) => {
    context.fillStyle = 'white';
    context.fillRect(0, 0, width, height);

    let scale;
    let y = 0;
    let x = 0;

    if (is_landscape(data)) {
      scale = width / data.width;
      y = (height - (data.height * scale)) / 2;
    } else {
      scale = height / data.height;
      x = (width - (data.width * scale)) / 2;
    }

    context.drawImage(data, safe_area + x, safe_area + y, (data.width * scale) - (safe_area * 2), (data.height * scale) - (safe_area * 2));
  };
};

const is_landscape = (image) => {
  return image.width > image.height;
};

const start = async function (parent, img_url) {
  const canvas = Canvas.createCanvas();
  const settings = {
    canvas,
    dimensions: [210, 210],
    pixelsPerInch: 300,
    orientation: 'landscape',
    units: 'mm',
    hotkeys: false,
    scaleToFitPadding: 0,
  };

  let img = await load(img_url); // Can't use on DOM in backend, load manually. Update: Lol, fucking thing uses the window
  settings.parent = parent;
  settings.data = img;
  CanvasSketch.canvasSketch(sketch, settings);
};

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.photo-page').forEach(function(canvas_tag) {
    const img_url = canvas_tag.dataset['url'];
    start(canvas_tag, img_url);
  });
});
