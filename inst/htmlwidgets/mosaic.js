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
        });
    };

    async function insertData(api, data) {
      if (!data) {
        return;
      }
      
      data = Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, HTMLWidgets.dataframeToD3(v)])
      );

      for (let name in data) {
        if (data[name]) {
          const db = await api.context.coordinator.databaseConnector().getDuckDB();
          await db.registerFileText("temp.json", JSON.stringify(data[name]));
          const query = window.vg.loadJSON(name, "temp.json");
          await api.context.coordinator.exec(query);
        }
      }

      return;
    }

    async function makeMosaicPlot(data, spec, options) {
      await insertData(options.api, data)
      await generatePlot(spec, options);
    }

    return {
      renderValue: function(x) {
        spec = x.spec;
        spec.width = width;
        spec.height = height;

        console.log(spec);
        
        options.baseURL = x.baseURL;

        if (x.api) {
          let api = window[x.api];
          if (!api) {
            throw new Error("No api found with id", x.api);
          }
          options.api = window[x.api];
        } else {
          options.api = window.vg.createAPIContext({
            coordinator: new window.vg.Coordinator(
              window.mosaicCore.wasmConnector()
            )
          });
          window.api = options.api;
        }

        const loader=document.createElement('div');
        loader.style.cssText='display:grid;place-items:center;width:100%;height:100%';
        loader.textContent='⏳ Loading...';
        el.replaceChildren(loader);

        makeMosaicPlot(x.data, spec, options).catch((err) => {
          const error = document.createElement('div');
          error.style.cssText='color:red;white-space:pre-wrap;font-family:monospace';
          error.textContent = err.message;          
          el.replaceChildren(error);
          console.error(err);
        });
      },

      resize: function(width, height) {
        spec.width = width;
        spec.height = height;
        generatePlot(spec, options);
      }

    };
  }
});

