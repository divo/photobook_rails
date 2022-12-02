import Canvas from 'canvas';
import CanvasSketch from 'canvas-sketch';
import load from 'load-asset';

const safe_area = 15; // mm!

const sketch = ({width, height, canvas, data}) => {
  return ({ context, width, height, data, canvas }) => {
    const img = data['img'];
    const name = data['name'];
    context.fillStyle = 'white';
    context.fillRect(0, 0, width, height);

    let scale;
    let y = 0;
    let x = 0;

    if (is_landscape(img)) {
      scale = width / img.width;
    } else {
      scale = height / img.height; // TODO: How to layout landscape covers? Easiest way is to simply not allow it
    }

    const s_height = img.height * scale;

    context.drawImage(img, x, y, (img.width * scale), s_height);

    const fontSize = 18 * scale;
    context.fillStyle = 'black';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.font = `normal ${fontSize}px Helvetica`;
    context.fillText(name, width / 2, s_height + (( height - s_height) / 2), width);
  };
};

const is_landscape = (image) => {
  return image.width > image.height;
};

const start = async function (parent, dataset) {
  const img_url = dataset['url'];
  const name = dataset['name'];

  const canvas = Canvas.createCanvas();
  const settings = {
    canvas,
    dimensions: [210, 210],
    pixelsPerInch: 300,
    orientation: 'landscape',
    units: 'mm',
    hotkeys: false,
    scaleToFitPadding: 0,
    attributes: { antialias: true }
  };

  let img = await load(img_url);
  settings.parent = parent;
  settings.data = { img: img, name: name };
  CanvasSketch.canvasSketch(sketch, settings);
};

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.cover-page').forEach(function(canvas_tag) {
    start(canvas_tag, canvas_tag.dataset);
  });
});
