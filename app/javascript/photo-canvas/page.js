import Canvas from 'canvas';
import CanvasSketch from 'canvas-sketch';
import load from 'load-asset';

const safe_area = 15;

const sketch = ({width, height, canvas, data}) => {
  return ({ context, width, height, data }) => {
    context.drawImage(data, 0, 0, width, height);
  };
};

const scale = (image, canvas) => {
  // TODO: Get the larger dimension and scale the image by it on the correct
  // dimension in order to handle portrait images
  return image.width / canvas.width
}

const start = async function (parent, img_url) {
  const canvas = Canvas.createCanvas();
  const settings = {
    canvas,
    dimensions: '8r',
    pixelsPerInch: 300,
    orientation: 'landscape',
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
