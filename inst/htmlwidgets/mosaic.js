HTMLWidgets.widget({
  name: 'mosaic',
  type: 'output',

  factory: function(el, width, height) {
    let spec;
    let options = {};

    function generatePlot (spec, options) {
      let ast = window.mosaicSpec.parseSpec(spec);

      return window.mosaicSpec.astToDOM(ast, options)
        .then((result) => {
          el.replaceChildren(result.element);
        })
        .catch((err) => {
          console.error(err);
        });
    };

    return {
      renderValue: function(x) {
        spec = x.spec;
        spec.width = width;
        spec.height = height;

        if (x.api) {
          let api = window[x.api];
          if (!api) {
            throw new Error("No api found with id", x.api);
          }
          options.api = window[x.api];
        }

        generatePlot(spec, options);
      },

      resize: function(width, height) {
        spec.width = width;
        spec.height = height;
        generatePlot(spec, options);
      }

    };
  }
});

