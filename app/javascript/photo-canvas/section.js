import render_setup from './render_setup.js'

const sketch = ({width, height, canvas, data}) => {
  return ({ context, width, height, data, canvas }) => {
    const img = data['img'];
    const country = data['country'];

    context.fillStyle = 'white';
    context.fillRect(0, 0, width, height);

    let scale;
    let y = 0;
    let x = 0;

    scale = width / img.width;

    const s_height = img.height * scale;

    context.drawImage(img, x, y, (img.width * scale), s_height);

    // This is probably going to be a big pain in the ass when I go to render pdfs
    context.save();
    const textSize = context.measureText(country);
    context.fillStyle = 'white';
    const rect_width = textSize.actualBoundingBoxLeft + textSize.actualBoundingBoxRight + (20 * 2);
    const rect_height = textSize.actualBoundingBoxAscent + textSize.actualBoundingBoxDescent + (10 * 2);
    const rect_x = rect_width / 2;
    const rect_y = rect_height / 2;
    context.fillRect((width / 2) - rect_x, height /2 - rect_y, rect_width, rect_height);
    context.restore();

    context.save();
    const fontSize = 12;
    context.fillStyle = 'black';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.font = `oblique ${fontSize}px Helvetica`;
    context.globalAlpha = 0.5
    context.fillText(country, width / 2, height / 2);
    context.restore();
  };
};

const is_landscape = (image) => {
  return image.width > image.height;
};

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.section-page').forEach(function(canvas_tag) {
    render_setup(sketch, canvas_tag);
  });
});
