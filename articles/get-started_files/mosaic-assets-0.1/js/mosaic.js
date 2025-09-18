const {mosaicCore, mosaicSpec, vg} = window.LibMosaic;

var Shiny = window.Shiny;
window.mosaicCore = mosaicCore;
window.vg = vg;
window.mosaicSpec = mosaicSpec;

function base64ToArrayBuffer(base64) {
  const binary = atob(base64);
  const len = binary.length;
  const buffer = new ArrayBuffer(len);
  const view = new Uint8Array(buffer);
  for (let i = 0; i < len; i++) view[i] = binary.charCodeAt(i);
  return buffer;
}

export function registerMosaicHandler(ns) {
    const promises = new Map();

    const shinyMosaicConnector = () => {
        return {
            query: function (query) {
                const id = crypto.randomUUID();
                query.id = id;
                let promise = new Promise ((resolve, reject) => {
                    promises.set(id, [resolve, reject]);
                });
                Shiny.setInputValue(ns + "-mosaic_query", query, {priority: "event"});
                return promise;
            },
        }
    }

    Shiny.addCustomMessageHandler(ns + '-mosaic_reply', msg => {
        const [resolve, reject] = promises.get(msg.id);
        try {
            if (msg.error) {
                reject(msg.error);
                return;
            }
            
            if (msg.query.type === "arrow") {
                const buffer = base64ToArrayBuffer(msg.result);
                const table = mosaicCore.decodeIPC(buffer);
                console.log(table);
                resolve(table);
            } else {
                resolve(msg.result);
            }
        } catch (error) {
            reject(error);
        } finally {
            promises.delete(msg.id);
        }
    });

    window[ns + '_connector'] = shinyMosaicConnector();
    window[ns + '_coordinator'] = new vg.Coordinator(window[ns + '_connector']);
    window[ns] = vg.createAPIContext({coordinator: window[ns + '_coordinator']});
}

if (window.Shiny) {

window.Shiny.addCustomMessageHandler('register_mosaic_api', msg => {
    registerMosaicHandler(msg.ns);
})

}
