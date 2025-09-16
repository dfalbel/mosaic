import * as mosaicCore from 'https://cdn.jsdelivr.net/npm/@uwdata/mosaic-core@0.18.0/+esm';
import * as vg from 'https://cdn.jsdelivr.net/npm/@uwdata/vgplot@0.18.0/+esm'
import * as mosaicSpec from 'https://cdn.jsdelivr.net/npm/@uwdata/mosaic-spec@0.18.0/+esm'
var Shiny = window.Shiny;
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
    console.log("registering!");
    const promises = new Map();

    const shinyMosaicConnector = () => {
        return {
            query: function (query) {
                const id = crypto.randomUUID();
                query.id = id;
                console.log("Querying:", ns, query)
                let promise = new Promise ((resolve, reject) => {
                    promises.set(id, [resolve, reject]);
                });
                Shiny.setInputValue(ns + "-mosaic_query", query, {priority: "event"});
                return promise;
            },
        }
    }

    Shiny.addCustomMessageHandler(ns + '-mosaic_reply', msg => {
        console.log("Reply:", msg);
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

Shiny.addCustomMessageHandler('register_mosaic_api', msg => {
    console.log('registering vg!');
    registerMosaicHandler(msg.ns);
    console.log('registered vg:', msg.ns);
})

// window.vg = vg;
// window.vg.coordinator().databaseConnector(shinyMosaicConnector());
// create an area chart, returned as an HTML element
// you can subsequently add this to your webpage



// window.chart = window.vg.plot(
//     window.vg.areaY(window.vg.from("mtcars"), { x: "mpg", y: "disp" })
// );



