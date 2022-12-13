import render_setup from './render_setup.js'

const sketch = ({width, height, canvas, data}) => {
  return ({ context, width, height, data, canvas }) => {
    // const safe_area = 15; // mm!
    let safe_area = 25; // mm!
    const fontSize = 10;
    let scaledFontSize = fontSize;
    const textSafeArea = 10;
    const img = data['img'];
    const address = data['address'];

    context.fillStyle = 'white';
    context.fillRect(0, 0, width, height);

    let pos = {};

    do {
      pos = calculatePositions(safe_area, img, width, height);
      scaledFontSize = fontSize * pos.scale;
      safe_area = safe_area + 5;
    } while (address != '' && isTextCropped(pos.y, pos.s_height, textSafeArea, scaledFontSize, height))

    context.drawImage(img, pos.x, pos.y, pos.s_width, pos.s_height);
    context.fillStyle = 'rgb(126, 123, 127)';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.font = `oblique ${scaledFontSize}px Helvetica`;
    context.fillText(address, width / 2, pos.y + pos.s_height + 10, width);
  };
};

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
