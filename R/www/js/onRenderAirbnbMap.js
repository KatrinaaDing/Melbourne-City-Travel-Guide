shinyjs.onRenderAirbnbMap = function(el, x) {
  // data from constant defined earlier
  const CHEAP_THRESHOLD = 124;
  const MEDIUM_THRESHOLD = 180;
  // get average price of markers in a cluster
  const getAvgPrice = (markers) =>
    (markers.reduce((a, b) => a + parseFloat(b.options.price), 0) / markers.length).toFixed(3)
  let map = this;
  map.eachLayer(function (layer) {
    if (layer instanceof L.MarkerClusterGroup) {
      // create cluster icon
      layer.options.iconCreateFunction = function (cluster) {
        const averagePrice = getAvgPrice(cluster.getAllChildMarkers());
        // cluster icon background style (used to be gradient but found that transparent background is better)
        iconHtml = '<div style=\"background: radial-gradient(circle at center, transparent, transparent); width: 40px; height: 40px; border-radius: 50%;\"></div>';
        // icon style
        iconStyle = 'style=\"width: 26px; height: 26px; position: relative; top: -32px; left: 8px;\"';
        if (averagePrice > MEDIUM_THRESHOLD) {
          iconHtml += '<img src=\"icons/expensive.svg\" ' + iconStyle + ' />';
        } else if (averagePrice > CHEAP_THRESHOLD) {
          iconHtml += '<img src=\"icons/medium-price.svg\" ' + iconStyle + ' />';
        } else {
          iconHtml += '<img src=\"icons/cheap.svg\" ' + iconStyle + ' />';
        }
        // cluster label (num of childern markers)
        iconHtml += '<div style=\"position: relative; top: -35px; font-size: 12px; text-align: center; font-weight: 700;\">' + cluster.getAllChildMarkers().length + '</div>';

        return L.divIcon({ html: iconHtml, className: 'my-cluster-icon', iconSize: L.point(40, 40) });
      };
      // create hover popup
      layer.on('clustermouseover', function (a) {
        let cluster = a.layer;
        const averagePrice = getAvgPrice(cluster.getAllChildMarkers());
        let popup = L.popup()
          .setLatLng(cluster.getLatLng())
          .setContent(`Numbers of Airbnb: ${cluster.getChildCount()} <br>Average price: $${averagePrice} per night`)
          .openOn(map);
      });
      layer.on('clustermouseout', function (a) {
        map.closePopup();
      });
    }
  });
}