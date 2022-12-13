import render_setup from './render_setup.js'

const sketch = ({width, height, canvas, data}) => {
  let safe_area = 25; // mm!
  const fontSize = 4;
  const textSafeArea = 10;
  const img = data['img'];
  const address = data['address'];

  let pos = {};

  do {
    pos = calculatePositions(safe_area, img, width, height);
    safe_area = safe_area + 5;
  } while (address != '' && isTextCropped(pos.y, pos.s_height, textSafeArea, fontSize, height))

  return ({ context, width, height, data, canvas }) => {
    context.fillStyle = 'white';
    context.fillRect(0, 0, width, height);


    context.drawImage(img, pos.x, pos.y, pos.s_width, pos.s_height);
    draw_text(address, width, pos, fontSize, textSafeArea, context);
  };
};

const draw_text = (text, width, pos, fontSize, textSafeArea, context) => {
  const transform = context.getTransform();
  const x_scale = Math.ceil(transform.a);
  const y_scale = Math.ceil(transform.d);
  context.setTransform(1, 0, 0, 1, 0, 0); // There is a bug in Cairo related to rendering text in a transformed canvas
  context.font = `oblique ${fontSize * x_scale}px Helvetica`;
  context.textAlign = 'center';
  context.fillStyle = 'rgb(126, 123, 127)';
  context.textBaseline = 'middle';

  context.fillText(text, (width / 2) * x_scale, (pos.y + pos.s_height + textSafeArea) * y_scale);
}

const isTextCropped = (y, s_height, textSafeArea, scaledFontSize, height) => {
  return (y + s_height + textSafeArea + (scaledFontSize / 2)) > height - textSafeArea;
}

const calculatePositions = (safe_area, img, width, height) => {
  let result = {};

    if (is_landscape(img)) {
      result.scale = width / img.width;
      result.ratio = img.width / img.height;
      result.s_width = (img.width * result.scale) - (safe_area * 2)
      result.s_height = result.s_width / result.ratio;
      result.y = (height - result.s_height) / 2;
      result.x = safe_area;
    } else {
      result.scale = height / img.height;
      result.ratio = img.height / img.width;
      result.s_height = (img.height * result.scale) - (safe_area * 2)
      result.s_width = result.s_height / result.ratio;
      result.x = (width - result.s_width) / 2;
      result.y = safe_area;
    }

  return result;
}

const is_landscape = (image) => {
  return image.width > image.height;
};

document.addEventListener("turbo:load", function() {
  document.querySelectorAll('.photo-content').forEach(function(canvas_tag) {
    render_setup(sketch, canvas_tag);
  });
});
