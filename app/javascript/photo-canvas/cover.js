import render_setup from './render_setup.js'

const sketch = ({width, height, canvas, data}) => {
  return ({ context, width, height, data, canvas }) => {
    const safe_area = 15; // mm!
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

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.cover-page').forEach(function(canvas_tag) {
    render_setup(sketch, canvas_tag);
  });
});
