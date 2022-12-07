import render_setup from './render_setup.js'


const sketch = ({width, height, canvas, data}) => {
  return ({ context, width, height, data, canvas }) => {
    const safe_area = 25; // mm!
    const img = data['img'];

    context.fillStyle = 'white';
    context.fillRect(0, 0, width, height);

    let scale;
    let ratio;
    let y = 0;
    let x = 0;
    let s_width;
    let s_height;

    if (is_landscape(img)) {
      scale = width / img.width;
      ratio = img.width / img.height;
      s_width = (img.width * scale) - (safe_area * 2)
      s_height = s_width / ratio;
      y = (height - s_height) / 2;
      x = safe_area;
    } else {
      scale = height / img.height;
      ratio = img.height / img.width;
      s_height = (img.height * scale) - (safe_area * 2)
      s_width = s_height / ratio;
      x = (width - s_width) / 2;
      y = safe_area;
    }

    context.drawImage(img, x, y, s_width, s_height);
  };
};

const is_landscape = (image) => {
  return image.width > image.height;
};

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.photo-page').forEach(function(canvas_tag) {
    render_setup(sketch, canvas_tag);
  });
});
