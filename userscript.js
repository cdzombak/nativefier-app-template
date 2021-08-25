// Example user script:

if (window.location.hostname === 'www.lofi.cafe') {
  if (window.localStorage.getItem('lowEnergyMode') === null) {
    window.localStorage.setItem('lowEnergyMode', 'true');
    window.location.reload();
  }
}
